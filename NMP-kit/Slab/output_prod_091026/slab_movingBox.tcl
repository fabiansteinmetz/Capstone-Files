#####################################################
# VMD: density of a FIXED small CUBE moved up (+z) from the slab centre
# -> locate the interface (slab analogue of movingSphereInterface.tcl)
# Output: moving_box_slab.dat   columns: d_A  avg_O_count  density_g_per_cm3
# Run in the folder containing SlabProd.dcd (Tk console: cd there, source this file)
#####################################################
set psf "../../Solvate/NMP-100A.psf"
set dcd "SlabProd.dcd"
set out "moving_box_slab.dat"

mol new $psf type psf waitfor all
mol addfile $dcd type dcd waitfor all
set nframes [molinfo top get numframes]
puts "frames loaded: $nframes"
if {$nframes < 1} { puts "ERROR: no frames loaded - check the dcd path"; return }

set M_NMP 99.13
set N_A   6.02214076e23

# cube side (A): must fit well inside the density plateau (slab is ~98 A thick)
set s  25.0
set hs [expr {$s/2.0}]
set volume_cm3 [expr {$s*$s*$s*1.0e-24}]

# displacement of the cube centre from the slab centre: 0 .. 80 A in 1 A steps
# (slab half-thickness ~49 A, so the cube top face passes the surface and reaches vacuum)
set dmax 80
set ND [expr {$dmax + 1}]
for {set i 0} {$i < $ND} {incr i} { set total($i) 0 }

set sel [atomselect top "name O7"]
set N [$sel num]
if {$N == 0} { puts "no O7 atoms found"; return }

for {set f 0} {$f < $nframes} {incr f} {
    molinfo top set frame $f
    $sel frame $f
    set xs [$sel get x]
    set ys [$sel get y]
    set zs [$sel get z]
    set a [molinfo top get a]
    set b [molinfo top get b]

    # slab centre of this frame (mean O7 position)
    set sx 0.0; set sy 0.0; set sz 0.0
    foreach x $xs y $ys z $zs { set sx [expr {$sx+$x}]; set sy [expr {$sy+$y}]; set sz [expr {$sz+$z}] }
    set cx [expr {$sx/$N}]; set cy [expr {$sy/$N}]; set cz [expr {$sz/$N}]

    # keep only atoms inside the cube's x,y window (wrapped), remember their z offset
    set dzs {}
    foreach x $xs y $ys z $zs {
        set dx [expr {$x-$cx}]
        set dy [expr {$y-$cy}]
        set dx [expr {$dx - $a*round($dx/$a)}]
        set dy [expr {$dy - $b*round($dy/$b)}]
        if {abs($dx) <= $hs && abs($dy) <= $hs} { lappend dzs [expr {$z-$cz}] }
    }

    # count atoms with |dz - d| <= s/2 for every d
    for {set d 0} {$d <= $dmax} {incr d} {
        set c 0
        foreach dz $dzs { if {abs($dz - $d) <= $hs} { incr c } }
        incr total($d) $c
    }
}

set fh [open $out w]
puts $fh "# d_A avg_O_count density_g_per_cm3   (cube side s = $s A)"
for {set d 0} {$d <= $dmax} {incr d} {
    set avg [expr {double($total($d))/$nframes}]
    set rho [expr {($avg*$M_NMP/$N_A)/$volume_cm3}]
    puts $fh "$d $avg $rho"
}
close $fh
puts "done -> $out"