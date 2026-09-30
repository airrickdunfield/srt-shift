#!/usr/bin/env bash
# srt-shift — shift every timestamp in an .srt subtitle file
#
# Usage:
#   ./srt-shift.sh movie.srt            # prompts for the delay
#   ./srt-shift.sh movie.srt 1500       # subs appear 1.5 s later
#   ./srt-shift.sh movie.srt -750       # subs appear 0.75 s earlier
#
# Writes movie.shifted.srt next to the original (the original is untouched).

set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") <file.srt> [offset_ms]" >&2
  echo "  positive offset = subtitles later, negative = earlier" >&2
  exit 1
}

[[ $# -ge 1 ]] || usage
in="$1"
[[ -f "$in" ]] || { echo "File not found: $in" >&2; exit 1; }

offset="${2:-}"
if [[ -z "$offset" ]]; then
  read -rp "Delay in milliseconds (negative to make subs earlier): " offset
fi
offset="${offset#+}"
[[ "$offset" =~ ^-?[0-9]+$ ]] || { echo "Offset must be a whole number of ms, e.g. 1500 or -750" >&2; exit 1; }

out="${in%.[sS][rR][tT]}.shifted.srt"

awk -v off="$offset" '
  function to_ms(t,   a) {
    split(t, a, /[:,.]/)
    return ((a[1] * 60 + a[2]) * 60 + a[3]) * 1000 + a[4]
  }
  function fmt(ms) {
    if (ms < 0) { ms = 0; clamped++ }
    return sprintf("%02d:%02d:%02d,%03d",
      int(ms / 3600000), int(ms / 60000) % 60, int(ms / 1000) % 60, ms % 1000)
  }
  /-->/ {
    cr = sub(/\r$/, "")                      # keep Windows line endings if present
    n = index($0, "-->")
    start = substr($0, 1, n - 1); gsub(/ /, "", start)
    rest = substr($0, n + 3);     sub(/^ +/, "", rest)
    sp = index(rest, " ")
    if (sp) { end = substr(rest, 1, sp - 1); tail = substr(rest, sp) }
    else    { end = rest; tail = "" }
    printf "%s --> %s%s%s\n", fmt(to_ms(start) + off), fmt(to_ms(end) + off), tail, (cr ? "\r" : "")
    cues++
    next
  }
  { print }
  END {
    printf "Shifted %d cues by %d ms\n", cues, off > "/dev/stderr"
    if (clamped) printf "Note: %d timestamps went below 0 and were set to 00:00:00,000\n", clamped > "/dev/stderr"
  }
' "$in" > "$out"

echo "Saved: $out"
