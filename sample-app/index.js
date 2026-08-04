'use strict';

const http = require('http');

const PORT = process.env.PORT || 8080;
const VERSION = process.env.APP_VERSION || '1.0.0';

const svc = {
  db: process.env.DB_HOST || '',
  redis: process.env.REDIS_HOST || '',
};

const esc = (s) =>
  String(s).replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

function serviceCard(icon, name, value) {
  const ok = value && value.length > 0;
  return `
      <div class="card">
        <div class="card-top">
          <span class="icon">${icon}</span>
          <span class="name">${name}</span>
          <span class="pill ${ok ? 'ok' : 'off'}">${ok ? 'connected' : 'not set'}</span>
        </div>
        <div class="endpoint">${ok ? esc(value) : '—'}</div>
      </div>`;
}

// The platform components this blueprint provisions (icon, name, detail).
const STACK = [
  ['☸️', 'Amazon EKS', 'Kubernetes 1.33'],
  ['🌐', 'Amazon VPC', 'multi-AZ, public/private'],
  ['🔐', 'AWS KMS', 'encryption at rest'],
  ['📦', 'Amazon ECR', 'container images'],
  ['🛡️', 'AWS WAF', 'web ACL on the ALB'],
  ['⚖️', 'AWS ALB', 'LB Controller ingress'],
  ['📜', 'cert-manager', 'in-cluster TLS'],
  ['🔑', 'External Secrets', 'Secrets Manager sync'],
  ['📈', 'Cluster Autoscaler', 'node scaling'],
  ['💾', 'EBS CSI Driver', 'persistent volumes'],
  ['📊', 'metrics-server', 'HPA metrics'],
  ['🪵', 'Fluent Bit', 'logs → CloudWatch'],
  ['🔥', 'Prometheus + Grafana', 'metrics & dashboards'],
  ['🚀', 'Argo CD', 'GitOps delivery'],
];

function tile([icon, name, detail]) {
  return `
        <div class="tile">
          <span class="t-icon">${icon}</span>
          <div class="t-body"><span class="t-name">${name}</span><span class="t-detail">${detail}</span></div>
        </div>`;
}

function page() {
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<title>ARC Microservices EKS Blueprint</title>
<style>
  :root { color-scheme: dark; }
  * { box-sizing: border-box; }
  body {
    margin: 0; min-height: 100vh; display: flex; flex-direction: column;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    color: #e6edf3; background: radial-gradient(1200px 600px at 50% -10%, #1b2b4a 0%, #0b1220 55%, #070b14 100%);
  }
  main { flex: 1; width: 100%; max-width: 960px; margin: 0 auto; padding: 60px 24px 40px; }
  .badge { display: inline-flex; align-items: center; gap: 8px; padding: 6px 14px; border-radius: 999px;
    background: rgba(46,204,113,.12); border: 1px solid rgba(46,204,113,.35); color: #7ee2a8;
    font-size: 13px; font-weight: 600; letter-spacing: .3px; }
  .dot { width: 8px; height: 8px; border-radius: 50%; background: #2ecc71; box-shadow: 0 0 10px #2ecc71; }
  h1 { font-size: 34px; line-height: 1.15; margin: 20px 0 8px; font-weight: 700; }
  .sub { color: #9fb0c3; font-size: 16px; margin: 0 0 40px; max-width: 640px; }
  h2 { font-size: 13px; text-transform: uppercase; letter-spacing: 1.2px; color: #6f8098;
    margin: 40px 0 14px; font-weight: 700; }
  .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 16px; }
  .card { background: rgba(255,255,255,.03); border: 1px solid rgba(255,255,255,.08);
    border-radius: 14px; padding: 18px; }
  .card-top { display: flex; align-items: center; gap: 10px; }
  .icon { font-size: 18px; }
  .name { font-weight: 600; font-size: 15px; }
  .pill { margin-left: auto; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .5px;
    padding: 3px 9px; border-radius: 999px; }
  .pill.ok { background: rgba(46,204,113,.14); color: #7ee2a8; }
  .pill.off { background: rgba(148,163,184,.14); color: #94a3b8; }
  .endpoint { margin-top: 12px; font-family: ui-monospace, SFMono-Regular, Menlo, monospace; font-size: 12.5px;
    color: #a8c1dd; word-break: break-all; }
  .tiles { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 12px; }
  .tile { display: flex; align-items: center; gap: 12px; padding: 14px 16px; border-radius: 12px;
    background: rgba(255,255,255,.025); border: 1px solid rgba(255,255,255,.07); }
  .t-icon { font-size: 20px; }
  .t-body { display: flex; flex-direction: column; }
  .t-name { font-weight: 600; font-size: 14px; }
  .t-detail { font-size: 12px; color: #8397ad; }
  .meta { margin-top: 34px; color: #6f8098; font-size: 13px; display: flex; gap: 18px; flex-wrap: wrap; }
  .meta b { color: #cdd9e6; }
  footer { text-align: center; padding: 22px; color: #7c8da3; font-size: 13px;
    border-top: 1px solid rgba(255,255,255,.06); }
  footer b { color: #cdd9e6; font-weight: 600; }
</style>
</head>
<body>
  <main>
    <span class="badge"><span class="dot"></span> Live</span>
    <h1>ARC Microservices EKS Blueprint</h1>
    <p class="sub">A production-grade microservices platform on Amazon EKS — fronted by an ALB with WAF &amp; TLS,
      wired to managed data services, and delivered via the SourceFuse ARC Blueprint.</p>

    <h2>Connected services</h2>
    <div class="grid">
      ${serviceCard('🗄️', 'Aurora PostgreSQL', svc.db)}
      ${serviceCard('⚡', 'ElastiCache Redis', svc.redis)}
    </div>

    <h2>Platform stack</h2>
    <div class="tiles">
      ${STACK.map(tile).join('')}
    </div>

    <div class="meta">
      <span>version <b>${esc(VERSION)}</b></span>
      <span>served ${new Date().toISOString()}</span>
    </div>
  </main>
  <footer>&copy; ${new Date().getFullYear()} SourceFuse &middot; EKS Microservices Blueprint &middot; Maintained by <b>Mastan</b></footer>
</body>
</html>`;
}

// The frontend (SPA) is served from a different origin (CloudFront) than this
// API (ALB), so browser fetch()es are cross-origin. Allow CORS so the UI's
// health card can call this backend. Public read-only endpoints -> "*" is fine.
const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

const server = http.createServer((req, res) => {
  // CORS preflight.
  if (req.method === 'OPTIONS') {
    res.writeHead(204, CORS);
    res.end();
    return;
  }
  // Health/info as JSON — returns the backend's live wiring so the UI can prove
  // the full stack (EKS pod reachable + which data services it's connected to).
  if (req.url === '/health' || req.url === '/api/info') {
    res.writeHead(200, { 'Content-Type': 'application/json', ...CORS });
    res.end(JSON.stringify({
      status: 'ok',
      version: VERSION,
      services: {
        db: svc.db ? 'connected' : 'not set',
        redis: svc.redis ? 'connected' : 'not set',
      },
      time: new Date().toISOString(),
    }));
    return;
  }
  res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8', ...CORS });
  res.end(page());
});

server.listen(PORT, () => console.log(`Sample app listening on :${PORT}`));
