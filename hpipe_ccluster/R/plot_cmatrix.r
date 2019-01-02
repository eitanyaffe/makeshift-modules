plot.filter=function(ifn.mat, ifn.contigs, fdir)
{
    tab = load.table(ifn.contigs)
    mat = load.table(ifn.mat)
    mat$score = log10(mat$contacts / mat$factor) - mean(log10(mat$contacts / mat$factor))
    mat$length2 = tab$length[match(mat$contig2, tab$contig)]

    N = 10
    breaks = quantile(mat$score, 0:N/N)

    s = sapply(split(mat$length2, mat$contig1), sum)

    fig.start(fdir=fdir, ofn=paste(fdir, "/filter.pdf", sep=""), type="pdf", width=6, height=6)
    plot(log10(mat$contacts), mat$score, pch=".")
    fig.end()
}
