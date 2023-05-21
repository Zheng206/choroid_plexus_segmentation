#!/bin/bash

# Use Singularity

# set temporary directory

for inv in $(find data -name $2 -type f);
do
    subject=`echo $inv | cut -f 2 -d '/'`
    bsub -J "segmentation" -oo out.log -eo err.log singularity run --cleanenv \
    -B $PWD \
    -B /scratch \
    --env SUBJECTS_DIR=$PWD/choroid_plexus/automatic_pipeline \
    --env SURFER_FRONTDOOR=1 \
    --env FS_LICENSE=$PWD/license/license.txt $1 recon-all -i $inv -subject $SUBJECTS_DIR/$subject -all
done 


