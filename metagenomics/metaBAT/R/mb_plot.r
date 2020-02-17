
plot.scores=function(ifn.score, ifn.bins,  min.score, min.zscore, fdir)
{
    scores = load.table(ifn.score)
    bins = load.table(ifn.bins)

    N = dim(scores)[1]
    n = sum(scores$pearson < min.score)
    pp = round(100 * n / N,2)

    main = sprintf("discarded: %d contigs (%.2f%%)", n, pp)

    fig.start(fdir=fdir, ofn=paste(fdir, "/pearson_ctg_bin_cor.pdf", sep=""), type="pdf", height=3, width=4)
    plot(ecdf(scores$pearson), main=main, xlab="pearson")
    abline(v=min.score, lty=2)
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/zscore_ctg_bin_cor.pdf", sep=""), type="pdf", height=3, width=4)
    plot(ecdf(scores$zscore), main=main, xlab="z-score", xlim=c(-4,4))
    abline(v=min.zscore, lty=2)
    fig.end()

    pearson.fdir = paste(fdir, "/pearson", sep="")
    zscore.fdir = paste(fdir, "/zscore", sep="")
    system(paste("mkdir -p", pearson.fdir, zscore.fdir))

    bins = bins[bins$length > 500000,]
    for (bin in bins$bin) {
        scores.bin = scores[scores$bin == bin,]
        cc = scores.bin$pearson
        qq = quantile(cc,c(0.1,0.9))
        cc.middle = cc[cc>=qq[1] & cc<=qq[2]]
        min.bin.score = sd(cc.middle) * min.zscore + mean(cc.middle)

        fig.start(fdir=pearson.fdir, ofn=paste(pearson.fdir, "/", bin, ".pdf", sep=""), type="pdf", height=4, width=4)
        plot(ecdf(scores.bin$pearson), main=bin, xlab="pearson", xlim=c(0.9,1))
        abline(v=min.bin.score, lty=2)
        abline(v=min.score, lty=3)
        fig.end()

        fig.start(fdir=zscore.fdir, ofn=paste(zscore.fdir, "/", bin, ".pdf", sep=""), type="pdf", height=4, width=4)
        plot(ecdf(scores.bin$zscore), main=bin, xlab="z-score", xlim=c(-4,4))
        abline(v=min.zscore, lty=3)
        fig.end()
    }
}
