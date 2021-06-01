compare=function(binary, ifn, idir, wdir, kmer, ofn, ofn.stats)
{
    # collect signatures locally
    df = load.table(ifn)
    system(paste("mkdir -p", wdir))
    tfns =  paste0(wdir, "/", df$SGCC_LIB_ID, ".sig")

    # verify files exist
    missing.files = NULL
    cat(sprintf("locating %d signature files under: %s\n", dim(df)[1], idir))
    for (i in 1:dim(df)[1]) {
        fn = sprintf("%s/libs/%s/work/sourmash.sig", idir, df$SGCC_LIB_ID[i])
        if (!file.exists(fn))
            missing.files = c(missing.files, fn)
    }
    if (length(missing.files) > 0)
        stop(sprintf("signature file missing: %d\nfiles: %s\n", length(missing.files), paste(missing.files, collapse=",")))

    # copy files
    cat(sprintf("copying signature files: %d\n", dim(df)[1])) 
    for (i in 1:dim(df)[1]) {
        exec(sprintf("cp %s/libs/%s/work/sourmash.sig %s", idir, df$SGCC_LIB_ID[i], tfns[i]), verbose=F)
    }
    
    wfn = paste0(wdir, "/table")
    write.table(x=paste0(df$SGCC_LIB_ID, ".sig"), file=wfn, quote=F, row.names=F,col.names=F)

    # compare sigs
    exec(sprintf("cd %s && %s compare -k %d --from-file %s --csv %s",
                      wdir, binary, kmer, wfn, ofn))
    system(paste("rm -rf", wdir))

    rr.stats = NULL
    for (i in 1:dim(df)[1]) {
        xx = read.delim(sprintf("%s/libs/%s/work/read_count", idir, df$SGCC_LIB_ID[i]), header=F)
        rr.stats = rbind(rr.stats, data.frame(id=xx[1,1], reads=sum(xx[,3]), bps=sum(xx[,4])))
    }
    save.table(rr.stats, ofn.stats)
}
