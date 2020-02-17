plot.stats=function(ldir, fdir, ids, titles)
{
    N = length(ids)
    cols = rainbow(N)

    fig.start(fdir=fdir, width=600, height=200 + N*40, ofn=paste(fdir, "/id_legend.png", sep=""))
    par(mai=c(2,1.5,1,0.5))
    plot.new()
    legend("center", fill=cols, legend=ids)
    fig.end()

    par(mai=c(2,1.5,1,0.5))

    get.reads=function(x, side) { x[x[,2] == side,3] }
    get.bps=function(x, side) { x[x[,2] == side,4] }

    reads.count.m = NULL
    reads.loss.m = NULL
    bps.count.m = NULL
    bps.loss.m = NULL

    width = 350

    for (id in ids) {
        reads = NULL
        bps = NULL

        x = load.table(paste(ldir, "/", id, "/trimmomatic/.stats", sep=""), header=F)
        bps = rbind(bps, data.frame(id=id, type="no_adapter_R1", count=get.bps(x,"R1")))
        bps = rbind(bps, data.frame(id=id, type="no_adapter_R2", count=get.bps(x,"R2")))
        reads = rbind(reads, data.frame(id=id, type="no_adapter_R1", count=get.reads(x,"R1")))
        reads = rbind(reads, data.frame(id=id, type="no_adapter_R2", count=get.reads(x,"R2")))

        reads.count.m = rbind(reads.count.m, reads$count)
        colnames(reads.count.m) = reads$type

        bps.count.m = rbind(bps.count.m, bps$count)
        colnames(bps.count.m) = bps$type

        # ffdir = paste(fdir, "/datasets/", id, sep="")
        # fig.start(fdir=ffdir, width=width, height=400, ofn=paste(ffdir, "/read_count.png", sep=""))
        # barplot(reads$count, names.arg=reads$type, border=NA, main="read count (M)", las=2, col="darkblue", ylab="M reads")
        # fig.end()

    }

    # plot comparison
    fig.start(fdir=fdir, width=width, height=400, ofn=paste(fdir, "/read_count.png", sep=""))
    par(mai=c(2,1.5,1,0.5))
    barplot(reads.count.m/10^6, beside=T, border=NA, main="read count (M)", las=2, col=cols)
    fig.end()
}
