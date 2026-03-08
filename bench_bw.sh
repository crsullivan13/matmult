#!/bin/bash
# Usage: ./bench_bw.sh <size> <algo> <runs>
# Reports median bandwidth in MB/s across <runs> executions.

set -e

if [ $# -lt 3 ] || [ $# -gt 4 ]; then
    echo "Usage: $0 <size> <algo> <runs> [core]"
    echo "  algo: 0=naive 1=jk 2=tiling 3=transposed 4=simd"
    echo "  core: optional CPU core to pin to via taskset (e.g. 3)"
    exit 1
fi

SIZE=$1
ALGO=$2
RUNS=$3
CORE=${4:-}

if [ -n "$CORE" ]; then
    RUN_PREFIX="taskset -c $CORE"
else
    RUN_PREFIX=""
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$SCRIPT_DIR/matrix"

if [ ! -x "$BIN" ]; then
    echo "error: $BIN not found or not executable" >&2
    exit 1
fi

bw_values=()
time_values=()
for i in $(seq 1 "$RUNS"); do
    output=$(${RUN_PREFIX} "$BIN" -n "$SIZE" -a "$ALGO")
    bw=$(echo "$output" | awk '/bw:/ { for(i=1;i<=NF;i++) if($i=="bw:") print $(i+1) }')
    t=$(echo "$output" | awk '/bw:/ { print $2 }')
    if [ -z "$bw" ] || [ -z "$t" ]; then
        echo "error: missing fields in output on run $i" >&2
        exit 1
    fi
    bw_values+=("$bw")
    time_values+=("$t")
done

median_field() {
    printf '%s\n' "$@" | sort -n | awk '
    { a[NR] = $1 }
    END {
        n = NR
        if (n % 2 == 1)
            print a[(n+1)/2]
        else
            printf "%.6f\n", (a[n/2] + a[n/2+1]) / 2.0
    }'
}

median_bw=$(median_field "${bw_values[@]}")
median_time=$(median_field "${time_values[@]}")

CORE_STR=${CORE:+" core=$CORE"}
echo "size=$SIZE algo=$ALGO runs=$RUNS${CORE_STR}  median_time=${median_time}s  median_bw=${median_bw} MB/s"
