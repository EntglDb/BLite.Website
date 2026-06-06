<template>
  <div class="doc-page">
    <h1>🔐 <span class="title-gradient">Encryption at Rest</span></h1>
    <p class="lead">AES-256-GCM authenticated encryption for every page written to disk — transparent to your application code.</p>

    <section>
      <h2>Overview</h2>
      <p>BLite 5.0.0 adds first-class encryption at rest via the <code>CryptoOptions</code> API. Every database page is encrypted individually using <strong>AES-256-GCM</strong> before being written to disk and decrypted transparently on read. The nonce (IV) is derived per-page so each write is unique.</p>
      <p>When encryption is enabled the database file is opaque — even with direct filesystem access, data cannot be read without the key.</p>
    </section>

    <section>
      <h2>Quick Start</h2>
      <pre><code><span class="keyword">using</span> <span class="type">BLite.Core</span>;
<span class="keyword">using</span> <span class="type">BLite.Core.Crypto</span>;

<span class="keyword">var</span> key = <span class="type">CryptoOptions</span>.DeriveKey(<span class="string">"my-passphrase"</span>, salt: myStoredSalt);

<span class="keyword">var</span> crypto = <span class="keyword">new</span> <span class="type">CryptoOptions</span> { Key = key };  <span class="comment">// 32-byte AES-256 key</span>
<span class="keyword">using var</span> engine = <span class="keyword">new</span> <span class="type">BLiteEngine</span>(<span class="string">"secure.blite"</span>, crypto);
<span class="keyword">var</span> col = engine.GetOrCreateCollection(<span class="string">"users"</span>);</code></pre>
    </section>

    <section>
      <h2>Key Derivation</h2>
      <p>Use the built-in <code>CryptoOptions.DeriveKey</code> helper to derive a 32-byte key from a passphrase using PBKDF2-HMAC-SHA256:</p>
      <pre><code><span class="comment">// Generate a salt once and persist it alongside the database</span>
<span class="keyword">var</span> salt = <span class="type">CryptoOptions</span>.GenerateSalt();   <span class="comment">// returns byte[32]</span>
<span class="type">File</span>.WriteAllBytes(<span class="string">"secure.salt"</span>, salt);

<span class="comment">// Each subsequent open: read the salt + derive the key</span>
<span class="keyword">var</span> salt = <span class="type">File</span>.ReadAllBytes(<span class="string">"secure.salt"</span>);
<span class="keyword">var</span> key  = <span class="type">CryptoOptions</span>.DeriveKey(<span class="string">"my-passphrase"</span>, salt);</code></pre>
      <div class="doc-callout doc-callout-warning">
        <strong>Never</strong> store the passphrase. Store only the salt. If the passphrase is lost, the database cannot be recovered.
      </div>
    </section>

    <section>
      <h2>Providing a Custom Crypto Provider</h2>
      <p>For HSM or KMS integration, implement <code>IBLiteCryptoProvider</code>:</p>
      <pre><code><span class="keyword">public class</span> <span class="type">AzureKvsCryptoProvider</span> : <span class="type">IBLiteCryptoProvider</span>
{
    <span class="keyword">public</span> <span class="type">Memory</span>&lt;<span class="keyword">byte</span>&gt; Encrypt(<span class="type">ReadOnlySpan</span>&lt;<span class="keyword">byte</span>&gt; plaintext, <span class="keyword">long</span> pageIndex) { <span class="comment">/* ... */</span> }
    <span class="keyword">public</span> <span class="type">Memory</span>&lt;<span class="keyword">byte</span>&gt; Decrypt(<span class="type">ReadOnlySpan</span>&lt;<span class="keyword">byte</span>&gt; ciphertext, <span class="keyword">long</span> pageIndex) { <span class="comment">/* ... */</span> }
}

<span class="keyword">var</span> crypto = <span class="keyword">new</span> <span class="type">CryptoOptions</span> { Provider = <span class="keyword">new</span> <span class="type">AzureKvsCryptoProvider</span>() };
<span class="keyword">using var</span> engine = <span class="keyword">new</span> <span class="type">BLiteEngine</span>(<span class="string">"secure.blite"</span>, crypto);</code></pre>
    </section>

    <section>
      <h2>NullCryptoProvider (testing)</h2>
      <p>For unit tests or environments where encryption is optional, use <code>NullCryptoProvider</code> — a no-op pass-through that conforms to the same interface without performing any encryption:</p>
      <pre><code>Crypto = <span class="keyword">new</span> <span class="type">CryptoOptions</span> { Provider = <span class="type">NullCryptoProvider</span>.Instance }</code></pre>
    </section>

    <section>
      <h2>GDPR Inspection</h2>
      <p>The GDPR <a href="/docs/gdpr">inspection report</a> exposes the <code>IsEncrypted</code> flag for Art. 30 compliance documentation.</p>
    </section>

    <section>
      <h2>Performance Notes</h2>
      <ul>
        <li>AES-256-GCM is hardware-accelerated on all modern CPUs (AES-NI).</li>
        <li>Each page is encrypted independently — random reads incur no extra I/O.</li>
        <li>The GCM authentication tag is stored adjacent to each page for tamper detection.</li>
        <li>Bulk inserts and WAL commits are unaffected in throughput beyond the encryption overhead (~3–5 % on modern hardware).</li>
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
.doc-callout-warning { border-color: #e88a1a; background: rgba(232, 138, 26, 0.08); }
</style>
