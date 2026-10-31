#!/bin/bash
# Run from inside the folder that holds SystemEquil.conf and System/ :
#   nohup bash job.sh > job.out 2>&1 &
cd "$(dirname "$0")" || exit 1
export CUDA_VISIBLE_DEVICES=0
NAMD="${NAMD:-$HOME/NAMD_Git-2025-01-10_Linux-x86_64-multicore-CUDA/namd3}"

for f in System/system.psf System/system.pdb System/fix.pdb System/cell.inc SystemEquil.conf \
         ../inputs/par_all36m_prot.prm ../inputs/par_all36_na.prm ../inputs/par_all36_carb.prm \
         ../inputs/par_all36_lipid.prm ../inputs/par_all36_cgenff.prm ../inputs/NMP.prm; do
    [ -s "$f" ] || { echo "MISSING FILE: $f"; exit 1; }
done
[ -x "$NAMD" ] || { echo "NAMD not found: $NAMD"; exit 1; }

echo "start: $(date)"
mkdir -p SystemEquil
"$NAMD" +p4 SystemEquil.conf > SystemEquil/SystemEquil.log 2> SystemEquil/SystemEquil.err
if grep -q WallClock SystemEquil/SystemEquil.log; then
    echo "SystemEquil finished: $(date)"
else
    echo "SystemEquil FAILED. Last lines:"; tail -n 25 SystemEquil/SystemEquil.log; tail -n 25 SystemEquil/SystemEquil.err
fi
