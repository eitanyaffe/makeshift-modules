distance.matrix=function(ifn.sets, ifn.bins, idir, p.value, ofn)
{
    df.bins = load.table(ifn.bins)

    df.libs = load.table(ifn.sets)
    sets = unique(df.libs$set)
    N = length(sets)

    cat(sprintf("number of set pairs: %d\n", (N*(N-1))/2))

    result = NULL
    for (i in 1:N) {
        for (j in 1:N) {
            if (i >= j)
                next
            set.i = sets[i]
            set.j = sets[j]
            df = read.delim(paste(idir, "/diverge/", set.i, "_", set.j, "/bin.sites", sep=""))
            df = df[df$P_value < p.value,]
            df$delta.major = abs(df$major1/(1+df$coverage1) - df$major2/(1+df$coverage2))
            df$delta.minor = abs(df$minor1/(1+df$coverage1) - df$minor2/(1+df$coverage2))
            df$delta = (df$delta.major + df$delta.minor) / 2

            ss = sapply(split(df$delta, df$bin), sum)
            dfp = data.frame(df.bins, set1=set.i, set2=set.j)
            ix = match(dfp$bin, names(ss))
            dfp$weight = ifelse(!is.na(ix), ss[ix], 0)
            dfp$distance = dfp$weight / dfp$segment.length
            result = rbind(result, dfp)
        }
    }
    save.table(result, ofn)
}
