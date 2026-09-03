#!/usr/bin/env bash
# Pubblica il sito di documentazione BLite (Vue + Vite SSG) sul suo dominio di
# PRODUZIONE, sullo stesso server Plesk usato per i siti in ~/Documents/GitHub/WebSites.
#
# Il dominio deve GIÀ esistere come subscription su Plesk: questo script non lo crea
# (creare una subscription è un'operazione di hosting/fatturazione a parte, da fare
# a mano su Plesk prima di lanciare questo script).
#
# NB: nessuna conferma interattiva — sovrascrive subito il sito pubblico via
# rsync --delete. Lanciarlo solo quando l'utente lo chiede esplicitamente.
#
# Uso:
#   deploy/publish-prod.sh [dominio-produzione]
#
# Esempio:
#   deploy/publish-prod.sh                # usa il default blitedb.com
#   deploy/publish-prod.sh blitedb.com
#
# Richiede: deploy/.env compilato (vedi deploy/.env.example), accesso SSH root/admin
# al server Plesk, rsync installato sia in locale che sul server.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

DOMAIN="${1:-blitedb.com}"

# --- Carica configurazione ---
ENV_FILE="$SCRIPT_DIR/.env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "Errore: manca $ENV_FILE. Copia deploy/.env.example in deploy/.env e compilalo." >&2
  exit 1
fi
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

: "${PLESK_SSH_HOST:?Variabile PLESK_SSH_HOST mancante in deploy/.env}"
: "${PLESK_SSH_USER:=root}"
: "${PLESK_SSH_PORT:=22}"

SSH_OPTS=(-p "$PLESK_SSH_PORT" -o StrictHostKeyChecking=accept-new)
if [[ -n "${PLESK_SSH_KEY:-}" ]]; then
  SSH_OPTS+=(-i "$PLESK_SSH_KEY")
fi

SSH_TARGET="$PLESK_SSH_USER@$PLESK_SSH_HOST"

echo "==> Progetto:  BLite.Website"
echo "==> Dominio:   https://$DOMAIN  (PRODUZIONE)"
echo "==> Server:    $SSH_TARGET:$PLESK_SSH_PORT"
echo

# --- 1. Verifica che il dominio esista già come subscription su Plesk ---
echo "==> Verifico che '$DOMAIN' esista come subscription su Plesk..."
DOMAIN_INFO=$(ssh "${SSH_OPTS[@]}" "$SSH_TARGET" "plesk bin domain --info '$DOMAIN' 2>&1") || {
  echo "Errore: dominio '$DOMAIN' non trovato su Plesk." >&2
  echo "Questo script non crea subscription nuove: va creata a mano su Plesk prima." >&2
  exit 1
}

WWW_ROOT=$(echo "$DOMAIN_INFO" | grep -i "WWW.Root" | sed -E 's/.*WWW.Root-*:[[:space:]]*//')
if [[ -z "$WWW_ROOT" ]]; then
  echo "Errore: non sono riuscito a determinare il WWW Root da 'plesk bin domain --info'." >&2
  exit 1
fi
echo "    WWW Root: $WWW_ROOT"

# --- 2. Build statico (vue-tsc + vite-ssg) ---
echo "==> Build (npm run build)..."
if [[ ! -d "$REPO_ROOT/node_modules" ]]; then
  echo "    node_modules assente, eseguo npm install..."
  (cd "$REPO_ROOT" && npm install)
fi
(cd "$REPO_ROOT" && npm run build)

OUTPUT_DIR="$REPO_ROOT/dist"
if [[ ! -d "$OUTPUT_DIR" ]]; then
  echo "Errore: '$OUTPUT_DIR' non esiste dopo la build. Controlla l'output di 'npm run build'." >&2
  exit 1
fi

# --- 3. Upload via rsync ---
echo "==> Carico i file (rsync)..."
RSYNC_SSH="ssh ${SSH_OPTS[*]}"
rsync -avz --delete \
  -e "$RSYNC_SSH" \
  "$OUTPUT_DIR"/ "$SSH_TARGET:$WWW_ROOT"/

# --- 4. Sistema i permessi (best effort) ---
echo "==> Sistemo i permessi del document root..."
ssh "${SSH_OPTS[@]}" "$SSH_TARGET" \
  "SYS_USER=\$(plesk bin domain --info '$DOMAIN' | grep -i 'FTP Login' | sed -E 's/.*FTP Login[[:space:]]*:[[:space:]]*//'); \
   if [[ -n \"\$SYS_USER\" ]]; then chown -R \"\$SYS_USER\":psacln '$WWW_ROOT' 2>/dev/null || true; fi" \
  || echo "    (non bloccante: verifica manualmente i permessi se il sito non si vede)"

echo
echo "✔ Pubblicato in produzione: https://$DOMAIN"
