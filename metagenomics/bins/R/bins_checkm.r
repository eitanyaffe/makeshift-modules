bin.select=function(ifn, min.length, ofn)
{
    df = load.table(ifn)
    df = df[df$length>=min.length,]
    save.table(df, ofn)
}

checkm.parse=function(ifn.checkm, ifn.bin.table, ofn)
{
    checkm = load.table(ifn.checkm)
    df = load.table(ifn.bin.table)
    checkm$bin = gsub("bin.", "", checkm$Bin.Id)

    ix = match(df$bin, checkm$bin)
    if (any(is.na(ix)))
        stop("not all bins found")

    df$Completeness = checkm$Completeness[ix]
    df$Contamination = checkm$Contamination[ix]
    save.table(df, ofn)
}
