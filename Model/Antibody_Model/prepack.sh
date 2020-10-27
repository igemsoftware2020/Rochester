#!/bin/bash
#SBATCH -p standard -n 8
#SBATCH -t 1-00:00:00
#SBATCH --mail-type=FAIL,END --output=prepack.log
#SBATCH -a 1-8

# Aftter we relax the antibody and biomarker PDBs, we combine the biomarker and antibody in one PDB for each antibody, which is the initial pose.
# Before we can SnugDock the initial pose, we need to prepack the initial pose PDBs into a form readable by SnugDock.
# The initial pose PDBs were saved as 1-8.pdb.

# Load ROSETTA.
module load rosetta/2020.08

# Prepack.
docking_prepack_protocol.default.linuxgccrelease 
# Prepack database.
/-database /software/rosetta/src/rosetta_src_2020.08.61146_bundle/main/database 
# Input files 1-8.pdb
/-s $SLURM_ARRAY_TASK_ID.pdb 
# Specify the antibody chain (LH) and biomarker (A) chain in the PDB.
/-docking:partners LH_A 
# Recommended options by ROSETTA.
/-ex1 -ex2aro 
# Output files into the folders 1-12
/-out:path:all $SLURM_ARRAY_TASK_ID 
