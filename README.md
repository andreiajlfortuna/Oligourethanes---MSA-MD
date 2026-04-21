# Oligourethanes — MSA-MD

Setup and analysis workflow for **Multiple Simulated Annealing – Molecular Dynamics (MSA-MD)** simulations.

---

## Analysis Workflow

### Clustering — Conformer Populations

This section describes how to process trajectories and perform clustering analysis.

---

### 1. Convert `.trr` to `.xtc`

Extract compressed trajectory files from simulation outputs:

```bash
for i in {1..200}; do
  echo 0 | mpirun -np 1 gmx_mpi trjconv -f $i/md.trr -o $i/md.xtc
done
```

---

### 2. Concatenate Trajectories

Combine all trajectory files into a single dataset:

```bash
mpirun -np 1 gmx_mpi trjcat -f */md.xtc -o concatenated_trajectories/all_md.xtc -cat
```

---

### 3. Center the Trajectory

Remove periodic boundary effects and center the molecule:

```bash
mpirun -np 1 gmx_mpi trjconv \
  -f all_md.xtc \
  -s md.tpr \
  -pbc mol \
  -center \
  -o centered_${name}.xtc <<< $'2\n2'
```

---

### 4. Create Index File

Exclude hydrogen atoms from RMSD calculations:

```bash
mpirun -np 1 gmx_mpi make_ndx -f md.tpr -o index.ndx
```

Inside the interactive prompt:

```
r UNK & ! a H*
name 4 HA
q
```

---

### 5. Clustering (GROMOS Method)

Run the clustering script:

```bash
bash cluster.sh
```

### Parameters

* Every **10th frame** is used for clustering
* Total sample size: **100,000 snapshots**
* Time interval: **20 ps**

---

### Output

The clustering procedure generates:

* **Clustered PDB file (single system)**

  * Contains representative (middle) structures
  * Sorted from **most populated → least populated cluster**

* **Individual cluster PDB files**

  * Each file represents one cluster
  * Includes structures belonging to that cluster

---

###   Notes

* Hydrogen atoms are excluded to improve RMSD-based clustering accuracy
* Ensure all trajectory files are consistent before concatenation
* Parallel execution (`mpirun`) is used but configured here for single-core runs

---

 
