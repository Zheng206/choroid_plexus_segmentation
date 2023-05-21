library(neurobase)
library(tidyverse)
library(oro.nifti)
library(oro.dicom)
library(fslr)
library(extrantsr)
library(ANTsR)
library(freesurfer)

main_dir = "choroid_plexus"

### Extract Volume Data
aseg_files = list.files(pattern = "aseg_eitted.stats", recursive = TRUE, full.names = TRUE)
#aseg_files = aseg_files[which(grepl("stats/", aseg_files))]
patient = list.files(paste0(main_dir, "/automatic_pipeline"))
patient = patient[which(!grepl("fsaverage", patient))]

extract_data_f = function(x){
  p = str_split(x, "/")[[1]][4]
  out = read_aseg_stats(x)
  measure_df = out$measures %>% select(measure, value, units) %>% mutate(measure = paste0(measure, "_", units)) %>% select(measure, value) %>% pivot_wider(names_from = "measure", values_from = "value")
  measure_df$subject_id = p
  measure_df = measure_df[c(ncol(measure_df), 1:(ncol(measure_df)-1))]
  structure_df = out$structures %>% filter(SegId %in% c(31,63)) 
  structure_df$subject_id = p
  structure_df = structure_df[c(ncol(structure_df), 1:(ncol(structure_df)-1))]
  return(list(measure_df, structure_df))
}

data_list = vector("list", length(aseg_files))
data_list = lapply(aseg_files, extract_data_f)


measure_all_df = lapply(1:length(aseg_files), function(x) return(data_list[[x]][[1]])) %>% bind_rows()
structure_all_df = lapply(1:length(aseg_files), function(x) return(data_list[[x]][[2]])) %>% bind_rows()

write_csv(measure_all_df, paste0(main_dir, "/volume/measure_all.csv"))
write_csv(structure_all_df, paste0(main_dir, "/volume/choroid_plexus_all.csv"))



