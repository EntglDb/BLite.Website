<template>
  <div class="doc-page">
    <h1>🌐 <span class="title-gradient">Blazor WebAssembly</span></h1>
    <p class="lead">Run BLite directly in the browser. The <code>BLite.Wasm</code> package provides OPFS and IndexedDB storage backends so you can embed a full ACID-safe document database in any Blazor WASM application — no server required.</p>

    <section>
      <h2>Installation</h2>
      <pre><code>dotnet add package BLite.Wasm</code></pre>
      <p>
        <code>BLite.Wasm</code> targets <code>net10.0-browser</code> and depends on <code>BLite</code>.
        It adds two storage backends built on browser APIs and a DI extension for Blazor WASM projects.
      </p>
    </section>

    <section>
      <h2>Quick Start — Blazor WASM</h2>
      <p>Register BLite in <code>Program.cs</code> and inject it into any component:</p>

      <h3>Program.cs</h3>
      <pre><code><span class="keyword">using</span> <span class="type">BLite.Wasm</span>;

<span class="keyword">var</span> builder = <span class="type">WebAssemblyHostBuilder</span>.CreateDefault(args);

<span class="comment">// Registers BLite with automatic backend selection (OPFS → IndexedDB fallback)</span>
builder.Services.AddBLiteWasm(<span class="string">"mydb"</span>);</code></pre>

      <h3>Counter.razor</h3>
      <pre><code>@inject <span class="type">BLiteEngine</span> Db

@code {
    <span class="keyword">private async</span> <span class="type">Task</span> SaveAsync()
    {
        <span class="keyword">var</span> col = Db.GetOrCreateCollection(<span class="string">"events"</span>);
        col.Insert(<span class="keyword">new</span> <span class="type">BsonDocument</span> { [<span class="string">"ts"</span>] = <span class="type">DateTime</span>.UtcNow });
    }
}</code></pre>
    </section>

    <section>
      <h2>Storage Backends</h2>
      <p>
        <code>BLite.Wasm</code> ships two storage backends. <code>BLiteWasm.CreateAsync()</code> automatically
        selects OPFS when available and falls back to IndexedDB:
      </p>
      <table class="info-table">
        <thead>
          <tr><th>Backend</th><th>API</th><th>Performance</th><th>Compatibility</th></tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>OPFS</strong></td>
            <td><code>FileSystemSyncAccessHandle</code></td>
            <td>High — synchronous I/O from Worker threads</td>
            <td>Chrome 102+, Firefox 111+, Safari 15.2+</td>
          </tr>
          <tr>
            <td><strong>IndexedDB</strong></td>
            <td>Async IDB transactions</td>
            <td>Moderate — async JS interop per page</td>
            <td>All modern browsers</td>
          </tr>
        </tbody>
      </table>
      <pre><code><span class="comment">// Automatic selection (recommended)</span>
<span class="keyword">var</span> engine = <span class="keyword">await</span> <span class="type">BLiteWasm</span>.CreateAsync(<span class="string">"mydb"</span>);

<span class="comment">// Force a specific backend</span>
<span class="keyword">var</span> engine = <span class="keyword">await</span> <span class="type">BLiteWasm</span>.CreateAsync(<span class="string">"mydb"</span>, <span class="type">WasmStorageBackend</span>.IndexedDb);
<span class="keyword">var</span> engine = <span class="keyword">await</span> <span class="type">BLiteWasm</span>.CreateAsync(<span class="string">"mydb"</span>, <span class="type">WasmStorageBackend</span>.Opfs);</code></pre>
    </section>

    <section>
      <h2>IPageStorage Abstraction</h2>
      <p>
        Starting in BLite 4.3, the storage engine is decoupled from the file system via the
        <code>IPageStorage</code> and <code>IWriteAheadLog</code> interfaces. All existing <code>PageFile</code>
        and <code>WriteAheadLog</code> behaviour is unchanged; WASM backends simply plug in as alternative
        implementations.
      </p>
      <pre><code><span class="comment">// Core interface — browser backends implement this</span>
<span class="keyword">public interface</span> <span class="type">IPageStorage</span>
{
    <span class="keyword">int</span> PageSize { <span class="keyword">get</span>; }
    <span class="keyword">uint</span> NextPageId { <span class="keyword">get</span>; }
    <span class="keyword">void</span> Open();
    <span class="keyword">void</span> ReadPage(<span class="keyword">uint</span> pageId, <span class="type">Span</span>&lt;<span class="keyword">byte</span>&gt; destination);
    <span class="type">ValueTask</span> ReadPageAsync(<span class="keyword">uint</span> pageId, <span class="type">Memory</span>&lt;<span class="keyword">byte</span>&gt; destination, <span class="type">CancellationToken</span> ct);
    <span class="keyword">void</span> WritePage(<span class="keyword">uint</span> pageId, <span class="type">ReadOnlySpan</span>&lt;<span class="keyword">byte</span>&gt; source);
    <span class="keyword">uint</span> AllocatePage();
    <span class="keyword">void</span> FreePage(<span class="keyword">uint</span> pageId);
    <span class="keyword">void</span> Flush();
    <span class="type">Task</span> FlushAsync(<span class="type">CancellationToken</span> ct);
}</code></pre>

      <h3>In-Memory Storage</h3>
      <p>
        <code>MemoryPageStorage</code> and <code>MemoryWriteAheadLog</code> are also available in the base
        <code>BLite</code> package. They require no file system — useful for unit tests, ephemeral caches,
        and server-side preview scenarios.
      </p>
      <pre><code><span class="comment">// Create a fully in-memory engine — no file system required</span>
<span class="keyword">var</span> engine = <span class="type">BLiteEngine</span>.CreateInMemory();

<span class="comment">// With custom page size</span>
<span class="keyword">var</span> engine = <span class="type">BLiteEngine</span>.CreateInMemory(pageSize: <span class="number">8192</span>);

<span class="comment">// Custom storage via StorageEngine constructor</span>
<span class="keyword">var</span> storage = <span class="keyword">new</span> <span class="type">MemoryPageStorage</span>(pageSize: <span class="number">4096</span>);
<span class="keyword">var</span> wal = <span class="keyword">new</span> <span class="type">MemoryWriteAheadLog</span>();
<span class="keyword">var</span> engine = <span class="keyword">new</span> <span class="type">BLiteEngine</span>(<span class="keyword">new</span> <span class="type">StorageEngine</span>(storage, wal));</code></pre>
    </section>

    <section>
      <h2>WASM Storage Classes</h2>

      <h3>OpfsPageStorage</h3>
      <p>
        Uses <code>FileSystemSyncAccessHandle</code> via JS interop. Pages are stored as sequential
        regions in a single OPFS file. Must be called from a Worker thread (not the main browser thread).
        Delivers the best throughput of the two browser backends.
      </p>

      <h3>IndexedDbPageStorage</h3>
      <p>
        Uses async IndexedDB transactions via <code>[JSImport]</code>. Each page is stored as a keyed
        blob in an IDB object store. Compatible with all modern browsers including those without OPFS.
        Data is exchanged as base64 strings to satisfy <code>[JSImport]</code> async constraints.
      </p>

      <h3>OpfsWriteAheadLog</h3>
      <p>
        Appends WAL records to a dedicated OPFS <code>.wal</code> file. Binary format is identical to the
        file-based <code>WriteAheadLog</code> — full crash recovery is supported.
      </p>

      <h3>IndexedDbWriteAheadLog</h3>
      <p>
        Stores WAL records as serialised byte arrays in an IDB object store.
        <code>TruncateAsync()</code> clears all entries in a single IDB transaction.
      </p>
    </section>

    <section>
      <h2>DocumentDbContext in WASM</h2>
      <p>
        The typed <code>DocumentDbContext</code> API works in Blazor WASM via a new pluggable constructor
        that accepts a <code>StorageEngine</code> directly:
      </p>
      <pre><code><span class="keyword">public class</span> <span class="type">AppDb</span> : <span class="type">DocumentDbContext</span>
{
    <span class="keyword">public</span> <span class="type">AppDb</span>(<span class="type">StorageEngine</span> storage) : <span class="keyword">base</span>(storage) { }

    <span class="keyword">public</span> <span class="type">DocumentCollection</span>&lt;<span class="type">Todo</span>&gt; Todos =&gt; GetCollection&lt;<span class="type">Todo</span>&gt;();
}

<span class="comment">// Blazor WASM Program.cs</span>
builder.Services.AddSingleton(<span class="keyword">async</span> sp =>
{
    <span class="keyword">var</span> engine = <span class="keyword">await</span> <span class="type">BLiteWasm</span>.CreateAsync(<span class="string">"appdb"</span>);
    <span class="keyword">return new</span> <span class="type">AppDb</span>(engine.StorageEngine);
});</code></pre>
    </section>

    <section>
      <h2>Blazor WASM Counter Demo</h2>
      <p>
        A complete sample is available in the repository at
        <code>samples/BLite.BlazorWasm</code>. It demonstrates a counter that persists across page
        reloads using the OPFS backend with automatic IndexedDB fallback.
      </p>
      <pre><code><span class="comment">// Clone the BLite repo and run the sample</span>
git clone https://github.com/EntglDb/BLite
cd BLite/samples/BLite.BlazorWasm
dotnet run</code></pre>
    </section>

    <section>
      <h2>Browser Compatibility</h2>
      <table class="info-table">
        <thead>
          <tr><th>Feature</th><th>Chrome</th><th>Firefox</th><th>Safari</th><th>Edge</th></tr>
        </thead>
        <tbody>
          <tr>
            <td>OPFS (<code>FileSystemSyncAccessHandle</code>)</td>
            <td>102+</td>
            <td>111+</td>
            <td>15.2+</td>
            <td>102+</td>
          </tr>
          <tr>
            <td>IndexedDB fallback</td>
            <td>✅ All</td>
            <td>✅ All</td>
            <td>✅ All</td>
            <td>✅ All</td>
          </tr>
          <tr>
            <td>In-memory (<code>BLiteEngine.CreateInMemory()</code>)</td>
            <td>✅ All</td>
            <td>✅ All</td>
            <td>✅ All</td>
            <td>✅ All</td>
          </tr>
        </tbody>
      </table>
      <div class="info-box">
        <strong>💡 Tip:</strong> <code>AddBLiteWasm()</code> automatically detects OPFS availability at runtime
        and falls back to IndexedDB without any configuration change. You only need to force a backend
        if you have specific requirements.
      </div>
    </section>
  </div>
</template>

<style scoped>
.doc-page { max-width: 800px; }
h1 { font-size: 2.5rem; font-weight: 800; margin-bottom: 16px; }
.title-gradient { background: linear-gradient(135deg, var(--blite-red), #f97316); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }
.lead { font-size: 1.2rem; color: var(--text-secondary); margin-bottom: 48px; line-height: 1.7; }
section { margin-bottom: 48px; }
h2 { font-size: 1.8rem; font-weight: 700; margin-bottom: 16px; color: var(--blite-red); border-bottom: 2px solid rgba(231, 76, 60, 0.2); padding-bottom: 8px; }
h3 { font-size: 1.3rem; font-weight: 600; margin: 24px 0 12px; }
p { margin-bottom: 16px; line-height: 1.7; color: var(--text-secondary); }
ul { margin: 16px 0; padding-left: 24px; }
li { margin-bottom: 8px; color: var(--text-secondary); }
code { font-family: var(--font-mono); font-size: 0.9rem; background: rgba(231, 76, 60, 0.1); padding: 2px 6px; border-radius: 4px; color: var(--blite-red); }
pre { background: rgba(10, 10, 10, 0.6); border: 1px solid rgba(231, 76, 60, 0.2); border-radius: 8px; padding: 20px; overflow-x: auto; margin: 16px 0; }
pre code { background: none; padding: 0; color: var(--text-secondary); }
.keyword { color: var(--blite-red); }
.type { color: #06b6d4; }
.string { color: #a1a1aa; }
.number { color: #06b6d4; }
.comment { color: #52525b; font-style: italic; }
.info-box { padding: 16px 20px; border-radius: 8px; margin: 24px 0; border-left: 4px solid #06b6d4; background: rgba(6, 182, 212, 0.05); }
.info-table { width: 100%; border-collapse: collapse; margin: 16px 0; font-size: 0.95rem; }
.info-table th { text-align: left; padding: 12px 16px; background: rgba(231, 76, 60, 0.08); color: var(--blite-red); font-weight: 600; border-bottom: 1px solid rgba(231, 76, 60, 0.2); }
.info-table td { padding: 10px 16px; border-bottom: 1px solid rgba(255, 255, 255, 0.05); color: var(--text-secondary); }
.info-table tr:last-child td { border-bottom: none; }
</style>
