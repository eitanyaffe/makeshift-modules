lib.order=function(ifn, field, start.day, end.day, ofn)
{
    df = load.table(ifn)
    df$day = df[,field]
    df = df[,c("Meas_ID", "day")]

    length = end.day - start.day
    df$order = df$day - start.day
    df$order = ifelse(df$order<0, -df$order + length-0.5, df$order)
    df = df[order(df$order),]
    df$order = 1:dim(df)[1]
    df = df[order(df$day),]

    save.table(df, ofn)
}

create.lib.links=function(ifn, base.dir, n.samples, n.reads, lib.ids.ofn, odir)
{
    df = load.table(ifn)
    df = df[order(df$order),]
    ids = df$Meas_ID[1:n.samples]

    cat(sprintf("creating links in directory: %s\n", odir))
    for (i in 1:length(ids)) {
        id = ids[i]
        ifn1 = paste(base.dir, "/libs/", id, "/subsample/", n.reads/1000, "k/R1.fastq", sep="")
        ifn2 = paste(base.dir, "/libs/", id, "/subsample/", n.reads/1000, "k/R2.fastq", sep="")

        ofn1 = paste(odir, "/", id, "_R1.fastq", sep="")
        ofn2 = paste(odir, "/", id, "_R2.fastq", sep="")

        if (!file.exists(ifn1))
            stop(sprintf("file not found: %s", ifn1))
        if (!file.exists(ifn2))
            stop(sprintf("file not found: %s", ifn2))

        command = sprintf("ln -sf %s %s", ifn1, ofn1)
        if (system(command) != 0)
            stop(sprintf("command failed: %s", command))

        command = sprintf("ln -sf %s %s", ifn2, ofn2)
        if (system(command) != 0)
            stop(sprintf("command failed: %s", command))

    }
    command = paste("echo", paste(ids, sep=" ", collapse=" "), " > ", lib.ids.ofn)
    if (system(command) != 0)
        stop(sprintf("command failed: %s", command))
}

