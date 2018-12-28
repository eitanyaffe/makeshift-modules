source("R/distrib.r")

distrib.ntcmp=function(
	  mummer, mummer.parse, split.dir1, split.dir2, odir,
	  qsub.dir, batch.max.jobs, total.max.jobs.fn, dtype, show.coords, parse.show.coords.script, jobname)
{
  system(paste("rm -rf", qsub.dir))
  system(paste("mkdir -p", qsub.dir, odir))

  files1 = list.files(split.dir1)
  N1 = length(files1)
  cat(sprintf("Using %s contig files found in directory: %s\n", N1, split.dir1))

  files2 = list.files(split.dir2)
  N2 = length(files2)
  cat(sprintf("Using %s contig files found in directory: %s\n", N2, split.dir2))

  commands = NULL
  for (i1  in 1:N1) {
  for (i2  in 1:N2) {
    file.i1 =  paste(split.dir1, "/", i1, sep="")
    file.i2 =  paste(split.dir2, "/", i2, sep="")

    if (!file.exists(file.i1) || !file.exists(file.i2))
      stop("input file missing")

    ofile =  paste(odir, "/", i1, "_", i2, ".table", sep="")
    command = paste(mummer, "-maxmatch -b -c -F", file.i1, file.i2, "|", mummer.parse, ofile)
    commands = c(commands, command)
  } }
  distrib(commands, working.dir=getwd(), qsub.dir=qsub.dir, jobname=jobname, batch.max.jobs=batch.max.jobs,
	  total.max.jobs.fn=total.max.jobs.fn, sleep.time=10, rprofile=NULL,
	  path=NULL, host.keys=NULL, retries=3, req.mem=NA, dtype=dtype)
}

