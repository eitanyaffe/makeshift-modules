
plot.stats.internal=function(read.count, read.yield, bp.count, bp.yield, fdir)
{
    # total read count
    fig.start(fdir=fdir, type="pdf", width=4, height=4, ofn=paste(fdir, "/read_count_ecdf.pdf", sep=""))
    plot(ecdf(read.count$final/10^6), main="total reads", ylab="fraction", xlab="read count (M)")
    fig.end()

    # total bp count
    fig.start(fdir=fdir, type="pdf", width=4, height=4, ofn=paste(fdir, "/bp_count_ecdf.pdf", sep=""))
    plot(ecdf(bp.count$final/10^9), main="total bps", ylab="fraction", xlab="bp count (G)")
    fig.end()
    
    # read yield
    for (field in c("duplicate", "deconseq")) {
        fig.start(fdir=fdir, type="pdf", width=4, height=4, ofn=paste(fdir, "/", field, "_read_yield_ecdf.pdf", sep=""))
        plot(ecdf(read.yield[,field]), main=paste(field, "read yield"), ylab="fraction", xlab="yield (%)")
        fig.end()
    }

    # bp yield
    for (field in c("trimmomatic")) {
        fig.start(fdir=fdir, type="pdf", width=4, height=4, ofn=paste(fdir, "/", field, "_bp_yield_ecdf.pdf", sep=""))
        plot(ecdf(bp.yield[,field]), main=paste(field, "bp yield"), ylab="fraction", xlab="yield (%)")
        fig.end()
    }
}

plot.stats=function(ifn.reads.count, ifn.reads.yield, ifn.bps.count, ifn.bps.yield, fdir)
{
    read.count = load.table(ifn.reads.count)
    bp.count = load.table(ifn.bps.count)
    read.yield = load.table(ifn.reads.yield)
    bp.yield = load.table(ifn.bps.yield)
    plot.stats.internal(read.count=read.count, read.yield=read.yield,
                        bp.count=bp.count, bp.yield=bp.yield, fdir=fdir)
}

plot.stats.selected=function(ifn.selected, ifn.reads.count, ifn.reads.yield, ifn.bps.count, ifn.bps.yield, fdir)
{
    df.selected = load.table(ifn.selected)
    restrict=function(df) { df[is.element(df$id, df.selected$id),] }
    read.count = restrict(load.table(ifn.reads.count))
    bp.count = restrict(load.table(ifn.bps.count))
    read.yield = restrict(load.table(ifn.reads.yield))
    bp.yield = restrict(load.table(ifn.bps.yield))

    plot.stats.internal(read.count=read.count, read.yield=read.yield,
                        bp.count=bp.count, bp.yield=bp.yield, fdir=fdir)
}
