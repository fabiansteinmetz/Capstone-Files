package require solvate
solvate -spsf ../inputs/NMP_model_50A.psf -spdb ../inputs/NMP_model_50A.pdb -stop ../inputs/NMP.top -ks "resname NMP and name C1" -ws 50 -minmax {{-50 -50 -50} {50 50 50}} -o NMP-100A
quit
