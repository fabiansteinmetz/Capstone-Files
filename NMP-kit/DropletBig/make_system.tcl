#####################################################
# VMD: put the BIG NMP droplet (5,680 molecules) ABOVE a graphene sheet in one system
# Run in the Tk console:  cd <folder with the input files>;  source make_system.tcl
# Writes into ./System/:  system.psf  system.pdb  system.coor  fix.pdb  cell.inc
#####################################################
package require topotools

# ---------------- EDIT THESE ----------------
set gr_psf   "graphite/Graphite_bonds.psf"          ;# graphene topology (the BONDED one, not prebond), built with D = 265, Z = 2
set gr_pdb   "graphite/Graphite_bonds.pdb"          ;# graphene coordinates
set nmp_psf  "../Solvate/NMP-100A.psf"        ;# topology of the droplet (all 5,680 molecules)  <- check this path
set nmp_coor "../DropletProd/output_prod_081026/DropletProd.restart.coor"  ;# final positions of the big droplet run   <- check this path
set R_guess  61.0      ;# rough droplet radius (A). Only used to throw away evaporated molecules
set gap      4.0       ;# distance sheet top -> LOWEST NMP atom (A)
set vac_top  60.0      ;# vacuum above the droplet (A)
set Dgr      265       ;# the D you built the graphene with (D = 265 -> 140,450 atoms per layer)
set nlayers  4         ;# number of graphene layers in your files
# --------------------------------------------
# lateral cell of the hexagonal graphene: two vectors of length D*a at 120 degrees (a = sqrt(3)*1.418 A)
set a_lat [expr {sqrt(3.0)*1.418}]
set cell_a [list [expr {$Dgr*$a_lat/2.0}] [expr {-$Dgr*$a_lat*sqrt(3.0)/2.0}] 0]
set cell_b [list [expr {$Dgr*$a_lat/2.0}] [expr { $Dgr*$a_lat*sqrt(3.0)/2.0}] 0]
puts "lateral cell length [expr {$Dgr*$a_lat}] A,  expected graphene atoms: [expr {2*$Dgr*$Dgr*$nlayers}]"

# graphene
set g [mol new $gr_psf type psf waitfor all]
mol addfile $gr_pdb type pdb waitfor all
set gall [atomselect $g all]
set mm [measure minmax $gall]
set zbot [lindex $mm 0 2]
set ztop [lindex $mm 1 2]
puts "graphene: [$gall num] atoms, z from $zbot to $ztop"

# droplet: centre it on the middle of the droplet (first pass: all atoms, second pass: without far-away strays)
set n [mol new $nmp_psf type psf waitfor all]
mol addfile $nmp_coor type namdbin waitfor all
set nall [atomselect $n all]
$nall moveby [vecscale -1.0 [measure center $nall weight mass]]
set r1 [expr {$R_guess + 15.0}]
set core [atomselect $n "same residue as (name O7 and (x*x + y*y + z*z) < [expr {$r1*$r1}])"]
$nall moveby [vecscale -1.0 [measure center $core weight mass]]

# keep only the droplet itself: whole molecules whose oxygen is within R_guess + 8 A of the centre (the rest are strays)
set r2 [expr {$R_guess + 8.0}]
set keep [atomselect $n "same residue as (name O7 and (x*x + y*y + z*z) < [expr {$r2*$r2}])"]
puts "droplet: kept [$keep num] of [$nall num] atoms"
set rg [measure rgyr $keep weight mass]
puts "droplet equivalent radius Rg*sqrt(5/3) = [expr {$rg*sqrt(5.0/3.0)}] A   (compare with R_guess = $R_guess)"

# move the droplet so that its lowest atom sits $gap above the top graphene layer
set nm [measure minmax $keep]
set dz [expr {$ztop + $gap - [lindex $nm 0 2]}]
$nall moveby [list 0 0 $dz]
set nm [measure minmax $keep]
set zlow  [lindex $nm 0 2]
set zhigh [lindex $nm 1 2]
puts "droplet z from $zlow to $zhigh  (graphene top at $ztop)"

# merge into one molecule
set m [::TopoTools::selections2mol [list $gall $keep]]
set all [atomselect $m all]
set nmp [atomselect $m "resname NMP"]
set grp [atomselect $m "not resname NMP"]
puts "merged: [$all num] atoms, [topo numbonds -molid $m] bonds, [topo numangles -molid $m] angles, [topo numdihedrals -molid $m] dihedrals"

# graphene carbons: use the CHARMM/CGenFF aromatic carbon type so NO extra parameter file is needed
# (all its bonded + LJ parameters are already in par_all36_cgenff.prm). Charge 0, mass of carbon.
$grp set type CG2R61
$grp set charge 0.0
$grp set mass 12.011

file mkdir System
$all writepsf System/system.psf
$all writepdb System/system.pdb
$all writenamdbin System/system.coor

# fixed-atom file: beta = 1 for the TOP and BOTTOM graphene layers (held in place),
# beta = 0 for the inner layers (free to move) and for all NMP.
# Layers are told apart by z (flat layers ~3.35 A apart): the outermost 1 A on each side.
$all set beta 0
set fixsel [atomselect $m "(not resname NMP) and (z > [expr {$ztop - 1.0}] or z < [expr {$zbot + 1.0}])"]
$fixsel set beta 1
puts "fixed graphene atoms (top + bottom layer): [$fixsel num]   (expected [expr {2*2*$Dgr*$Dgr}])"
$all writepdb System/fix.pdb

# periodic cell (z is periodic too: vacuum on top, sheet underneath)
set zlo  [expr {$zbot - 3.0}]
set zhi  [expr {$zhigh + $vac_top}]
set H    [expr {$zhi - $zlo}]
set zmid [expr {($zlo + $zhi)/2.0}]
set fh [open System/cell.inc w]
puts $fh "cellBasisVector1 [lindex $cell_a 0] [lindex $cell_a 1] [lindex $cell_a 2]"
puts $fh "cellBasisVector2 [lindex $cell_b 0] [lindex $cell_b 1] [lindex $cell_b 2]"
puts $fh "cellBasisVector3 0 0 $H"
puts $fh "cellOrigin 0 0 $zmid"
close $fh
puts "cell height $H A.  Written to System/. Check the counts above."
