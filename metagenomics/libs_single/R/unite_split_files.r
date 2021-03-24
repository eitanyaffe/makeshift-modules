list.file.pairs=function(path, pattern)
{
    fns = list.files(path, pattern)
    if (length(fns) == 0)
        stop(paste("no files found in", path))
    if (!all(grepl("R[12]", fns)))
        stop("not all files have R[12] in name")
    fns = unique(gsub("R[12]", "@@@@", fns))
    bname = gsub("@@@@", "", fns)
    fns = paste(path, "/", fns, sep="")
    data.frame(base=bname, fn1=gsub("@@@@", "R1", fns), fn2=gsub("@@@@", "R2", fns))
}

unite.split.files=function(idir, pattern, ofn1, ofn2)
{
  files = list.file.pairs(path=idir, pattern=pattern)
  system(paste("rm -rf", ofn1, ofn2))
  N = dim(files)[1]
  cat(sprintf("processing %s files found in directory: %s\n", N, idir))
  cat(sprintf("generating R1 file: %s\n", ofn1))
  cat(sprintf("generating R2 file: %s\n", ofn2))

  if (N == 0)
      stop()
  commands = NULL
  for (i  in 1:N) {
      ifn1 = files$fn1[i]
      ifn2 = files$fn2[i]
      command1 = sprintf("cat %s >> %s", ifn1, ofn1)
      command2 = sprintf("cat %s >> %s", ifn2, ofn2)

      if (system(command1) != 0)
          stop(sprintf("error in command: %s", command1))
      if (system(command2) != 0)
          stop(sprintf("error in command: %s", command2))
  }
}
