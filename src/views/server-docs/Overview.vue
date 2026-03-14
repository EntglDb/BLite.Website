<template>
  <div class="doc-page">
    <div class="page-header">
      <span class="preview-chip">⚠ Preview — v0.1.4</span>
      <h1>🖥️ <span class="title-gradient">BLite.Server</span></h1>
    </div>
    <p class="lead">
      BLite.Server turns the embedded BLite engine into a network-accessible database with
      gRPC, a REST API, user authentication, multi-tenancy, and an integrated Blazor Web Studio —
      all shipping as a single <code>.exe</code> or Docker image.
    </p>

    <div class="warning-box">
      <strong>⚠ Preview Software.</strong> BLite.Server is currently in public preview.
      The wire protocol, REST paths and configuration keys are stable for testing, but may
      change before the 1.0 general availability release. Use in production at your own risk.
    </div>

    <section>
      <h2>What is BLite.Server?</h2>
      <p>
        BLite is an <strong>embedded</strong> NoSQL database — it runs inside your .NET process
        with no external dependencies. BLite.Server wraps that same engine and exposes it as a
        standalone service that multiple clients can connect to simultaneously.
      </p>
      <ul>
        <li><strong>gRPC endpoint</strong> — high-throughput, binary protocol on port <code>2626</code></li>
        <li><strong>REST API</strong> — JSON over HTTP on port <code>2627</code> with OpenAPI / Swagger UI</li>
        <li><strong>Blazor Web Studio</strong> — browser-based management UI on port <code>2628</code></li>
        <li><strong>Multi-tenancy</strong> — isolated databases per user or namespace</li>
        <li><strong>API-key auth</strong> — fine-grained per-collection permissions</li>
        <li><strong>BLQL</strong> — full MQL-style query language available over both gRPC and REST</li>
        <li><strong>Transactions</strong> — cross-collection ACID transactions over the network</li>
      </ul>
    </section>

    <section>
      <h2>Architecture</h2>
      <p>A single ASP.NET Core 10 host serves all three endpoints and delegates every operation to the embedded engine:</p>
      <pre><code>┌────────────────────────────────────────────────────┐
│                    BLite.Server                    │
│                                                    │
│  ┌──────────┐  ┌─────────────────┐  ┌──────────┐  │
│  │   gRPC   │  │   REST /api/v1  │  │  Studio  │  │
│  │  :2626   │  │      :2627      │  │  :2628   │  │
│  └────┬─────┘  └────────┬────────┘  └────┬─────┘  │
│       │                 │                │         │
│       └─────────┬────── ┘                │         │
│                 ▼                        │         │
│        ┌────────────────┐                │         │
│        │  EngineRegistry│◄───────────────┘         │
│        │  (singleton)   │                          │
│        └───────┬────────┘                          │
│                │  one BLiteEngine per database      │
│                ▼                                   │
│        ┌────────────────┐                          │
│        │  BLiteEngine   │  (embedded BLite core)   │
│        └────────────────┘                          │
└────────────────────────────────────────────────────┘</code></pre>
    </section>

    <section>
      <h2>Endpoints at a Glance</h2>
      <table class="info-table">
        <thead>
          <tr>
            <th>Endpoint</th>
            <th>Default Port</th>
            <th>Protocol</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>gRPC</strong></td>
            <td><code>2626</code></td>
            <td>HTTP/2</td>
            <td>Binary, streaming, high-throughput. Primary interface for the official client SDKs.</td>
          </tr>
          <tr>
            <td><strong>REST API</strong></td>
            <td><code>2627</code></td>
            <td>HTTP/1.1 + HTTP/2</td>
            <td>JSON over HTTP. Full CRUD + BLQL queries. Includes Swagger UI at <code>/swagger</code>.</td>
          </tr>
          <tr>
            <td><strong>Studio</strong></td>
            <td><code>2628</code></td>
            <td>HTTP/1.1 + HTTP/2</td>
            <td>Blazor Server web application. Management UI for databases, collections, users.</td>
          </tr>
        </tbody>
      </table>
    </section>

    <section>
      <h2>Key Concepts</h2>

      <h3>Databases &amp; Collections</h3>
      <p>
        Each database maps to a separate <code>.db</code> file managed by its own
        <code>BLiteEngine</code> instance. Collections are created on demand.
        The system database (key <code>""</code>) hosts the <code>_users</code> collection.
      </p>

      <h3>Namespaces</h3>
      <p>
        Users with a <code>Namespace</code> field work inside a transparent prefix:
        logical name <code>"orders"</code> is stored as <code>"tenant1:orders"</code>.
        This enables multiple tenants to share a single database engine without data leakage.
      </p>

      <h3>API Keys</h3>
      <p>
        Every request must carry an API key via the <code>x-api-key</code> header or
        <code>Authorization: Bearer &lt;key&gt;</code>. Keys are stored as SHA-256 hex hashes —
        the plaintext is returned exactly once at creation time.
      </p>

      <h3>Dev Mode</h3>
      <p>
        When no users exist yet (fresh install, before running <code>/setup</code>),
        the server operates in <em>Dev Mode</em>: all requests are authenticated as a synthetic
        root user with full permissions. This makes local development frictionless while
        remaining safe by default in production (setup creates the first real user).
      </p>
    </section>

    <section>
      <h2>Quick Links</h2>
      <div class="link-grid">
        <router-link to="/server/installation" class="link-card">
          <span class="lc-icon">📦</span>
          <span class="lc-text">Installation</span>
          <span class="lc-arrow">→</span>
        </router-link>
        <router-link to="/server/protocol" class="link-card">
          <span class="lc-icon">🔌</span>
          <span class="lc-text">Protocol &amp; API</span>
          <span class="lc-arrow">→</span>
        </router-link>
        <router-link to="/server/studio" class="link-card">
          <span class="lc-icon">🎨</span>
          <span class="lc-text">Web Studio</span>
          <span class="lc-arrow">→</span>
        </router-link>
        <router-link to="/server/clients" class="link-card">
          <span class="lc-icon">📡</span>
          <span class="lc-text">Client SDKs</span>
          <span class="lc-arrow">→</span>
        </router-link>
      </div>
    </section>
  </div>
</template>

<style scoped>
.doc-page {
  max-width: 860px;
}

.page-header {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 16px;
}

.preview-chip {
  display: inline-block;
  padding: 4px 12px;
  font-size: 0.78rem;
  font-weight: 700;
  letter-spacing: 0.05em;
  color: #f59e0b;
  background: rgba(245, 158, 11, 0.1);
  border: 1px solid rgba(245, 158, 11, 0.3);
  border-radius: 20px;
  width: fit-content;
}

h1 {
  font-size: 2.5rem;
  font-weight: 800;
  margin-bottom: 0;
}

.lead {
  font-size: 1.2rem;
  color: var(--text-secondary);
  margin-bottom: 32px;
}

.warning-box {
  padding: 16px 20px;
  border-radius: 8px;
  margin: 0 0 40px;
  border-left: 4px solid #f59e0b;
  background: rgba(245, 158, 11, 0.06);
  color: var(--text-secondary);
}

.warning-box strong {
  color: #f59e0b;
}

section {
  margin-bottom: 48px;
}

h2 {
  font-size: 1.8rem;
  font-weight: 700;
  margin-bottom: 16px;
  color: var(--blite-red);
  border-bottom: 2px solid rgba(231, 76, 60, 0.2);
  padding-bottom: 8px;
}

h3 {
  font-size: 1.2rem;
  font-weight: 600;
  margin: 24px 0 8px;
  color: var(--text-primary);
}

p {
  margin-bottom: 16px;
  line-height: 1.7;
  color: var(--text-secondary);
}

ul {
  margin: 16px 0;
  padding-left: 24px;
}

li {
  margin-bottom: 8px;
  color: var(--text-secondary);
}

li strong {
  color: var(--blite-red);
}

code {
  font-family: var(--font-mono);
  font-size: 0.9rem;
  background: rgba(231, 76, 60, 0.1);
  padding: 2px 6px;
  border-radius: 4px;
  color: var(--blite-red);
}

pre {
  background: rgba(10, 10, 10, 0.6);
  border: 1px solid rgba(231, 76, 60, 0.2);
  border-radius: 8px;
  padding: 20px;
  overflow-x: auto;
  margin: 16px 0;
}

pre code {
  background: none;
  padding: 0;
  color: var(--text-secondary);
  font-size: 0.85rem;
}

.info-table {
  width: 100%;
  border-collapse: collapse;
  margin: 16px 0;
}

.info-table th {
  text-align: left;
  padding: 10px 16px;
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-bottom: 1px solid rgba(231, 76, 60, 0.2);
}

.info-table td {
  padding: 12px 16px;
  color: var(--text-secondary);
  border-bottom: 1px solid rgba(255, 255, 255, 0.04);
  vertical-align: top;
}

.info-table tr:hover td {
  background: rgba(231, 76, 60, 0.03);
}

.link-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
  margin-top: 16px;
}

.link-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 20px;
  background: rgba(231, 76, 60, 0.04);
  border: 1px solid rgba(231, 76, 60, 0.15);
  border-radius: 8px;
  color: var(--text-secondary);
  transition: all 0.2s ease;
}

.link-card:hover {
  background: rgba(231, 76, 60, 0.08);
  border-color: rgba(231, 76, 60, 0.35);
  color: var(--text-primary);
}

.lc-icon {
  font-size: 1.3rem;
}

.lc-text {
  flex: 1;
  font-weight: 500;
}

.lc-arrow {
  color: var(--blite-red);
  font-size: 1.1rem;
}
</style>
