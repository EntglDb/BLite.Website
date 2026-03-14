<template>
  <div class="doc-page">
    <h1>🔗 <span class="title-gradient">Version Matrix</span></h1>
    <p class="lead">BLite.Server wraps a specific version of BLite (the embedded engine). Use this table to ensure your server build and your embedded engine are compatible.</p>

    <section>
      <h2>BLite.Server ↔ BLite Engine</h2>
      <table class="matrix-table">
        <thead>
          <tr>
            <th>BLite.Server</th>
            <th>BLite Engine</th>
            <th>Status</th>
            <th>Release Date</th>
            <th>Notes</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in serverMatrix" :key="row.server">
            <td><code>{{ row.server }}</code></td>
            <td><code>{{ row.engine }}</code></td>
            <td><span :class="['status-badge', `status-${row.status}`]">{{ row.statusLabel }}</span></td>
            <td class="date-col">{{ row.date }}</td>
            <td class="notes-col">{{ row.notes }}</td>
          </tr>
        </tbody>
      </table>
    </section>

    <section>
      <h2>Client SDK Compatibility</h2>
      <p>
        All client SDKs target the <strong>gRPC protocol version</strong> defined by the Protobuf contracts in <code>BLite.Proto</code>.
        A protocol version bump happens only when breaking changes are made to the service definitions or wire format.
        Minor and patch releases of BLite.Server are always backward-compatible with the same major client SDK version.
      </p>
      <table class="matrix-table">
        <thead>
          <tr>
            <th>BLite.Server</th>
            <th>BLite.Client (.NET)</th>
            <th>@blite/client (npm)</th>
            <th>blite-client-java</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in clientMatrix" :key="row.server">
            <td><code>{{ row.server }}</code></td>
            <td><code>{{ row.dotnet }}</code></td>
            <td><code>{{ row.npm }}</code></td>
            <td><code>{{ row.java }}</code></td>
          </tr>
        </tbody>
      </table>
    </section>

    <section>
      <h2>Runtime Requirements</h2>
      <table class="info-table">
        <thead>
          <tr><th>Component</th><th>Requirement</th></tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>BLite.Server</strong></td>
            <td>Self-contained binary (no .NET runtime required on host). Bundled .NET 10 runtime.</td>
          </tr>
          <tr>
            <td><strong>BLite.Client (.NET)</strong></td>
            <td>.NET 8+ or .NET 10. Supports ASP.NET Core dependency injection.</td>
          </tr>
          <tr>
            <td><strong>@blite/client (TypeScript)</strong></td>
            <td>Node.js 18+. ESM and CommonJS builds included.</td>
          </tr>
          <tr>
            <td><strong>blite-client-java</strong></td>
            <td>Java 21+. Requires sealed interface pattern matching. Spring Boot 3.x optional.</td>
          </tr>
        </tbody>
      </table>
    </section>

    <section>
      <h2>Protocol Versioning</h2>
      <p>The BLite Server wire protocol follows this stability contract:</p>
      <ul>
        <li><strong>Major version (0 → 1):</strong> may include breaking changes to gRPC service definitions, REST path structure, or the BLQL filter serialization format.</li>
        <li><strong>Minor version (0.1 → 0.2):</strong> additive changes only — new RPC methods, new REST endpoints, new filter operators. Older clients continue to work.</li>
        <li><strong>Patch version (0.1.1 → 0.1.3):</strong> bug fixes and security patches. No protocol changes.</li>
      </ul>
      <div class="warning-box">
        <strong>⚠ Preview period (0.x):</strong> Until the 1.0 release, even minor version bumps may include breaking changes.
        Pin your client and server versions to the same minor release during the preview period.
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
interface ServerRow {
  server: string
  engine: string
  status: 'preview' | 'stable' | 'deprecated'
  statusLabel: string
  date: string
  notes: string
}

interface ClientRow {
  server: string
  dotnet: string
  npm: string
  java: string
}

const serverMatrix: ServerRow[] = [
  {
    server: '0.1.3',
    engine: '3.6.4',
    status: 'preview',
    statusLabel: 'Preview',
    date: '2026-03-13',
    notes: 'Initial public preview. gRPC, REST, Studio, multi-tenant, BLQL, Transactions, KV Store.',
  },
]

const clientMatrix: ClientRow[] = [
  { server: '0.1.x', dotnet: '0.1.x', npm: '0.1.x', java: '0.1.x' },
]
</script>

<style scoped>
.doc-page {
  max-width: 900px;
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
  color: var(--text-primary);
}

code {
  font-family: var(--font-mono);
  font-size: 0.9rem;
  background: rgba(231, 76, 60, 0.1);
  padding: 2px 6px;
  border-radius: 4px;
  color: var(--blite-red);
}

.matrix-table {
  width: 100%;
  border-collapse: collapse;
  margin: 16px 0;
}

.matrix-table th {
  text-align: left;
  padding: 10px 16px;
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-bottom: 1px solid rgba(231, 76, 60, 0.2);
}

.matrix-table td {
  padding: 12px 16px;
  color: var(--text-secondary);
  border-bottom: 1px solid rgba(255, 255, 255, 0.04);
  vertical-align: middle;
}

.matrix-table tr:hover td {
  background: rgba(231, 76, 60, 0.03);
}

.date-col {
  white-space: nowrap;
  font-family: var(--font-mono);
  font-size: 0.85rem;
}

.notes-col {
  font-size: 0.88rem;
}

.status-badge {
  display: inline-block;
  padding: 3px 10px;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 700;
  letter-spacing: 0.05em;
  text-transform: uppercase;
}

.status-preview {
  color: #f59e0b;
  background: rgba(245, 158, 11, 0.12);
  border: 1px solid rgba(245, 158, 11, 0.3);
}

.status-stable {
  color: #22c55e;
  background: rgba(34, 197, 94, 0.10);
  border: 1px solid rgba(34, 197, 94, 0.25);
}

.status-deprecated {
  color: var(--text-muted);
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(255,255,255,0.08);
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

.info-table td strong {
  color: var(--text-primary);
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
