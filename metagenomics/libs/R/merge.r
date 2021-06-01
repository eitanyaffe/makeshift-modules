merge.fastq=function(ifn, idir, ofn1, ofn2)
{
    df = load.table(ifn)
    cat(sprintf("generating merged R1 file: %s\n", ofn1))
    cat(sprintf("generating merged R2 file: %s\n", ofn2))
    exec=function(cmd) {
        if (system(cmd) != 0)
            stop(sprintf("failed running command: %s\n", cmd))
    }
    exec(paste("rm -rf", ofn1, ofn2))
    for (i in 1:dim(df)[1]) {
        id = df$chunk[i]
        ifn1 = paste0(idir, "/", id, "/paired/paired_R1.fastq")
        ifn2 = paste0(idir, "/", id, "/paired/paired_R2.fastq")
        exec(paste("cat", ifn1, ">>", ofn1))
        exec(paste("cat", ifn2, ">>", ofn2))
    }
}

merge.stats=function(ifn, idir, ofn)
{
    df = load.table(ifn)
    cat(sprintf("merging stats from dir: %s\n", idir))
    rr = NULL
    for (i in 1:dim(df)[1]) {
        id = df$chunk[i]
        rr.i = read.delim(paste0(idir, "/", id, "/remove_human/.count_deconseq"), header=F)
        if (i == 1)
            rr = rr.i
        else
            rr[,3:4] = rr[,3:4] + rr.i[,3:4]
    }
    cat(sprintf("saving result table: %s\n", ofn))
    write.table(rr, ofn, quote=F, row.names=F, col.names=F, sep="\t")
}
