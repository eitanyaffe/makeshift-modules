table.shared=function(genome.ifn, genome.field, edge.margin, min.count, min.live.freq, max.live.freq, fixed.freq, idir, ofn)
{
    ctable = load.table(genome.ifn)
    ctable$genome = ctable[,genome.field]
    fc = field.count(ctable, "contig")
    contigs = fc$contig[fc$count>1]

    result = NULL
    for (contig in contigs) {

        # coverage
        cov.ifn = paste(idir, "/", contig, ".cov", sep="")
        cov.vec = read.delim(cov.ifn, header=F)[,1]
        count = fc$count[match(contig, fc$contig)]
        N = length(cov.vec)
        cov.vec = cov.vec[-c(1:edge.margin, (N-edge.margin+1):N)]
        df = data.frame(contig=contig, length=(N-2*edge.margin), genome.count=count, cov.median=median(cov.vec), cov.sd=sd(cov.vec))

        # snps
        poly.ifn = paste(idir, "/", contig, ".poly", sep="")
        poly = read.delim(poly.ifn)
        poly = poly[poly$coord > edge.margin & poly$coord < (N - edge.margin),]
        df$live.snp.count = sum(poly$type == "snp" & poly$count >= min.count & poly$percent >= 100*min.live.freq & poly$percent <= 100*max.live.freq)
        df$fixed.snp.count = sum(poly$type == "snp" & poly$count >= min.count & poly$percent >= 100*fixed.freq)

        result = rbind(result, df)
    }
    result$cov.variance.ratio = result$cov.sd / sqrt(result$cov.median)
    save.table(result, ofn)
}

shared.select=function(ifn, max.live.density, max.coverage.variance.ratio, ofn)
{
    df = load.table(ifn)
    df$live.snp.freq = df$live.snp.count / df$length
    df$selected = df$live.snp.freq < max.live.density/10 & df$cov.median >= 10 & df$cov.variance.ratio <= max.coverage.variance.ratio
    save.table(df, ofn)
}

plot.shared.snps=function(ifn, snp.estimate.100y, fdir)
{
    df = load.table(ifn)
    df = df[df$cov.median >= 10,]
    df$live.snp.freq = (df$live.snp.count+1) / df$length
    fig.start(fdir=fdir, ofn=paste(fdir, "/live_snp_rate_distrib.pdf", sep=""), type="pdf", height=4, width=6)
    hist(log10(df$live.snp.freq), main="live snp rate distrib", xlab="log10(snp/bp)")
    abline(v=log10(snp.estimate.100y), lwd=2, col=2)
    abline(v=log10(snp.estimate.100y/100), lwd=2, col=2, lty=3)
    fig.end()
}
