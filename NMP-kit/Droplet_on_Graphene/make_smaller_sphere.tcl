#####################################################
# VMD (run LOCALLY, Tk console): cut a sphere of NMP out of the equilibrated bulk cube
#   cd <folder with the files below>;  source make_sphere.tcl
# Writes Input/sphere.psf and Input/sphere.pdb
#####################################################
set psf  "../Solvate/NMP-100A.psf"            ;# topology of the cube (5,680 molecules)
set coor "../NVT2/output_270926/NVT2.restart.coor"       ;# equilibrated cube coordinates
set box  98.4657964777             ;# cube side, from the last line of NVT2.restart.xsc
set R    40.0                      ;# sphere radius in A: 40 -> ~1,600 molecules, 46 -> ~2,500 (max ~46 for this cube)

mol new $psf type psf waitfor all
mol addfile $coor type namdbin waitfor all

# the cube is centred on the origin; put every molecule back inside the cell (whole molecules)
pbc set [list $box $box $box] -all
pbc wrap -compound residue -center origin

# keep whole molecules whose oxygen (O7) lies inside the sphere
set sel [atomselect top "same residue as (name O7 and (x*x + y*y + z*z) < [expr {$R*$R}])"]
set nmol [llength [lsort -unique [$sel get residue]]]
set expected [expr {5680.0 * (4.0/3.0*3.14159265*$R*$R*$R) / ($box*$box*$box)}]
puts "molecules kept: $nmol   (expected about [expr {int($expected)}])   atoms: [$sel num]"

file mkdir Input
$sel writepsf Input/sphere.psf
$sel writepdb Input/sphere.pdb
puts "wrote Input/sphere.psf and Input/sphere.pdb"
