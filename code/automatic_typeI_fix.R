library(neurobase)
library(tidyverse)
library(oro.nifti)
library(oro.dicom)
library(WhiteStripe)
library(fslr)
library(extrantsr)
library(ANTsR)
library(freesurfer)
source("code/TypeI_fixing.R")


main_dir = "./choroid_plexus"
patient = list.files(paste0(main_dir, "/automatic_pipeline"))
patient = patient[which(!grepl("MSDC_*|fsaverage", patient))]
aseg_img_files = list.files(path = main_dir, pattern = "^aseg.mgz", recursive = TRUE, full.names = TRUE)
brain_img_files = list.files(path = main_dir, pattern = "^brain.mgz", recursive = TRUE, full.names = TRUE)

typeI_fix_run = function(p, aseg_img_files, brain_img_files, thre, main_dir){
    out.dir = paste0(main_dir, "/editted/", p)
    dir.create(out.dir)
    img_1 = aseg_img_files[which(grepl(p,aseg_img_files))]
    brain_1 = brain_img_files[which(grepl(p,brain_img_files))]
    img = readmgz(img_1)
    brain = readmgz(brain_1)
    L = fslr::rpi_orient(img)
    reoriented_img = L[["img"]]
    L_brain = fslr::rpi_orient(brain)
    reoriented_brain = L_brain[["img"]]
    choroid_plexus = (reoriented_img == 31 | reoriented_img == 63)
    other_region = reoriented_img * (!choroid_plexus)
    writenii(choroid_plexus, paste0(out.dir, "/choroid_plexus_orig_mask"))
    writenii(reoriented_brain, paste0(out.dir, "/brain"))
    label = ants2oro(labelClusters(oro2ants(choroid_plexus),minClusterSize = 1))
    df = get_cluster_index(p, label)
    df$threshold = thre
    df = fix_typeI_seg(p, df, thre, label, reoriented_img, main_dir, L)
    return(df)
}

args = commandArgs(trailingOnly = TRUE)
p = str_split(args[1], "=")[[1]][2]
thre = as.numeric(str_split(args[2], "=")[[1]][2])


summary_df = typeI_fix_run(p, aseg_img_files, brain_img_files, thre, main_dir)
out = paste0(main_dir, "/quality_check/",p)
dir.create(out)
write_csv(summary_df,paste0(out, "/quality_summary_", p, ".csv"))


