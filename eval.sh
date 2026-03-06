#!/bin/bash
# Evaluate the performance of matrix multiplication algorithms
# 0: naive, 1: jk reordering, 2: tiling, 3: tiling + transposed, 4: tiling + transposed + simd

if [ $# -ne 1 ]; then
    echo "Usage: $0 <algorithm>"
    echo "  algorithm - 0: naive, 1: jk reordering, 2: tiling, 3: tiling + transposed, 4: tiling + transposed + simd"
    exit 1
fi
algo=$1
echo "n ws dur"
echo "-----------------------------"
for n in 16 32 64 128 256 512 1024 2048; do
    ./matrix -n $n -a $algo > tmp.txt
    dur=`cat tmp.txt | awk '{ print $2 }'`
    ws=`expr $n \* $n \* 4 \* 3 / 1024`
    echo $n $ws $dur
done
