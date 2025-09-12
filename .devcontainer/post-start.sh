#!/bin/bash
set -euo pipefail

echo "🕰️ Building demo containers. This may take a second."
docker compose build

# Mayhem auto-login if secret provided
if [ -n "${MAYHEM_API_KEY:-}" ]; then
  echo "🔐 mayhem login via MAYHEM_API_KEY"
    mayhem login https://app.mayhem.security "$MAYHEM_API_KEY" || true

else
  echo "🔐 mayhem: no MAYHEM_API_KEY set; run \"mayhem login\" once in this codespace"
fi
