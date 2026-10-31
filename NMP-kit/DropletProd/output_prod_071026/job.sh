export CUDA_VISIBLE_DEVICES=0

echo "==============================="
START_TIME=$(date +%s)
echo "DROPLET EQUILIBRATION"
echo "Start time: $(date)"

../../NAMD_Git-2025-01-10_Linux-x86_64-multicore-CUDA/namd3 +p4  DropletProd.conf > DropletProd.log

END_TIME=$(date +%s)
echo "End time: $(date)"
ELAPSED=$((END_TIME - START_TIME))
printf 'Elapsed time: %02d:%02d:%02d (%d seconds)\n' $((ELAPSED/3600)) $(((ELAPSED%3600)/60)) $((ELAPSED%60)) $ELAPSED