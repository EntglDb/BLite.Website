<script setup lang="ts">
import { RouterView, useRoute } from 'vue-router'

const route = useRoute()

const serverSections = [
  { path: '/server/overview', label: 'Overview', icon: '🖥️' },
  { path: '/server/installation', label: 'Installation', icon: '📦' },
  { path: '/server/protocol', label: 'Protocol & API', icon: '🔌' },
  { path: '/server/studio', label: 'Web Studio', icon: '🎨' },
  { path: '/server/clients', label: 'Client SDKs', icon: '📡' },
  { path: '/server/version-matrix', label: 'Version Matrix', icon: '🔗' },
]

const isActive = (path: string) => route.path === path
</script>

<template>
  <div class="docs-layout">
    <aside class="docs-sidebar">
      <div class="sidebar-header">
        <h2>BLite.Server</h2>
        <span class="preview-badge">Preview</span>
      </div>
      <nav class="sidebar-nav">
        <router-link
          v-for="section in serverSections"
          :key="section.path"
          :to="section.path"
          :class="{ active: isActive(section.path) }"
          class="nav-item"
        >
          <span class="nav-icon">{{ section.icon }}</span>
          <span class="nav-label">{{ section.label }}</span>
        </router-link>
      </nav>
    </aside>

    <main class="docs-content">
      <div class="container">
        <RouterView />
      </div>
    </main>
  </div>
</template>

<style scoped>
.docs-layout {
  display: flex;
  min-height: calc(100vh - var(--header-height));
  position: relative;
}

.docs-sidebar {
  width: 280px;
  background: rgba(15, 15, 15, 0.5);
  border-right: 1px solid rgba(231, 76, 60, 0.1);
  position: sticky;
  top: var(--header-height);
  height: calc(100vh - var(--header-height));
  overflow-y: auto;
  padding: 32px 0;
}

.sidebar-header {
  padding: 0 24px 24px;
  border-bottom: 1px solid rgba(231, 76, 60, 0.1);
}

.sidebar-header h2 {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--blite-red);
}

.preview-badge {
  display: inline-block;
  margin-top: 8px;
  padding: 2px 10px;
  font-size: 0.7rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: #f59e0b;
  background: rgba(245, 158, 11, 0.12);
  border: 1px solid rgba(245, 158, 11, 0.3);
  border-radius: 20px;
}

.sidebar-nav {
  padding: 24px 0;
  display: flex;
  flex-direction: column;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 24px;
  color: var(--text-secondary);
  transition: all 0.2s ease;
  border-left: 2px solid transparent;
}

.nav-item:hover {
  background: rgba(231, 76, 60, 0.05);
  color: var(--text-primary);
}

.nav-item.active {
  background: rgba(231, 76, 60, 0.1);
  border-left-color: var(--blite-red);
  color: var(--blite-red);
}

.nav-icon {
  font-size: 1.2rem;
}

.nav-label {
  font-size: 0.95rem;
  font-weight: 500;
}

.docs-content {
  flex: 1;
  padding: 48px 0;
  overflow-y: auto;
  padding-top: calc(var(--header-height) + 48px);
}
</style>
