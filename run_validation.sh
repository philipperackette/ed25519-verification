#!/usr/bin/env bash
# run_validation.sh — Automated build, run, and hash collection for Ed25519 verification.
#
# Usage:
#   bash run_validation.sh
#
# This script compiles the source, runs the full verification (including Schoof),
# and collects all artifacts into a timestamped output directory suitable for
# independent publication and PGP signing.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$ROOT_DIR/ed25519_verify.cpp"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="$ROOT_DIR/validation_output_${STAMP}"
BIN="$OUT_DIR/ed25519_verify"
SYSTEM_INFO="$OUT_DIR/system_info.txt"
BUILD_LOG="$OUT_DIR/build.log"
RUN_LOG="$OUT_DIR/verification.log"
HASHES="$OUT_DIR/hashes.txt"

mkdir -p "$OUT_DIR"

log_section() {
  printf '\n===== %s =====\n' "$1"
}

collect_cmd() {
  local label="$1"
  shift
  echo
  echo "--- ${label} ---"
  if command -v "$1" >/dev/null 2>&1; then
    "$@" 2>&1 || true
  else
    echo "Command not available: $1"
  fi
}

# Collect system information
{
  echo "Validation run timestamp (UTC): $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  echo "Working directory: $ROOT_DIR"
  echo "Output directory:  $OUT_DIR"
  echo "Source file:       $SRC"
  collect_cmd "uname -a" uname -a
  collect_cmd "os-release" bash -lc 'cat /etc/os-release'
  collect_cmd "hostnamectl" hostnamectl
  collect_cmd "lscpu" lscpu
  collect_cmd "nproc" nproc
  collect_cmd "free -h" free -h
  collect_cmd "g++ --version" g++ --version
  collect_cmd "sha256sum source" sha256sum "$SRC"
} > "$SYSTEM_INFO"

# Compile
{
  log_section "Compiling"
  echo "Command: g++ -O2 -std=c++17 -Wall -Wextra -pedantic -o $BIN $SRC"
  g++ -O2 -std=c++17 -Wall -Wextra -pedantic -o "$BIN" "$SRC"
  echo "Exit code: $?"
} 2>&1 | tee "$BUILD_LOG"

# Run full verification
{
  log_section "Running verification (full)"
  echo "Command: $BIN"
  echo "Started: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  echo
  if command -v /usr/bin/time >/dev/null 2>&1; then
    /usr/bin/time -v "$BIN"
  else
    "$BIN"
  fi
  echo
  echo "Finished: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
} 2>&1 | tee "$RUN_LOG"

# Copy source and script into output
cp "$SRC" "$OUT_DIR/ed25519_verify.cpp"
cp "$ROOT_DIR/run_validation.sh" "$OUT_DIR/run_validation.sh"

# Generate hashes
(
  cd "$OUT_DIR"
  sha256sum \
    ed25519_verify.cpp \
    ed25519_verify \
    build.log \
    verification.log \
    system_info.txt \
    run_validation.sh \
    > hashes.txt
)

echo
echo "================================================================"
echo "  Validation complete."
echo "  Output directory: $OUT_DIR"
echo "================================================================"
echo
echo "Next step: sign the hash manifest with your PGP key:"
echo "  cd $OUT_DIR"
echo "  gpg --armor --detach-sign hashes.txt"
echo
