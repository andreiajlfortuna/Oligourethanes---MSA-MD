#!/bin/bash
#SBATCH --job-name=gmx_cluster
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH -p standard
#SBATCH --time=40:00:00
#SBATCH --output=cluster_%j.out
#SBATCH --error=cluster_%j.err

set -euo pipefail

module purge
module load gromacs/2024.3-gcc-14.2.0

INPUT_DIR="$(pwd)"
NAME=cluster
SCRATCH_BASE="/mnt/storage_3/home/afortuna/pl0596-01/scratch"

export TMPDIR="$SCRATCH_BASE/$SLURM_JOB_ID"
export SCR="$TMPDIR"

mkdir -p "$TMPDIR"
cd "$TMPDIR"

cp -r "$INPUT_DIR" "$TMPDIR/"
cp "$INPUT_DIR/md.tpr" "$TMPDIR/"

cd "$TMPDIR/concatenated_trajectories"

printf "HA\nUNK\n" | gmx_mpi cluster \
    -n index.ndx \
    -s ../md.tpr \
    -f centered.xtc \
    -o clusters_0.2.xpm \
    -g clusters_0.2.log \
    -method gromos \
    -dist "clusters-rmsd-dist_0.2.xvg" \
    -sz "clusters-size_0.2.xvg" \
    -tr "clusters-trans_0.2.xpm" \
    -ntr "clusters-trans_0.2.xvg" \
    -clid "clusters-id_0.2.xvg" \
    -cl "clusters_0.2.pdb" \
    -wcl 100 \
    -cutoff 0.16 \
    -dt 20


# Copy outputs
OUTPUT_DIR="${NAME}_${SLURM_JOB_ID}"
mkdir -p "$SLURM_SUBMIT_DIR/$OUTPUT_DIR"
cp -r "$TMPDIR"/* "$SLURM_SUBMIT_DIR/$OUTPUT_DIR/"


# Cleanup
rm -rf "$TMPDIR"
