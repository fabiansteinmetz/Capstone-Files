export CUDA_VISIBLE_DEVICES=0
NAMD=../../NAMD_Git-2025-01-10_Linux-x86_64-multicore-CUDA/namd3

run_stage () {
    local label=$1
    local conf=$2
    local log=$3

    echo "==============================="
    echo "$label"
    echo "Start time: $(date)"
    START_TIME=$(date +%s)

    $NAMD +p4 "$conf" > "$log"
    STATUS=$?

    END_TIME=$(date +%s)
    echo "End time: $(date)"
    ELAPSED=$((END_TIME - START_TIME))
    printf 'Elapsed time: %02d:%02d:%02d (%d seconds)\n' $((ELAPSED/3600)) $(((ELAPSED%3600)/60)) $((ELAPSED%60)) $ELAPSED

    if [ $STATUS -ne 0 ]; then
        echo "ERROR: $label failed (exit code $STATUS). Stopping chain."
        exit 1
    fi
}

run_stage "NVT1 — 4 ns, fixed volume" "NVT1.conf" "NVT1.log"

cd ../NPT
run_stage "NPT — 7 ns, pressure equilibration" "NPT.conf" "NPT.log"

cd ../NVT2
run_stage "NVT2 — 4 ns, production" "NVT2.conf" "NVT2.log"

echo "All three stages completed successfully."
