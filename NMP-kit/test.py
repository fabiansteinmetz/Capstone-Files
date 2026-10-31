import MDAnalysis as mda

u = mda.Universe("Solvate/NMP-100A.psf", "NVT2/output_270926/NVT2.restart.coor")
com = u.atoms.center_of_mass()
print("center of mass (x, y, z):", com)