#!/bin/bash
#######################################################################
# NMP CUBE-SLAB SURFACE-TENSION PIPELINE (vacuum along z)
#   SlabEquil -> SlabProd
#
# Run from inside the Slab/ folder:
#     nohup bash job.sh > job.out 2>&1 &
# Follow progress with:   tail -f job.out
#
# A stage is SKIPPED if its log already finished (so if the job dies, just
# start it again and it resumes at the first unfinished stage).
#######################################################################
cd "$(dirname "$0")" || exit 1

export CUDA_VISIBLE_DEVICES=0
NAMD="${NAMD:-$HOME/NAMD_Git-2025-01-10_Linux-x86_64-multicore-CUDA/namd3}"
NP=4

# ---------------- settings (timestep = 2 fs) ----------------
# ---------------------------------------------------------------

# ---------------- pre-flight checks ----------------
missing=0
for f in ../Solvate/NMP-100A.psf ../Solvate/NMP-100A.pdb \
         ../inputs/par_all36m_prot.prm ../inputs/par_all36_na.prm ../inputs/par_all36_carb.prm \
         ../inputs/par_all36_lipid.prm ../inputs/par_all36_cgenff.prm ../inputs/NMP.prm \
         SlabEquil.conf SlabProd.conf; do
    [ -s "$f" ] || { echo "MISSING FILE: $f"; missing=1; }
done
[ -x "$NAMD" ] || { echo "NAMD not found or not executable: $NAMD"; missing=1; }
[ $missing -eq 0 ] || { echo "Fix the above and rerun."; exit 1; }

echo "==============================="
echo "SLAB PIPELINE start: $(date)"
T0=$(date +%s)

run_stage () {
    stage=$1
    if [ -s "$stage/$stage.restart.xsc" ] && grep -q "WallClock" "$stage/$stage.log" 2>/dev/null; then
        echo "--- $stage: already finished, skipping"
        return 0
    fi
    echo "--- $stage: start $(date)"
    mkdir -p "$stage"
    ( cd "$stage" && "$NAMD" +p$NP "../$stage.conf" > "$stage.log" 2> "$stage.err" )
    if ! grep -q "WallClock" "$stage/$stage.log"; then
        echo "!!! $stage FAILED (no WallClock in log). Stopping the pipeline."
        echo "--- last lines of $stage/$stage.log:";  tail -n 25 "$stage/$stage.log"
        echo "--- last lines of $stage/$stage.err:";  tail -n 25 "$stage/$stage.err"
        exit 1
    fi
    echo "--- $stage: done $(date)"
}

run_stage SlabEquil
run_stage SlabProd

END=$(date +%s); ELAPSED=$((END-T0))
printf 'SLAB PIPELINE finished: %s   elapsed %02d:%02d:%02d\n' "$(date)" $((ELAPSED/3600)) $(((ELAPSED%3600)/60)) $((ELAPSED%60))