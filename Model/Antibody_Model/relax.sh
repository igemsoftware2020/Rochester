#!/bin/bash
#SBATCH -p standard -n 12
#SBATCH -t 1-00:00:00
#SBATCH --mail-type=FAIL,END
#SBATCH --output=relax.log
#SBATCH -a 1-12

# Before we can work with PDBs in ROSETTA, we need to relax the PDBs into a ROSETTA readable file.
# The antibody PDBs were saved as 1-8.pdb; the biomarker PDBs were saved as 9-12.pdb.

# Load ROSETTA.
module load rosetta/2020.08

# Relax.
relax.default.linuxgccrelease 
# Input files 1-12.pdb
/-in:file:s $SLURM_ARRAY_TASK_ID.pdb
# Relax into 5 constructs, out of which we chose one based on the energy score.
/-nstruct 5
# Recommended options by ROSETTA 
/-relax:constrain_relax_to_start_coords -relax:ramp_constraints false -ex1 -ex2 -use_input_sc -flip_HNQ -no_optH false 
# Output files into the folders 1-12
/-out:path:all $SLURM_ARRAY_TASK_ID
