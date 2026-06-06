<template>
  <div class="doc-page">
    <h1>🔄 Transactions</h1>
    <p class="lead">BLite provides full ACID transaction support with Write-Ahead Logging (WAL) for durability and crash recovery. All write operations are async-only since v4.0.0.</p>

    <section>
      <h2>Auto-commit (Default Behavior)</h2>
      <p>
        By default every write operation (<code>InsertAsync</code>, <code>UpdateAsync</code>, <code>DeleteAsync</code>)
        is individually auto-committed when no explicit transaction is passed.
        This is the simplest model and is sufficient for most use cases.
      </p>

      <pre><code><span class="keyword">using</span> <span class="keyword">var</span> db = <span class="keyword">new</span> <span class="type">AppDbContext</span>(<span class="string">"mydb.blite"</span>);

<span class="comment">// Each operation commits immediately — no transaction needed</span>
<span class="keyword">await</span> db.Users.InsertAsync(<span class="keyword">new</span> <span class="type">User</span> { Name = <span class="string">"Alice"</span>, Age = <span class="number">30</span> });
<span class="keyword">await</span> db.Users.InsertAsync(<span class="keyword">new</span> <span class="type">User</span> { Name = <span class="string">"Bob"</span>, Age = <span class="number">25</span> });</code></pre>

      <h3>Bulk Insert</h3>
      <pre><code><span class="keyword">var</span> newUsers = <span class="keyword">new</span> <span class="type">List</span>&lt;<span class="type">User</span>&gt;
{
    <span class="keyword">new</span> <span class="type">User</span> { Name = <span class="string">"User1"</span>, Age = <span class="number">20</span> },
    <span class="keyword">new</span> <span class="type">User</span> { Name = <span class="string">"User2"</span>, Age = <span class="number">21</span> },
    <span class="keyword">new</span> <span class="type">User</span> { Name = <span class="string">"User3"</span>, Age = <span class="number">22</span> }
};

<span class="comment">// InsertBulkAsync auto-commits all documents in one WAL write</span>
<span class="keyword">await</span> db.Users.InsertBulkAsync(newUsers);</code></pre>

      <div class="info-box">
        <strong>💡 About <code>SaveChangesAsync()</code></strong>
        <p style="margin:8px 0 0">
          <code>SaveChangesAsync()</code> called without a transaction argument is a <strong>no-op</strong> — it exists
          only for API compatibility. For atomic multi-operation batches use an
          explicit transaction (see below) and call <code>SaveChangesAsync(txn)</code> or
          <code>txn.CommitAsync()</code>.
        </p>
      </div>
    </section>

    <section>
      <h2>Explicit Transactions</h2>
      <p>
        For atomic multi-operation batches, pass an <code>ITransaction</code> to each write method.
        The changes are held in WAL memory and only flushed on commit.
        Disposing without committing automatically rolls back.
      </p>

      <h3>Basic Explicit Transaction</h3>
      <pre><code><span class="keyword">using</span> <span class="keyword">var</span> db = <span class="keyword">new</span> <span class="type">AppDbContext</span>(<span class="string">"mydb.blite"</span>);

<span class="comment">// Begin a transaction — ITransaction implements IDisposable</span>
<span class="keyword">using</span> <span class="keyword">var</span> txn = db.BeginTransaction();

<span class="keyword">try</span>
{
    <span class="comment">// Pass txn to every write that must be atomic</span>
    <span class="keyword">await</span> db.Users.InsertAsync(<span class="keyword">new</span> <span class="type">User</span> { Name = <span class="string">"Alice"</span>, Age = <span class="number">30</span> }, txn);
    <span class="keyword">await</span> db.Users.InsertAsync(<span class="keyword">new</span> <span class="type">User</span> { Name = <span class="string">"Bob"</span>, Age = <span class="number">25</span> }, txn);

    <span class="keyword">await</span> txn.CommitAsync(); <span class="comment">// or: await db.SaveChangesAsync(txn)</span>
}
<span class="keyword">catch</span>
{
    <span class="comment">// Automatically rolled back on dispose if CommitAsync was not called</span>
    <span class="keyword">throw</span>;
}</code></pre>

      <h3>Async BeginTransactionAsync</h3>
      <pre><code><span class="keyword">using</span> <span class="keyword">var</span> txn = <span class="keyword">await</span> db.BeginTransactionAsync();

<span class="keyword">try</span>
{
    <span class="keyword">await</span> db.Users.InsertAsync(<span class="keyword">new</span> <span class="type">User</span> { Name = <span class="string">"Charlie"</span> }, txn);
    <span class="keyword">await</span> db.Users.UpdateAsync(existingUser, txn);

    <span class="keyword">await</span> txn.CommitAsync();
}
<span class="keyword">catch</span>
{
    <span class="keyword">await</span> txn.RollbackAsync();
    <span class="keyword">throw</span>;
}</code></pre>

      <h3>When to Use Explicit Transactions</h3>
      <ul>
        <li>✅ Two or more writes that must succeed or fail together</li>
        <li>✅ Complex multi-step operations with conditional logic</li>
        <li>✅ Operations spanning multiple collections with dependencies</li>
        <li>✅ When you need to roll back based on business logic</li>
      </ul>
    </section>

    <section>
      <h2>Comparing Auto-commit vs Explicit</h2>

      <h3>⚡ Auto-commit (default)</h3>
      <div class="comparison-box success">
        <strong>Best for:</strong>
        <ul>
          <li>Independent inserts, updates, deletes</li>
          <li>Bulk operations via <code>InsertBulkAsync</code></li>
          <li>Rapid development and simple CRUD</li>
        </ul>
        <pre><code><span class="comment">// Each write commits immediately</span>
<span class="keyword">await</span> db.Users.InsertAsync(user1);
<span class="keyword">await</span> db.Users.InsertAsync(user2);</code></pre>
      </div>

      <h3>🔧 Explicit Transactions (<code>BeginTransaction</code>)</h3>
      <div class="comparison-box warning">
        <strong>Best for:</strong>
        <ul>
          <li>Atomic multi-write batches</li>
          <li>Complex business logic with conditionals</li>
          <li>Cross-collection atomic operations</li>
          <li>Fine-grained rollback control</li>
        </ul>
        <pre><code><span class="keyword">using</span> <span class="keyword">var</span> txn = db.BeginTransaction();
<span class="keyword">await</span> db.Users.InsertAsync(user, txn);
<span class="keyword">if</span> (condition) <span class="keyword">await</span> txn.CommitAsync();
<span class="keyword">else</span> <span class="keyword">await</span> txn.RollbackAsync();</code></pre>
      </div>
    </section>

    <section>
      <h2>Batch Operations with Explicit Transactions</h2>
      <p>Perform a delete-then-insert atomically:</p>
      <pre><code><span class="keyword">using</span> <span class="keyword">var</span> txn = <span class="keyword">await</span> db.BeginTransactionAsync();

<span class="comment">// Collect IDs to delete (reads are outside the transaction)</span>
<span class="type">List</span>&lt;<span class="type">ObjectId</span>&gt; toDelete = <span class="keyword">await</span> db.Users.AsQueryable()
    .Where(u => u.Age > <span class="number">60</span>)
    .Select(u => u.Id)
    .ToListAsync();

<span class="keyword">foreach</span> (<span class="keyword">var</span> id <span class="keyword">in</span> toDelete)
    <span class="keyword">await</span> db.Users.DeleteAsync(id, txn);

<span class="comment">// Insert new batch atomically with the deletes</span>
<span class="keyword">await</span> db.Users.InsertBulkAsync(newBatch, txn);

<span class="keyword">await</span> txn.CommitAsync();</code></pre>
    </section>

    <section>
      <h2>Error Handling</h2>
      <pre><code><span class="keyword">using</span> <span class="keyword">var</span> txn = db.BeginTransaction();

<span class="keyword">try</span>
{
    <span class="keyword">await</span> db.Users.InsertAsync(<span class="keyword">new</span> <span class="type">User</span> { Name = <span class="string">"Alice"</span> }, txn);
    <span class="keyword">await</span> db.Users.InsertAsync(<span class="keyword">new</span> <span class="type">User</span> { Name = <span class="string">"Bob"</span> }, txn);

    <span class="keyword">await</span> txn.CommitAsync();
}
<span class="keyword">catch</span> (<span class="type">ValidationException</span> ex)
{
    <span class="comment">// Rolled back automatically on dispose</span>
    Console.WriteLine($<span class="string">"Validation failed: {ex.Message}"</span>);
}
<span class="keyword">catch</span> (<span class="type">IOException</span> ex)
{
    Console.WriteLine($<span class="string">"I/O error: {ex.Message}"</span>);
}</code></pre>
    </section>

    <section>
      <h2>Explicit Rollback</h2>
      <p>Call <code>RollbackAsync()</code> to explicitly discard all changes in a transaction:</p>
      <pre><code><span class="keyword">using</span> <span class="keyword">var</span> txn = db.BeginTransaction();

<span class="keyword">await</span> db.Users.InsertAsync(<span class="keyword">new</span> <span class="type">User</span> { Name = <span class="string">"Test"</span> }, txn);

<span class="keyword">if</span> (someCondition)
{
    <span class="keyword">await</span> txn.RollbackAsync(); <span class="comment">// Discard changes</span>
    <span class="keyword">return</span>;
}

<span class="keyword">await</span> txn.CommitAsync();</code></pre>
    </section>

    <section>
      <h2>CancellationToken Support</h2>
      <p>All async operations accept an optional <code>CancellationToken</code>:</p>
      <pre><code><span class="keyword">var</span> cts = <span class="keyword">new</span> <span class="type">CancellationTokenSource</span>(<span class="type">TimeSpan</span>.FromSeconds(<span class="number">5</span>));

<span class="keyword">try</span>
{
    <span class="keyword">using</span> <span class="keyword">var</span> txn = <span class="keyword">await</span> db.BeginTransactionAsync(cts.Token);

    <span class="keyword">await</span> db.Users.InsertBulkAsync(largeDataset, txn, cts.Token);
    <span class="keyword">await</span> txn.CommitAsync(cts.Token);
}
<span class="keyword">catch</span> (<span class="type">OperationCanceledException</span>)
{
    <span class="comment">// Transaction automatically rolled back on dispose</span>
    Console.WriteLine(<span class="string">"Operation cancelled"</span>);
}</code></pre>
    </section>

    <section>
      <h2>Transaction Isolation</h2>
      <p>BLite uses <strong>Read Committed</strong> isolation. Each read sees the last committed state; writes inside a transaction are not visible to other readers until commit.</p>
      <pre><code><span class="comment">// Reader sees committed data only</span>
<span class="keyword">var</span> user = <span class="keyword">await</span> db.Users.FindByIdAsync(userId);   <span class="comment">// reads last committed value</span>

<span class="comment">// Writer holds changes until commit</span>
<span class="keyword">using</span> <span class="keyword">var</span> txn = db.BeginTransaction();
user.Age = <span class="number">31</span>;
<span class="keyword">await</span> db.Users.UpdateAsync(user, txn);

<span class="comment">// Another reader still sees Age = 30 until txn.CommitAsync() is called</span>
<span class="keyword">await</span> txn.CommitAsync();</code></pre>
    </section>

    <section>
      <h2>Read-Only Operations</h2>
      <p>Queries are outside the transaction model and always read committed data:</p>
      <pre><code><span class="keyword">using</span> <span class="keyword">var</span> db = <span class="keyword">new</span> <span class="type">AppDbContext</span>(<span class="string">"mydb.blite"</span>);

<span class="comment">// Async LINQ — no transaction needed</span>
<span class="type">List</span>&lt;<span class="type">User</span>&gt; users = <span class="keyword">await</span> db.Users.AsQueryable()
    .Where(u => u.Age > <span class="number">25</span>)
    .OrderBy(u => u.Name)
    .ToListAsync();

<span class="comment">// Streaming — no transaction needed</span>
<span class="keyword">await foreach</span> (<span class="keyword">var</span> u <span class="keyword">in</span> db.Users.FindAllAsync())
    Process(u);</code></pre>
    </section>

    <section>
      <h2>BLiteSession — Per-Connection Isolation <span style="font-size:0.6em;vertical-align:middle;background:rgba(231,76,60,0.15);color:var(--blite-red);padding:2px 8px;border-radius:12px;font-weight:600">v3.8.0</span></h2>
      <p>
        When a single <code>BLiteEngine</code> instance is shared across multiple concurrent clients
        (e.g. inside BLite.Server), <code>BLiteSession</code> provides <strong>per-connection isolated
        transaction contexts</strong>. Each session carries its own transaction state so independent callers
        cannot interfere with each other.
      </p>
      <p>Open a session with <code>engine.OpenSession()</code>. Disposing the session automatically rolls back any uncommitted transaction.</p>
      <pre><code><span class="keyword">using</span> <span class="keyword">var</span> engine = <span class="keyword">new</span> <span class="type">BLiteEngine</span>(<span class="string">"data.db"</span>);

<span class="comment">// One session per connected client / per request</span>
<span class="keyword">using</span> <span class="keyword">var</span> session = engine.OpenSession();

<span class="comment">// Explicit transaction on this session</span>
<span class="keyword">using</span> <span class="keyword">var</span> txn = session.BeginTransaction();

<span class="keyword">try</span>
{
    <span class="keyword">await</span> session.InsertAsync(<span class="string">"orders"</span>, orderDoc, ct);
    <span class="keyword">await</span> session.InsertAsync(<span class="string">"invoices"</span>, invoiceDoc, ct);
    <span class="keyword">await</span> session.CommitAsync(ct);
}
<span class="keyword">catch</span>
{
    session.Rollback(); <span class="comment">// or disposed automatically</span>
    <span class="keyword">throw</span>;
}

<span class="comment">// Convenience CRUD without explicit transaction (auto-commit)</span>
<span class="type">BsonId</span> id = <span class="keyword">await</span> session.InsertAsync(<span class="string">"users"</span>, userDoc, ct);
<span class="type">BsonDocument</span>? doc = <span class="keyword">await</span> session.FindByIdAsync(<span class="string">"users"</span>, id, ct);

<span class="comment">// Access a collection scoped to this session</span>
<span class="keyword">var</span> col = session.GetOrCreateCollection(<span class="string">"events"</span>);
<span class="keyword">await</span> col.InsertAsync(eventDoc, ct);</code></pre>
      <div class="info-box">
        <strong>💡 When to use BLiteSession</strong>
        <ul>
          <li>✅ <strong>Server mode</strong> — one session per client connection ensures transaction isolation</li>
          <li>✅ <strong>Shared engine</strong> — multiple concurrent callers on a single <code>BLiteEngine</code></li>
          <li>✅ <strong>Dispose-safe</strong> — uncommitted transactions are rolled back automatically on disposal</li>
          <li>⚠️ <strong>Embedded single-process apps</strong> — not required; use <code>DocumentDbContext</code> or <code>BLiteEngine</code> directly</li>
        </ul>
      </div>
    </section>

    <section>
      <h2>Hot Backup (v1.8.0)</h2>
      <p>Create a <strong>consistent, online backup</strong> of the database without stopping or pausing the engine. Concurrent reads and writes remain safe during the copy.</p>
      <pre><code><span class="comment">// Typed API (DocumentDbContext)</span>
<span class="keyword">using</span> <span class="keyword">var</span> db = <span class="keyword">new</span> <span class="type">AppDbContext</span>(<span class="string">"mydb.blite"</span>);
<span class="keyword">await</span> db.BackupAsync(<span class="string">"backups/mydb-2026-06-06.blite"</span>);

<span class="comment">// Schema-less API (BLiteEngine)</span>
<span class="keyword">using</span> <span class="keyword">var</span> engine = <span class="keyword">new</span> <span class="type">BLiteEngine</span>(<span class="string">"mydb.blite"</span>);
<span class="keyword">await</span> engine.BackupAsync(<span class="string">"backups/mydb-2026-06-06.blite"</span>);</code></pre>
      <p>The backup file is a <strong>standalone, fully consistent database</strong> that can be opened directly with a new engine instance.</p>
      <div class="info-box">
        <strong>How it works:</strong>
        <ul>
          <li>Acquires the commit lock (no new commits during copy)</li>
          <li>Checkpoints WAL into the PageFile</li>
          <li>Copies the PageFile to the destination path</li>
          <li>Releases the lock — writes resume immediately</li>
          <li>WAL is <strong>not</strong> copied — the destination is already consistent</li>
        </ul>
      </div>
      <pre><code><span class="comment">// With CancellationToken support</span>
<span class="keyword">var</span> cts = <span class="keyword">new</span> <span class="type">CancellationTokenSource</span>(<span class="type">TimeSpan</span>.FromSeconds(<span class="number">30</span>));
<span class="keyword">await</span> db.BackupAsync(<span class="string">"backup.blite"</span>, cts.Token);</code></pre>
    </section>

    <section>
      <h2>Best Practices</h2>
      <ul>
        <li>✅ <strong>Use auto-commit</strong> for independent single writes — simpler and sufficient</li>
        <li>✅ <strong>Use explicit transactions</strong> when two or more writes must be atomic</li>
        <li>✅ <strong>Always pass <code>txn</code></strong> to every write that must be part of the transaction</li>
        <li>✅ <strong>Always use <code>using</code></strong> on transactions to guarantee rollback on exceptions</li>
        <li>✅ <strong>Keep transactions short</strong> to minimize WAL pressure and lock contention</li>
        <li>✅ <strong>Pass <code>CancellationToken</code></strong> for long-running operations</li>
        <li>✅ <strong>Use <code>BLiteSession</code></strong> when multiple tasks share a single engine instance</li>
        <li>⚠️ <strong>Don't nest transactions</strong> — BLite uses a single active transaction per context</li>
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
  line-height: 1.7;
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
  font-size: 1.3rem;
  font-weight: 600;
  margin: 24px 0 12px;
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
  margin-bottom: 12px;
  color: var(--text-secondary);
  line-height: 1.6;
}

li strong, li code {
  color: var(--blite-red);
}

code {
  font-family: var(--font-mono);
  font-size: 0.9rem;
  background: rgba(231, 76, 60, 0.1);
  padding: 2px 6px;
  border-radius: 4px;
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
}

.keyword { color: var(--blite-red); }
.type { color: #06b6d4; }
.string { color: #a1a1aa; }
.number { color: #06b6d4; }
.comment { color: #52525b; font-style: italic; }

.info-box { 
  padding: 16px 20px; 
  border-radius: 8px; 
  margin: 24px 0; 
  border-left: 4px solid #06b6d4; 
  background: rgba(6, 182, 212, 0.05); 
}

.info-box ul { 
  margin-top: 12px; 
}

.info-box li { 
  color: var(--text-secondary); 
  font-size: 0.95rem; 
}

.comparison-box {
  padding: 20px;
  border-radius: 8px;
  margin: 16px 0;
  border-left: 4px solid;
}

.comparison-box.success {
  border-left-color: #10b981;
  background: rgba(16, 185, 129, 0.05);
}

.comparison-box.warning {
  border-left-color: #f59e0b;
  background: rgba(245, 158, 11, 0.05);
}

.comparison-box ul {
  margin: 12px 0;
}

.comparison-box pre {
  margin-top: 16px;
}
</style>
