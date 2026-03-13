<template>
  <div class="doc-page">
    <h1>📦 <span class="title-gradient">Installation</span></h1>
    <p class="lead">BLite.Server ships as a Docker image, a Windows installer, and a Linux binary. Pick the option that fits your environment.</p>

    <section>
      <h2>Docker (Recommended)</h2>
      <p>The fastest way to get started. Pull and run the official image:</p>
      <pre><code>docker pull ghcr.io/entgldb/blite-server:latest

docker run -d \
  --name blite \
  -p 2626:2626 \
  -p 2627:2627 \
  -p 2628:2628 \
  -v ./blite-data:/app/data \
  ghcr.io/entgldb/blite-server:latest</code></pre>
      <p>Then open the first-run setup wizard in your browser:</p>
      <pre><code>https://localhost:2628/setup</code></pre>
      <div class="info-box">
        <strong>📁 Persistent data:</strong> Always mount a host volume to <code>/app/data</code>.
        Without it, all databases and configuration are lost when the container stops.
      </div>

      <h3>Docker Compose</h3>
      <pre><code><span class="keyword">services</span>:
  <span class="type">blite</span>:
    <span class="keyword">image</span>: <span class="string">ghcr.io/entgldb/blite-server:latest</span>
    <span class="keyword">restart</span>: <span class="string">unless-stopped</span>
    <span class="keyword">ports</span>:
      - <span class="string">"2626:2626"</span>   <span class="comment"># gRPC</span>
      - <span class="string">"2627:2627"</span>   <span class="comment"># REST</span>
      - <span class="string">"2628:2628"</span>   <span class="comment"># Studio</span>
    <span class="keyword">volumes</span>:
      - <span class="string">./blite-data:/app/data</span>
    <span class="keyword">environment</span>:
      - <span class="string">Studio__Enabled=true</span></code></pre>
    </section>

    <section>
      <h2>Windows Installer</h2>
      <p>
        The Windows package is an Inno Setup installer that registers BLite.Server as
        a Windows Service, installs the binary under <code>Program Files\BLite</code>,
        and adds a firewall exception for ports <code>2626</code>–<code>2628</code>.
      </p>
      <p>Download from the GitHub releases page:</p>
      <pre><code>https://github.com/EntglDb/BLite.Server/releases/latest</code></pre>
      <p>
        After installation the service is started automatically.
        Open the Studio at <code>https://localhost:2628/setup</code> to create the root user.
      </p>
      <div class="info-box">
        <strong>🔒 TLS:</strong> The installer generates a self-signed certificate on first run.
        Replace <code>%ProgramData%\BLite\server.pfx</code> with your own certificate to enable
        trusted HTTPS.
      </div>
    </section>

    <section>
      <h2>Linux (systemd)</h2>
      <p>Download the prebuilt binary and set up a systemd unit:</p>
      <pre><code><span class="comment"># Download and extract</span>
wget https://github.com/EntglDb/BLite.Server/releases/latest/download/blite-server-linux-x64.tar.gz
tar -xzf blite-server-linux-x64.tar.gz -C /opt/blite

<span class="comment"># Create data directory</span>
mkdir -p /var/lib/blite/data

<span class="comment"># Copy service unit</span>
cp /opt/blite/blite-server.service /etc/systemd/system/

<span class="comment"># Enable and start</span>
systemctl daemon-reload
systemctl enable --now blite-server</code></pre>

      <h3>Service Unit (blite-server.service)</h3>
      <pre><code>[<span class="type">Unit</span>]
<span class="keyword">Description</span>=BLite Server
<span class="keyword">After</span>=network.target

[<span class="type">Service</span>]
<span class="keyword">Type</span>=notify
<span class="keyword">WorkingDirectory</span>=<span class="string">/opt/blite</span>
<span class="keyword">ExecStart</span>=<span class="string">/opt/blite/BLite.Server</span>
<span class="keyword">Restart</span>=always
<span class="keyword">User</span>=blite
<span class="keyword">Environment</span>=<span class="string">ASPNETCORE_ENVIRONMENT=Production</span>
<span class="keyword">Environment</span>=<span class="string">BLiteServer__DatabasePath=/var/lib/blite/blite.db</span>
<span class="keyword">Environment</span>=<span class="string">BLiteServer__DatabasesDirectory=/var/lib/blite/data</span>

[<span class="type">Install</span>]
<span class="keyword">WantedBy</span>=multi-user.target</code></pre>
    </section>

    <section>
      <h2>Configuration (appsettings.json)</h2>
      <p>All settings live in <code>appsettings.json</code> next to the binary (or via environment variables):</p>
      <pre><code>{
  <span class="keyword">"BLiteServer"</span>: {
    <span class="keyword">"DatabasePath"</span>:      <span class="string">"blite.db"</span>,          <span class="comment">// system database file path</span>
    <span class="keyword">"MaxPageSizeBytes"</span>:  <span class="number">16384</span>,              <span class="comment">// BLiteEngine page size</span>
    <span class="keyword">"DatabasesDirectory"</span>: <span class="string">"data/tenants"</span>    <span class="comment">// tenant .db files</span>
  },
  <span class="keyword">"Studio"</span>: {
    <span class="keyword">"Enabled"</span>: <span class="string">true</span>                       <span class="comment">// enable Blazor Studio (off by default in Docker)</span>
  },
  <span class="keyword">"Kestrel"</span>: {
    <span class="keyword">"Endpoints"</span>: {
      <span class="keyword">"Grpc"</span>:   { <span class="keyword">"Url"</span>: <span class="string">"https://*:2626"</span>, <span class="keyword">"Protocols"</span>: <span class="string">"Http2"</span> },
      <span class="keyword">"Rest"</span>:   { <span class="keyword">"Url"</span>: <span class="string">"https://*:2627"</span>, <span class="keyword">"Protocols"</span>: <span class="string">"Http1AndHttp2"</span> },
      <span class="keyword">"Studio"</span>: { <span class="keyword">"Url"</span>: <span class="string">"https://*:2628"</span>, <span class="keyword">"Protocols"</span>: <span class="string">"Http1AndHttp2"</span> }
    }
  },
  <span class="keyword">"Transactions"</span>: {
    <span class="keyword">"TimeoutSeconds"</span>: <span class="number">60</span>
  }
}</code></pre>

      <h3>Environment Variable Override</h3>
      <p>Any setting can be overridden via environment variables using <code>__</code> as the section separator:</p>
      <pre><code><span class="comment"># Examples</span>
BLiteServer__DatabasePath=<span class="string">/data/system.db</span>
Studio__Enabled=<span class="string">true</span>
Transactions__TimeoutSeconds=<span class="string">120</span></code></pre>
    </section>

    <section>
      <h2>First Run</h2>
      <p>On the very first start, no users exist yet. Navigate to the Studio setup wizard to create the root user:</p>
      <pre><code>https://localhost:2628/setup</code></pre>
      <p>Create the root admin API key. <strong>Store the plaintext key immediately</strong> — it cannot be recovered after the setup screen is closed. All subsequent requests require this key (or a key created for a sub-user).</p>

      <div class="info-box">
        <strong>🛡 Dev Mode:</strong> Until setup is complete, the server operates in Dev Mode —
        all requests are authenticated as a synthetic root user. Dev Mode ends permanently
        once the first real user is saved.
      </div>
    </section>

    <section>
      <h2>Next Steps</h2>
      <router-link to="/server/protocol" class="cta-button">Protocol &amp; API →</router-link>
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

.cta-button {
  display: inline-block;
  padding: 12px 32px;
  background: var(--blite-red);
  color: white;
  font-weight: 600;
  border-radius: 8px;
  transition: all 0.2s ease;
}

.cta-button:hover {
  background: var(--blite-red-glow);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(231, 76, 60, 0.3);
}
</style>
