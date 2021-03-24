make=function(ifn, type, target, is.dry)
{
    df = load.table(ifn)
    df = df[df$Meas_Type == type,]
    cat(sprintf("number of libraries: %d\n", dim(df)[1]))
    for (i in 1:dim(df)[1]) {
        lib.id = df$lib[i]
        subject.id = df$subject.id[i]
        command = sprintf("make %s LIB_ID=%s SUBJECT_ID=%s",
            target, lib.id, subject.id)
        if (is.dry) {
            command = paste(command, "-n")
        }
        if (system(command) != 0)
            stop(paste("error in command:", command))
    }
}

extract.ids=function(ifn, type, ofn)
{
    df = load.table(ifn)
    df = df[df$Meas_Type == type,]

    command = paste("echo", paste(df$lib, sep=" ", collapse=" "), " > ", ofn)
    if (system(command) != 0)
        stop(sprintf("command failed: %s", command))
}

compare.old=function(command.pre, ifn, type, ifn.template, id.template, kmer, ofn)
{
    df = load.table(ifn)
    df = df[df$Meas_Type == type,]
    ids = df$lib
    fns = NULL
    for (id in ids)
        fns = c(fns, gsub(id.template, id, ifn.template))
    command = sprintf("%s -k %d --csv %s %s",
                      command.pre, kmer, ofn, paste(fns, collapse=" "))
#    if (system(command) != 0)
#        stop(sprintf("command failed: %s", command))
}

compare=function(command.pre, idir, kmer, ofn)
{
    command = sprintf("%s compare -k %d --traverse-directory --csv %s %s",
                      paste(command.pre, collapse=" "), kmer, ofn, idir)
    cat(sprintf("command: %s\n", command))
    if (system(command) != 0)
        stop(sprintf("command failed: %s", command))
}
