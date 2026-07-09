<template>
  <div class="doc-page">
    <h1>📊 <span class="title-gradient">Audit Trail</span></h1>
    <p class="lead">Structured write audit with OpenTelemetry-compatible metrics, a pluggable sink interface, and zero overhead when disabled.</p>

    <section>
      <h2>Overview</h2>
      <p>BLite 5.0.0 introduces a built-in audit subsystem that records every write (insert, update, delete) with the caller context. The audit trail is:</p>
      <ul>
        <li><strong>Pluggable</strong> — attach any <code>IBLiteAuditSink</code> implementation (database, file, HTTP webhook…)</li>
        <li><strong>OTel-compatible</strong> — <code>BLiteDiagnostics.ActivitySource</code> emits spans that propagate to Jaeger, Grafana, Datadog, etc.</li>
        <li><strong>Zero-overhead when disabled</strong> — the hot path is a null-sink guarded by a single bool check.</li>
      </ul>
    </section>

    <section>
      <h2>Enabling the Audit Sink</h2>
      <pre><code><span class="keyword">using</span> <span class="type">BLite.Core.Audit</span>;

<span class="keyword">using var</span> engine = <span class="keyword">new</span> <span class="type">BLiteEngine</span>(<span class="string">"mydb.blite"</span>);

engine.ConfigureAudit(<span class="keyword">new</span> <span class="type">BLiteAuditOptions</span>
{
    Sink           = <span class="keyword">new</span> <span class="type">MyAuditSink</span>(),    <span class="comment">// your IBLiteAuditSink implementation</span>
    EnableMetrics  = <span class="keyword">true</span>,
    SlowOperationThreshold = <span class="type">TimeSpan</span>.FromMilliseconds(<span class="number">100</span>)
});</code></pre>
    </section>

    <section>
      <h2>Custom Audit Sink</h2>
      <p>Implement <code>IBLiteAuditSink</code> to forward events to any backend:</p>
      <pre><code><span class="comment">// IBLiteAuditSink methods are synchronous — queue async work internally if needed</span>
<span class="keyword">public class</span> <span class="type">PostgresAuditSink</span> : <span class="type">IBLiteAuditSink</span>
{
    <span class="keyword">public void</span> OnInsert(<span class="type">InsertAuditEvent</span> e)
    {
        <span class="comment">// e.CollectionName, e.DocumentSizeBytes, e.Elapsed, e.UserId, e.TransactionId</span>
        _channel.Writer.TryWrite((<span class="string">"insert"</span>, e.CollectionName, e.UserId, <span class="type">DateTime</span>.UtcNow));
    }

    <span class="keyword">public void</span> OnCommit(<span class="type">CommitAuditEvent</span> e)
    {
        <span class="comment">// e.CollectionName, e.PagesWritten, e.WalSizeBytes, e.Elapsed, e.UserId</span>
        _channel.Writer.TryWrite((<span class="string">"commit"</span>, e.CollectionName, e.UserId, <span class="type">DateTime</span>.UtcNow));
    }
}</code></pre>
    </section>

    <section>
      <h2>Caller Context</h2>
      <p>Use <code>IAuditContextProvider</code> to attach a per-request identity (e.g. the current HTTP user) to every audit entry:</p>
      <pre><code><span class="keyword">public class</span> <span class="type">HttpUserContextProvider</span> : <span class="type">IAuditContextProvider</span>
{
    <span class="keyword">private readonly</span> <span class="type">IHttpContextAccessor</span> _http;
    <span class="keyword">public</span> <span class="type">HttpUserContextProvider</span>(<span class="type">IHttpContextAccessor</span> http) => _http = http;

    <span class="keyword">public string?</span> GetContext() =>
        _http.HttpContext?.User.Identity?.Name;
}

<span class="comment">// Register in DI</span>
services.AddSingleton&lt;<span class="type">IAuditContextProvider</span>, <span class="type">HttpUserContextProvider</span>&gt;();</code></pre>
    </section>

    <section>
      <h2>Engine Metrics</h2>
      <p><code>BLiteMetrics</code> is updated atomically after every write and exposes counters readable without I/O:</p>
      <pre><code><span class="keyword">var</span> metrics = engine.AuditMetrics;
Console.WriteLine(<span class="string">$"Inserts:             {metrics.TotalInserts}"</span>);
Console.WriteLine(<span class="string">$"Index-scan queries:  {metrics.TotalQueriesIndexScan}"</span>);
Console.WriteLine(<span class="string">$"BSON-scan queries:   {metrics.TotalQueriesBsonScan}"</span>);
Console.WriteLine(<span class="string">$"Full-scan queries:   {metrics.TotalQueriesFullScan}"</span>);
Console.WriteLine(<span class="string">$"Commits:             {metrics.TotalCommits}"</span>);</code></pre>
      <p>BLite.Server exposes these via the <code>GET /api/v1/{dbId}/metrics</code> REST endpoint.</p>
    </section>

    <section>
      <h2>OpenTelemetry Spans</h2>
      <p>When an OpenTelemetry <code>ActivitySource</code> listener is attached, BLite emits spans for every engine operation. Use the standard OTLP pipeline:</p>
      <pre><code><span class="comment">// In your OTLP setup</span>
tracerProvider.AddSource(<span class="type">BLiteDiagnostics</span>.ActivitySource.Name);</code></pre>
      <p>BLite.Server is pre-wired to emit spans via <code>TelemetryInterceptor</code> for every gRPC call. Configure the OTLP exporter in <code>appsettings.json</code>:</p>
      <pre><code><span class="string">"Telemetry"</span>: {
  <span class="string">"Enabled"</span>: <span class="keyword">true</span>,
  <span class="string">"ServiceName"</span>: <span class="string">"blite-server"</span>,
  <span class="string">"Otlp"</span>: { <span class="string">"Endpoint"</span>: <span class="string">"http://localhost:4317"</span> }
}</code></pre>
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
</style>
