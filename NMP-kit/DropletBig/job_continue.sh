#!/bin/bash
# Continue the wetting run (part 2). Run from inside the folder that holds SystemWet2.conf, System/ and SystemWet/ :
#   NAMD=/path/to/namd3 nohup bash job_continue.sh > job2.out 2>&1 &
cd "$(dirname "$0")" || exit 1
export CUDA_VISIBLE_DEVICES=0
NAMD="${NAMD:?set NAMD=/path/to/namd3 before running}"

for f in System/system.psf System/system.pdb System/fix.pdb SystemWet2.conf \
         SystemWet/SystemWet.restart.coor SystemWet/SystemWet.restart.vel SystemWet/SystemWet.restart.xsc \
         ../inputs/par_all36m_prot.prm ../inputs/par_all36_na.prm ../inputs/par_all36_carb.prm \
         ../inputs/par_all36_lipid.prm ../inputs/par_all36_cgenff.prm ../inputs/NMP.prm; do
    [ -s "$f" ] || { echo "MISSING FILE: $f"; exit 1; }
done
[ -x "$NAMD" ] || { echo "NAMD not found: $NAMD"; exit 1; }

echo "start: $(date)"
mkdir -p SystemWet2
"$NAMD" +p8 SystemWet2.conf > SystemWet2/SystemWet2.log 2> SystemWet2/SystemWet2.err
if grep -q WallClock SystemWet2/SystemWet2.log; then
    echo "SystemWet2 finished: $(date)"
else
    echo "SystemWet2 FAILED. Last lines:"; tail -n 25 SystemWet2/SystemWet2.log; tail -n 25 SystemWet2/SystemWet2.err
fi
