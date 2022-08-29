#!/bin/bash

#SBATCH --mail-type=FAIL
#SBATCH --mail-user=youremailhere@gmail.com
#SBATCH -p general
#SBATCH -o BlankFilter_%j.log
#SBATCH -e BlankFilter_%j.err
#SBATCH --job-name=BlankFilter
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=3
#SBATCH --mem=20gb
#SBATCH --time=2:00:00

##Move to correct WD
cd $SLURM_SUBMIT_DIR
source ../samples.conf
cd $MAIN_DIR/3_BlankFilter

##load modules
module unload python
module load dimspy

echo "Starting Blank Filter"
#Blank Filter:
#Filter peaks across samples that are present in the blank samples.

dimspy blank-filter \
--input ../2_AlignSamples/alignSamples.* \
--output blankFilter.$SLURM_JOB_ID \
--blank-label 'blank' \
--min-fraction 0.0 \
--function mean \
--min-fold-change 0.0 \
--remove-blank-samples

echo "Blank Filter Complete"

dimspy create-sample-list \
--input blankFilter.$SLURM_JOB_ID \
--output  samplelist.blankFilter.$SLURM_JOB_ID \
--delimiter tab

dimspy hdf5-pm-to-txt \
--input blankFilter.$SLURM_JOB_ID \
--output pm.blankFilter.$SLURM_JOB_ID \
--delimiter tab \
--attribute_name intensity \
--representation-samples rows

dimspy hdf5-pm-to-txt \
--input blankFilter.$SLURM_JOB_ID \
--output comp.blankFilter.$SLURM_JOB_ID \
--delimiter tab \
--comprehensive \
--attribute_name intensity \
--representation-samples rows

echo "Conversion of Files Complete"
echo "Step Complete"

echo "Submitting Next Step"
cd ../4_SampleFilter/
sbatch RunSampleFilter.sh

