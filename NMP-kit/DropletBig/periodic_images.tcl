# Run in VMD (Tk console):  source periodic_images.tcl
# Load system.psf and the DCD(s) first (File > New Molecule), then source this.
# Writes periodic_images_vmd.csv  (same columns as the python script, except
# n_near_edge replaces n_cross_mol: it is an UPPER BOUND).

set D      265        ;# graphene size
set dt     10.0       ;# ps between frames
set cutoff 12.0
set outfile periodic_images_vmd.csv

set L   [expr {$D*sqrt(3.0)*1.418}]
set h   [expr {$L*sqrt(3.0)/2.0}]      ;# perpendicular distance between opposite edges
set det [expr {$L*$L*sqrt(3.0)/2.0}]

set nmp [atomselect top "resname NMP"]
set nat [$nmp num]
set nmol [expr {$nat/16}]
set out [open $outfile w]
puts $out "frame,time_ns,n_mol,n_out,n_near_edge"

set nf [molinfo top get numframes]
for {set fr 0} {$fr < $nf} {incr fr} {
    $nmp frame $fr
    set xyz [$nmp get {x y z}]
    set nout 0
    set nnear 0
    for {set m 0} {$m < $nmol} {incr m} {
        set sx 0.0
        set sy 0.0
        for {set k 0} {$k < 16} {incr k} {
            set a [lindex $xyz [expr {$m*16+$k}]]
            set sx [expr {$sx + [lindex $a 0]}]
            set sy [expr {$sy + [lindex $a 1]}]
        }
        set x [expr {$sx/16.0}]
        set y [expr {$sy/16.0}]
        set fa [expr {($x*$L*sqrt(3.0)/2.0 - $y*$L/2.0)/$det}]
        set fb [expr {($x*$L*sqrt(3.0)/2.0 + $y*$L/2.0)/$det}]
        if {abs($fa) > 0.5 || abs($fb) > 0.5} {
            incr nout
        } else {
            set da [expr {(0.5-abs($fa))*$h}]
            set db [expr {(0.5-abs($fb))*$h}]
            if {$da < $cutoff || $db < $cutoff} { incr nnear }
        }
    }
    puts $out "$fr,[format %.3f [expr {($fr+1)*$dt/1000.0}]],$nmol,$nout,$nnear"
}
close $out
puts "wrote $outfile ($nf frames)"
