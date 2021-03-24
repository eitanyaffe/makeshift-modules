merge.libs=function(nlv.bin, ifn, ids, template.ifn, template.id, ofn)
{
    # ifns = paste(lib.dir, "/libs/", ids, "/lib.nlv", sep="")
    ifns = NULL
    for (id in ids)
        ifns = c(ifns, gsub(template.id, id, template.ifn))
    if (length(ifns) > 1) {
        command = paste(nlv.bin, "merge", ofn, paste(ifns, collapse=" "))
    } else {
        cat(sprintf("single library in set, linking nlv file %s\n", ifns[1]))
        command = paste("ln -sf", ifns[1], ofn)
    }
    if (system(command) != 0)
        stop(paste("error in command:", command))
}

merge.sets=function(ifn, module, is.dry)
{
    df = load.table(ifn)
    sets = unique(df$set)
    N = length(sets)

    cat(sprintf("number of libraries: %d\n", dim(df)[1]))
    cat(sprintf("number of sets: %d\n", N))

    for (set in sets) {
        ids = paste(df$lib[df$set == set], collapse=" ")
        command = sprintf("make m=%s nlv_merge_lib NLV_SET=%s NLV_SET_IDS='%s'",
            module, set, ids)
        if (is.dry) {
            command = paste(command, "-n")
        }
        if (system(command) != 0)
            stop(paste("error in command:", command))
    }
}

get.set.ids=function(ifn, ofn)
{
    df = load.table(ifn)
    sets = unique(df$set)
    cat(sprintf("writing file: %s\n", ofn))
    fc = file(ofn)
    writeLines(paste(sets, collapse=" "), fc)
    close(fc)
}

make.set.pairs=function(ifn, module, target, is.dry)
{
    df = load.table(ifn)
    sets = unique(df$set)
    N = length(sets)

    cat(sprintf("number of libraries: %d\n", dim(df)[1]))
    cat(sprintf("number of sets: %d\n", N))


    for (i in 1:N) {
        for (j in 1:N) {
            if (i >= j)
                next
            set.i = sets[i]
            set.j = sets[j]
            command = sprintf("make m=%s %s NLV_SET1=%s NLV_SET2=%s",
                module, target, set.i, set.j)
            if (is.dry) {
                command = paste(command, "-n")
            }
            if (system(command) != 0)
                stop(paste("error in command:", command))
        }
    }
    if (is.dry)
        stop(paste("dry run, stopping", command))
}

make.sets=function(ifn, module, target, is.dry)
{
    df = load.table(ifn)
    sets = unique(df$set)
    N = length(sets)

    cat(sprintf("number of libraries: %d\n", dim(df)[1]))
    cat(sprintf("number of sets: %d\n", N))

    for (i in 1:N) {
        set = sets[i]
        command = sprintf("make m=%s %s NLV_SET=%s",
            module, target, set)
        if (is.dry) {
            command = paste(command, "-n")
        }
        if (system(command) != 0)
            stop(paste("error in command:", command))
    }
    if (is.dry)
        stop(paste("dry run, stopping", command))
}

make.set.table=function(ifn, base.dir, ofn)
{
    df = load.table(ifn)
    sets = unique(df$set)
    result = data.frame(set=sets, fn=paste(base.dir, "/sets/", sets, "/set.nlv", sep=""))
    save.table(result, ofn)
}
