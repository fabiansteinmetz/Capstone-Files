#####################################################
# VMD (run LOCALLY, Tk console): has the sphere finished relaxing?
#   cd <folder with Input/ and the downloaded SphereEquil.dcd>;  source check_sphere.tcl
# Writes sphere_check.dat:  time_ps  Rg_A  R_equiv_A  n_stray
#   R_equiv = Rg * sqrt(5/3)  (radius of a uniform sphere with this radius of gyration)
#   n_stray = molecules more than 10 A outside R_equiv (evaporated)
#####################################################
mol new Input/sphere.psf type psf waitfor all
mol addfile SphereEquil/SphereEquil.dcd type dcd waitfor all
set nframes [molinfo top get numframes]
puts "frames: $nframes"
if {$nframes < 1} { puts "DCD not loaded - check pwd / file name"; return }

set all [atomselect top all]
set ox  [atomselect top "name O7"]
set out [open sphere_check.dat w]
puts $out "# time_ps Rg_A R_equiv_A n_stray"
for {set f 0} {$f < $nframes} {incr f} {
    $all frame $f; $ox frame $f
    set c  [measure center $all weight mass]
    set rg [measure rgyr $all weight mass]
    set R  [expr {$rg*sqrt(5.0/3.0)}]
    set cx [lindex $c 0]; set cy [lindex $c 1]; set cz [lindex $c 2]
    set stray 0
    foreach x [$ox get x] y [$ox get y] z [$ox get z] {
        set d [expr {sqrt(($x-$cx)*($x-$cx) + ($y-$cy)*($y-$cy) + ($z-$cz)*($z-$cz))}]
        if {$d > $R + 10.0} { incr stray }
    }
    puts $out "[expr {$f*10.0}] $rg $R $stray"
}
close $out
puts "wrote sphere_check.dat  (10 ps per frame)"
