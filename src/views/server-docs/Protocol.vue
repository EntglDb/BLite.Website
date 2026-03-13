<template>
  <div class="doc-page">
    <h1>🔌 <span class="title-gradient">Protocol &amp; API</span></h1>
    <p class="lead">BLite.Server exposes three interfaces: a high-throughput gRPC endpoint for the official client SDKs, a human-friendly REST API, and a BLQL query language available on both.</p>

    <section>
      <h2>Authentication</h2>
      <p>Every request must carry an API key. Two header formats are accepted:</p>
      <pre><code><span class="comment"># Header-based (gRPC metadata and REST)</span>
x-api-key: your-api-key-here

<span class="comment"># Bearer token (REST only)</span>
Authorization: Bearer your-api-key-here</code></pre>
      <p>
        Keys are stored as <strong>SHA-256 hex hashes</strong> in the system database.
        The plaintext key is returned exactly once — at creation or rotation time.
      </p>
      <div class="info-box">
        <strong>🛡 Dev Mode:</strong> When no users have been created yet (before first setup), all requests are authenticated automatically as a synthetic root user with full permissions.
      </div>
    </section>

    <section>
      <h2>Permissions</h2>
      <p>Each API key carries a list of per-collection permission entries:</p>
      <table class="info-table">
        <thead>
          <tr><th>Flag</th><th>Value</th><th>Description</th></tr>
        </thead>
        <tbody>
          <tr><td><code>Query</code></td><td><code>1</code></td><td>Read documents and run queries</td></tr>
          <tr><td><code>Insert</code></td><td><code>2</code></td><td>Insert new documents</td></tr>
          <tr><td><code>Update</code></td><td><code>4</code></td><td>Update existing documents</td></tr>
          <tr><td><code>Delete</code></td><td><code>8</code></td><td>Delete documents</td></tr>
          <tr><td><code>Drop</code></td><td><code>16</code></td><td>Drop collections</td></tr>
          <tr><td><code>Admin</code></td><td><code>32</code></td><td>User management and database operations</td></tr>
          <tr><td><code>Write</code></td><td><code>14</code></td><td>Shorthand: Insert | Update | Delete</td></tr>
          <tr><td><code>All</code></td><td><code>63</code></td><td>All flags combined</td></tr>
        </tbody>
      </table>
      <p>Collection <code>"*"</code> grants permissions on all collections. Namespace isolation is applied transparently — users never see the physical prefix.</p>
    </section>

    <section>
      <h2>gRPC Endpoint — Port 2626</h2>
      <p>The gRPC endpoint is the primary interface for all official client SDKs. It runs on HTTP/2 only and uses <strong>Protobuf + MessagePack</strong> internally:</p>
      <ul>
        <li>Document payloads are transmitted as <strong>C-BSON</strong> bytes (the native BLite wire format)</li>
        <li>Query descriptors are serialized with <strong>MessagePack</strong></li>
        <li>gRPC service definitions live in <code>BLite.Proto</code></li>
      </ul>

      <h3>Available Services</h3>
      <table class="info-table">
        <thead>
          <tr><th>Service</th><th>Description</th></tr>
        </thead>
        <tbody>
          <tr>
            <td><code>DynamicService</code></td>
            <td>Schema-less operations: Insert, Update, Delete, Query, FindById, InsertBulk. Document payloads are raw <code>BsonDocument</code> bytes.</td>
          </tr>
          <tr>
            <td><code>DocumentService</code></td>
            <td>Typed operations using the client SDK's compile-time BSON mappers. Supports streaming responses.</td>
          </tr>
          <tr>
            <td><code>AdminService</code></td>
            <td>User management (create, rotate, delete), database management. Requires <code>Admin</code> permission.</td>
          </tr>
          <tr>
            <td><code>MetadataService</code></td>
            <td>Collection listing, index introspection, collection statistics.</td>
          </tr>
          <tr>
            <td><code>TransactionService</code></td>
            <td>Begin, Commit, Rollback across any collection. One active transaction per database at a time.</td>
          </tr>
        </tbody>
      </table>

      <h3>Connecting with grpcurl</h3>
      <pre><code><span class="comment"># List services</span>
grpcurl -H <span class="string">"x-api-key: your-key"</span> -insecure localhost:2626 list

<span class="comment"># Call an RPC</span>
grpcurl -H <span class="string">"x-api-key: your-key"</span> -insecure \
  -d <span class="string">'{"collection":"orders"}'</span> \
  localhost:2626 blite.DynamicService/Query</code></pre>
    </section>

    <section>
      <h2>REST API — Port 2627</h2>
      <p>All REST endpoints live under <code>/api/v1</code>. A Swagger UI is available at <code>/swagger</code>.</p>

      <h3>Documents</h3>
      <table class="info-table">
        <thead>
          <tr><th>Method</th><th>Path</th><th>Description</th></tr>
        </thead>
        <tbody>
          <tr><td><code>GET</code></td><td><code>/{dbId}/{col}/documents</code></td><td>List documents (paginated)</td></tr>
          <tr><td><code>GET</code></td><td><code>/{dbId}/{col}/documents/{id}</code></td><td>Find document by ID</td></tr>
          <tr><td><code>POST</code></td><td><code>/{dbId}/{col}/documents</code></td><td>Insert a document</td></tr>
          <tr><td><code>PUT</code></td><td><code>/{dbId}/{col}/documents/{id}</code></td><td>Replace a document</td></tr>
          <tr><td><code>DELETE</code></td><td><code>/{dbId}/{col}/documents/{id}</code></td><td>Delete a document</td></tr>
        </tbody>
      </table>

      <h3>Collections &amp; Databases</h3>
      <table class="info-table">
        <thead>
          <tr><th>Method</th><th>Path</th><th>Description</th></tr>
        </thead>
        <tbody>
          <tr><td><code>GET</code></td><td><code>/api/v1/databases</code></td><td>List all databases</td></tr>
          <tr><td><code>POST</code></td><td><code>/api/v1/databases</code></td><td>Create a database</td></tr>
          <tr><td><code>DELETE</code></td><td><code>/api/v1/databases/{dbId}</code></td><td>Drop a database</td></tr>
          <tr><td><code>GET</code></td><td><code>/api/v1/{dbId}/collections</code></td><td>List collections</td></tr>
          <tr><td><code>DELETE</code></td><td><code>/api/v1/{dbId}/collections/{col}</code></td><td>Drop a collection</td></tr>
        </tbody>
      </table>

      <h3>Users</h3>
      <table class="info-table">
        <thead>
          <tr><th>Method</th><th>Path</th><th>Description</th></tr>
        </thead>
        <tbody>
          <tr><td><code>GET</code></td><td><code>/api/v1/users</code></td><td>List users (Admin)</td></tr>
          <tr><td><code>POST</code></td><td><code>/api/v1/users</code></td><td>Create user (Admin)</td></tr>
          <tr><td><code>DELETE</code></td><td><code>/api/v1/users/{username}</code></td><td>Delete user (Admin)</td></tr>
          <tr><td><code>POST</code></td><td><code>/api/v1/users/{username}/rotate</code></td><td>Rotate API key (Admin)</td></tr>
        </tbody>
      </table>

      <h3>dbId Sentinel</h3>
      <p>Use <code>default</code> in the URL to target the system (default) database. For tenant databases, use the database ID assigned at creation time.</p>
    </section>

    <section>
      <h2>BLQL — BLite Query Language</h2>
      <p>BLQL is an MQL-inspired query language available on both the gRPC <code>DynamicService</code> and the REST <code>POST /{dbId}/{col}/query</code> endpoint.</p>

      <h3>REST Example</h3>
      <pre><code>POST /api/v1/default/orders/query
Content-Type: application/json
x-api-key: your-key

{
  <span class="keyword">"filter"</span>: { <span class="string">"status"</span>: { <span class="string">"$eq"</span>: <span class="string">"active"</span> } },
  <span class="keyword">"sort"</span>:   { <span class="string">"created_at"</span>: -<span class="number">1</span> },
  <span class="keyword">"skip"</span>:   <span class="number">0</span>,
  <span class="keyword">"take"</span>:   <span class="number">20</span>,
  <span class="keyword">"select"</span>: [<span class="string">"_id"</span>, <span class="string">"status"</span>, <span class="string">"total"</span>]
}</code></pre>

      <h3>Supported Filter Operators</h3>
      <table class="info-table">
        <thead>
          <tr><th>Operator</th><th>Description</th></tr>
        </thead>
        <tbody>
          <tr><td><code>$eq</code></td><td>Equal to</td></tr>
          <tr><td><code>$ne</code></td><td>Not equal to</td></tr>
          <tr><td><code>$gt</code> / <code>$gte</code></td><td>Greater than / greater than or equal</td></tr>
          <tr><td><code>$lt</code> / <code>$lte</code></td><td>Less than / less than or equal</td></tr>
          <tr><td><code>$in</code></td><td>Value is in an array</td></tr>
          <tr><td><code>$nin</code></td><td>Value is not in an array</td></tr>
          <tr><td><code>$startsWith</code></td><td>String starts with prefix</td></tr>
          <tr><td><code>$contains</code></td><td>String contains substring</td></tr>
          <tr><td><code>$and</code> / <code>$or</code></td><td>Logical combinators</td></tr>
        </tbody>
      </table>
    </section>

    <section>
      <h2>Transactions over gRPC</h2>
      <p>Cross-collection ACID transactions are available via the <code>TransactionService</code>:</p>
      <pre><code><span class="comment">// Begin a transaction</span>
<span class="keyword">var</span> txn = await txnClient.BeginAsync(<span class="keyword">new</span> <span class="type">BeginRequest</span> { DatabaseId = <span class="string">"default"</span> });

<span class="comment">// Pass transaction ID in subsequent write requests</span>
await dynamicClient.InsertAsync(<span class="keyword">new</span> <span class="type">InsertRequest</span> {
    Collection   = <span class="string">"orders"</span>,
    TransactionId = txn.TransactionId,
    Document     = bsonBytes
});

<span class="comment">// Commit or rollback</span>
await txnClient.CommitAsync(<span class="keyword">new</span> <span class="type">CommitRequest</span> { TransactionId = txn.TransactionId });</code></pre>
      <div class="warning-box">
        <strong>⚠ Important:</strong> Only one active transaction per database is allowed at a time.
        Always call <code>Commit</code> or <code>Rollback</code> — an abandoned transaction blocks
        the database until the configured <code>Transactions:TimeoutSeconds</code> expires.
      </div>
    </section>
  </div>
</template>

<style scoped>
.doc-page {
  max-width: 860px;
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

ul {
  margin: 16px 0;
  padding-left: 24px;
}

li {
  margin-bottom: 8px;
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
