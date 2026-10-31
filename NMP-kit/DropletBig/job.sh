#!/bin/bash
# Run from inside the folder that holds SystemWet.conf and System/ :
#   nohup bash job.sh > job.out 2>&1 &
cd "$(dirname "$0")" || exit 1
export CUDA_VISIBLE_DEVICES=0
NAMD="${NAMD:-$HOME/NAMD_Git-2025-01-10_Linux-x86_64-multicore-CUDA/namd3}"

for f in System/system.psf System/system.pdb System/fix.pdb System/cell.inc SystemWet.conf \
         ../inputs/par_all36m_prot.prm ../inputs/par_all36_na.prm ../inputs/par_all36_carb.prm \
         ../inputs/par_all36_lipid.prm ../inputs/par_all36_cgenff.prm ../inputs/NMP.prm; do
    [ -s "$f" ] || { echo "MISSING FILE: $f"; exit 1; }
done
[ -x "$NAMD" ] || { echo "NAMD not found: $NAMD"; exit 1; }

echo "start: $(date)"
mkdir -p SystemWet
"$NAMD" +p4 SystemWet.conf > SystemWet/SystemWet.log 2> SystemWet/SystemWet.err
if grep -q WallClock SystemWet/SystemWet.log; then
    echo "SystemWet finished: $(date)"
else
    echo "SystemWet FAILED. Last lines:"; tail -n 25 SystemWet/SystemWet.log; tail -n 25 SystemWet/SystemWet.err
fi
