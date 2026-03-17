<template>
  <div class="comparisons-page">
    <div class="container">
    <h1>⚖️ <span class="title-gradient">Comparisons & Positioning</span></h1>
    <p class="lead">How BLite compares to LiteDB, SQLite, CouchbaseLite, and DuckDB — and why the fastest path to your data is eliminating the hidden overhead of intermediate representations.</p>

    <section>
      <h2>The Embedded Database Landscape</h2>
      <p>The .NET ecosystem offers several embedded storage options, each making different trade-offs between performance, flexibility, and developer experience. BLite was built around a specific insight that none of the existing solutions address: the dominant overhead is rarely raw I/O — it's the hidden cost of <strong>materializing data through intermediate representations</strong> before it reaches your C# types.</p>
    </section>

    <section>
      <h2>Feature Comparison</h2>
      <p>Stacked against the embedded database engines we benchmark, plus Realm .NET as a notable mobile alternative.</p>
      <div class="table-scroll">
        <table>
          <thead>
            <tr>
              <th>Feature</th>
              <th class="highlight-col">BLite</th>
              <th>LiteDB</th>
              <th>SQLite + EF Core</th>
              <th>CouchbaseLite</th>
              <th>DuckDB</th>
              <th>Realm .NET</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Data Model</td>
              <td class="highlight-col"><strong>Document (BSON)</strong></td>
              <td>Document (BSON)</td>
              <td>Relational</td>
              <td>Document (JSON)</td>
              <td>Relational / Columnar</td>
              <td>Object</td>
            </tr>
            <tr>
              <td>NativeAOT / Trimming</td>
              <td class="highlight-col"><span class="badge-good">✅ Full</span></td>
              <td><span class="badge-bad">❌</span></td>
              <td><span class="badge-mid">⚠️ Partial</span></td>
              <td><span class="badge-bad">❌</span></td>
              <td><span class="badge-bad">❌</span></td>
              <td><span class="badge-bad">❌</span></td>
            </tr>
            <tr>
              <td>Reflection-Free</td>
              <td class="highlight-col"><span class="badge-good">✅ Zero</span></td>
              <td><span class="badge-bad">❌ Heavy</span></td>
              <td><span class="badge-bad">❌ Heavy</span></td>
              <td><span class="badge-bad">❌</span></td>
              <td><span class="badge-bad">❌</span></td>
              <td><span class="badge-bad">❌</span></td>
            </tr>
            <tr>
              <td>Source Generators</td>
              <td class="highlight-col"><span class="badge-good">✅ Roslyn</span></td>
              <td><span class="badge-bad">❌</span></td>
              <td><span class="badge-bad">❌</span></td>
              <td><span class="badge-bad">❌</span></td>
              <td><span class="badge-bad">❌</span></td>
              <td>Fody weaver</td>
            </tr>
            <tr>
              <td>Dependencies</td>
              <td class="highlight-col"><span class="badge-good">0</span></td>
              <td>0</td>
              <td>Many (EF Core)</td>
              <td>Native (LiteCore)</td>
              <td>Native (DuckDB)</td>
              <td>Native (C++)</td>
            </tr>
            <tr>
              <td>Native Code</td>
              <td class="highlight-col"><span class="badge-good">None (pure C#)</span></td>
              <td>None</td>
              <td>SQLite native lib</td>
              <td>C++ LiteCore</td>
              <td>C++ DuckDB</td>
              <td>C++ core</td>
            </tr>
            <tr>
              <td>Spatial Indexing</td>
              <td class="highlight-col"><span class="badge-good">✅ R-Tree</span></td>
              <td><span class="badge-bad">❌</span></td>
              <td>Extension</td>
              <td><span class="badge-bad">❌</span></td>
              <td>Extension</td>
              <td><span class="badge-bad">❌</span></td>
            </tr>
            <tr>
              <td>Change Data Capture</td>
              <td class="highlight-col"><span class="badge-good">✅ Built-in</span></td>
              <td><span class="badge-bad">❌</span></td>
              <td><span class="badge-bad">❌</span></td>
              <td>Notifications</td>
              <td><span class="badge-bad">❌</span></td>
              <td>Notifications</td>
            </tr>
            <tr>
              <td>ACID Transactions</td>
              <td class="highlight-col"><span class="badge-good">✅</span></td>
              <td><span class="badge-good">✅</span></td>
              <td><span class="badge-good">✅</span></td>
              <td><span class="badge-good">✅</span></td>
              <td><span class="badge-good">✅</span></td>
              <td><span class="badge-good">✅</span></td>
            </tr>
            <tr>
              <td>Async API</td>
              <td class="highlight-col"><span class="badge-good">✅ Full</span></td>
              <td><span class="badge-bad">❌</span></td>
              <td><span class="badge-good">✅</span></td>
              <td><span class="badge-mid">⚠️ Partial</span></td>
              <td><span class="badge-good">✅</span></td>
              <td><span class="badge-good">✅</span></td>
            </tr>
            <tr>
              <td>P2P / Distributed</td>
              <td class="highlight-col"><span class="badge-good">✅ via EntglDb</span></td>
              <td><span class="badge-bad">❌</span></td>
              <td><span class="badge-bad">❌</span></td>
              <td>Sync Gateway</td>
              <td><span class="badge-bad">❌</span></td>
              <td>Atlas Sync</td>
            </tr>
            <tr>
              <td>Primary Use Case</td>
              <td class="highlight-col">Any .NET</td>
              <td>.NET Framework/Core</td>
              <td>Any .NET</td>
              <td>iOS, Android, .NET</td>
              <td>.NET (analytics / OLAP)</td>
              <td>iOS, Android, .NET</td>
            </tr>
            <tr>
              <td>License</td>
              <td class="highlight-col">MIT</td>
              <td>MIT</td>
              <td>Mixed</td>
              <td>Apache 2.0</td>
              <td>MIT</td>
              <td>Apache 2.0</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <section>
      <h2>⚡ The Hidden Cost of Data Materialization</h2>
      <p>BLite was designed from first principles to eliminate the <strong>hidden friction</strong> that slows every other embedded database: the <em>materialization pipeline</em> — the chain of intermediate transformations between raw storage bytes and the typed C# object your application actually uses.</p>

      <h3>The Traditional Pipeline</h3>
      <p>Every conventional embedded database — LiteDB with its <code>BsonDocument</code> mapper, CouchbaseLite bridging through its C++ LiteCore, SQLite deserializing rows and mapping through Dapper or EF Core — routes your data through multiple intermediate representations before it reaches your code:</p>
      <div class="pipeline">
        <div class="pipe-step">
          <div class="pipe-num">1</div>
          <div class="pipe-body">
            <div class="pipe-label">Interpret Query</div>
            <div class="pipe-sub">Parse expression tree or SQL string; reflect over type metadata to build an execution plan</div>
          </div>
        </div>
        <div class="pipe-connector">↓</div>
        <div class="pipe-step">
          <div class="pipe-num">2</div>
          <div class="pipe-body">
            <div class="pipe-label">Apply &amp; Filter</div>
            <div class="pipe-sub">Traverse index or scan pages; evaluate predicates against stored data</div>
          </div>
        </div>
        <div class="pipe-connector">↓</div>
        <div class="pipe-step">
          <div class="pipe-num">3</div>
          <div class="pipe-body">
            <div class="pipe-label">Read Raw Bytes</div>
            <div class="pipe-sub">Load BSON payload, SQLite row, or JSON string from disk</div>
          </div>
        </div>
        <div class="pipe-connector pipe-connector-costly">↓</div>
        <div class="pipe-step pipe-costly">
          <div class="pipe-num">4</div>
          <div class="pipe-body">
            <div class="pipe-label">Intermediate Format <span class="pipe-tag">overhead</span></div>
            <div class="pipe-sub">Deserialize into a temporary <code>BsonDocument</code>, <code>IDataReader</code>, or JSON string — an untyped copy of your data never needed by the caller</div>
          </div>
        </div>
        <div class="pipe-connector pipe-connector-costly">↓</div>
        <div class="pipe-step pipe-costly">
          <div class="pipe-num">5</div>
          <div class="pipe-body">
            <div class="pipe-label">Object Mapping <span class="pipe-tag">overhead</span></div>
            <div class="pipe-sub">Reflect over type fields; copy values one by one into your <code>CustomerOrder</code> — then discard every intermediate object</div>
          </div>
        </div>
      </div>
      <p>Steps 4 and 5 are pure overhead — temporary allocations that exist only to bridge the gap between what the database returns and what your application needs. LiteDB produces ~48 KB of intermediate data just to return a single 7 KB document.</p>

      <h3>BLite: Direct Serialization</h3>
      <p>BLite source generators emit a <code>BsonWriter&lt;T&gt;</code> and <code>BsonReader&lt;T&gt;</code> for each of your types at compile time. They know the exact field layout of <code>CustomerOrder</code> before the first line of code runs — no intermediate <code>BsonDocument</code>, no runtime reflection, no temporary copies:</p>
      <div class="pipeline pipeline-blite">
        <div class="pipe-step">
          <div class="pipe-num">1</div>
          <div class="pipe-body">
            <div class="pipe-label">Resolve Index</div>
            <div class="pipe-sub">O(1) B-Tree or R-Tree lookup — no query string parsing</div>
          </div>
        </div>
        <div class="pipe-connector">↓</div>
        <div class="pipe-step">
          <div class="pipe-num">2</div>
          <div class="pipe-body">
            <div class="pipe-label">Read Raw Bytes</div>
            <div class="pipe-sub">Load BSON payload from page cache</div>
          </div>
        </div>
        <div class="pipe-connector">↓</div>
        <div class="pipe-step pipe-blite">
          <div class="pipe-num">3</div>
          <div class="pipe-body">
            <div class="pipe-label">Direct Deserialization <span class="pipe-tag pipe-tag-good">source-generated</span></div>
            <div class="pipe-sub">Generated <code>BsonReader&lt;CustomerOrder&gt;</code> writes bytes directly into your typed object — zero reflection, zero intermediate allocation, zero wasted copies</div>
          </div>
        </div>
      </div>
      <p>The same principle applies on write: <code>BsonWriter&lt;CustomerOrder&gt;</code> serializes your object straight to BSON bytes — without ever building a <code>Dictionary</code> or <code>BsonDocument</code> first. This is why BLite's <code>FindById</code> allocates <strong>7 KB</strong> vs. <strong>48 KB</strong> for LiteDB: the intermediate document that every other engine creates is simply never produced.</p>
    </section>

    <section>
      <h2>Performance at a Glance</h2>
      <p>Measured on a realistic e-commerce <code>CustomerOrder</code> document (~1–2 KB). Environment: Windows 11, i7-13800H, .NET 10.0.4, BDN v0.15.8 — March 17, 2026.</p>

      <h3>Insert</h3>
      <div class="table-scroll">
        <table>
          <thead>
            <tr><th>Operation</th><th class="highlight-col">BLite</th><th>LiteDB 5.0.21</th><th>SQLite+JSON</th><th>CouchbaseLite 4.0.3</th><th>DuckDB 1.3.0</th></tr>
          </thead>
          <tbody>
            <tr>
              <td>Single Insert (latency)</td>
              <td class="highlight-col"><strong>164.6 μs</strong></td>
              <td>826.9 μs <span class="badge-bad">5.1x slower</span></td>
              <td>7,380.1 μs <span class="badge-bad">44.8x slower</span></td>
              <td>466.6 μs <span class="badge-bad">2.8x slower</span></td>
              <td>28,218 μs <span class="badge-bad">172x slower</span></td>
            </tr>
            <tr>
              <td>Batch 1000 (latency)</td>
              <td class="highlight-col"><strong>14,086 μs</strong></td>
              <td>27,047 μs <span class="badge-bad">1.9x slower</span></td>
              <td>25,008 μs <span class="badge-bad">1.8x slower</span></td>
              <td>91,217 μs <span class="badge-bad">6.5x slower</span></td>
              <td>361,785 μs <span class="badge-bad">25.7x slower</span></td>
            </tr>
            <tr>
              <td>Batch 1000 (allocated)</td>
              <td class="highlight-col"><strong>31,312 KB</strong></td>
              <td>32,993 KB</td>
              <td>6,296 KB †</td>
              <td>32,548 KB</td>
              <td>4,512 KB †</td>
            </tr>
          </tbody>
        </table>
      </div>

      <h3>Read</h3>
      <div class="table-scroll">
        <table>
          <thead>
            <tr><th>Operation</th><th class="highlight-col">BLite</th><th>LiteDB 5.0.21</th><th>SQLite+JSON</th><th>CouchbaseLite 4.0.3</th><th>DuckDB 1.3.0</th></tr>
          </thead>
          <tbody>
            <tr>
              <td>FindById (latency)</td>
              <td class="highlight-col"><strong>3.980 μs</strong></td>
              <td>22.257 μs <span class="badge-bad">5.6x slower</span></td>
              <td>38.249 μs <span class="badge-bad">9.6x slower</span></td>
              <td>23.374 μs <span class="badge-bad">5.9x slower</span></td>
              <td>11,296 μs <span class="badge-bad">2,843x slower</span></td>
            </tr>
            <tr>
              <td>FindById (allocated)</td>
              <td class="highlight-col"><strong>7.16 KB</strong></td>
              <td>47.8 KB</td>
              <td>9.34 KB</td>
              <td>9.77 KB</td>
              <td>12.59 KB</td>
            </tr>
            <tr>
              <td>Scan 1000 docs (latency)</td>
              <td class="highlight-col"><strong>2,502 μs</strong></td>
              <td>8,455 μs <span class="badge-bad">3.4x slower</span></td>
              <td>8,046 μs <span class="badge-bad">3.2x slower</span></td>
              <td>10,463 μs <span class="badge-bad">4.2x slower</span></td>
              <td>28,986 μs <span class="badge-bad">11.6x slower</span></td>
            </tr>
            <tr>
              <td>Scan 1000 docs (allocated)</td>
              <td class="highlight-col"><strong>5,091 KB</strong></td>
              <td>17,296 KB <span class="badge-bad">3.4x more</span></td>
              <td>7,804 KB</td>
              <td>2,221 KB</td>
              <td>1,956 KB</td>
            </tr>
          </tbody>
        </table>
      </div>

      <p style="font-size:0.85rem; color: var(--text-muted);">† SQLite and DuckDB report minimal managed allocations — native C library memory is excluded from BenchmarkDotNet measurement. BLite is 100% managed; all allocations are captured. Full details: <router-link to="/docs/benchmarks">Benchmarks page</router-link>.</p>
    </section>

    <section>
      <h2>What Makes BLite Unique</h2>
      <div class="highlights">
        <div class="highlight">
          <div class="highlight-value">0</div>
          <div class="highlight-label">Reflection Calls</div>
        </div>
        <div class="highlight">
          <div class="highlight-value">0</div>
          <div class="highlight-label">Dependencies</div>
        </div>
        <div class="highlight">
          <div class="highlight-value">0</div>
          <div class="highlight-label">Native Binaries</div>
        </div>
        <div class="highlight">
          <div class="highlight-value">100%</div>
          <div class="highlight-label">AOT Compatible</div>
        </div>
      </div>
      <p>BLite is the only embedded document database for .NET that combines <strong>source-generated mappers</strong>, <strong>zero reflection</strong>, and <strong>full NativeAOT support</strong> in a pure managed library with zero external dependencies.</p>
      <p>This means:</p>
      <ul>
        <li><strong>Instant startup</strong> — no runtime type scanning or mapper initialization.</li>
        <li><strong>Trimmer-safe</strong> — publish tiny self-contained binaries without worrying about reflection metadata.</li>
        <li><strong>Cross-platform without friction</strong> — no native interop, no platform-specific builds.</li>
        <li><strong>Compile-time safety</strong> — mapping errors surface at build time, not at runtime.</li>
      </ul>
    </section>

    <section>
      <h2>🌐 A Cosmos DB for Embedded Applications</h2>
      <p>Azure Cosmos DB popularized the idea of a globally distributed, multi-model document database. BLite brings the same <strong>document-oriented philosophy</strong> to the embedded world:</p>
      <div class="table-scroll">
        <table>
          <thead>
            <tr>
              <th>Concept</th>
              <th>Azure Cosmos DB</th>
              <th class="highlight-col">BLite</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Data Format</td>
              <td>JSON / BSON</td>
              <td class="highlight-col">BSON</td>
            </tr>
            <tr>
              <td>Data Model</td>
              <td>Document-oriented</td>
              <td class="highlight-col">Document-oriented</td>
            </tr>
            <tr>
              <td>Partitioning</td>
              <td>Partition keys</td>
              <td class="highlight-col">Collections</td>
            </tr>
            <tr>
              <td>Schema</td>
              <td>Schema-free</td>
              <td class="highlight-col">Schema-free</td>
            </tr>
            <tr>
              <td>Indexing</td>
              <td>Automatic + custom</td>
              <td class="highlight-col">Explicit indexes + R-Tree</td>
            </tr>
            <tr>
              <td>Transactions</td>
              <td>Scoped to partition</td>
              <td class="highlight-col">Full ACID per database</td>
            </tr>
            <tr>
              <td>Change Feed</td>
              <td>Change Feed</td>
              <td class="highlight-col">Change Data Capture</td>
            </tr>
            <tr>
              <td>Distribution</td>
              <td>Cloud-native global</td>
              <td class="highlight-col">Embedded P2P via EntglDb</td>
            </tr>
            <tr>
              <td>Deployment</td>
              <td>Cloud service</td>
              <td class="highlight-col">In-process library</td>
            </tr>
            <tr>
              <td>Cost</td>
              <td>RU-based billing</td>
              <td class="highlight-col">Free &amp; open source</td>
            </tr>
          </tbody>
        </table>
      </div>
      <p>If you think of Cosmos DB as <em>"a document database that scales globally in the cloud"</em>, then BLite is <em>"a document database that runs locally with cloud-like capabilities on any device."</em></p>
    </section>

    <section>
      <h2>🔗 BLite + EntglDb = Embedded Distributed Database</h2>
      <p>On its own, BLite is a powerful single-node embedded database. When paired with <a href="https://www.entgldb.com" target="_blank">EntglDb</a>, it becomes something entirely new in the .NET ecosystem: an <strong>embedded, peer-to-peer distributed document database</strong>.</p>

      <div class="info-box">
        <div class="info-header">🌐 EntglDb — Peer-to-Peer Data Sync for .NET</div>
        <p><a href="https://www.entgldb.com" target="_blank">EntglDb</a> is a distributed data synchronization framework that provides:</p>
        <ul>
          <li><strong>P2P Replication</strong> — nodes sync directly without a central server.</li>
          <li><strong>Conflict Resolution</strong> — automatic CRDT-based or custom resolution strategies.</li>
          <li><strong>Offline-First</strong> — each node works independently and syncs when connected.</li>
          <li><strong>Pluggable Persistence</strong> — BLite is a first-class persistence backend.</li>
        </ul>
      </div>

      <div class="architecture-diagram">
        <div class="arch-row">
          <div class="arch-node app">📱 App A<span class="node-sub">BLite + EntglDb</span></div>
          <div class="arch-connector">⟷</div>
          <div class="arch-node app">💻 App B<span class="node-sub">BLite + EntglDb</span></div>
          <div class="arch-connector">⟷</div>
          <div class="arch-node app">🖥️ App C<span class="node-sub">BLite + EntglDb</span></div>
        </div>
        <div class="arch-label">Each node runs a full BLite database locally — data syncs peer-to-peer via EntglDb</div>
      </div>

      <p>This combination enables scenarios that were previously only possible with cloud backends:</p>
      <ul>
        <li><strong>Multi-device sync</strong> — MAUI apps on phones, tablets, and desktops stay in sync without a server.</li>
        <li><strong>Edge computing</strong> — IoT devices replicate readings across a mesh network.</li>
        <li><strong>Collaborative apps</strong> — multiple users share data in real-time with conflict resolution.</li>
        <li><strong>Resilient architectures</strong> — no single point of failure; every node owns its data.</li>
      </ul>
    </section>

    <section>
      <h2>🎯 Target Scenarios</h2>
      <div class="scenarios">
        <div class="scenario">
          <div class="scenario-icon">📱</div>
          <h3>Mobile (MAUI)</h3>
          <p>AOT-compiled MAUI apps with instant data access, no native SQLite dependency, and optional P2P sync between devices.</p>
        </div>
        <div class="scenario">
          <div class="scenario-icon">🌡️</div>
          <h3>IoT & Edge</h3>
          <p>Lightweight data storage on resource-constrained devices. Spatial indexing for geo-enabled sensors. Mesh sync via EntglDb.</p>
        </div>
        <div class="scenario">
          <div class="scenario-icon">⚙️</div>
          <h3>CLI & Background Services</h3>
          <p>Trimmed, single-file executables with embedded persistence. Zero startup overhead from reflection-free design.</p>
        </div>
        <div class="scenario">
          <div class="scenario-icon">🖥️</div>
          <h3>Desktop Apps</h3>
          <p>WPF, WinUI, Avalonia — any .NET desktop framework. Local-first storage with CDC for reactive UI updates.</p>
        </div>
        <div class="scenario">
          <div class="scenario-icon">🧪</div>
          <h3>Testing & Prototyping</h3>
          <p>In-memory mode for fast unit tests. No external process, no cleanup. Perfect for integration testing.</p>
        </div>
        <div class="scenario">
          <div class="scenario-icon">🏗️</div>
          <h3>Microservices</h3>
          <p>Local caching or event sourcing with ACID guarantees and zero infrastructure. EntglDb adds state replication across instances.</p>
        </div>
      </div>
    </section>

    <section>
      <h2>When to Use What</h2>
      <div class="decision-grid">
        <div class="decision-card">
          <h3>Choose BLite when…</h3>
          <ul>
            <li>You need NativeAOT or trimming.</li>
            <li>You want zero dependencies and pure managed code.</li>
            <li>You prefer document-oriented data over relational tables.</li>
            <li>You want compile-time mapping safety.</li>
            <li>You need spatial indexing or CDC built-in.</li>
            <li>You want a fully async API.</li>
          </ul>
        </div>
        <div class="decision-card">
          <h3>Choose SQLite + EF Core when…</h3>
          <ul>
            <li>You need complex relational queries (joins, aggregates).</li>
            <li>You have an existing SQL schema you must reuse.</li>
            <li>You need full-text search.</li>
          </ul>
        </div>
        <div class="decision-card">
          <h3>Choose LiteDB when…</h3>
          <ul>
            <li>You don't need AOT and reflection is acceptable.</li>
            <li>You need BsonExpression-based LINQ queries.</li>
            <li>You are on .NET Framework and can't upgrade.</li>
          </ul>
        </div>
        <div class="decision-card">
          <h3>Choose CouchbaseLite when…</h3>
          <ul>
            <li>You build iOS or Android apps requiring offline-first sync.</li>
            <li>You need replication via Couchbase Sync Gateway.</li>
            <li>You are already in the Couchbase ecosystem.</li>
          </ul>
        </div>
        <div class="decision-card">
          <h3>Choose DuckDB when…</h3>
          <ul>
            <li>Your workload is analytical (OLAP) rather than transactional (OLTP).</li>
            <li>You need SQL aggregations over columnar data files (Parquet, CSV).</li>
            <li>You are not doing per-document point reads or writes.</li>
          </ul>
        </div>
      </div>
    </section>

    <div class="info-box">
      <div class="info-header">📦 Get Started</div>
      <p>Ready to try BLite? Install it from NuGet:</p>
      <pre><code>dotnet add package BLite
dotnet add package BLite.SourceGenerators</code></pre>
      <p>Pair it with <a href="https://www.entgldb.com" target="_blank">EntglDb</a> for distributed scenarios:</p>
      <pre><code>dotnet add package EntglDb.Persistence.BLite</code></pre>
      <p>Check the <router-link to="/docs/getting-started">Getting Started</router-link> guide for a full walkthrough.</p>
    </div>
    </div>
  </div>
</template>

<style scoped>
.comparisons-page { padding: 48px 0 80px; }
.container { max-width: 960px; margin: 0 auto; padding: 0 24px; }
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

.info-box { background: rgba(231, 76, 60, 0.05); border: 1px solid rgba(231, 76, 60, 0.2); border-radius: 8px; padding: 20px; margin: 24px 0; }
.info-header { font-weight: 600; color: var(--blite-red); margin-bottom: 12px; font-size: 1.1rem; }
.info-box ul { margin-top: 12px; }
.info-box a, .info-box .router-link-active { color: var(--blite-red); text-decoration: underline; }

.table-scroll { overflow-x: auto; margin: 24px 0; }
table { width: 100%; border-collapse: collapse; min-width: 700px; }
th, td { padding: 12px; text-align: left; border-bottom: 1px solid rgba(231, 76, 60, 0.2); }
th { color: var(--blite-red); font-weight: 600; font-size: 0.9rem; }
td { color: var(--text-secondary); font-size: 0.9rem; }
.highlight-col { background: rgba(231, 76, 60, 0.05); }

.badge-good { display: inline-block; padding: 4px 8px; background: rgba(34, 197, 94, 0.2); color: #22c55e; border-radius: 4px; font-size: 0.8rem; font-weight: 600; }
.badge-bad { display: inline-block; padding: 4px 8px; background: rgba(239, 68, 68, 0.15); color: #ef4444; border-radius: 4px; font-size: 0.8rem; font-weight: 600; }
.badge-mid { display: inline-block; padding: 4px 8px; background: rgba(251, 146, 60, 0.2); color: #fb923c; border-radius: 4px; font-size: 0.8rem; font-weight: 600; }

.highlights { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 16px; margin: 24px 0; }
.highlight { background: rgba(231, 76, 60, 0.1); border: 1px solid rgba(231, 76, 60, 0.3); border-radius: 8px; padding: 20px; text-align: center; }
.highlight-value { font-size: 2rem; font-weight: 800; font-family: var(--font-mono); color: var(--blite-red); }
.highlight-label { font-size: 0.85rem; color: var(--text-muted); margin-top: 8px; text-transform: uppercase; letter-spacing: 1px; }

.architecture-diagram { background: rgba(10, 10, 10, 0.6); border: 1px solid rgba(231, 76, 60, 0.2); border-radius: 12px; padding: 32px; margin: 24px 0; text-align: center; }
.arch-row { display: flex; align-items: center; justify-content: center; gap: 16px; flex-wrap: wrap; }
.arch-node { background: rgba(231, 76, 60, 0.1); border: 1px solid rgba(231, 76, 60, 0.3); border-radius: 8px; padding: 16px 24px; font-size: 1.1rem; font-weight: 600; display: flex; flex-direction: column; align-items: center; gap: 4px; }
.arch-node.app { color: var(--text-primary); }
.node-sub { font-size: 0.75rem; color: var(--text-muted); font-weight: 400; }
.arch-connector { font-size: 1.5rem; color: var(--blite-red); font-weight: 700; }
.arch-label { margin-top: 20px; font-size: 0.9rem; color: var(--text-muted); font-style: italic; }

.scenarios { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin: 24px 0; }
.scenario { background: rgba(15, 15, 15, 0.5); border: 1px solid rgba(231, 76, 60, 0.15); border-radius: 8px; padding: 24px; transition: border-color 0.2s ease; }
.scenario:hover { border-color: rgba(231, 76, 60, 0.4); }
.scenario-icon { font-size: 2rem; margin-bottom: 12px; }
.scenario h3 { margin-top: 0; color: var(--text-primary); }
.scenario p { font-size: 0.9rem; margin-bottom: 0; }

.decision-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin: 24px 0; }
.decision-card { background: rgba(15, 15, 15, 0.5); border: 1px solid rgba(231, 76, 60, 0.15); border-radius: 8px; padding: 24px; }
.decision-card:first-child { border-color: rgba(231, 76, 60, 0.4); background: rgba(231, 76, 60, 0.05); }
.decision-card h3 { margin-top: 0; color: var(--blite-red); font-size: 1.1rem; }
.decision-card ul { margin-bottom: 0; }
.decision-card li { font-size: 0.9rem; }

.pipeline { display: flex; flex-direction: column; margin: 24px 0; }
.pipe-step { background: rgba(15,15,15,0.6); border: 1px solid rgba(231,76,60,0.2); border-radius: 8px; padding: 14px 18px; display: flex; gap: 14px; align-items: flex-start; }
.pipe-step.pipe-costly { border-color: rgba(239,68,68,0.45); background: rgba(239,68,68,0.08); }
.pipe-step.pipe-blite { border-color: rgba(34,197,94,0.45); background: rgba(34,197,94,0.08); }
.pipe-num { font-size: 1.3rem; font-weight: 800; color: var(--blite-red); font-family: var(--font-mono); min-width: 22px; flex-shrink: 0; line-height: 1.4; }
.pipeline-blite .pipe-num { color: #22c55e; }
.pipe-body { flex: 1; min-width: 0; }
.pipe-label { font-size: 0.9rem; font-weight: 600; color: var(--text-primary); margin-bottom: 4px; display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.pipe-sub { font-size: 0.82rem; color: var(--text-muted); line-height: 1.6; }
.pipe-connector { font-size: 1rem; color: var(--blite-red); padding: 2px 0 2px 18px; line-height: 1; }
.pipe-connector.pipe-connector-costly { color: #ef4444; }
.pipeline-blite .pipe-connector { color: #22c55e; }
.pipe-tag { display: inline-block; padding: 1px 7px; border-radius: 4px; font-size: 0.72rem; font-weight: 600; background: rgba(239,68,68,0.2); color: #ef4444; text-transform: uppercase; letter-spacing: 0.5px; }
.pipe-tag.pipe-tag-good { background: rgba(34,197,94,0.2); color: #22c55e; }
</style>
