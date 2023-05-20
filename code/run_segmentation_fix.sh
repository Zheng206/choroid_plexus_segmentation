#!/bin/bash
module load singularity/3.8.3
bsub -J seg_fix -n 35 -oo out.log -eo err.log singularity run --cleanenv \
    -B $PWD \
    -B /scratch \
    --env FS_LICENSE=$PWD/license.txt \
    --env SURFER_FRONTDOOR=1 \
    /project/singularity_images/neuror_latest.sif Rscript $PWD/code/choroid_plexus/automatic_typeI_fix.R