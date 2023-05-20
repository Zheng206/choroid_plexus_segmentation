
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

exc_index = function(df, thre){
  avg = df %>% filter(cluster %in% c(1,2)) %>% pull(X2) %>% mean()
  other = df %>% filter(!cluster %in% c(1,2)) %>% pull(X2)
  if (length(other) != 0){
  diff = sapply(other, function(x) (x-avg)/avg, USE.NAMES = FALSE)}else{diff = 0}
  exc = which(diff > thre) + 2
  return(exc)}


fix_typeI_seg = function(df, thre, label, orig, out){
  exc = exc_index(df, thre)
  mask = !(label %in% exc | label == 0)
  cp = mask * orig
  other = (!(orig == 31 | orig == 63)) * orig
  img_edit = other + cp
  message("saving edited segmentation...........")
  writenii(img_edit, paste0(out, "/aseg_editted"))
  mri_convert(img_edit, outfile = paste0(out, "/aseg_editted.mgz"))
  writenii(mask, paste0(out, "/choroid_plexus_editted_mask"))
}



