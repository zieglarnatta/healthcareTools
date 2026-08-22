#!/usr/bin/env bash
set -euo pipefail
# Wrapper to generate pairwise suites and run pabot with sane environment setup.
# Usage: tools/run_pabot.sh [--processes N] [--outputdir DIR] [--limit N] [--dry-run]

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENV_BIN="$ROOT/.venv/bin"
DRIVERS_DIR="$ROOT/drivers"
GEN_SCRIPT="$ROOT/tools/generate_pairwise.py"
GEN_LIMIT=0
PROCESSES=50
OUTPUTDIR="$ROOT/results_generated"
DRY_RUN=0

show_help(){
  cat <<'EOF'
Usage: run_pabot.sh [--processes N] [--outputdir DIR] [--limit N] [--dry-run]

Options:
  --processes N   Number of pabot processes (default 50)
  --outputdir DIR Output directory for pabot results (default: results_generated)
  --limit N       Limit generated suites (passed to generator). 0 = no limit (use allpairspy if available)
  --dry-run       Print commands instead of executing
  --help          Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --processes)
      PROCESSES="$2"; shift 2;;
    --outputdir)
      OUTPUTDIR="$2"; shift 2;;
    --limit)
      GEN_LIMIT="$2"; shift 2;;
    --dry-run)
      DRY_RUN=1; shift;;
    --help)
      show_help; exit 0;;
    *)
      echo "Unknown arg: $1"; show_help; exit 2;;
  esac
done

echo "ROOT: $ROOT"

# Ensure venv bin on path
if [ -d "$VENV_BIN" ]; then
  export PATH="$VENV_BIN:$DRIVERS_DIR:$PATH"
fi

# Compute PYTHONPATH to ensure worker visibility
PY_EXEC=$(command -v "$VENV_BIN/python" 2>/dev/null || command -v python3 || command -v python || true)
if [ -n "$PY_EXEC" ]; then
  SITE_PACKAGES=$($PY_EXEC - <<'PY'
import site, sys
p=''
if hasattr(site,'getsitepackages'):
    try:
        p=site.getsitepackages()[0]
    except Exception:
        p=''
if not p:
    p=next((x for x in sys.path if 'site-packages' in x), '')
print(p)
PY
)
  if [ -n "$SITE_PACKAGES" ]; then
    export PYTHONPATH="$SITE_PACKAGES:$PYTHONPATH"
  fi
fi

GEN_CMD=("$PY_EXEC" "$GEN_SCRIPT")
if [ "$GEN_LIMIT" != "0" ]; then
  GEN_CMD+=("--limit" "$GEN_LIMIT")
fi

PABOT_BIN=""
if [ -x "$VENV_BIN/pabot" ]; then
  PABOT_BIN="$VENV_BIN/pabot"
else
  PABOT_BIN=$(command -v pabot || true)
fi

if [ -z "$PABOT_BIN" ]; then
  echo "Warning: pabot not found in venv or PATH. Please install robotframework-pabot into .venv or PATH." >&2
fi

GEN_STEP_CMD=("mkdir" -p "$ROOT/robotFrameworkTests/tests/generated")
if [ "$DRY_RUN" -eq 1 ]; then
  echo "DRY RUN: ${GEN_CMD[*]}"
  echo "DRY RUN: ${PABOT_BIN} --processes $PROCESSES --outputdir $OUTPUTDIR $ROOT/robotFrameworkTests/tests/generated"
  exit 0
fi

echo "Generating pairwise suites..."
"${GEN_CMD[@]}"

echo "Running pabot with $PROCESSES processes..."
mkdir -p "$OUTPUTDIR"
mkdir -p "$OUTPUTDIR/screenshots"
if [ -n "$PABOT_BIN" ]; then
  "$PABOT_BIN" --processes "$PROCESSES" --outputdir "$OUTPUTDIR" "$ROOT/robotFrameworkTests/tests/generated"
else
  echo "pabot not available; falling back to robot sequential run"
  "$PY_EXEC" -m robot --outputdir "$OUTPUTDIR" "$ROOT/robotFrameworkTests/tests/generated"
fi

echo "Pabot finished; results in: $OUTPUTDIR"
