# Documentation Update Instructions

This file describes the step-by-step process to keep the BLite documentation
up to date across all three repositories after a release or feature change.

---

## Repositories involved

| Repository | Content | Key files |
|---|---|---|
| `BLite` | Core engine README | `README.md`, `CHANGELOG.md` |
| `BLite.Server` | Server README | `README.md`, `CHANGELOG.md` |
| `BLite.Website` | Documentation website (Vue + Vite SSG) | `package.json`, `src/router/index.ts`, `src/views/docs/`, `src/views/server-docs/` |

---

## Step 1 — Verify current versions

1. Read `BLite/CHANGELOG.md` (first entry) to get the latest BLite engine version.
2. Read `BLite.Server/CHANGELOG.md` (first entry) to get the latest BLite.Server version.
3. Read `BLite.Website/package.json` → `"version"` field.
4. Run `git -C ../BLite tag --list "studio-v*" --sort=-version:refname` and take
   the first result as the **latest Studio version** (e.g. `studio-v3.8.0` → `3.8.0`).
   This tag drives the download URLs in `App.vue` and the badge in `Hero.vue`.
5. Compare all four values and note any mismatch.

**Where versions appear and must stay in sync:**

- `BLite/README.md` — NuGet badge, feature descriptions, version-specific mentions.
- `BLite.Server/README.md` — version references, compatibility notes.
- `BLite.Website/package.json` — `"version"` should track the latest BLite release.
- `BLite.Website/src/views/docs/Installation.vue` — NuGet install commands, version callouts.
- `BLite.Website/src/views/docs/GettingStarted.vue` — version mentions in quickstart.
- `BLite.Website/src/views/server-docs/Overview.vue` — server version, engine compatibility.
- `BLite.Website/src/views/server-docs/VersionMatrix.vue` — full compatibility table.
- `BLite.Website/src/views/server-docs/ServerInstallation.vue` — Docker tags, download links.
- `BLite.Website/src/components/Hero.vue` — `badge` text in the hero section (version + release summary).
- `BLite.Website/src/App.vue` — footer download links title and all 6 download URLs (MSI, Portable, .deb, tar.gz, macOS arm64, macOS x64). The URL pattern is `https://github.com/EntglDb/BLite/releases/download/studio-vX.Y.Z/BLite.Studio-X.Y.Z-<platform>.<ext>`. Use the **Studio tag version** (step 1.4) as `X.Y.Z` — it may differ from the engine version if a Studio release was cut independently.

> **Action:** Update all version references to match the latest released versions.

---

## Step 2 — Review CHANGELOGs for new features

1. Open `BLite/CHANGELOG.md` and collect all **Features** entries since the last
   documentation update.
2. Do the same for `BLite.Server/CHANGELOG.md`.
3. For each new feature, determine:
   - Does the existing documentation already cover it? → Update the relevant page.
   - Is it significant enough to need a **new dedicated page**? → Go to Step 4.
   - Is it a minor improvement? → Mention it in the relevant existing page.

### 2a. Inspect source code when CHANGELOG entries are unclear

CHANGELOG entries are often terse (e.g., "Add session APIs" or "non-blocking
checkpoints"). When a feature's scope, public API surface, or behavior is not
obvious from the CHANGELOG alone:

1. **Follow the commit hash** — Each CHANGELOG entry links to a commit. Use
   `git show <hash> --stat` to see which files were touched.
2. **Read the relevant source files** — Focus on:
   - New or changed **public types, methods, and properties** (look for `public`
     declarations in `BLite/src/` or `BLite.Server/src/`).
   - New **Protobuf definitions** (`BLite.Proto/`) for gRPC-level changes.
   - New or modified **REST endpoints** (`BLite.Server/src/BLite.Server/Rest/`).
   - New **Blazor pages or components** (`BLite.Server/src/BLite.Server/Components/`).
3. **Check tests** — Unit/integration tests often show usage examples and edge
   cases that must be reflected in the documentation. Look in `BLite/tests/` and
   `BLite.Server/tests/`.
4. **Check `AGENTS.md`** — The server repo's `AGENTS.md` is kept in sync with the
   architecture; cross-reference it for naming, invariants, and design decisions.

> **Goal:** Understand the exact public API and behavior before writing or
> updating documentation. Never document a feature based solely on the CHANGELOG
> summary — always verify against the source.

---

## Step 3 — Verify existing documentation is still accurate

For each documentation page, verify that the content reflects the current codebase.

### BLite embedded docs (`src/views/docs/`)

| Page | What to check |
|---|---|
| `GettingStarted.vue` | Install commands, minimal example, API surface |
| `Installation.vue` | NuGet package names, target frameworks, version |
| `Transactions.vue` | Transaction API (`BeginTransaction`, `SaveChanges`, session APIs) |
| `CRUD.vue` | Insert/Update/Delete/FindById signatures |
| `Querying.vue` | LINQ operators, index usage, async streaming |
| `Generators.vue` | Source generator attributes, supported types |
| `CDC.vue` | Change stream API, event types |
| `Spatial.vue` | R-Tree API, query syntax |
| `Architecture.vue` | Engine internals, page layout, WAL protocol |
| `Converters.vue` | Custom converter and HasConversion APIs |
| `Benchmarks.vue` | Benchmark numbers, comparison methodology |
| `DynamicAPI.vue` | BLiteEngine / DynamicCollection API |
| `BLQL.vue` | BLQL operators, filter syntax, fluent API |
| `TimeSeries.vue` | TimeSeries page type, retention, append API |
| `KvStore.vue` | IBLiteKvStore API, TTL, batch, prefix scan |
| `Comparisons.vue` | Feature matrix vs LiteDB / SQLite |

### BLite.Server docs (`src/views/server-docs/`)

| Page | What to check |
|---|---|
| `Overview.vue` | Architecture diagram, endpoint table, feature list |
| `ServerInstallation.vue` | Docker image, Windows/Linux install, port config |
| `Protocol.vue` | gRPC services, REST endpoints, auth model, BLQL over REST |
| `ServerStudio.vue` | Studio screenshots, feature description, auth flow |
| `Clients.vue` | SDK install commands, feature matrix, code samples |
| `VersionMatrix.vue` | Engine ↔ Server ↔ Client SDK compatibility table |

### README files

| File | What to check |
|---|---|
| `BLite/README.md` | Feature list, badges, code samples, version, target frameworks |
| `BLite.Server/README.md` | Architecture diagram, endpoints table, feature list, version |

> **Action:** For each page, read the source code of the relevant feature and
> compare it against the documentation. Fix any outdated API signatures, removed
> parameters, renamed types, or missing capabilities.

---

## Step 4 — Add new documentation pages (if needed)

When a new feature requires a dedicated page:

### 4a. Create the Vue component

1. Create a new `.vue` file in the appropriate directory:
   - BLite feature → `src/views/docs/MyFeature.vue`
   - Server feature → `src/views/server-docs/MyFeature.vue`
2. Follow the same structure as existing pages (template with sections, code
   samples, API reference).

### 4b. Register the route

1. Open `src/router/index.ts`.
2. Import the new component at the top of the file.
3. Add a child route under the `/docs` or `/server` parent with:
   - `path` — URL slug (kebab-case).
   - `component` — the imported component.
   - `meta.title` — SEO title (include "BLite" and a concise description).
   - `meta.description` — SEO description (150–160 chars, keyword-rich).

### 4c. Add sidebar navigation

1. Open the parent layout component (`Docs.vue` or `ServerDocs.vue`).
2. Add a `<router-link>` entry in the sidebar navigation list, in logical order.

### 4d. Cross-link

- Link to the new page from the relevant existing pages.
- If the feature was mentioned in the README, link to the docs page from there.

---

## Step 5 — Update `package.json` version

Bump the `"version"` field in `BLite.Website/package.json` to match the latest
BLite engine version (e.g., `"3.8.0"`). This keeps the website version aligned
with the engine it documents.

---

## Step 6 — Build and verify

```bash
cd BLite.Website
npm run build
npm run preview
```

1. Navigate through every documentation page and verify rendering.
2. Check that all code samples are syntax-highlighted and accurate.
3. Verify that internal links between pages work.
4. Spot-check SEO meta tags in the page source.

---

## Checklist summary

- [ ] Version numbers are consistent across all READMEs and the website
- [ ] Studio tag checked (`git tag --list "studio-v*"`) and download URLs updated accordingly
- [ ] Hero badge in `Hero.vue` updated with new version and release summary
- [ ] Footer download links in `App.vue` updated (title + all 6 URLs)
- [ ] CHANGELOG features are reflected in the documentation
- [ ] Existing pages are accurate with the current API
- [ ] New pages are created for significant new features
- [ ] Routes and sidebar links are added for new pages
- [ ] `package.json` version is bumped
- [ ] Website builds without errors
- [ ] Version matrix page is up to date
