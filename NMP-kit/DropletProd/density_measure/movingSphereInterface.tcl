#####################################################
# VMD Script: density of a FIXED small sphere moved   #
# outward from the droplet centre -> locate interface  #
# (droplet analogue of the "move the small cube up in  #
# z until density drops" method)                        #
#####################################################

mol new "../../Solvate/NMP-100A.psf" type psf
mol addfile "../output_prod_081026/DropletProd.dcd" type dcd waitfor all   ;# all frames

set nframes [molinfo top get numframes]
puts "frames loaded: $nframes"
if {$nframes < 1} { puts "ERROR: no frames loaded - check the dcd path"; return }

# Physical constants
set M_NMP   99.13
set N_A     6.02214076e23
set A3_to_cm3 1.0e-24

# Small-sphere radius: pick from the plateau of the shrinking-sphere curve => use 25
set r0 25.0
set r02 [expr {$r0 * $r0}]
set volume_cm3 [expr {(4.0/3.0) * 3.14159265358979 * $r0 * $r0 * $r0 * $A3_to_cm3}]

# Displacement sweep: from the centre (0) to well beyond the surface.
# Droplet R ~ 61 A, so d + r0 must pass R and reach into vacuum.
set d_list {}
for {set d 0.0} {$d <= 80.0} {set d [expr {$d + 1.0}]} { lappend d_list $d }

# Single direction: +z (same as moving the cube "up" in the slab method)
set dirs {{0 0 1}}

# Per-frame centre of mass (droplet drifts in the vacuum box)
puts "Pre-computing per-frame centre of mass..."
set com_x {}; set com_y {}; set com_z {}
for {set frame 0} {$frame < $nframes} {incr frame} {
    set all_sel [atomselect top "all" frame $frame]
    set com [measure center $all_sel weight mass]
    $all_sel delete
    lappend com_x [lindex $com 0]
    lappend com_y [lindex $com 1]
    lappend com_z [lindex $com 2]
}

set outfile [open "moving_sphere_density.dat" "w"]
puts $outfile "# d_A   avg_O_count   density_g_per_cm3   (r0 = $r0 A)"

foreach d $d_list {
    puts "displacement d = $d"
    set total 0.0
    set n 0
    for {set frame 0} {$frame < $nframes} {incr frame} {
        set cx0 [lindex $com_x $frame]
        set cy0 [lindex $com_y $frame]
        set cz0 [lindex $com_z $frame]
        foreach dir $dirs {
            set cx [expr {$cx0 + $d * [lindex $dir 0]}]
            set cy [expr {$cy0 + $d * [lindex $dir 1]}]
            set cz [expr {$cz0 + $d * [lindex $dir 2]}]
            # O7 = the single oxygen of each NMP molecule (atom count = molecule count)
            set sel [atomselect top \
                "name O7 and (x-($cx))*(x-($cx)) + (y-($cy))*(y-($cy)) + (z-($cz))*(z-($cz)) <= $r02" \
                frame $frame]
            set total [expr {$total + [$sel num]}]
            incr n
            $sel delete
        }
    }
    set avg_count [expr {$total / $n}]
    set density [expr {($avg_count * $M_NMP / $N_A) / $volume_cm3}]
    puts $outfile "$d $avg_count $density"
}

close $outfile
puts "done -> moving_sphere_density.dat"