make=function(ifn, idir, target, is.dry)
{
    df = load.table(ifn)
    cat(sprintf("number of samples: %d\n", dim(df)[1]))

    ifns = list.files(idir)
    cat(sprintf("number of files in input directory: %s\n", length(ifns)))

    n = dim(df)[1]
    for (i in 1:n) {
        id = df$sample[i]
        subject = df$subject[i]
        cat(sprintf("################################################################################\n"))
        cat(sprintf("## Sample: %s, progress: %d/%d\n", id, i, n))
        cat(sprintf("################################################################################\n"))
        ix1 = grepl(id, ifns) & grepl("_R1_", ifns)
        ix2 = grepl(id, ifns) & grepl("_R2_", ifns)
        if (sum(ix1) == 0 || sum(ix2) == 0) {
            cat(sprintf("Warning, skipping id %s since no files were found\n", id))
            next
        }

        ifn1 = paste(idir, ifns[ix1], sep="/")
        ifn2 = paste(idir, ifns[ix2], sep="/")

        # handle re-prep
        if (sum(grepl("reprep", ifn1)) > 0 || sum(grepl("reprep", ifn2)) > 0) {
            ifn1 = ifn1[grepl("reprep", ifn1)]
            ifn2 = ifn2[grepl("reprep", ifn2)]
        }
        if ( length(ifn1) != 1 || length(ifn2) != 1) {
            stop(paste("error with id", id))
        }

        command = sprintf("make m=qc %s ECOSYSTEM_ID=%s LIB_ID=%s QC_LIB_GZ_R1=%s QC_LIB_GZ_R2=%s", target, subject, id, ifn1, ifn2)
        if (is.dry) {
            command = paste(command, "-n")
        }
        if (system(command) != 0)
            stop(paste("error in command:", command))
    }
}

collect.counts=function(ifn, idir, fields, ofn)
{
    df = load.table(ifn)
    cat(sprintf("number of samples: %d\n", dim(df)[1]))

    result = NULL
    n = dim(df)[1]
    for (i in 1:n) {
        id = df$sample[i]
        subject = df$subject[i]
        idirx = paste(idir, "/systems/", subject, "/qc/", id, sep="")
        for (field in fields) {
            ifn.x = paste(idirx, "/.count_", field, sep="")
            if (!file.exists(ifn.x))
                next
            xx = read.delim(ifn.x, header=F)
            dfx = data.frame(subject=subject, sample=id, field=field, reads1=xx[1,3], reads2=xx[2,3], nts1=xx[1,4], nts2=xx[2,4])
            result = rbind(result, dfx)
        }
    }

    save.table(result, ofn)
}

yields=function(ifn, fields, ofn)
{
    df = load.table(ifn)

    # use R1
    df$count = df$reads1

    df$field.index = match(df$field, fields)
    df$prev.field = fields[pmax(1,df$field.index-1)]

    df$key = paste(df$subject, df$sample, df$field)
    df$prev.key = paste(df$subject, df$sample, df$prev.field)

    ix = match(df$prev.key, df$key)
    df$prev.count = df$count[ix]
    df$yield = df$count / df$prev.count

    result = df[,c("subject", "sample", "field", "count", "yield")]

    save.table(result, ofn)
}
