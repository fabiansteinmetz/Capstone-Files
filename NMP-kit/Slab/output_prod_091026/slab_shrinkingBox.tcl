#####################################################
# VMD: shrinking CUBE inside the slab (SlabProd.dcd)
# Output: shrinking_box_slab.dat   columns: L_A  avg_O_count  density_g_per_cm3
# Run in the folder containing SlabProd.dcd (Tk console: cd there, source this file)
#####################################################
set psf  "../../Solvate/NMP-100A.psf"
set dcd  "SlabProd.dcd"
set out  "shrinking_box_slab.dat"
set Lmax 100.0       ;# stay below the box size (98 A): bigger cubes see their own images
set dL   0.5
set M_NMP 99.13
set N_A   6.02214076e23

mol new $psf type psf waitfor all
mol addfile $dcd type dcd waitfor all
set nframes [molinfo top get numframes]
puts "frames: $nframes"
if {$nframes < 1} { puts "DCD not loaded - check pwd / file name"; return }

set sel [atomselect top "name O7"]
set N [$sel num]
puts "O7 atoms: $N"
if {$N == 0} { puts "no O7 atoms found"; return }

set nb [expr {int($Lmax/$dL + 0.5)}]
for {set i 0} {$i <= $nb} {incr i} { set hist($i) 0 }

for {set f 0} {$f < $nframes} {incr f} {
    molinfo top set frame $f
    $sel frame $f
    set xs [$sel get x]
    set ys [$sel get y]
    set zs [$sel get z]
    set a [molinfo top get a]
    set b [molinfo top get b]

    # slab centre of this frame (mean O7 position); x,y centre is arbitrary for an infinite slab
    set sx 0.0; set sy 0.0; set sz 0.0
    foreach x $xs y $ys z $zs { set sx [expr {$sx+$x}]; set sy [expr {$sy+$y}]; set sz [expr {$sz+$z}] }
    set cx [expr {$sx/$N}]; set cy [expr {$sy/$N}]; set cz [expr {$sz/$N}]

    foreach x $xs y $ys z $zs {
        set dx [expr {$x-$cx}]
        set dy [expr {$y-$cy}]
        set dz [expr {$z-$cz}]
        # wrap x,y into the periodic cell (z is not wrapped: vacuum)
        set dx [expr {$dx - $a*round($dx/$a)}]
        set dy [expr {$dy - $b*round($dy/$b)}]
        set m [expr {abs($dx)}]
        if {abs($dy) > $m} { set m [expr {abs($dy)}] }
        if {abs($dz) > $m} { set m [expr {abs($dz)}] }
        # smallest cube side that contains this atom = 2*m  -> bin index
        set k [expr {int(ceil(2.0*$m/$dL))}]
        if {$k < 1} { set k 1 }
        if {$k <= $nb} { incr hist($k) }
    }
}

set fh [open $out w]
puts $fh "# L_A avg_O_count density_g_per_cm3"
set cum 0
for {set j 1} {$j <= $nb} {incr j} {
    incr cum $hist($j)
    set L [expr {$j*$dL}]
    set avg [expr {double($cum)/$nframes}]
    set rho [expr {($avg*$M_NMP/$N_A)/($L*$L*$L*1e-24)}]
    puts $fh "$L $avg $rho"
}
close $fh
puts "wrote $out"
