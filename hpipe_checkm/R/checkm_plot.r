plot.analysis=function(ifn.qa, ifn.ca, ifn.contigs, ifn.info, type, min.complete, max.contam, fdir)
{
    qa = load.table(ifn.qa)
    info = load.table(ifn.info)

    qa$anchor = qa$Bin.Id

    ca = load.table(ifn.ca)
    fc = field.count(ca, field="contig")
    ca$is.multi = fc$count[match(ca$contig,fc$contig)]>1

    contigs = load.table(ifn.contigs)
    ca$length = contigs$length[match(ca$contig, contigs$contig)]
    anchors = sort(qa$anchor)
    N = length(anchors)

    if (type == "A")
        ca = ca[ca$anchor == ca$contig_anchor,]
    if (type == "X")
        ca = ca[ca$contig_anchor == 0,]
    if (type == "nS")
        ca = ca[!ca$is.multi,]
    if (type == "S")
        ca = ca[ca$is.multi,]

    qa$coverage = info$coverage[match(qa$anchor, info$anchor)]

    sx = sapply(split(ca$length, ca$anchor), median)
    qa$median.contig.length = sx[match(qa$anchor, names(sx))] / 1000

    sx = sapply(split(ca$length, ca$anchor), sum)
    qa$genome.size = sx[match(qa$anchor, names(sx))] / 1000

    qa = qa[order(match(qa$anchor, anchors)),]

    width = 1+N*0.15

    #########################################################################################################

    fig.start(fdir=fdir, ofn=paste(fdir, "/complete.pdf", sep=""), type="pdf", width=width, height=3)
    barplot(qa$Completeness, names.arg=anchors, border=NA, col="darkgreen", ylim=c(0,100), las=2, cex.names=0.8)
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/complete_sorted.pdf", sep=""), type="pdf", width=width, height=3)
    ix = order(qa$Completeness)
    barplot(qa$Completeness[ix], names.arg=anchors[ix], border=NA, col="darkgreen", ylim=c(0,100), las=2, cex.names=0.8)
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/complete_vs_contaminated_sorted.pdf", sep=""), type="pdf", width=width, height=5)
    ix = order(qa$Completeness, decreasing=T)
    plot.init(xlim=c(1,dim(qa)[1]), ylim=c(0,100), xlab="genome", ylab="%", axis.las=1)
    # plot(1:dim(qa)[1], qa$Completeness[ix], type="p", pch=19, col=1, ylim=c(0,100), las=2, xlab="genome", ylab="%")
    abline(h=min.complete, col=1, lty=2)
    abline(h=max.contam, col=2, lty=2)
    points(1:dim(qa)[1], qa$Contamination[ix], pch=19, col=2)
    points(1:dim(qa)[1], qa$Completeness[ix], pch=19, col=1)
    grid()
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/contamination.pdf", sep=""), type="pdf", width=width, height=3)
    barplot(qa$Contamination, names.arg=anchors, border=NA, col="red", ylim=c(0,100), las=2, cex.names=0.8)
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/hetero.pdf", sep=""), type="pdf", width=width, height=3)
    barplot(qa$Strain.heterogeneity, names.arg=anchors, border=NA, col="blue", ylim=c(0,100), las=2, cex.names=0.8)
    fig.end()

    #########################################################################################################
    # coverage length

    xlim = range(qa$coverage)
    ylim = range(qa$Completeness)
    cc = round(cor(qa$coverage, qa$Completeness, method="spearman"), 2)
    fig.start(fdir=fdir, ofn=paste(fdir, "/complete_vs_coverage.pdf", sep=""), type="pdf", width=5, height=5)
    plot.init(xlim=xlim, ylim=ylim, xlab="coverage", ylab="complete", log="x", main=paste("spearman=", cc, sep=""))
    points(qa$coverage, qa$Completeness, pch="+")
    fig.end()

    #########################################################################################################
    # median contig length

    xlim = c(min(qa$median.contig.length), 2*max(qa$median.contig.length))
    ylim = range(qa$Completeness)
    cc = round(cor(qa$median.contig.length, qa$Completeness, method="spearman"), 2)
    fig.start(fdir=fdir, ofn=paste(fdir, "/complete_vs_contig_length.pdf", sep=""), type="pdf", width=5, height=5)
    plot.init(xlim=xlim, ylim=ylim, xlab="kb", ylab="complete", log="x", main=paste("spearman=", cc, sep=""))
    points(qa$median.contig.length, qa$Completeness, pch="+")
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/complete_vs_contig_length_label.pdf", sep=""), type="pdf", width=5, height=5)
    plot.init(xlim=xlim, ylim=ylim, xlab="kb", ylab="complete", log="x", main=paste("spearman=", cc, sep=""))
    points(qa$median.contig.length, qa$Completeness, pch="+")
    text(qa$median.contig.length, qa$Completeness, pos=4, qa$anchor, cex=0.5)
    fig.end()

    #########################################################################################################
    # genome size

    xlim = c(min(qa$genome.size), max(qa$genome.size))
    ylim = range(qa$Completeness)
    cc = round(cor(qa$genome.size, qa$Completeness, method="spearman"), 2)
    fig.start(fdir=fdir, ofn=paste(fdir, "/complete_vs_genome_size.pdf", sep=""), type="pdf", width=5, height=5)
    plot.init(xlim=xlim, ylim=ylim, xlab="kb", ylab="complete", main=paste("spearman=", cc, sep=""))
    points(qa$genome.size, qa$Completeness, pch="+")
    fig.end()

    xlim = c(min(qa$genome.size), max(qa$genome.size))
    ylim = range(qa$Completeness)
    cc = round(cor(qa$genome.size, qa$Completeness, method="spearman"), 2)
    fig.start(fdir=fdir, ofn=paste(fdir, "/complete_vs_genome_size.pdf", sep=""), type="pdf", width=5, height=5)
    plot.init(xlim=xlim, ylim=ylim, xlab="kb", ylab="complete", main=paste("spearman=", cc, sep=""))
    points(qa$genome.size, qa$Completeness, pch="+")
    text(qa$genome.size, qa$Completeness, pos=match(qa$anchor, anchors) %% 4 + 1, qa$anchor, cex=0.5)
    fig.end()

    #########################################################################################################
    # contamination vs contig size

    xlim = c(min(qa$median.contig.length), 2*max(qa$median.contig.length))
    ylim = range(qa$Contamination)
    cc = round(cor(qa$median.contig.length, qa$Contamination, method="spearman"), 2)
    fig.start(fdir=fdir, ofn=paste(fdir, "/contamination_vs_contig_length.pdf", sep=""), type="pdf", width=5, height=5)
    plot.init(xlim=xlim, ylim=ylim, xlab="kb", ylab="contamination", log="x", main=paste("spearman=", cc, sep=""))
    points(qa$median.contig.length, qa$Contamination, pch="+")
    fig.end()

    #########################################################################################################
    # complete hist

    fig.start(fdir=fdir, ofn=paste(fdir, "/complete_hist.pdf", sep=""), type="pdf", width=5, height=5)
    hist(qa$Completeness, col="gray", main="completeness", breaks=10, xlim=c(0,100))
    fig.end()

    #########################################################################################################
    # stats

    nx = sum(qa$Completeness>=min.complete & qa$Contamination<=max.contam)
    fc = file(paste(fdir, "/stats.txt", sep=""))
    lines = c(
        sprintf("median completeness: %.1f", median(qa$Completeness)),
        sprintf("mean completeness: %.1f", mean(qa$Completeness)),
        sprintf("number of genomes completeness>=%.0f%% && contamination<=%.0f%%: %d (%.1f%%)", min.complete, max.contam, nx, 100*nx/dim(qa)[1])
        )
    writeLines(lines, fc)
    close(fc)

}

plot.analysis.simple=function(ifn.qa, min.complete, max.contam, fdir)
{
    qa = load.table(ifn.qa)
    qa$anchor = qa$Bin.Id
    anchors = sort(qa$anchor)

    N = length(anchors)
    width = 1+N*0.15

    fig.start(fdir=fdir, ofn=paste(fdir, "/complete_vs_contaminated_sorted.pdf", sep=""), type="pdf", width=width, height=5)
    ix = order(qa$Completeness, decreasing=T)
    plot.init(xlim=c(1,dim(qa)[1]), ylim=c(0,100), xlab="genome", ylab="%", axis.las=1)
    abline(h=min.complete, col=1, lty=2)
    abline(h=max.contam, col=2, lty=2)
    points(1:dim(qa)[1], qa$Contamination[ix], pch=19, col=2)
    points(1:dim(qa)[1], qa$Completeness[ix], pch=19, col=1)
    grid()
    fig.end()
}
