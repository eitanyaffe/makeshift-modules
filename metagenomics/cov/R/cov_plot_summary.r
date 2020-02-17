plot.summary=function(ifn.contigs, ifn.segments, fdir)
{
    get.N50=function(lens) {
        lens = sort(lens, decreasing=T)
        val = sum(lens)/2
        cs = cumsum(lens)
        ii = findInterval(val, cs)
        lens[ii+1]
    }
    contigs = load.table(ifn.contigs)
    segments = load.table(ifn.segments)
    segments$length = segments$end - segments$start + 1
    contigs$percent = 100 * contigs$outlier_nt / contigs$length


    #######################################################################################
    # Affected contigs
    #######################################################################################

    contigs.out = contigs[contigs$outlier_nt > 0,]
    contigs.out$class =
        ifelse(contigs.out$percent < 1, "<1%",
               ifelse(contigs.out$percent < 10, "<10%",
                      ifelse(contigs.out$percent < 20, "<20%",
                             ifelse(contigs.out$percent < 30, "<30%",
                                    ifelse(contigs.out$percent < 40, "<40%",
                                           ifelse(contigs.out$percent < 50, "<50%", ">=50%"))))))
    contigs.out$class.f = factor(contigs.out$class, levels=c("<1%", "<10%", "<20%", "<30%", "<40%", "<50%", ">=50%"))

    tt = table(contigs.out$class.f)
    tt = 100 * tt / dim(contigs)[1]

    clean.contig.percent = 100 * sum(contigs$outlier_nt == 0) / dim(contigs)[1]
    main = sprintf("contigs with outerliers=%.2f%%", 100-clean.contig.percent)

    fig.start(fdir=fdir, ofn=paste(fdir, "/contig_distrib.pdf", sep=""), type="pdf", height=4, width=4)
    barplot(tt, names.arg=names(tt), ylab="%", border=NA, col="darkblue", las=2, main=main, xlab="% of outliers in contig", cex.names=0.8)
    fig.end()

    #######################################################################################
    # N50
    #######################################################################################

    fig.start(fdir=fdir, ofn=paste(fdir, "/N50.pdf", sep=""), type="pdf", height=3,, width=1.8)
    vv = c(get.N50(contigs$length), get.N50(segments$length))/1000
    mm = barplot(vv, names.arg=c("before", "after"), border=NA, col="darkblue", ylab="N50 kb", las=2, ylim=c(0, max(vv)*1.2))
    text(mm, vv, pos=3, labels=round(vv,1), cex=0.75)
    fig.end()

    #######################################################################################
    # distribution of outliers
    #######################################################################################

    total.percent = 100 * sum(contigs$outlier_nt) / sum(contigs$length)
    main = sprintf("outlier sequence is %.2f%% of entire assembly", total.percent)

    fig.start(fdir=fdir, ofn=paste(fdir, "/outlier_distrib.pdf", sep=""), type="pdf", height=5, width=5)
    par(mai=c(1,1,1,0.1))
    plot(ecdf(contigs.out$percent), ylab="fraction", xlab="percentage of outliers in contig", main=main)
    fig.end()
}
