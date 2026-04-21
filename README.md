# Oligourethanes---MSA-MD

Setup for Multiple Simulated Annealing - Molecular Dynamics (MSA-MD)



Analysis

Clustering - conformer populations


#take xtc files
for i in {1..200}; do echo 0 | mpirun -np 1 gmx_mpi trjconv -f $i/md.trr -o $i/md.xtc; done

#concatenate
for dir in {1...200}; do mpirun -np 1 gmx_mpi trjcat -f */md.xtc -o concatenated_trajectories/all_md.xtc -cat; done

#center
mpirun -np 1 gmx_mpi trjconv -f all_md.xtc -s md.tpr -pbc mol -center -o centered_$name.xtc <<< $'2\n2'

1st create index.ndx - hydrogen atoms are excluded from the RMSD calculation
mpirun -np 1 gmx_mpi make_ndx -f md.tpr -o index.ndx 
r UNK & ! a H*
name 4 HA
q!

to run cluster.sh - uses gromos method; cut-off 0.2 nm
