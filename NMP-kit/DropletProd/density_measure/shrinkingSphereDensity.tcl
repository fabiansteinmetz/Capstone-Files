#####################################################
# VMD Script: mass density vs. shrinking-sphere radius #
# Counts ONE oxygen atom per NMP molecule (NMP has     #
# exactly one O), so atom count == molecule count.      #
# Converts to mass density using NMP's molar mass.       #
#####################################################

# 1) open the droplet production trajectory
mol new "../../Solvate/NMP-100A.psf" type psf
mol addfile "../output_prod_081026/DropletProd.dcd" type dcd waitfor all

set nframes [molinfo top get numframes]

# Physical constants for the count -> mass-density conversion
set M_NMP   99.13        ;# g/mol — NMP (C5H9NO) molar mass
set N_A     6.02214076e23 ;# Avogadro's number, 1/mol
set A3_to_cm3 1.0e-24     ;# 1 Angstrom^3 in cm^3

set radius_list {0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0 8.5 9.0 9.5 10.0 10.5 11.0 11.5 12.0 12.5 13.0 13.5 14.0 14.5 15.0 15.5 16.0 16.5 17.0 17.5 18.0 18.5 19.0 19.5 20.0 20.5 21.0 21.5 22.0 22.5 23.0 23.5 24.0 24.5 25.0 25.5 26.0 26.5 27.0 27.5 28.0 28.5 29.0 29.5 30.0 30.5 31.0 31.5 32.0 32.5 33.0 33.5 34.0 34.5 35.0 35.5 36.0 36.5 37.0 37.5 38.0 38.5 39.0 39.5 40.0 40.5 41.0 41.5 42.0 42.5 43.0 43.5 44.0 44.5 45.0 45.5 46.0 46.5 47.0 47.5 48.0 48.5 49.0 49.5 50.0 50.5 51.0 51.5 52.0 52.5 53.0 53.5 54.0 54.5 55.0 55.5 56.0 56.5 57.0 57.5 58.0 58.5 59.0 59.5 60.0 60.5 61.0 61.5 62.0 62.5 63.0 63.5 64.0 64.5 65.0 65.5 66.0 66.5 67.0 67.5 68.0 68.5 69.0 69.5 70.0 70.5 71.0 71.5 72.0 72.5 73.0 73.5 74.0 74.5 75.0}

# 2) Pre-compute per-frame center of mass once (droplet can drift; see
#    shrinkingSphere.tcl for the same reasoning).
puts "Pre-computing per-frame center of mass..."
set com_x {}
set com_y {}
set com_z {}
for {set frame 0} {$frame < $nframes} {incr frame} {
    set all_sel [atomselect top "all" frame $frame]
    set com [measure center $all_sel weight mass]
    $all_sel delete
    lappend com_x [lindex $com 0]
    lappend com_y [lindex $com 1]
    lappend com_z [lindex $com 2]
}

set outfile [open "shrinking_sphere_density.dat" "w"]
puts $outfile "# radius_A   avg_O_count   density_g_per_cm3"

# 3) For each radius: count O atoms within it per frame, average, convert to density
foreach radius $radius_list {

    puts "radius: $radius"

    set counts {}
    set r2 [expr {$radius * $radius}]

    for {set frame 0} {$frame < $nframes} {incr frame} {
        set cx [lindex $com_x $frame]
        set cy [lindex $com_y $frame]
        set cz [lindex $com_z $frame]

        # >>> CHECK the atom name "O" below matches NMP's oxygen in your
        # PSF exactly (open the PSF/PDB and confirm — CHARMM-style naming
        # could differ, e.g. "O1" or "OC"). <<<
        set sel [atomselect top \
            "name O7 and (x-($cx))*(x-($cx)) + (y-($cy))*(y-($cy)) + (z-($cz))*(z-($cz)) <= $r2" \
            frame $frame]

        lappend counts [$sel num]
        $sel delete
    }

    set sum 0.0
    foreach c $counts { set sum [expr {$sum + $c}] }
    set avg_count [expr {$sum / $nframes}]

    # mass density = (molecule count * molar mass / Avogadro) / sphere volume
    set volume_A3 [expr {(4.0/3.0) * 3.14159265358979 * $radius * $radius * $radius}]
    set volume_cm3 [expr {$volume_A3 * $A3_to_cm3}]
    set mass_g [expr {$avg_count * $M_NMP / $N_A}]
    set density [expr {$volume_cm3 > 0 ? $mass_g / $volume_cm3 : 0}]

    puts $outfile "$radius $avg_count $density"
}

close $outfile
