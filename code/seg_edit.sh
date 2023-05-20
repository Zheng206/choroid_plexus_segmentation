#!/bin/bash

patient=`ls choroid_plexus/automatic_pipeline`

module load singularity/3.8.3 # loading singularity module from the cluster

# set temporary directory
SINGULARITYENV_TMPDIR=/scratch # set singularity tmpdir to the cluster tmpdir

for p in $patient;
do
    bsub -J "segmentation" -oo out.log -eo err.log singularity run --cleanenv \
    -B $PWD \
    -B /scratch \
    --env SUBJECTS_DIR=$PWD/choroid_plexus/automatic_pipeline \
    --env SURFER_FRONTDOOR=1 \
    --env FS_LICENSE=$PWD/license.txt /project/singularity_images/neuror_latest.sif mri_segstats --seg $SUBJECTS_DIR/$p/mri/aseg_editted.mgz \
             --sum $SUBJECTS_DIR/$p/stats/aseg_eitted.stats \
             --pv $SUBJECTS_DIR/$p/mri/norm.mgz --empty --brainmask $SUBJECTS_DIR/$p/mri/brainmask.mgz \
             --brain-vol-from-seg --excludeid 0 \
             --excl-ctxgmwm --supratent --subcortgray --in $SUBJECTS_DIR/$p/mri/norm.mgz \
             --in-intensity-name norm --in-intensity-units MR \
             --etiv --surf-wm-vol --surf-ctx-vol --totalgray \
             --euler --ctab $FREESURFER_HOME/ASegStatsLUT.txt \
             --subject $p
done 

