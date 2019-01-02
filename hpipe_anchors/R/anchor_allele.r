correct.allele.table=function(df)
{
    df = df[df$REF1 >= -1 & df$REF2 >= -1,]
    compute.contig.total=function(df, field) {
        df = df[df[,field] != -1,]
        s = sapply(split(df[,field], df$contig), median)
        data.frame(contig=names(s), value=s)
    }
    ctotal1 = compute.contig.total(df, field="total1")
    df$total1 = ifelse(df$total1 != -1, df$total1, ctotal1$value[match(df$contig, ctotal1$contig)])
    ctotal2 = compute.contig.total(df, field="total2")
    df$total2 = ifelse(df$total2 != -1, df$total2, ctotal2$value[match(df$contig, ctotal2$contig)])

    df = df[!is.na(df$total1) & !is.na(df$total2),]
    df[df == -1] = 0
    df
}

get.typed.dd=function(df, min.freq, max.freq, low.freq, low.count)
{
    dd = data.frame(
        x=c(df$A1/df$total1, df$C1/df$total1, df$G1/df$total1, df$T1/df$total1),
        x.count=c(df$A1, df$C1, df$G1, df$T1),
        y=c(df$A2/df$total2, df$C2/df$total2, df$G2/df$total2, df$T2/df$total2),
        y.count=c(df$A2, df$C2, df$G2, df$T2))

    dd = dd[dd$x >= low.freq | dd$y >= low.freq,]
    dd$type.x =
        ifelse((dd$x > min.freq) & (dd$x < max.freq), "med",
               ifelse((dd$x < low.freq) | (dd$x.count <= low.count), "low", "high"))
    dd$type.y =
        ifelse((dd$y > min.freq) & (dd$y < max.freq), "med",
               ifelse((dd$y < low.freq) | (dd$y.count <= low.count), "low", "high"))
    dd$type =
        ifelse((dd$type.x == "med") &  (dd$type.y == "med"), "stable",
               ifelse((dd$type.x == "low") &  (dd$type.y == "med"), "gain",
                      ifelse((dd$type.x == "med") &  (dd$type.y == "low"), "loss", "other")))
    dd
}

compute.allele.matrix=function(ifn.anchors, ifn.ca, ifn.contigs, idir, ofn)
{
    min.total=10
    min.freq = 0.2
    max.freq = 0.8
    low.freq = 0.05
    low.count = 1

    table = load.table(ifn.anchors)

    ca = load.table(ifn.ca)
    ctable = load.table(ifn.contigs)
    ca = ca[ca$anchor == ca$contig_anchor,]
    ca$length = ctable$length[match(ca$contig, ctable$contig)]
    s = sapply(split(ca$length, ca$anchor), sum)
    ids = table$id
    result = NULL
    for (id in ids) {
        anchor = table$set[match(id, table$id)]
        anchor.length = s[match(anchor, names(s))]
        df = load.table(paste(idir, "/", anchor, sep=""))
        df = correct.allele.table(df)

        df = df[df$total1 > min.total & df$total2 > min.total,]
        dd = get.typed.dd(df=df, min.freq=min.freq, max.freq=max.freq, low.freq=low.freq, low.count=low.count)
        tt = t(as.matrix(table(factor(dd$type, levels=c("stable", "gain", "loss")))))
        xdf = data.frame(id=id, length=anchor.length, tt)
        xdf$stable.per.bp = xdf$stable/xdf$length
        xdf$gain.per.bp = xdf$gain/xdf$length
        xdf$loss.per.bp = xdf$loss/xdf$length
        result = rbind(result, xdf)
    }
    save.table(result, ofn)
}

plot.allele=function(ifn.anchors, idir, fdir)
{
    min.total=10
    min.freq = 0.2
    max.freq = 0.8
    low.freq = 0.05
    low.count = 1

    table = load.table(ifn.anchors)
    ids = table$id
    for (id in ids) {
        anchor = table$set[match(id, table$id)]
        df = load.table(paste(idir, "/", anchor, sep=""))
        df = correct.allele.table(df)

        df = df[df$total1 > min.total & df$total2 > min.total,]
        dd = get.typed.dd(df=df, min.freq=min.freq, max.freq=max.freq, low.freq=low.freq, low.count=low.count)
        dd$col = ifelse(dd$type=="stable", "green", ifelse(dd$type == "gain", "red", ifelse(dd$type == "loss", "blue", "black")))
        fig.start(fdir=fdir, ofn=paste(fdir, "/ratio_", id, ".pdf", sep=""), type="pdf", height=4, width=4)
        plot(dd$x, dd$y, pch=".", xlab="pre", ylab="post", xlim=c(0,1), ylim=c(0,1))
        grid()
        fig.end()

        fig.start(fdir=fdir, ofn=paste(fdir, "/nts_", id, ".pdf", sep=""), type="pdf", height=4, width=4)
        plot(dd$x.count+1, dd$y.count+1, log="xy", pch=".", xlab="pre", ylab="post")
        grid()
        fig.end()

        ## # total
        ## fig.start(fdir=fdir, ofn=paste(fdir, "/total_", id, ".pdf", sep=""), type="pdf", height=4, width=4)
        ## plot(df$total1, df$total2, pch=".", xlab="pre", ylab="post")
        ## grid()
        ## fig.end()
    }
}
