
### cluster distance
cluster_center=function(label, x){
  cluster=data.frame(which(label == x, arr.ind=TRUE))
  dim = unname(colMeans(cluster))
  return(dim)}


get_cluster_index = function(p, label){
  mat = c()
  cluster_num = max(label)
  nam = paste0("cluster_",1:cluster_num)

  for (i in 1:cluster_num){
    assign(nam[i], cluster_center(label, i))
  }

  for (item in nam){
    mat = rbind(mat, get(item))
  }
  df = data.frame(mat)
  df$cluster = 1:cluster_num
  df$subject = p
  return(df)}

exc_index = function(df, label, thre){
  diff_2 = abs(diff(df$X2[1:2]))/min(df$X2[1:2])
  if (diff_2 < thre){
    avg = df %>% filter(cluster %in% c(1,2)) %>% pull(X2) %>% mean()
    other = df %>% filter(!cluster %in% c(1,2)) %>% pull(X2)
    if (length(other) != 0){
    diff = sapply(other, function(x) abs((x-avg)/avg), USE.NAMES = FALSE)}else{diff = 0}
    exc = which(diff > thre) + 2
    extra_df = data.frame()
    }else{
      ind_max = which(df$X2[1:2] == max(df$X2[1:2]))
      ind_min = which(df$X2[1:2] == min(df$X2[1:2]))
      avg = df %>% filter(cluster %in% c(1,2,3)[-ind_max]) %>% pull(X2) %>% mean()
      extra_df = data.frame(which(label == ind_max, arr.ind=TRUE)) %>% filter(dim2 <= avg*(1+thre))
      other = df %>% filter(!cluster %in% c(1,2,3)[-ind_max]) %>% pull(X2)
      if (length(other) != 0){
      diff = sapply(other, function(x) abs((x-avg)/avg), USE.NAMES = FALSE)}else{diff = 0}
      exc = c(ind_max, which(diff[-1] > thre) + 2)
    }
  return(list(exc, extra_df))}


fix_typeI_seg = function(p, df, thre, label, orig, out, L){
  exc = exc_index(df, label, thre)[[1]]
  extra_df = exc_index(df, label, thre)[[2]]
  
  if(nrow(extra_df)== 0){
    mask = !(label %in% exc | label == 0)}else{
      mask = !(label %in% exc | label == 0)
      for(i in 1:nrow(extra_df)) {
        mask[extra_df[[i,"dim1"]], extra_df[[i,"dim2"]], extra_df[[i,"dim3"]]] = 1
      }
    }
  cp = mask * orig
  other = (!(orig == 31 | orig == 63)) * orig
  img_edit = other + cp
  message("saving edited segmentation...........")
  img_edit_rev = fslr::reverse_rpi_orient(img_edit, convention = L$convention, orientation = L$orientation)
  mri_convert(img_edit_rev, outfile = paste0(out, "/automatic_pipeline/", p, "/mri/aseg_editted.mgz"))
  writenii(mask, paste0(out, "/editted/", p, "/choroid_plexus_editted_mask"))
  df$exclude_status = sapply(df$cluster, function(x){
    if(x %in% exc){return("Yes")}else{return("No")}
  }, USE.NAMES = FALSE)
  return(df)
}



