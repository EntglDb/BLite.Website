<script setup lang="ts">
import { ref, watch } from 'vue'
import { RouterView, useRoute } from 'vue-router'
import { useHead } from '@unhead/vue'
import { DEFAULT_TITLE, DEFAULT_DESC } from './router'

const route = useRoute()
const BASE_URL = 'https://blitedb.com'
const mobileMenuOpen = ref(false)

watch(() => route.path, () => { mobileMenuOpen.value = false })

// useHead is reactive: vite-ssg bakes the correct title/description into the
// static HTML for each route at build time; on the client it stays reactive.
useHead(() => {
  const meta = route.meta as { title?: string; description?: string }
  const title = meta.title ?? DEFAULT_TITLE
  const description = meta.description ?? DEFAULT_DESC
  const url = `${BASE_URL}${route.path}`
  return {
    title,
    meta: [
      { name: 'description', content: description },
      { property: 'og:title', content: title },
      { property: 'og:description', content: description },
      { property: 'og:url', content: url },
      { name: 'twitter:title', content: title },
      { name: 'twitter:description', content: description },
    ],
    link: [
      { rel: 'canonical', href: url },
    ],
  }
})
</script>

<template>
  <div class="app-layout">
    <header class="main-header glass-panel">
      <div class="container header-content">
        <router-link to="/" class="logo-link">
          <img src="/icon.svg" alt="BLite" class="logo-img" />
          <div class="logo-text">BLite<span class="dot">.</span></div>
        </router-link>
        <nav class="desktop-nav">
          <router-link to="/">Home</router-link>
          <router-link to="/docs">Docs</router-link>
          <router-link to="/server">Server</router-link>
          <router-link to="/studio">Studio</router-link>
          <router-link to="/comparisons">Comparisons</router-link>
          <a href="https://github.com/EntglDb/BLite" target="_blank" class="github-link">GitHub ↗</a>
        </nav>
        <button class="hamburger" :class="{ open: mobileMenuOpen }" @click="mobileMenuOpen = !mobileMenuOpen" aria-label="Toggle navigation">
          <span></span><span></span><span></span>
        </button>
      </div>
    </header>

    <div class="mobile-nav" :class="{ open: mobileMenuOpen }">
      <nav>
        <router-link to="/">Home</router-link>
        <router-link to="/docs">Docs</router-link>
        <router-link to="/server">Server</router-link>
        <router-link to="/studio">Studio</router-link>
        <router-link to="/comparisons">Comparisons</router-link>
        <a href="https://github.com/EntglDb/BLite" target="_blank" class="github-link">GitHub ↗</a>
      </nav>
    </div>
    <div v-if="mobileMenuOpen" class="mobile-nav-overlay" @click="mobileMenuOpen = false"></div>

    <main>
      <RouterView v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </RouterView>
    </main>

    <footer class="main-footer">
      <div class="container footer-inner">
        <div class="footer-col">
          <p>© 2026 BLite Project. Open Source (MIT).</p>
          <p class="tagline">"Sky is Blite, no Clouds today."</p>
        </div>
        <div class="footer-col footer-downloads">
          <p class="footer-dl-title">⬇ Download BLite Studio v5.1.0</p>
          <div class="footer-dl-links">
            <a href="https://github.com/EntglDb/BLite/releases/download/studio-v5.1.0/BLite.Studio-5.1.0-win-x64.msi">🧻 Windows MSI</a>
            <a href="https://github.com/EntglDb/BLite/releases/download/studio-v5.1.0/BLite.Studio-5.1.0-win-x64-portable.zip">🧻 Windows Portable</a>
            <a href="https://github.com/EntglDb/BLite/releases/download/studio-v5.1.0/blite-studio_5.1.0_amd64.deb">🐧 Linux .deb</a>
            <a href="https://github.com/EntglDb/BLite/releases/download/studio-v5.1.0/BLite.Studio-5.1.0-linux-x64.tar.gz">🐧 Linux tar.gz</a>
            <a href="https://github.com/EntglDb/BLite/releases/download/studio-v5.1.0/BLite.Studio-5.1.0-osx-arm64.dmg">🍎 macOS Apple Silicon</a>
            <a href="https://github.com/EntglDb/BLite/releases/download/studio-v5.1.0/BLite.Studio-5.1.0-osx-x64.dmg">🍎 macOS Intel</a>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>

<style scoped>
.app-layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.main-header {
  position: fixed;
  top: 0;
  width: 100%;
  height: var(--header-height);
  z-index: 100;
  border-bottom: 1px solid rgba(231, 76, 60, 0.1);
  backdrop-filter: blur(12px);
  background: rgba(15, 15, 15, 0.8);
}

.header-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 100%;
}

.logo-link {
  display: flex;
  align-items: center;
  gap: 12px;
  text-decoration: none;
  transition: opacity 0.2s;
}

.logo-link:hover {
  opacity: 0.8;
}

.logo-img {
  width: 36px;
  height: 36px;
  object-fit: contain;
}

.logo-text {
  font-family: var(--font-mono);
  font-weight: 700;
  font-size: 1.3rem;
  letter-spacing: -0.5px;
  color: var(--text-primary);
}

.logo-text .dot {
  color: var(--blite-red);
}

nav {
  display: flex;
  gap: 32px;
}

nav a {
  font-size: 0.95rem;
  font-weight: 500;
  color: var(--text-secondary);
}

nav a:hover, nav a.router-link-active {
  color: var(--text-primary);
}

.github-link {
  color: var(--blite-red) !important;
  font-weight: 600 !important;
}

/* ── Hamburger ──────────────────────────────────────── */
.hamburger {
  display: none;
  flex-direction: column;
  justify-content: center;
  gap: 5px;
  width: 40px;
  height: 40px;
  padding: 6px;
  background: transparent;
  border: none;
  cursor: pointer;
}

.hamburger span {
  display: block;
  height: 2px;
  background: var(--text-primary);
  border-radius: 2px;
  transition: all 0.25s ease;
  transform-origin: center;
}

.hamburger.open span:nth-child(1) { transform: translateY(7px) rotate(45deg); }
.hamburger.open span:nth-child(2) { opacity: 0; transform: scaleX(0); }
.hamburger.open span:nth-child(3) { transform: translateY(-7px) rotate(-45deg); }

/* ── Mobile nav drawer ──────────────────────────────── */
.mobile-nav {
  display: none;
  position: fixed;
  top: var(--header-height);
  left: 0;
  width: 100%;
  background: rgba(15, 15, 15, 0.97);
  border-bottom: 1px solid rgba(231, 76, 60, 0.15);
  z-index: 99;
  transform: translateY(-100%);
  opacity: 0;
  transition: transform 0.3s ease, opacity 0.3s ease;
  backdrop-filter: blur(12px);
}

.mobile-nav.open {
  transform: translateY(0);
  opacity: 1;
}

.mobile-nav nav {
  flex-direction: column;
  gap: 0;
  padding: 8px 0 16px;
}

.mobile-nav nav a {
  display: block;
  padding: 14px 24px;
  font-size: 1rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.04);
}

.mobile-nav-overlay {
  position: fixed;
  inset: 0;
  top: var(--header-height);
  z-index: 98;
  background: transparent;
}

main {
  padding-top: var(--header-height);
  flex: 1;
}

.main-footer {
  border-top: 1px solid var(--border-color);
  padding: 40px 0;
  margin-top: 80px;
  color: var(--text-muted);
  font-size: 0.9rem;
}

.footer-inner {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 40px;
  flex-wrap: wrap;
}

.footer-col { display: flex; flex-direction: column; gap: 6px; }

.main-footer .tagline {
  margin-top: 4px;
  color: var(--blite-red);
  font-style: italic;
  font-size: 0.85rem;
}

.footer-dl-title {
  font-weight: 600;
  color: var(--text-secondary);
  margin-bottom: 8px;
}

.footer-dl-links {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.footer-dl-links a {
  color: var(--text-muted);
  font-size: 0.85rem;
  text-decoration: none;
  transition: color 0.2s;
}

.footer-dl-links a:hover {
  color: var(--blite-red);
}

/* ── Responsive ─────────────────────────────────────── */
@media (max-width: 768px) {
  .desktop-nav { display: none; }
  .hamburger { display: flex; }
  .mobile-nav { display: block; }

  .footer-inner {
    flex-direction: column;
    gap: 24px;
  }

  .footer-dl-links {
    flex-direction: column;
    gap: 8px;
  }
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
