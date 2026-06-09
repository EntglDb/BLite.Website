<template>
  <div class="doc-page">
    <h1>🔀 <span class="title-gradient">Multi-Process Access</span></h1>
    <p class="lead">Open the same BLite database from multiple processes simultaneously — with full ACID safety, cross-process WAL coordination, and zero configuration.</p>

    <section>
      <h2>Overview</h2>
      <p>By default BLite uses <code>FileShare.None</code> so a second process attempting to open the same file receives an <code>IOException</code> immediately. This keeps the single-process path lean and avoids any shared-memory overhead.</p>
      <p>Setting <code>AllowMultiProcessAccess = true</code> on <code>PageFileConfig</code> switches the engine into multi-process mode:</p>
      <ul>
        <li>The data file and WAL are opened with <code>FileShare.ReadWrite</code>.</li>
        <li>A <code>.wal-shm</code> sidecar file is created next to the WAL. It carries an atomic transaction-id counter, the published WAL end-offset, a writer-owner PID stamp, and a bounded reader-slot table.</li>
        <li>Cross-process writer serialisation uses a named <code>Mutex</code> on Windows (<code>Local\BLite_walshm_w_&lt;sha&gt;</code>) and <code>fcntl</code> OFD locks on Linux / macOS. Both primitives are auto-released by the kernel if the owner process crashes.</li>
        <li>Transaction IDs are allocated from the shared SHM counter so they are globally unique across processes.</li>
        <li>On open, a stale-PID check clears any writer-owner stamp left by a crashed previous owner.</li>
      </ul>
    </section>

    <section>
      <h2>Quick Start — DocumentDbContext</h2>
      <p>Pass a <code>PageFileConfig</code> with <code>AllowMultiProcessAccess = true</code> to the base constructor:</p>
      <pre><code><span class="keyword">using</span> <span class="type">BLite.Core</span>;
<span class="keyword">using</span> <span class="type">BLite.Core.Storage</span>;

<span class="keyword">public class</span> <span class="type">AppDb</span> : <span class="type">DocumentDbContext</span>
{
    <span class="keyword">private static readonly</span> <span class="type">PageFileConfig</span> _cfg =
        <span class="type">PageFileConfig</span>.Default <span class="keyword">with</span> { AllowMultiProcessAccess = <span class="keyword">true</span> };

    <span class="keyword">public</span> <span class="type">AppDb</span>() : <span class="keyword">base</span>(<span class="string">"app.blite"</span>, _cfg) { }

    <span class="keyword">public</span> <span class="type">DocumentCollection</span>&lt;<span class="type">int</span>, <span class="type">Order</span>&gt; Orders =&gt; Collection&lt;<span class="type">int</span>, <span class="type">Order</span>&gt;();
}</code></pre>
      <p>Every process that opens <code>AppDb</code> with this config co-operates safely on the same file.</p>
    </section>

    <section>
      <h2>Quick Start — BLiteEngine</h2>
      <pre><code><span class="keyword">using</span> <span class="type">BLite.Core</span>;
<span class="keyword">using</span> <span class="type">BLite.Core.Storage</span>;

<span class="keyword">var</span> config = <span class="type">PageFileConfig</span>.Default <span class="keyword">with</span> { AllowMultiProcessAccess = <span class="keyword">true</span> };
<span class="keyword">using var</span> engine = <span class="keyword">new</span> <span class="type">BLiteEngine</span>(<span class="string">"app.blite"</span>, config);

<span class="keyword">var</span> orders = engine.GetOrCreateCollection(<span class="string">"orders"</span>);</code></pre>
    </section>

    <section>
      <h2>PageFileConfig.Server() Preset</h2>
      <p>For server scenarios where the WAL and index files should live in dedicated sub-directories, use the <code>PageFileConfig.Server()</code> factory. It configures separate <code>wal/</code> and <code>collections/</code> directories and is the recommended starting point for multi-process deployments:</p>
      <pre><code><span class="keyword">var</span> config = <span class="type">PageFileConfig</span>.Server(<span class="string">"data/app.blite"</span>) <span class="keyword">with</span>
{
    AllowMultiProcessAccess = <span class="keyword">true</span>
};

<span class="keyword">using var</span> engine = <span class="keyword">new</span> <span class="type">BLiteEngine</span>(<span class="string">"data/app.blite"</span>, config);</code></pre>
      <p>The resulting layout on disk:</p>
      <pre><code>data/
  app.blite          <span class="comment">← main database file</span>
  app.blite.idx      <span class="comment">← B-Tree index file</span>
  wal/
    app.wal          <span class="comment">← Write-Ahead Log</span>
    app.wal-shm      <span class="comment">← shared memory sidecar (created automatically)</span>
  collections/
    app/             <span class="comment">← per-collection data files</span></code></pre>
    </section>

    <section>
      <h2>Lock Timeouts</h2>
      <p>The <code>LockTimeout</code> property controls how long a writer waits to acquire the cross-process lock before throwing <code>TimeoutException</code>. The default is 500 ms for both reads and writes.</p>
      <pre><code><span class="keyword">var</span> config = <span class="type">PageFileConfig</span>.Default <span class="keyword">with</span>
{
    AllowMultiProcessAccess = <span class="keyword">true</span>,
    LockTimeout = <span class="keyword">new</span> <span class="type">LockTimeout</span>(readMs: 1_000, writeMs: 3_000)
};</code></pre>
      <p>Use <code>LockTimeout.Immediate</code> for fail-fast behaviour — the call throws instantly if the lock is not available:</p>
      <pre><code><span class="keyword">var</span> config = <span class="type">PageFileConfig</span>.Default <span class="keyword">with</span>
{
    AllowMultiProcessAccess = <span class="keyword">true</span>,
    LockTimeout = <span class="type">LockTimeout</span>.Immediate
};</code></pre>
    </section>

    <section>
      <h2>Combined with Encryption</h2>
      <p>Multi-process mode and AES-256-GCM encryption can be used together. Pass <code>baseConfig</code> to the encryption constructor:</p>
      <pre><code><span class="keyword">var</span> multiProcessBase = <span class="type">PageFileConfig</span>.Default <span class="keyword">with</span> { AllowMultiProcessAccess = <span class="keyword">true</span> };
<span class="keyword">var</span> crypto = <span class="keyword">new</span> <span class="type">CryptoOptions</span> { Key = key };

<span class="keyword">using var</span> engine = <span class="keyword">new</span> <span class="type">BLiteEngine</span>(<span class="string">"secure.blite"</span>, crypto, baseConfig: multiProcessBase);</code></pre>
    </section>

    <section>
      <h2>Limitations</h2>
      <table class="info-table">
        <thead>
          <tr><th>Scenario</th><th>Supported</th><th>Notes</th></tr>
        </thead>
        <tbody>
          <tr><td>Multiple processes on the same machine</td><td>✅</td><td>Full ACID, WAL coordination via SHM + OS locks</td></tr>
          <tr><td>Multiple threads within one process</td><td>✅</td><td>Always supported, independent of this flag</td></tr>
          <tr><td>Blazor WASM / browser runtime</td><td>❌</td><td>No filesystem locking, no shared memory — use OPFS/IndexedDB backends instead</td></tr>
          <tr><td>Network filesystems (NFS, SMB)</td><td>❌</td><td>File-locking semantics are unreliable — keep the database on a local drive</td></tr>
        </tbody>
      </table>
    </section>

    <section>
      <h2>Crash Safety</h2>
      <p>If a writer process crashes mid-transaction the OS automatically releases the <code>Mutex</code> / OFD lock. The next process to open the database detects the stale PID in the <code>.wal-shm</code> sidecar, clears the writer-owner stamp, and proceeds normally — no manual recovery is required.</p>
    </section>
  </div>
</template>

<style scoped>
.doc-page { max-width: 800px; }
h1 { font-size: 2.5rem; font-weight: 800; margin-bottom: 16px; }
.lead { font-size: 1.2rem; color: var(--text-secondary); margin-bottom: 48px; line-height: 1.7; }
section { margin-bottom: 48px; }
h2 { font-size: 1.8rem; font-weight: 700; margin-bottom: 16px; color: var(--blite-red); border-bottom: 2px solid rgba(231, 76, 60, 0.2); padding-bottom: 8px; }
h3 { font-size: 1.3rem; font-weight: 600; margin: 24px 0 12px; }
p { margin-bottom: 16px; line-height: 1.7; color: var(--text-secondary); }
ul { margin: 16px 0; padding-left: 24px; }
li { margin-bottom: 12px; color: var(--text-secondary); line-height: 1.6; }
code { font-family: var(--font-mono); font-size: 0.9rem; background: rgba(231, 76, 60, 0.1); padding: 2px 6px; border-radius: 4px; color: var(--blite-red); }
pre { background: rgba(10, 10, 10, 0.6); border: 1px solid rgba(231, 76, 60, 0.2); border-radius: 8px; padding: 20px; overflow-x: auto; margin: 16px 0; }
pre code { background: none; padding: 0; color: var(--text-secondary); }
.keyword { color: var(--blite-red); }
.type { color: #06b6d4; }
.string { color: #a1a1aa; }
.comment { color: #52525b; font-style: italic; }
.info-table { width: 100%; border-collapse: collapse; margin: 16px 0; font-size: 0.95rem; }
.info-table th { text-align: left; padding: 12px 16px; background: rgba(231, 76, 60, 0.08); color: var(--blite-red); font-weight: 600; border-bottom: 1px solid rgba(231, 76, 60, 0.2); }
.info-table td { padding: 10px 16px; border-bottom: 1px solid rgba(255, 255, 255, 0.05); color: var(--text-secondary); }
.info-table tr:last-child td { border-bottom: none; }
</style>
