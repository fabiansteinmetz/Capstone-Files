#!/bin/bash
# Run from inside the Sphere/ folder:   nohup bash job.sh > job.out 2>&1 &
cd "$(dirname "$0")" || exit 1
export CUDA_VISIBLE_DEVICES=0
NAMD="${NAMD:-$HOME/NAMD_Git-2025-01-10_Linux-x86_64-multicore-CUDA/namd3}"

for f in Input/sphere.psf Input/sphere.pdb SphereEquil.conf \
         ../inputs/par_all36m_prot.prm ../inputs/par_all36_na.prm ../inputs/par_all36_carb.prm \
         ../inputs/par_all36_lipid.prm ../inputs/par_all36_cgenff.prm ../inputs/NMP.prm; do
    [ -s "$f" ] || { echo "MISSING FILE: $f"; exit 1; }
done
[ -x "$NAMD" ] || { echo "NAMD not found: $NAMD"; exit 1; }

echo "start: $(date)"
mkdir -p SphereEquil
"$NAMD" +p4 SphereEquil.conf > SphereEquil/SphereEquil.log 2> SphereEquil/SphereEquil.err
if grep -q WallClock SphereEquil/SphereEquil.log; then
    echo "SphereEquil finished: $(date)"
else
    echo "SphereEquil FAILED. Last lines:"; tail -n 25 SphereEquil/SphereEquil.log; tail -n 25 SphereEquil/SphereEquil.err
fi
