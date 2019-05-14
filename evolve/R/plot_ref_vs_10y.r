plot.ref.vs.10y=function(ifn.10y, ifn.ref, fdir)
{
    df.ref = load.table(ifn.ref)
    df.10y = load.table(ifn.10y)

    df.10y = df.10y[is.element(df.10y$fate, c("turnover", "persist")),]
    df.ref$div.ref = log10((100-df.ref$ref.identity)/100)
    df.10y$div.10y = log10(df.10y$fixed.density)
    df = merge(df.ref, df.10y, by="anchor")

    lim = range(c(df$div.ref, df$div.10y))

    fig.start(fdir=fdir, ofn=paste(fdir, "/ref_vs_10y.pdf", sep=""), type="pdf", height=5, width=5)
    plot.init(xlim=lim, ylim=lim, xlab="10y div", ylab="ref div")
    points(df$div.10y, df$div.ref, pch=19, col=ifelse(df$fate=="persist", "green", "orange"))
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/ref_vs_10y_text.pdf", sep=""), type="pdf", height=5, width=5)
    plot.init(xlim=lim, ylim=lim, xlab="10y div", ylab="ref div")
    points(df$div.10y, df$div.ref, pch=19, col=ifelse(df$fate=="persist", "green", "orange"))
    text(df$div.10y, df$div.ref, df$anchor.id.x, pos=4)
    fig.end()
}
