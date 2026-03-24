#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./launch.sh -c <num_clients> -r <num_replicas>

Options:
  -c    Number of clients to start (starting at client id 1)
  -r    Number of replicas (total nodes)
  -h    Show this help message
USAGE
}

is_positive_int() {
  [[ "$1" =~ ^[1-9][0-9]*$ ]]
}

CLIENTS=""
REPLICAS=""

while getopts ":c:r:h" opt; do
  case "$opt" in
    c) CLIENTS="$OPTARG" ;;
    r) REPLICAS="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) echo "Missing value for -$OPTARG" >&2; usage; exit 1 ;;
    \?) echo "Invalid option: -$OPTARG" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$CLIENTS" || -z "$REPLICAS" ]]; then
  echo "Both -c and -r are required." >&2
  usage
  exit 1
fi

if ! is_positive_int "$CLIENTS"; then
  echo "Invalid client count: $CLIENTS" >&2; exit 1
fi

if ! is_positive_int "$REPLICAS"; then
  echo "Invalid replica count: $REPLICAS" >&2; exit 1
fi

F=$(( (REPLICAS - 1) / 3 ))
K=$(( REPLICAS - F ))

echo "HotStuff params: r=$REPLICAS, f=$F, k=$K"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$PROJECT_DIR/config"

if [[ ! -d "$CONFIG_DIR" ]]; then
  echo "Config directory not found at: $CONFIG_DIR" >&2; exit 1
fi

if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl was not found in PATH." >&2; exit 1
fi

if ! command -v mvn >/dev/null 2>&1; then
  echo "Maven (mvn) was not found in PATH." >&2; exit 1
fi

# --- RSA keys ---
generate_keypair() {
  local priv="$1" pub="$2"
  echo "  Generating keys: $priv ..."
  openssl genpkey -algorithm RSA -out "$priv" -pkeyopt rsa_keygen_bits:2048 2>/dev/null
  openssl rsa -pubout -in "$priv" -out "$pub" 2>/dev/null
}

echo "Checking RSA keys..."

for ((i = 1; i <= REPLICAS; i++)); do
  priv="$CONFIG_DIR/node$i.priv"
  pub="$CONFIG_DIR/node$i.pub"
  if [[ ! -f "$priv" || ! -f "$pub" ]]; then
    generate_keypair "$priv" "$pub"
  fi
done

for ((i = 1; i <= CLIENTS; i++)); do
  priv="$CONFIG_DIR/client$i.priv"
  pub="$CONFIG_DIR/client$i.pub"
  if [[ ! -f "$priv" || ! -f "$pub" ]]; then
    generate_keypair "$priv" "$pub"
  fi
done

echo "All RSA keys ready."

# --- Threshold keys ---
shares_exist=true
for ((i = 1; i <= REPLICAS; i++)); do
  if [[ ! -f "$CONFIG_DIR/node$i.share.json" ]]; then
    shares_exist=false
    break
  fi
done

if [[ ! -f "$CONFIG_DIR/groupKey.json" || "$shares_exist" == false ]]; then
  echo "Generating threshold keys (k=$K, l=$REPLICAS)..."
  pushd "$PROJECT_DIR/crypto" >/dev/null
  mvn exec:java "-Dexec.mainClass=pt.depchain.crypto.ThresholdKeyGenerator" "-Dexec.args=$K $REPLICAS"
  popd >/dev/null
  echo "Threshold keys ready."
else
  echo "Threshold keys already exist, skipping."
fi

# --- Port checking ---
is_port_in_use() {
  local port="$1"
  (echo >/dev/tcp/localhost/$port) 2>/dev/null && return 0 || return 1
}

get_free_port() {
  local port="$1"
  while is_port_in_use "$port"; do
    echo "  Port $port is in use, trying $((port + 1))..."
    port=$(( port + 1 ))
  done
  echo "$port"
}

# --- Generate membership.json ---
echo "Allocating ports for membership.json..."

node_base=9001
client_base=4001

nodes_json=""
next_node_port=$node_base
for ((i = 1; i <= REPLICAS; i++)); do
  port=$(get_free_port "$next_node_port")
  entry="{\"id\":\"$i\",\"host\":\"localhost\",\"port\":$port,\"pub\":\"node$i.pub\"}"
  nodes_json="${nodes_json:+$nodes_json,}$entry"
  next_node_port=$(( port + 1 ))
done

clients_json=""
next_client_port=$client_base
for ((i = 1; i <= CLIENTS; i++)); do
  port=$(get_free_port "$next_client_port")
  entry="{\"id\":\"client$i\",\"host\":\"localhost\",\"port\":$port,\"pub\":\"client$i.pub\"}"
  clients_json="${clients_json:+$clients_json,}$entry"
  next_client_port=$(( port + 1 ))
done

cat > "$CONFIG_DIR/membership.json" <<JSON
[{"clients":[$clients_json],"nodes":[$nodes_json]}]
JSON

echo "membership.json generated."

# --- Launch windows ---
start_window() {
  local title="$1"
  local command="$2"

  if command -v gnome-terminal >/dev/null 2>&1; then
    gnome-terminal --title="$title" -- bash -lc "cd '$PROJECT_DIR'; $command; exec bash" &
  elif command -v xterm >/dev/null 2>&1; then
    xterm -title "$title" -e bash -lc "cd '$PROJECT_DIR'; $command; exec bash" &
  elif command -v x-terminal-emulator >/dev/null 2>&1; then
    x-terminal-emulator -e bash -lc "cd '$PROJECT_DIR'; $command; exec bash" &
  else
    echo "No supported terminal emulator found." >&2; exit 1
  fi
}

echo "Starting $REPLICAS replicas and $CLIENTS clients..."

for ((i = 1; i <= REPLICAS; i++)); do
  start_window \
    "Replica $i" \
    "cd '$PROJECT_DIR/service'; mvn exec:java '-Dexec.mainClass=pt.depchain.service.Node' '-Dexec.args=$i ../config/node$i.priv ../config/node$i.pub'"
done

sleep 1

for ((i = 1; i <= CLIENTS; i++)); do
  start_window \
    "Client $i" \
    "cd '$PROJECT_DIR/client'; mvn exec:java '-Dexec.mainClass=pt.depchain.client.ClientMain' '-Dexec.args=client$i ../config/client$i.priv ../config/client$i.pub'"
done

echo "All processes launched."
