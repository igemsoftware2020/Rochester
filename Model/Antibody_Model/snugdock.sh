#!/bin/bash
#SBATCH -p standard -n 8 -t 2-00:00:00 -a 1-8
#SBATCH --mail-type=FAIL,END --output=snugdock.log

#After we prepack the initial pose, we can find the antibody binding site with SnugDock.
# The prepacked initial pose PDBs were saved as 1-8.pdb

# Load ROSETTA.
module load rosetta/2020.08

# SnugDock.
snugdock.linuxgccrelease 
# Input files 1-8.pdb
/-s $SLURM_ARRAY_TASK_ID.pdb 
# Score files store the energy score with which we compare the 200 poses found by ROSETTA.
/-out:file:scorefile score.$SLURM_ARRAY_TASK_ID.sc 
# Output new binding poses
/-out:path:all $SLURM_ARRAY_TASK_ID 
# Other options specified in file "flags".
@flags
