uncompress=function(idir, count, ofn.table, odir) {
    ifn.table = paste(idir, "/table", sep="")
    df = load.table(ifn.table)
    df$dup = duplicated(df$submitted_subject_id_s)
    df = df[!df$dup,]

    N = dim(df)[1]
    if (count > 0)
        N = min(N, count)

    df = df[1:N,]

    result = data.frame(subject.id=df$submitted_subject_id_s, run.id=df$Run_s)
    save.table(result, ofn.table)

    for (id in result$run.id) {
        ifn1 = sprintf("%s/%s_1.fastq.gz", idir, id)
        ifn2 = sprintf("%s/%s_2.fastq.gz", idir, id)

        tdir = paste(odir, "/", id, sep="")
        ofn1 = paste(tdir, "/R1.fastq", sep="")
        ofn2 = paste(tdir, "/R2.fastq", sep="")

        done.fn =  paste(tdir, "/.done", sep="")
        if (file.exists(done.fn))
            next

        if (system(paste("mkdir -p", tdir)) != 0)
            stop("internal error")

        command1 = sprintf("gunzip -fvc %s > %s", ifn1, ofn1)
        command2 = sprintf("gunzip -fvc %s > %s", ifn2, ofn2)

        cat(sprintf("command1: %s\n", command1))
        if (system(command1) != 0)
            stop("internal error")

        cat(sprintf("command2: %s\n", command2))
        if (system(command2) != 0)
            stop("internal error")

        cat(sprintf("touch %s\n", done.fn))
        if (system(sprintf("touch %s",done.fn)) != 0)
            stop("internal error")

        cat("sleeping 2 minutes between commands...\n")
        if (system("sleep 2m") != 0)
            stop("break")
    }
}
