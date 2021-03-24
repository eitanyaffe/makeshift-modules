create.table.hmd=function(ifn, lib.count, respect.keys, ofn)
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
        breaks = c(which(df$key.diff != 0), dim(df)[1]+1)
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

create.table.brooks=function(ifn, subject.id, ofn)
{
    df = load.table(ifn)
    df = df[df$infant  == subject.id & df$location == "Gut",]
    N = dim(df)[1]
    result = data.frame(lib=df$sample, set=paste("s", 1:N, sep=""), set.index=1:N)
    save.table(result, ofn)
}

create.table.rainey=function(ifn, ids, ofn)
{
    df = load.table(ifn)
    df$community = paste0("C", df$community)
    df$lib = ifelse(df$regime != "None", paste0(df$community, "_", df$regime, df$T), paste0(df$community, "_T", df$T))

    # use subject
    # df = df[df$community  == subject.id,c("lib", "T", "regime", "community")]

    # use libs
    df = df[is.element(df$lib, ids),c("lib", "T", "regime", "community")]

    df$regime.index = match(df$regime, c("None", "V", "H"))
    df = df[order(df$regime.index, df$T),]
    N = dim(df)[1]
    result = data.frame(lib=df$lib, set=paste("s", 1:N, sep=""), set.index=1:N, timepoint=df$T, regime=df$regime, community=df$community)
    save.table(result, ofn)
}

create.table=function(type, ifn, subject.id, ids, lib.count, respect.keys, ofn)
{
    switch (type,
            HMD=create.table.hmd(ifn=ifn, lib.count, respect.keys=respect.keys, ofn=ofn),
            Brooks=create.table.brooks(ifn=ifn, subject.id=subject.id, ids, ofn=ofn),
            Rainey=create.table.rainey(ifn=ifn, ids=ids, ofn=ofn),
            stop(sprintf("unknown type: %s", type)))
}
