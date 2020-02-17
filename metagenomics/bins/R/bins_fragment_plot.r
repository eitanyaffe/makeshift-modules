plot.fragments=function(ifn, fdir)
{
    df = load.table(ifn)
    ss = split(df$bin, df$contig)

    ss.has.zero = sapply(ss, function(x) { any(x==0) })
    ss.all.zero = sapply(ss, function(x) { all(x==0) })
    ss.single.bin = sapply(ss, function(x) { sum(x!=0)==1 })
    ss.n.bins = sapply(ss, function(x) { length(unique(x)) })

    bb = data.frame(contigs=names(ss),
        n.bins=ss.n.bins,
        has.zero=ifelse(ss.has.zero,"has.zero","no.zero"),
        all.zero=ifelse(ss.all.zero,"all.zero","some.zero"),
        has.multi=ifelse(ss.single.bin,"single", "multi"))

    N = max(bb$n.bins)
    levels = 1:N
    tt = table(factor(bb$n.bins, levels=levels))
    ff = 100 * tt[1] / sum(tt)

    main = sprintf("single-bin contigs: %.2f%%", ff)
    fig.start(fdir=fdir, ofn=paste(fdir, "/bin_per_contig.pdf", sep=""), type="pdf", width=4, height=3)
    barplot(tt, names.arg=names(tt), main=main, cex.axis=0.8, xlab="bins/contigs")
    fig.end()
}
