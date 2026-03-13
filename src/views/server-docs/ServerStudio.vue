<template>
  <div class="doc-page">
    <h1>🎨 <span class="title-gradient">Web Studio</span></h1>
    <p class="lead">BLite.Server ships a built-in browser-based management UI — built with Blazor Server — for browsing databases, editing documents, running queries, and managing users.</p>

    <section>
      <h2>Enabling the Studio</h2>
      <p>The Studio is <strong>disabled by default</strong> in production Docker images. Enable it in <code>appsettings.json</code>:</p>
      <pre><code>{
  <span class="keyword">"Studio"</span>: {
    <span class="keyword">"Enabled"</span>: <span class="string">true</span>
  }
}</code></pre>
      <p>Or via environment variable:</p>
      <pre><code>Studio__Enabled=<span class="string">true</span></code></pre>
      <p>Once enabled, the Studio is served on port <code>2628</code> (configurable via <code>Kestrel:Endpoints:Studio</code>).</p>

      <div class="info-box">
        <strong>ℹ Security:</strong> The Studio requires its own Admin API key to log in — separate from the API key used by your application. Keep the Studio port off the public internet unless you need remote admin access.
      </div>
    </section>

    <section>
      <h2>First-Run Setup</h2>
      <p>On the very first launch with no users configured, navigate to:</p>
      <pre><code>https://localhost:2628/setup</code></pre>
      <p>The setup wizard will:</p>
      <ol class="steps-list">
        <li>Prompt you to create the <strong>root admin user</strong> with a username and a generated API key.</li>
        <li>Display the plaintext API key once — <strong>copy and store it immediately</strong>. It cannot be recovered.</li>
        <li>Mark the server as configured, disabling Dev Mode permanently.</li>
      </ol>

      <div class="warning-box">
        <strong>⚠ Save your key immediately.</strong> The plaintext API key is shown exactly once.
        If you lose it, you must rotate the key via the Studio or the
        <code>POST /api/v1/users/{username}/rotate</code> REST endpoint.
      </div>
    </section>

    <section>
      <h2>Logging In</h2>
      <p>After setup is complete, navigate to:</p>
      <pre><code>https://localhost:2628/login</code></pre>
      <p>Enter your username and API key. The Studio authenticates against the BLite permission system — only users with <code>Admin</code> permission on <code>"*"</code> (all collections) can log into the Studio.</p>
      <p>Studio authentication is <strong>session-scoped</strong> (Blazor Server circuit). Closing the tab or refreshing the page logs you out — no persistent browser cookies are involved.</p>
    </section>

    <section>
      <h2>Features</h2>

      <h3>Dashboard</h3>
      <p>The home screen shows a summary of all registered databases, total collection count, and server uptime.</p>

      <h3>Databases</h3>
      <p>Browse all tenant databases. Create new databases and drop existing ones (requires <code>Admin</code> permission). Each database displays its file size and collection count.</p>

      <h3>Collections &amp; Documents</h3>
      <p>Select any collection to open a two-panel view:</p>
      <ul>
        <li><strong>Left panel:</strong> paginated document list with ID, a preview of key fields, and quick-delete buttons.</li>
        <li><strong>Right panel:</strong> a full JSON/BSON document editor. Insert new documents or edit existing ones — changes are saved on confirmation.</li>
      </ul>
      <p>A built-in BLQL query bar lets you filter the list without leaving the page.</p>

      <h3>Users</h3>
      <p>The Users page (Admin only) allows you to:</p>
      <ul>
        <li>List all users with their namespace, database isolation, and permission summary.</li>
        <li>Create new users with fine-grained per-collection permissions.</li>
        <li>Rotate an existing user's API key (old key is invalidated immediately).</li>
        <li>Delete users.</li>
      </ul>

      <h3>System Info</h3>
      <p>Displays the connected BLite engine version, server uptime, and the active configuration paths. Useful for verifying the correct data directory is in use.</p>
    </section>

    <section>
      <h2>Navigation Structure</h2>
      <table class="info-table">
        <thead>
          <tr><th>URL</th><th>Page</th><th>Description</th></tr>
        </thead>
        <tbody>
          <tr><td><code>/setup</code></td><td>Setup Wizard</td><td>First-run only; creates root user</td></tr>
          <tr><td><code>/login</code></td><td>Login</td><td>Studio authentication</td></tr>
          <tr><td><code>/</code></td><td>Dashboard</td><td>Server status overview</td></tr>
          <tr><td><code>/databases</code></td><td>Databases</td><td>Manage tenant databases</td></tr>
          <tr><td><code>/collections</code></td><td>Collections</td><td>Browse collections within a database</td></tr>
          <tr><td><code>/documents</code></td><td>Documents</td><td>View, edit, and query documents</td></tr>
          <tr><td><code>/users</code></td><td>Users</td><td>User and permission management</td></tr>
        </tbody>
      </table>
    </section>

    <section>
      <h2>Security Notes</h2>
      <ul>
        <li>Studio authentication is <strong>independent</strong> from API-level authentication. Even if a Studio session is active, gRPC/REST requests still require a valid <code>x-api-key</code> header.</li>
        <li>The Studio is served over the same TLS certificate as the REST API. In development, this is a self-signed cert — you will need to accept the browser warning or trust the cert in your OS store.</li>
        <li>Collections whose names start with <code>_</code> are reserved and hidden from non-Admin users. The Studio only shows them when logged in as Admin.</li>
      </ul>
    </section>
  </div>
</template>

<style scoped>
.doc-page {
  max-width: 800px;
}

h1 {
  font-size: 2.5rem;
  font-weight: 800;
  margin-bottom: 16px;
}

.lead {
  font-size: 1.2rem;
  color: var(--text-secondary);
  margin-bottom: 48px;
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

ul, ol {
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

.steps-list {
  counter-reset: steps;
  list-style: none;
  padding-left: 0;
}

.steps-list li {
  display: flex;
  gap: 12px;
  padding: 10px 0;
  border-bottom: 1px solid rgba(255,255,255,0.04);
  counter-increment: steps;
}

.steps-list li::before {
  content: counter(steps);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  min-width: 24px;
  border-radius: 50%;
  background: rgba(231, 76, 60, 0.15);
  color: var(--blite-red);
  font-size: 0.8rem;
  font-weight: 700;
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

.keyword { color: var(--blite-red); }
.string { color: #a1a1aa; }

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
  padding: 10px 16px;
  color: var(--text-secondary);
  border-bottom: 1px solid rgba(255, 255, 255, 0.04);
  vertical-align: top;
}

.info-table tr:hover td {
  background: rgba(231, 76, 60, 0.03);
}

.info-box {
  padding: 16px 20px;
  border-radius: 8px;
  margin: 24px 0;
  border-left: 4px solid #06b6d4;
  background: rgba(6, 182, 212, 0.05);
  color: var(--text-secondary);
}

.info-box strong {
  color: #06b6d4;
}

.warning-box {
  padding: 16px 20px;
  border-radius: 8px;
  margin: 24px 0;
  border-left: 4px solid #f59e0b;
  background: rgba(245, 158, 11, 0.06);
  color: var(--text-secondary);
}

.warning-box strong {
  color: #f59e0b;
}
</style>
