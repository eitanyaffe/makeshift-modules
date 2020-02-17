
plot.scatter=function(ifn.bins, ifn.cmp, set1, set2, fdir)
{
    bins = load.table(ifn.bins)
    bins = bins[bins$class == "host",]
    df = load.table(ifn.cmp)
    df$rpk1 = 1000 * df$count1/df$length
    df$rpk2 = 1000 * df$count2/df$length
    df$log.rpk1 = log10(1+df$rpk1)
    df$log.rpk2 = log10(1+df$rpk2)

    for (bin in bins$bin) {
        dfb = df[df$bin == bin,]
        xlim = c(0, 1.1 * max(dfb$log.rpk1))
        ylim = c(0, 1.1 * max(dfb$log.rpk2))
        fig.start(fdir=fdir, ofn=paste(fdir, "/", bin, ".pdf", sep=""), type="pdf", width=5, height=5)
        plot.init(xlim=xlim, ylim=ylim, xlab=set1, ylab=set2, main=bin)
        points(dfb$log.rpk1, dfb$log.rpk2, pch=19, cex=0.3)
        fig.end()
    }
}
