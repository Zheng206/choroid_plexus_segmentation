
library(neurobase)
library(tidyverse)
library(oro.nifti)
library(oro.dicom)
library(WhiteStripe)
library(fslr)
library(extrantsr)
library(ANTsR)
library(freesurfer)
source("/home/zhengren/Desktop/Project/choroid_plexus_segmentation/code/choroid_plexus/TypeI_fixing.R")

main_dir = "/home/zhengren/Desktop/Project/uvm_40_patients/choroid_plexus"
patient = list.files(paste0(main_dir, "/automatic_pipeline"))
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
    label = ants2oro(labelClusters(oro2ants(choroid_plexus),minClusterSize = 20))
    df = get_cluster_index(p, label)
    df$threshold = thre
    p_new = str_split(p,"_")[[1]][2]
    fix_typeI_seg(df, thre, label, reoriented_img, paste0(main_dir, "/automatic_pipeline/", p, "/", p_new, "/mri"))
    return(df)
}

#i = as.numeric(Sys.getenv("LSB_JOBINDEX"))
summary_df = parallel::mclapply(1:length(patient), function(i) typeI_fix_run(patient[i], aseg_img_files, brain_img_files, 0.2, main_dir),
                        mc.cores = future::availableCores()) %>% dplyr::bind_rows()
#summary_df = typeI_fix_run(patient[i], aseg_img_files, brain_img_files, 0.2, main_dir)
write_csv(summary_df,paste0(main_dir, "/quality_check/quality_summary.csv"))
