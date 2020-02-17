source("R/distrib.r")

# directory with files which have matching R1/R2 in names
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

distrib.pair.fastq=function(
    pair.script, idir, pattern, odir.pairs, odir.R1, odir.R2, wdir,
    qsub.dir, batch.max.jobs, total.max.jobs.fn, dtype, jobname)
{
  system(paste("rm -rf", qsub.dir))
  system(paste("mkdir -p", qsub.dir, odir.pairs, odir.R1, odir.R2))

  files = list.file.pairs(path=idir, pattern=pattern)

  N = dim(files)[1]
  cat(sprintf("processing %s files found in directory: %s\n", N, idir))
  if (N == 0)
      stop()
  commands = NULL
  for (i  in 1:N) {
      ifn1 = files$fn1[i]
      ifn2 = files$fn2[i]
      base = files$base[i]
      ofn.paired.R1 = paste(odir.pairs, "/R1", base, sep="")
      ofn.paired.R2 = paste(odir.pairs, "/R2", base, sep="")
      ofn.non.paired.R1 = paste(odir.R1, "/R1", base, sep="")
      ofn.non.paired.R2 = paste(odir.R2, "/R2", base, sep="")
      command = paste("perl", pair.script, ifn1, ifn2, ofn.paired.R1, ofn.paired.R2, ofn.non.paired.R1, ofn.non.paired.R2)
      # cat(sprintf("command: %s\n", command))
      commands = c(commands, command)
  }

  distrib(commands, working.dir=wdir, qsub.dir=qsub.dir, jobname=jobname, batch.max.jobs=batch.max.jobs,
	  total.max.jobs.fn=total.max.jobs.fn, sleep.time=10, rprofile=NULL,
	  path=NULL, host.keys=NULL, retries=3, req.mem=NA, dtype=dtype)
}

