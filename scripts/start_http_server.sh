#!/usr/bin/env bash
# Start a simple Python HTTP server if not already running.
# Usage: scripts/start_http_server.sh [port] [host] [webroot]

set -euo pipefail

PORT="${1:-8000}"
HOST="${2:-127.0.0.1}"
# default webroot: repo root (one level up from scripts)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEBROOT="${3:-$(cd "$SCRIPT_DIR/.." && pwd)}"
PIDFILE="$WEBROOT/.robot_http_server.pid"
LOGFILE="${WEBROOT}/.robot_http_server.log"

check_server() {
    # prefer curl if available
    if command -v curl >/dev/null 2>&1; then
        curl --silent --fail "http://$HOST:$PORT/" >/dev/null 2>&1 && return 0 || return 1
    else
        # fallback to python check
        python3 - <<PYCODE >/dev/null 2>&1 || true
import sys
try:
    from urllib.request import urlopen
    urlopen('http://%s:%s/' % ('%s','%s'))
    sys.exit(0)
except Exception:
    sys.exit(1)
PYCODE
        return $?
    fi
}

start_server() {
    echo "Starting http.server on $HOST:$PORT serving $WEBROOT"
    (cd "$WEBROOT" && nohup python3 -m http.server "$PORT" --bind "$HOST" >"$LOGFILE" 2>&1 & echo $! > "$PIDFILE")
    sleep 1
}

if check_server; then
    echo "HTTP server is already running at http://$HOST:$PORT/"
    exit 0
fi

# If PID file exists, check if process is alive
if [ -f "$PIDFILE" ]; then
    pid=$(cat "$PIDFILE" 2>/dev/null || true)
    if [ -n "$pid" ] && ps -p "$pid" >/dev/null 2>&1; then
        echo "PID file indicates server running (pid $pid). Waiting briefly and rechecking..."
        sleep 1
        if check_server; then
            echo "HTTP server is now responding."
            exit 0
        else
            echo "PID exists but server not responding. Removing stale PID file."
            rm -f "$PIDFILE"
        fi
    else
        echo "Stale PID file found, removing."
        rm -f "$PIDFILE"
    fi
fi

start_server

if check_server; then
    pid=$(cat "$PIDFILE" 2>/dev/null || echo "")
    echo "Server started (pid: $pid). Logs: $LOGFILE"
    exit 0
else
    echo "Failed to start HTTP server. See $LOGFILE for details." >&2
    exit 2
fi
