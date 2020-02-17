create.table=function(ifn, lib.count, respect.keys, ofn)
{
    df = load.table(ifn)
    df = df[df$Meas_Type == "MetaG",]
    df$date = as.Date(df$Samp_Date, "%d-%b-%Y")

    if (any(table(df$date) > 1)) {
        ss = split(df, df$date)
        new.df = NULL
        for (i in 1:length(ss)) {
            df.lib = ss[[i]]
            df.lib = df.lib[order(df.lib$Samp_Type),]
            df.lib = df.lib[1,]
            new.df = rbind(new.df, df.lib)
        }
        df = new.df
    }
    df = df[order(df$date),]
    df$lib.index = 1:dim(df)[1]

    bin.df=function(dfx) {
        N = dim(dfx)[1]
        dfx$index = 1:N
        n.bins = floor(N / lib.count)
        if (n.bins > 1) {
            breaks = c(0, 1:(n.bins-1)*lib.count, N)
            as.numeric(cut(dfx$index, breaks=breaks))
        } else {
            rep(1, N)
        }
    }

    result = NULL
    if (respect.keys) {
        keys = unique(df$Event_Key)
        df$key.index = match(df$Event_Key, keys)
        df$key.diff = diff(c(0, df$key.index))
        breaks = c(which(df$key.diff != 0), dim(df)[1])
        ss = split(df, cut(df$lib.index, breaks=breaks, right=F))
        result = NULL
        set.count = 0
        for (i in 1:length(ss)) {
            result.i = ss[[i]]
            result.i$set.index = bin.df(result.i) + set.count
            result = rbind(result, result.i)
            set.count = max(result$set.index)
        }
    } else {
        df$set.index = bin.df(df)
        result = df
    }
    result$set = paste("s", result$set.index, sep="")
    result = result[,c("lib.index", "lib", "date", "Event_Key", "set", "set.index")]
    save.table(result, ofn)
}

make.sets=function(ifn, module, is.dry)
{
    df = load.table(ifn)
    sets = unique(df$set)
    N = length(sets)

    cat(sprintf("number of libraries: %d\n", dim(df)[1]))
    cat(sprintf("number of sets: %d\n", N))

    for (set in sets) {
        ids = paste(df$lib[df$set == set], collapse=" ")
        command = sprintf("make m=%s snps_set SNPS_SET_LABEL=%s SNPS_SET_IDS='%s'",
            module, set, ids)
        if (is.dry) {
            command = paste(command, "-n")
        }
        if (system(command) != 0)
            stop(paste("error in command:", command))
    }
}
