<template>
  <div class="doc-page">
    <h1>🛡️ <span class="title-gradient">GDPR Compliance</span></h1>
    <p class="lead">Built-in Art. 30 inspection, Art. 15/20 subject-data export, personal-data field tagging, and configurable retention — all in the engine, no external tooling required.</p>

    <section>
      <h2>Overview</h2>
      <p>BLite 5.0.0 ships a dedicated GDPR subsystem under the <code>BLite.Core.GDPR</code> namespace. It provides:</p>
      <ul>
        <li><strong>Personal data field tagging</strong> — <code>[PersonalData]</code> attribute marks sensitive properties on mapped types.</li>
        <li><strong>GDPR inspection report</strong> — enumerate all collections with their personal-data fields, retention policy, encryption status, and audit status in one call.</li>
        <li><strong>Subject data export</strong> — extract all documents matching a field/value pair across collections and emit a portable JSON report (Art. 15/20).</li>
        <li><strong>GdprMode.Strict</strong> — optional engine mode that rejects schema-less writes to collections that declare a typed schema with personal data.</li>
      </ul>
    </section>

    <section>
      <h2>Marking Personal Data</h2>
      <p>Decorate properties on your mapped types with <code>[PersonalData]</code> and optionally <code>[DataSensitivity]</code>:</p>
      <pre><code><span class="keyword">using</span> <span class="type">BLite.Core.GDPR</span>;

<span class="keyword">public class</span> <span class="type">User</span>
{
    <span class="keyword">public</span> <span class="type">ObjectId</span> Id { <span class="keyword">get</span>; <span class="keyword">set</span>; }
    <span class="keyword">public string</span>   Name  { <span class="keyword">get</span>; <span class="keyword">set</span>; } = <span class="string">""</span>;

    [<span class="type">PersonalData</span>]
    <span class="keyword">public string</span> Email { <span class="keyword">get</span>; <span class="keyword">set</span>; } = <span class="string">""</span>;

    [<span class="type">PersonalData</span>, <span class="type">DataSensitivity</span>(<span class="type">SensitivityLevel</span>.High)]
    <span class="keyword">public string?</span> PhoneNumber { <span class="keyword">get</span>; <span class="keyword">set</span>; }
}</code></pre>
      <p>The engine reads these attributes at collection registration time and records the field names in its metadata store — no runtime overhead on the hot path.</p>
    </section>

    <section>
      <h2>Art. 30 — Inspection Report</h2>
      <p>Generate a complete processing record for one database:</p>
      <pre><code><span class="keyword">using</span> <span class="type">BLite.Core.GDPR</span>;

<span class="keyword">var</span> report = <span class="type">GdprEngineExtensions</span>.InspectDatabase(engine);

Console.WriteLine(<span class="string">$"Encrypted: {report.IsEncrypted}"</span>);
Console.WriteLine(<span class="string">$"Audit enabled: {report.IsAuditEnabled}"</span>);

<span class="keyword">foreach</span> (<span class="keyword">var</span> col <span class="keyword">in</span> report.Collections)
{
    Console.WriteLine(<span class="string">$"Collection: {col.Name}"</span>);
    Console.WriteLine(<span class="string">$"  Personal fields: {string.Join(", ", col.PersonalDataFields)}"</span>);
    Console.WriteLine(<span class="string">$"  Retention: {col.RetentionPolicy?.MaxAge}"</span>);
}</code></pre>
      <p>Via BLite.Server REST: <code>GET /api/v1/{dbId}/gdpr/inspect</code> (requires <code>Admin</code> permission).</p>
    </section>

    <section>
      <h2>Art. 15/20 — Subject Data Export</h2>
      <p>Export all documents for a specific data subject across all collections:</p>
      <pre><code><span class="keyword">var</span> query = <span class="keyword">new</span> <span class="type">SubjectQuery</span>
{
    FieldName  = <span class="string">"Email"</span>,
    FieldValue = <span class="type">BsonValue</span>.FromString(<span class="string">"alice@example.com"</span>),
    Format     = <span class="type">SubjectExportFormat</span>.Json
};

<span class="keyword">await using var</span> report = <span class="keyword">await</span> <span class="type">GdprEngineExtensions</span>.ExportSubjectDataAsync(engine, query);
<span class="keyword">await</span> report.ExportAsJsonAsync(<span class="type">File</span>.OpenWrite(<span class="string">"alice-export.json"</span>));</code></pre>
      <p>To scope the search to specific collections, set <code>SubjectQuery.Collections</code>:</p>
      <pre><code>Collections = [<span class="string">"users"</span>, <span class="string">"orders"</span>]</code></pre>
      <p>Via BLite.Server REST: <code>POST /api/v1/{dbId}/{collection}/gdpr/export-subject</code> with body <code>{"fieldName":"email","fieldValue":"alice@example.com"}</code>.</p>
    </section>

    <section>
      <h2>Retention Policies</h2>
      <p>BLite 5.0.0 generalises retention — it is no longer limited to TimeSeries collections. Any typed collection can declare a retention policy:</p>
      <pre><code><span class="keyword">var</span> col = engine.GetOrCreateCollection&lt;<span class="type">ObjectId</span>, <span class="type">AuditEntry</span>&gt;(mapper);

col.HasRetentionPolicy(<span class="keyword">new</span> <span class="type">RetentionPolicy</span>
{
    MaxAge           = <span class="type">TimeSpan</span>.FromDays(90),   <span class="comment">// delete docs older than 90 days</span>
    TimestampField   = <span class="string">"CreatedAt"</span>
});

<span class="comment">// Force an immediate prune (otherwise runs automatically on insert)</span>
<span class="keyword">await</span> col.PruneAsync();</code></pre>
    </section>

    <section>
      <h2>Secure Erase</h2>
      <p>When <code>HasSecureErase</code> is configured on a collection, BLite zero-overwrites the page regions previously occupied by a deleted document before reclaiming them. This prevents data recovery from the raw file:</p>
      <pre><code>col.HasSecureErase();</code></pre>
      <div class="doc-callout doc-callout-info">
        Secure erase adds one extra write per deleted document. Enable it only for collections that store personal or sensitive data.
      </div>
    </section>

    <section>
      <h2>GdprMode.Strict</h2>
      <p>In strict mode the engine rejects schema-less (dynamic) writes to any collection that has a registered typed schema containing <code>[PersonalData]</code> fields. This prevents accidental untagged writes:</p>
      <pre><code><span class="keyword">var</span> options = <span class="keyword">new</span> <span class="type">BLiteEngineOptions</span>
{
    DatabasePath = <span class="string">"mydb.blite"</span>,
    GdprMode     = <span class="type">GdprMode</span>.Strict
};</code></pre>
    </section>

    <section>
      <h2>BLite Studio GDPR Page</h2>
      <p>BLite.Server 2.0.0 adds a dedicated <strong>GDPR</strong> page at <code>/gdpr</code> in the Blazor Studio that provides:</p>
      <ul>
        <li>Art. 30 inspection report with encryption badge, audit badge, per-collection personal data fields, and retention summary.</li>
        <li>Subject data export form — enter field name + value and download a JSON file directly from the browser.</li>
        <li>One-click Vacuum to compact the database and reclaim free space.</li>
      </ul>
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
.doc-callout { border-left: 4px solid; padding: 0.6rem 1rem; border-radius: 4px; margin: 1rem 0; font-size: 0.9em; line-height: 1.6; color: var(--text-secondary); }
.doc-callout-info { border-color: #3b82f6; background: rgba(59, 130, 246, 0.08); }
</style>
