cov.table=function(genome.ifn, genome.field, edge.margin, idir, ofn)
{
    ctable = load.table(genome.ifn)
    ctable$genome = ctable[,genome.field]
    fc = field.count(ctable, "contig")
    shared = fc$contig[fc$count>1]

    ctable = ctable[!is.element(ctable$contig, shared),]
    genomes = sort(unique(ctable$genome))

    cat(sprintf("number of genomes: %d\n", length(genomes)))
    result = NULL
    for (genome in genomes) {
        contigs = ctable$contig[ctable$genome == genome]
        # cat(sprintf("genome: %d, contig count: %d\n", genome, length(contigs)))

        # extract coverage stats
        df = NULL
        genome.cov.vec = NULL
        for (contig in contigs) {
            cov.ifn = paste(idir, "/", contig, ".cov", sep="")
            cov.vec = read.delim(cov.ifn, header=F)[,1]
            N = length(cov.vec)
            cov.vec = cov.vec[-c(1:edge.margin, (N-edge.margin+1):N)]
            df = rbind(df, data.frame(contig=contig, cov.median=median(cov.vec), cov.sd=sd(cov.vec)))
            genome.cov.vec = c(genome.cov.vec, cov.vec)
        }
        genome.cov = median(genome.cov.vec)
        df$copy = ifelse(genome.cov > 0, df$cov.median / genome.cov, 0)
        df$variance.ratio = ifelse(df$cov.median > 0, df$cov.sd / sqrt(df$cov.median), 0)
        result = rbind(result, data.frame(genome=genome, df))
    }
    save.table(result, ofn)
}

filter.table=function(ifn, ofn, ifn.contig, min.copy, max.copy, max.coverage.variance.ratio)
{
    ctable = load.table(ifn.contig)
    df = load.table(ifn)
    df$length = ctable$length[match(df$contig, ctable$contig)]
    df$selected = (df$copy >= min.copy) & (df$copy <= max.copy) & df$variance.ratio <= max.coverage.variance.ratio
    save.table(df, ofn)
}

plot.genome.snps=function(ifn, snp.estimate.100y, fdir)
{
    df = load.table(ifn)
    df = df[df$xcov >= 10,]

    fig.start(fdir=fdir, ofn=paste(fdir, "/live_snp_rate_distrib.pdf", sep=""), type="pdf", height=4, width=6)
    hist(log10(df$live.snp.freq), main="live snp rate distrib (xcov>=10)", xlab="log10(snp/bp)")
    abline(v=log10(snp.estimate.100y), lwd=2, col=2)
    abline(v=log10(snp.estimate.100y/100), lwd=2, col=2, lty=3)
    fig.end()

    df = load.table(ifn)
    df = df[df$xcov >= 1,]
    fig.start(fdir=fdir, ofn=paste(fdir, "/fixed_snp_rate_distrib.pdf", sep=""), type="pdf", height=4, width=6)
    hist(log10(df$fixed.snp.freq), main="fixed snp rate distrib (xcov>=1)", xlab="log10(snp/bp)")
    abline(v=log10(snp.estimate.100y), lwd=2, col=2)
    abline(v=log10(snp.estimate.100y/100), lwd=2, col=2, lty=3)
    fig.end()

    print(sum(df$live.snp.freq < snp.estimate.100y))
}
