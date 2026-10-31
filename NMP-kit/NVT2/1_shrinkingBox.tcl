#####################################################
# VMD Script to Count Oxygen Densities by Z-layers #
#####################################################
# 1) open .dcd file for the first cycle
mol new "../../0_setup_files/NMP-100A.psf" type psf
mol addfile "05_dynamics.dcd" type dcd waitfor all

# 2) Set the different values of the cube length from 0.5 to 50.0
set width_lenght {0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0 8.5 9.0 9.5 10.0 10.5 11.0 11.5 12.0 12.5 13.0 13.5 14.0 14.5 15.0 15.5 16.0 16.5 17.0 17.5 18.0 18.5 19.0 19.5 20.0 20.5 21.0 21.5 22.0 22.5 23.0 23.5 24.0 24.5 25.0 25.5 26.0 26.5 27.0 27.5 28.0 28.5 29.0 29.5 30.0 30.5 31.0 31.5 32.0 32.5 33.0 33.5 34.0 34.5 35.0 35.5 36.0 36.5 37.0 37.5 38.0 38.5 39.0 39.5 40.0 40.5 41.0 41.5 42.0 42.5 43.0 43.5 44.0 44.5 45.0 45.5 46.0 46.5 47.0 47.5 48.0 48.5 49.0 49.5 50.0 50.5 51.0 51.5 52.0 52.5 53.0 53.5 54.0 54.5 55.0 55.5 56.0 56.5 57.0 57.5 58.0 58.5 59.0 59.5 60.0 60.5 61.0 61.5 62.0 62.5 63.0 63.5 64.0 64.5 65.0 65.5 66.0 66.5 67.0 67.5 68.0 68.5 69.0 69.5 70.0 70.5 71.0 71.5 72.0 72.5 73.0 73.5 74.0 74.5 75.0 75.5 76.0 76.5 77.0 77.5 78.0 78.5 79.0 79.5 80.0}

set shrinking [open "shrinking_box.dat" "w"]
set nframes [molinfo top get numframes]


# 3) For each value of cube length: 
foreach length $width_lenght {

	puts "width length: $length"

	set atoms_in_box {}
	
	# 3.1) CALCULATE THE NUMBER OF ATOMS IN THAT BOX FOR EACH FRAME
	for {set frame 0} {$frame < $nframes} {incr frame} {
		set sel [atomselect top "name OH2 and x >= -$length/2 and x <= $length/2 and y >= -$length/2 and y <= $length/2 and z >= - $length/2 and z <= $length" frame $frame]

		set count [$sel num]

		# 3.2) APPEND TO atoms_in_box
		lappend atoms_in_box $count
		$sel delete
	}
	
	# 3.3) AVERAGE atoms_in_box

	set sum 0.0
	foreach count $atoms_in_box {
		set sum [expr {$sum + $count}]
	}
	
	set avg_atoms [expr {$sum / $nframes}]	

	# 3.4) OUTPUT length AND atoms_in_box INTO FILE shrinking
	puts $shrinking "$length $avg_atoms"
}

close $shrinking