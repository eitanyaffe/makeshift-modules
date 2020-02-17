create.tables=function(sample.ifn, seq.ifn, subject.lookup.ifn, base.dir, subject.id, ofn.lib.table, ofn.lib.ids)
{
    df = load.table(sample.ifn)
    seq.df = load.table(seq.ifn)
    subject.lookup = load.table(subject.lookup.ifn)

    df = df[df$ID != "" & df$Subject != "" & df$Note != "Andres",]
    if (any(duplicated(df$ID)))
        stop("field ID is not unique")

    if (any(is.na(match(df$ID, seq.df$Sample.ID))))
        stop("internal")
    df$seq.key = seq.df$Sample_Name[match(df$ID, seq.df$Sample.ID)]

    df = df[!is.na(match(df$Subject, subject.lookup$index)),]
    df$subject.id = subject.lookup$subject[match(df$Subject, subject.lookup$index)]

    result = data.frame(lib.id=df$ID, subject=df$subject.id, passage=df$Passage, media=df$Media, cipro=df$Cipro, replicate=df$Replicate, seq.key=df$seq.key, note=df$Note)

    if (!any(result$subject == subject.id))
        stop("subject not found")
    result = result[result$subject == subject.id,]

    result$dir = base.dir
    result$fn1 = ""
    result$fn2 = ""

    for (i in 1:dim(result)[1]) {
        pattern = paste(result$seq.key[i], "_S", sep="")
        fns = list.files(path=base.dir, pattern=pattern)
        if (length(fns) == 0) {
            cat(sprintf("Warning: Skipping sample since files are missing for sample %s, directory=%s, key=%s\n", result$lib.id[i], base.dir, result$seq.key[i]))
            next
        }
        if (length(fns) != 2)
            stop(sprintf("expecting two files for measure %s in directory: %s", result$lib.id[i], base.dir))
        result$fn1[i] = fns[grepl("R1", fns)]
        result$fn2[i] = fns[grepl("R2", fns)]
    }

    save.table(result, ofn.lib.table)

    cat(sprintf("saving ids to file: %s\n", ofn.lib.ids))
    command = paste("echo", paste(result$lib.id, sep=" ", collapse=" "), " > ", ofn.lib.ids)
    if (system(command) != 0)
        stop(sprintf("command failed: %s", command))
}
