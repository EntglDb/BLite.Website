<template>
  <div class="doc-page">
    <h1>📡 <span class="title-gradient">Client SDKs</span></h1>
    <p class="lead">
      Official clients for BLite.Server are available for .NET, TypeScript/JavaScript, and Java.
      All three speak the gRPC protocol and share the same feature surface.
    </p>

    <section>
      <h2>Feature Matrix</h2>
      <div class="table-wrapper">
        <table class="matrix-table">
          <thead>
            <tr>
              <th>Feature</th>
              <th>
                <div class="sdk-header">
                  <span class="sdk-icon">🔷</span>
                  <span>.NET</span>
                </div>
              </th>
              <th>
                <div class="sdk-header">
                  <span class="sdk-icon">🟨</span>
                  <span>TypeScript</span>
                </div>
              </th>
              <th>
                <div class="sdk-header">
                  <span class="sdk-icon">☕</span>
                  <span>Java</span>
                </div>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in matrix" :key="row.feature">
              <td class="feature-col">{{ row.feature }}</td>
              <td class="check-col"><span :class="cellClass(row.dotnet)">{{ cellIcon(row.dotnet) }}</span></td>
              <td class="check-col"><span :class="cellClass(row.ts)">{{ cellIcon(row.ts) }}</span></td>
              <td class="check-col"><span :class="cellClass(row.java)">{{ cellIcon(row.java) }}</span></td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <section>
      <h2>🔷 .NET — BLite.Client</h2>
      <p>The official .NET client. Integrates with ASP.NET Core dependency injection and supports strongly-typed BSON serialization via C# source generators.</p>

      <h3>Install</h3>
      <pre><code>dotnet add package BLite.Client</code></pre>

      <h3>Quick Start</h3>
      <pre><code><span class="keyword">using</span> BLite.Client;

<span class="comment">// Register in DI (ASP.NET Core)</span>
builder.Services.AddBLiteClient(o =>
{
    o.Host   = <span class="string">"localhost"</span>;
    o.Port   = <span class="number">2626</span>;
    o.ApiKey = <span class="string">"your-api-key"</span>;
});

<span class="comment">// Inject BLiteClient and use it</span>
<span class="keyword">var</span> client     = sp.GetRequiredService&lt;<span class="type">BLiteClient</span>&gt;();
<span class="keyword">var</span> collection = client.GetCollection&lt;<span class="type">Order</span>&gt;(<span class="string">"orders"</span>);

<span class="comment">// Insert</span>
<span class="keyword">var</span> id = await collection.InsertAsync(newOrder);

<span class="comment">// Query</span>
<span class="keyword">var</span> results = await collection.AsQueryable()
    .Where(o => o.Status == <span class="string">"active"</span>)
    .OrderByDescending(o => o.CreatedAt)
    .Take(<span class="number">20</span>)
    .ToListAsync();</code></pre>

      <div class="sdk-links">
        <a href="https://www.nuget.org/packages/BLite.Client" target="_blank" class="sdk-link nuget">
          <span>NuGet ↗</span>
        </a>
        <a href="https://github.com/EntglDb/BLite.Server" target="_blank" class="sdk-link github">
          <span>GitHub ↗</span>
        </a>
      </div>
    </section>

    <section>
      <h2>🟨 TypeScript — @blite/client</h2>
      <p>Built on <code>@grpc/grpc-js</code>. Works in Node.js and server-side environments. Supports both callback and async/await styles.</p>

      <h3>Install</h3>
      <pre><code>npm install @blite/client</code></pre>

      <h3>Quick Start</h3>
      <pre><code><span class="keyword">import</span> { <span class="type">BLiteClient</span> } from <span class="string">'@blite/client'</span>;

<span class="keyword">const</span> client = <span class="keyword">new</span> <span class="type">BLiteClient</span>({
  host:   <span class="string">'localhost'</span>,
  port:   <span class="number">2626</span>,
  apiKey: <span class="string">'your-api-key'</span>,
});

<span class="comment">// Insert a document</span>
<span class="keyword">const</span> id = <span class="keyword">await</span> client.insert(<span class="string">'orders'</span>, {
  status: <span class="string">'active'</span>,
  total:  <span class="number">99.95</span>,
});

<span class="comment">// Query with a builder</span>
<span class="keyword">const</span> results = <span class="keyword">await</span> client
  .query(<span class="string">'orders'</span>)
  .where(q => q.eq(<span class="string">'status'</span>, <span class="string">'active'</span>))
  .orderByDesc(<span class="string">'createdAt'</span>)
  .take(<span class="number">20</span>)
  .toArray();</code></pre>

      <div class="sdk-links">
        <a href="https://www.npmjs.com/package/@blite/client" target="_blank" class="sdk-link npm">
          <span>npm ↗</span>
        </a>
        <a href="https://github.com/EntglDb/BLite.Server" target="_blank" class="sdk-link github">
          <span>GitHub ↗</span>
        </a>
      </div>
    </section>

    <section>
      <h2>☕ Java — blite-client-java</h2>
      <p>Built on <code>grpc-java</code>. Available on Maven Central. Requires Java 21+ (uses sealed interface pattern matching for query builder).</p>

      <h3>Install</h3>
      <pre><code><span class="comment">&lt;!-- Maven --&gt;</span>
&lt;<span class="keyword">dependency</span>&gt;
  &lt;<span class="keyword">groupId</span>&gt;<span class="string">io.blite</span>&lt;/<span class="keyword">groupId</span>&gt;
  &lt;<span class="keyword">artifactId</span>&gt;<span class="string">blite-client-java</span>&lt;/<span class="keyword">artifactId</span>&gt;
  &lt;<span class="keyword">version</span>&gt;<span class="string">0.1.2</span>&lt;/<span class="keyword">version</span>&gt;
&lt;/<span class="keyword">dependency</span>&gt;</code></pre>
      <pre><code><span class="comment">// Gradle (Kotlin DSL)</span>
implementation(<span class="string">"io.blite:blite-client-java:0.1.2"</span>)</code></pre>

      <h3>Quick Start</h3>
      <pre><code><span class="keyword">import</span> io.blite.client.BLiteClient;
<span class="keyword">import</span> io.blite.client.BLiteClientOptions;

<span class="keyword">var</span> options = <span class="keyword">new</span> BLiteClientOptions(<span class="string">"localhost"</span>, <span class="number">2626</span>, <span class="string">"your-api-key"</span>);
<span class="keyword">try</span> (<span class="keyword">var</span> client = <span class="keyword">new</span> BLiteClient(options)) {

    <span class="comment">// Insert</span>
    Map&lt;String, Object&gt; doc = Map.of(<span class="string">"status"</span>, <span class="string">"active"</span>, <span class="string">"total"</span>, <span class="number">99.95</span>);
    String id = client.insert(<span class="string">"orders"</span>, doc);

    <span class="comment">// Query</span>
    List&lt;Map&lt;String, Object&gt;&gt; results = client
        .query(<span class="string">"orders"</span>)
        .where(q -> q.eq(<span class="string">"status"</span>, <span class="string">"active"</span>))
        .orderByDesc(<span class="string">"createdAt"</span>)
        .take(<span class="number">20</span>)
        .toList();
}</code></pre>

      <h3>Spring Boot Integration</h3>
      <pre><code><span class="comment">// application.yml</span>
blite:
  host: <span class="string">localhost</span>
  port: <span class="number">2626</span>
  api-key: <span class="string">${BLITE_API_KEY}</span>

<span class="comment">// Auto-configured bean available via @Autowired</span>
@<span class="type">Autowired</span>
<span class="keyword">private</span> BLiteClient client;</code></pre>

      <div class="sdk-links">
        <a href="https://central.sonatype.com/artifact/io.blite/blite-client-java" target="_blank" class="sdk-link maven">
          <span>Maven Central ↗</span>
        </a>
        <a href="https://github.com/EntglDb/BLite.Server" target="_blank" class="sdk-link github">
          <span>GitHub ↗</span>
        </a>
      </div>
    </section>

    <section>
      <h2>Admin &amp; KV Clients</h2>
      <p>Each SDK also ships dedicated clients for user management and the key-value store:</p>
      <table class="info-table">
        <thead>
          <tr><th>Client</th><th>.NET</th><th>TypeScript</th><th>Java</th></tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>Admin</strong></td>
            <td><code>BLiteAdminClient</code></td>
            <td><code>BLiteAdminClient</code></td>
            <td><code>BLiteAdminClient</code></td>
          </tr>
          <tr>
            <td><strong>Key-Value Store</strong></td>
            <td><code>BLiteKvStore</code></td>
            <td><code>BLiteKvStore</code></td>
            <td><code>BLiteKvStore</code></td>
          </tr>
        </tbody>
      </table>
    </section>
  </div>
</template>

<script setup lang="ts">
type SupportLevel = 'yes' | 'no' | 'partial'

interface MatrixRow {
  feature: string
  dotnet: SupportLevel
  ts: SupportLevel
  java: SupportLevel
}

const matrix: MatrixRow[] = [
  { feature: 'Insert / FindById / Update / Delete',   dotnet: 'yes', ts: 'yes', java: 'yes' },
  { feature: 'Bulk insert & bulk operations',          dotnet: 'yes', ts: 'yes', java: 'yes' },
  { feature: 'BLQL query builder',                     dotnet: 'yes', ts: 'yes', java: 'yes' },
  { feature: 'Strongly-typed collections',             dotnet: 'yes', ts: 'no',  java: 'no'  },
  { feature: 'Streaming query results',                dotnet: 'yes', ts: 'yes', java: 'yes' },
  { feature: 'ACID transactions',                      dotnet: 'yes', ts: 'yes', java: 'yes' },
  { feature: 'Key-value store (IBLiteKvStore)',        dotnet: 'yes', ts: 'yes', java: 'yes' },
  { feature: 'Admin: user management',                 dotnet: 'yes', ts: 'yes', java: 'yes' },
  { feature: 'Admin: database management',             dotnet: 'yes', ts: 'yes', java: 'yes' },
  { feature: 'Source-generator BSON mappers',          dotnet: 'yes', ts: 'no',  java: 'no'  },
  { feature: 'Spring Boot auto-configuration',         dotnet: 'no',  ts: 'no',  java: 'yes' },
  { feature: 'ASP.NET Core DI integration',            dotnet: 'yes', ts: 'no',  java: 'no'  },
]

const cellIcon = (v: SupportLevel) => v === 'yes' ? '✓' : v === 'partial' ? '~' : '–'
const cellClass = (v: SupportLevel) => ({
  'check-yes': v === 'yes',
  'check-partial': v === 'partial',
  'check-no': v === 'no',
})
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
.type { color: #06b6d4; }
.string { color: #a1a1aa; }
.comment { color: var(--text-muted); font-style: italic; }
.number { color: #f59e0b; }

/* Feature matrix */
.table-wrapper {
  overflow-x: auto;
  margin: 16px 0;
}

.matrix-table {
  width: 100%;
  border-collapse: collapse;
}

.matrix-table th {
  padding: 12px 16px;
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--text-muted);
  border-bottom: 1px solid rgba(231, 76, 60, 0.2);
  text-align: left;
}

.sdk-header {
  display: flex;
  align-items: center;
  gap: 8px;
}

.sdk-icon {
  font-size: 1.1rem;
}

.matrix-table td {
  padding: 10px 16px;
  border-bottom: 1px solid rgba(255,255,255,0.04);
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.feature-col {
  min-width: 240px;
}

.check-col {
  text-align: center;
}

.check-yes {
  color: #22c55e;
  font-weight: 700;
  font-size: 1rem;
}

.check-partial {
  color: #f59e0b;
  font-weight: 700;
}

.check-no {
  color: var(--text-muted);
}

.matrix-table tr:hover td {
  background: rgba(231, 76, 60, 0.03);
}

/* Info table */
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
}

/* SDK action links */
.sdk-links {
  display: flex;
  gap: 10px;
  margin: 20px 0 8px;
  flex-wrap: wrap;
}

.sdk-link {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 0.85rem;
  font-weight: 600;
  transition: all 0.2s ease;
  text-decoration: none;
}

.sdk-link.nuget {
  background: rgba(0, 100, 180, 0.15);
  border: 1px solid rgba(0, 100, 180, 0.3);
  color: #60a5fa;
}
.sdk-link.npm {
  background: rgba(204, 51, 0, 0.12);
  border: 1px solid rgba(204, 51, 0, 0.3);
  color: #f97316;
}
.sdk-link.maven {
  background: rgba(255, 160, 0, 0.10);
  border: 1px solid rgba(255, 160, 0, 0.3);
  color: #fbbf24;
}
.sdk-link.github {
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(255,255,255,0.1);
  color: var(--text-secondary);
}
.sdk-link:hover {
  filter: brightness(1.2);
  transform: translateY(-1px);
}
</style>
