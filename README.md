# Choroid Plexus Segmentation Pipeline

The proposed pipeline is developed on the Freesurfer built-in pipeline and further fixs the Type I issue (extra masks around lateral ventricle area), aiming to get a more accurate choroid plexus segmentation. To better avoid the potential inconvenience from software installation, we suggest to use a estabilished singularity image from PennSIVE group that contains all required packages.

To better use the pipeline, the following steps should be followed:

*   Organize MRI data into a specific format
*   Set up singularity on the cluster
*   Run Freesurfer built-in Pipeline
*   Run Type I Issue Fixing Script
*   Segmentation Quality Check
*   Run Stats Regeneration and Extraction Pipeline

## Data Structure

On the current stage, the proposed pipeline highly relied on the data structure. Therefore, we suggest users to manage their MRI data using the following format:

Main Directory: UVM_data (as you name) 

(Note: users can download code and license from Github and save it in the main directory) 

>   * data
>        * subject
>            * anat
>                * flair.nii.gz
>                * mprage.nii.gz
>                * T2star.nii.gz
>   * code
>       * automatic_typeI_fix.R
>       * extract_mask.R
>       * recon_all.sh
>       * seg_edit.sh
>       * TypeI_fixing.R
>   * license
>       * license.txt
>       * ASegStatsLUT.txt
>   * choroid_plexus
>       * automatic_pipeline
>       * editted
>       * quality_check
>       * volume

Some commands to help create choroid_plexus folder under the main directory:

```bash
cd /path/to/main_dir(UVM_data)

mkdir choroid_plexus
mkdir choroid_plexus/automatic_pipeline
mkdir choroid_plexus/editted
mkdir choroid_plexus/quality_check
mkdir choroid_plexus/volume
```

## Set up Singularity 

```bash
module load singularity/3.8.3 
# you may have a different version of singularity on your cluster, please check for the right version.

sin_path=/path/to/save/image/neuror.sif

singularity pull -F $sin_path docker://pennsive/neuror
```

## Run FreeSurfer Built-in Pipeline

```bash
SINGULARITYENV_TMPDIR=/scratch
# set singularity tmpdir to the cluster tmpdir, might be different from cluster to cluster.

bash code/recon_all.sh $sin_path "mprage.nii.gz" 
```
Note: Need to replace "/scratch" here and inside recon_all.sh to your cluster tmp directory. Be causious about how to submit a job on cluster, it might be different from PennSIVE cluster

## Type I Issue Fixing 

After the Freesufer Pipeline is done for all subjects, we run the Type I Issue Fixing Step.

```bash
patient=`ls ./choroid_plexus/automatic_pipeline | grep -v "fsaverage"`

for p in $patient;
do
    bsub -J seg_fix -o out.log -e err.log singularity run --cleanenv \
    -B $PWD \
    -B /scratch \
    --env FS_LICENSE=$PWD/license/license.txt \
    --env SURFER_FRONTDOOR=1 \
    $sin_path Rscript $PWD/code/automatic_typeI_fix.R p=$p thre=0.2
done
```
Note: Again, be causious about submiting a job on cluster and binding cluster tmp directory.

## Quality Check

Upon finishing the Type I Issue fixing step, make sure to conduct a quality check for editted choroid segmentation (we use a default threshold of 0.2 to fix the Type I issue, but some patients might need a smaller threshold due to the remaining of Type I issue). Check **quality_summary_<patientID>.csv** file in the `data/quality_check` directory, go through each mask and record which patients need smaller threshold.

Then run Type I fixing for patients that require a different threshold:

* 20140213-1445
* 20160615-1501

```bash
patient="20140213-1445"
bsub -J seg_fix -o out_seg.log -e err_seg.log singularity run --cleanenv \
    -B $PWD \
    -B /scratch \
    --env FS_LICENSE=$PWD/license/license.txt \
    --env SURFER_FRONTDOOR=1 \
    $sin_path Rscript $PWD/code/automatic_typeI_fix.R p=$patient thre=0.1
```
Use patient "20140213-1445" for illustration

## Stats Regeneration

```bash
bash code/seg_edit.sh $sin_path
```


## Extract Volume Data

```bash
bsub -J seg_fix -o out.log -e err.log singularity run --cleanenv \
    -B $PWD \
    -B /scratch \
    --env FS_LICENSE=$PWD/license/license.txt \
    --env SURFER_FRONTDOOR=1 \
    $sin_path Rscript $PWD/code/extract_mask.R "aseg_editted.stats"
```
