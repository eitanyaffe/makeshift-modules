make.from.hmd=function(ifn, target, is.dry)
{
    df = load.table(ifn)
    cat(sprintf("number of libraries: %d\n", dim(df)[1]))
    for (i in 1:dim(df)[1]) {
        ifn1 = paste(df$dir[i], "/", df$fn1[i], sep="")
        ifn2 = paste(df$dir[i], "/", df$fn2[i], sep="")
        lib.id = df$Meas_ID[i]
        command = sprintf("make %s LIB_ID=%s TEMPO_INPUT_R1=%s TEMPO_INPUT_R2=%s",
            target, lib.id, ifn1, ifn2)
        if (is.dry) {
            command = paste(command, "-n")
        }
        if (system(command) != 0)
            stop(paste("error in command:", command))
    }
}

make.from.passage=function(ifn, target, is.dry)
{
    df = load.table(ifn)
    cat(sprintf("number of libraries: %d\n", dim(df)[1]))
    for (i in 1:dim(df)[1]) {
        ifn1 = paste(df$dir[i], "/", df$fn1[i], sep="")
        ifn2 = paste(df$dir[i], "/", df$fn2[i], sep="")
        lib.id = df$lib.id[i]

        # !!!
        if (lib.id == "S313")
            next

        command = sprintf("make %s LIB_ID=%s LIB_INPUT_R1=%s LIB_INPUT_R2=%s",
            target, lib.id, ifn1, ifn2)
        if (is.dry) {
            command = paste(command, "-n")
        }
        print (command)
        if (system(command) != 0)
            stop(paste("error in command:", command))
    }
}

make.from.raw=function(ids, target, is.dry)
{
    cat(sprintf("number of libraries: %d\n", length(ids)))
    for (id in ids) {
        command = sprintf("make %s LIB_ID=%s", target, id)
        if (is.dry) {
            command = paste(command, "-n")
        }
        if (system(command) != 0)
            stop(paste("error in command:", command))
    }
}

make=function(type, ifn, ids, target, is.dry)
{
    if (type == "hmd") {
        make.from.hmd(ifn=ifn, target=target, is.dry=is.dry)
    } else if (type == "pass") {
        make.from.passage(ifn=ifn, target=target, is.dry=is.dry)
    } else {
        make.from.raw(ids=ids, target=target, is.dry=is.dry)
    }
}
