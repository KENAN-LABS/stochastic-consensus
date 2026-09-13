#!/usr/bin/env bash
# Builds a small four-unit fixture in the case workspace.
#
# It is deliberately synthetic and deliberately tiny — the case is testing the
# orchestration, not the analysis. What it does need is real structure: units of
# obviously different importance, so tiering has something to do, and genuine
# seams between them, so the cross-cutting trace agents have a thread to follow.
#
# No absolute paths and no machine-local content. This runs in the eval's own
# workspace and everything it writes is disposable.
set -euo pipefail

mkdir -p packages/api/src packages/billing/src packages/web/src tools

cat > README.md <<'EOF'
# shopfront

Four workspaces. `api` fronts everything, `billing` owns money, `web` is the
customer client, `tools` holds release scripts.
EOF

cat > package.json <<'EOF'
{ "name": "shopfront", "private": true,
  "workspaces": ["packages/api", "packages/billing", "packages/web", "tools"] }
EOF

# ---- packages/api -------------------------------------------------------
cat > packages/api/package.json <<'EOF'
{ "name": "@shopfront/api", "version": "2.4.0",
  "dependencies": { "express": "4.18.2", "jsonwebtoken": "8.5.1",
                    "@shopfront/billing": "workspace:*" } }
EOF
cat > packages/api/src/server.js <<'EOF'
const express = require('express');
const { verify } = require('./auth');
const { charge } = require('@shopfront/billing');

const app = express();
app.use(express.json());

// Every authenticated route funnels through here.
app.use((req, res, next) => {
  const token = req.headers['x-session'];
  const user = verify(token);
  if (!user) return res.status(401).json({ error: 'unauthenticated' });
  req.user = user;
  next();
});

app.post('/orders', async (req, res) => {
  const { items, currency } = req.body;
  // NOTE: currency is optional here. billing assumes it is always present.
  const total = items.reduce((n, i) => n + i.price * i.qty, 0);
  const result = await charge(req.user.id, total, currency);
  res.json({ ok: true, chargeId: result.id });
});

module.exports = app;
EOF
cat > packages/api/src/auth.js <<'EOF'
const jwt = require('jsonwebtoken');

// Secret falls back to a constant when the env var is missing.
const SECRET = process.env.SESSION_SECRET || 'dev-secret';

function verify(token) {
  if (!token) return null;
  try {
    return jwt.verify(token, SECRET);
  } catch {
    return null;
  }
}

function issue(userId) {
  return jwt.sign({ id: userId }, SECRET, { expiresIn: '30d' });
}

module.exports = { verify, issue };
EOF
cat > packages/api/src/orders.js <<'EOF'
const store = new Map();

function put(order) { store.set(order.id, order); return order; }
function get(id) { return store.get(id); }
// In-memory only. Survives nothing.
module.exports = { put, get };
EOF

# ---- packages/billing ---------------------------------------------------
cat > packages/billing/package.json <<'EOF'
{ "name": "@shopfront/billing", "version": "1.1.3",
  "dependencies": { "stripe": "10.17.0" } }
EOF
cat > packages/billing/src/index.js <<'EOF'
const { toMinorUnits } = require('./money');
const gateway = require('./gateway');

// currency is required. The API treats it as optional.
async function charge(userId, amount, currency) {
  const minor = toMinorUnits(amount, currency);
  return gateway.create({ userId, amount: minor, currency });
}

module.exports = { charge };
EOF
cat > packages/billing/src/money.js <<'EOF'
const ZERO_DECIMAL = new Set(['JPY', 'KRW']);

function toMinorUnits(amount, currency) {
  if (ZERO_DECIMAL.has(currency)) return Math.round(amount);
  return Math.round(amount * 100);
}

module.exports = { toMinorUnits };
EOF
cat > packages/billing/src/gateway.js <<'EOF'
const Stripe = require('stripe');
const client = new Stripe(process.env.STRIPE_KEY);

// No idempotency key. A retried request charges twice.
async function create({ userId, amount, currency }) {
  return client.paymentIntents.create({
    amount, currency, metadata: { userId },
  });
}

module.exports = { create };
EOF

# ---- packages/web -------------------------------------------------------
cat > packages/web/package.json <<'EOF'
{ "name": "@shopfront/web", "version": "3.0.1",
  "dependencies": { "react": "18.2.0" } }
EOF
cat > packages/web/src/api-client.js <<'EOF'
const BASE = process.env.API_BASE || 'http://localhost:3000';

// Sends the session token the API's middleware expects.
export async function placeOrder(items) {
  const res = await fetch(`${BASE}/orders`, {
    method: 'POST',
    headers: { 'content-type': 'application/json',
               'x-session': localStorage.getItem('session') },
    // currency is never sent.
    body: JSON.stringify({ items }),
  });
  return res.json();
}
EOF
cat > packages/web/src/Cart.jsx <<'EOF'
import { placeOrder } from './api-client';

export function Cart({ items }) {
  const submit = () => placeOrder(items);
  return <button onClick={submit}>Checkout</button>;
}
EOF

# ---- tools --------------------------------------------------------------
cat > tools/package.json <<'EOF'
{ "name": "@shopfront/tools", "version": "0.0.4" }
EOF
cat > tools/release.sh <<'EOF'
#!/usr/bin/env bash
set -e
npm version "$1" --workspaces
npm publish --workspaces --access public
EOF
chmod +x tools/release.sh

echo "fixture ready"
