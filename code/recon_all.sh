#!/bin/bash

# Use Singularity
module load singularity/3.8.3 # loading singularity module from the cluster

# set temporary directory
SINGULARITYENV_TMPDIR=/scratch # set singularity tmpdir to the cluster tmpdir

for inv in $(find data -name "mprage.nii.gz" -type f);
do
    subject=`echo $inv | cut -f 2 -d '/'`
    bsub -J "segmentation" -oo out.log -eo err.log singularity run --cleanenv \
    -B $PWD \
    -B /scratch \
    --env SUBJECTS_DIR=$PWD/choroid_plexus/automatic_pipeline \
    --env SURFER_FRONTDOOR=1 \
    --env FS_LICENSE=$PWD/license.txt /project/singularity_images/neuror_latest.sif recon-all -i $inv -subject $SUBJECTS_DIR/$subject -all
done 


