
plot.trj.matrix=function(ifn.bins, ifn.pos, ifn.base, ifn.set, prefix, lib.labels, fdir)
{
    bins = load.table(ifn.bins)
    df = load.table(ifn.pos)
    trj.base = load.table(ifn.base)
    trj.set = load.table(ifn.set)
    total = load.table(paste(prefix, ".total", sep=""))

    get.bin=function(tgt) {
        ix = match(paste(tgt$contig,tgt$coord),paste(df$contig,df$coord))
        if (any(is.na(ix)))
            stop("internal")
        df$bin[ix]
    }
    trj.base = cbind(data.frame(bin=get.bin(trj.base)), trj.base)
    trj.set = cbind(data.frame(bin=get.bin(trj.set)), trj.set)
    total = cbind(data.frame(bin=get.bin(total)), total)

    bins = bins[bins$fix.count > 0 & bins$base.cov>=10 & bins$set.cov>=10,]

    N = dim(trj.set)[2] - 3
    xlim = c(0, N)

    for (bin in bins$bin) {
#        if (sum(trj.base$bin == bin) == 0)
#            next
        base.bin = trj.base[trj.base$bin == bin,-(1:3)]
        set.bin = trj.set[trj.set$bin == bin,-(1:3)]
        total.bin = total[total$bin == bin,-(1:3)]

        ylim = c(0, max(c(unlist(total.bin), unlist(base.bin), unlist(set.bin)))+1)

        ofn = paste(fdir, "/", bin, ".pdf", sep="")
        fig.start(ofn=ofn, fdir=fdir, type="pdf", width=6, height=3)
#        par(mai=c(2,1,0.5,0.5))
        plot.init(xlim=xlim, ylim=ylim, axis.las=1, x.axis=F)
#        axis(side=1, at=1:N-0.5, lib.labels, las=2)
        for (i in 1:dim(base.bin)[1]) {
            lines(1:N - 0.5, total.bin[i,], col="gray")
            lines(1:N - 0.5, base.bin[i,], col=1)
            lines(1:N - 0.5, set.bin[i,], col=2)
        }
        fig.end()
    }
}
