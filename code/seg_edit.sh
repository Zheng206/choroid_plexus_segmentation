#!/bin/bash

patient=`ls choroid_plexus/automatic_pipeline | grep -v fsaverage`

SUBJECTS_DIR=$PWD/choroid_plexus/automatic_pipeline
export $SUBJECTS_DIR

for p in $patient;
do
    bsub -J "segmentation" -oo out.log -eo err.log singularity run --cleanenv \
    -B $PWD \
    -B /scratch \
    --env SUBJECTS_DIR=$PWD/choroid_plexus/automatic_pipeline \
    --env SURFER_FRONTDOOR=1 \
    --env FS_LICENSE=$PWD/license/license.txt $1 mri_segstats --seg $SUBJECTS_DIR/$p/mri/aseg_editted.mgz \
                                                              --sum $SUBJECTS_DIR/$p/stats/aseg_editted.stats \
                                                              --pv $SUBJECTS_DIR/$p/mri/norm.mgz --empty --brainmask $SUBJECTS_DIR/$p/mri/brainmask.mgz \
                                                              --brain-vol-from-seg --excludeid 0 \
                                                              --excl-ctxgmwm --supratent --subcortgray --in $SUBJECTS_DIR/$p/mri/norm.mgz \
                                                              --in-intensity-name norm --in-intensity-units MR \
                                                              --etiv --surf-wm-vol --surf-ctx-vol --totalgray \
                                                              --euler --ctab $PWD/license/ASegStatsLUT.txt \
                                                              --subject $p
done 

