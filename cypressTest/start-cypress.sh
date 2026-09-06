#!/usr/bin/env bash
set -eu

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PORT="${PORT:-8000}"
BASE_URL="${BASE_URL:-http://localhost:${PORT}}"
SPEC="${SPEC:-}"

check_server() {
  curl -fsS "${BASE_URL}/MDS_activity_note.html" >/dev/null 2>&1 || \
  curl -fsS "${BASE_URL}/MDS_html.html" >/dev/null 2>&1
}

if check_server; then
  echo "Local web server already responding at ${BASE_URL}"
else
  echo "No local web server detected at ${BASE_URL}; starting python3 -m http.server ${PORT} from ${ROOT_DIR}"
  (cd "${ROOT_DIR}" && python3 -m http.server "${PORT}" >/tmp/healthcare_http.log 2>&1 &) || {
    echo "Failed to start the Python HTTP server."
    exit 1
  }

  for _ in $(seq 1 30); do
    if check_server; then
      echo "Server is ready at ${BASE_URL}"
      break
    fi
    sleep 1
  done

  if ! check_server; then
    echo "The local web server did not become ready on ${BASE_URL}."
    exit 1
  fi
fi

cd "${ROOT_DIR}/cypressTest"
if [ -n "${SPEC}" ]; then
  echo "Running Cypress with spec: ${SPEC}"
  npx cypress run --config "baseUrl=${BASE_URL}" --spec "${SPEC}"
else
  npx cypress run --config "baseUrl=${BASE_URL}"
fi
