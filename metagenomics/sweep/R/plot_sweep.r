
plot.scatters=function(ifn.eb, ifn.bins, ifn.ratio, ifn.class, id.a, id.b, fdir)
{
    df = load.table(ifn.eb)
    bins = load.table(ifn.bins)
    ratio = load.table(ifn.ratio)
    class = load.table(ifn.class)

    bins = bins[bins$class == "host",]

    bins$ratio = ratio$ratio[match(bins$bin, ratio$host)]

    df$log.count.a = log10(1+df$count.a) - log10(df$length/10^3)
    df$log.count.b = log10(1+df$count.b) - log10(df$length/10^3)

    # !!!
    # df$log.count.a[df$log.count.a<0] = 0
    # df$log.count.b[df$log.count.b<0] = 0

    df = df[df$count.a >= 10 | df$count.b >= 10,]

    ix = match(paste(df$host, df$element), paste(class$host, class$element))
    df$class = ifelse(!is.na(ix), class$class[ix], "none")

    # identify multi
    dfx = df[df$class == "gain" | df$class == "loss",]
    fc = field.count(dfx, "element")
    multi.id = as.numeric(fc$element[fc$count>1])
    df$multi = is.element(df$element, multi.id) & (df$class == "gain" | df$class == "loss")
    df$zero = df$count.a == 0 | df$count.b == 0

    df$col = "gray"
    ## df$col =
    ##     ifelse(df$count.b == 0, "darkblue",
    ##            ifelse(df$count.a == 0, "darkred",
    ##                   ifelse(df$class == "gain", "red", ifelse(df$class == "loss", "blue", "gray"))))

    fdir.simple = paste(fdir, "/simple", sep="")
    fdir.text = paste(fdir, "/text", sep="")
    fdir.text.full = paste(fdir, "/text_full", sep="")

    for (bin in bins$bin) {
        ix = match(bin, bins$bin)
        ratio = bins$ratio[ix]
        main = sprintf("bin=%d, base.cov=%.1f, cov.b=%.1f\nfix.count=%d", bin, bins$base.cov[ix], bins$set.cov[ix], bins$fix.count[ix])

        dfh = df[df$host == bin,]
        if (dim(dfh)[1] == 0)
            next

        if (!is.na(ratio) && ratio > 0)
            dfh$log.count.b = dfh$log.count.b - log10(ratio)

        dfh$log.count.a[dfh$log.count.a<0] = 0
        dfh$log.count.b[dfh$log.count.b<0] = 0

        # xlim = c(0, max(dfh$log.count.a)+0.1)
        # ylim = c(0, max(dfh$log.count.b)+0.1)
        # lim = c(0, max(c(dfh$log.count.a, dfh$log.count.b))+0.1)
        lim = range(c(dfh$log.count.a, dfh$log.count.b))
        xlim = lim
        ylim = lim
        height = 5.5

        fig.start(paste(fdir.simple, "/", bin, ".pdf", sep=""), type="pdf", fdir=fdir.simple, width=5, height=height)
        plot.init(xlim=xlim, ylim=ylim, xlab=id.a, ylab=id.b, main=main)

        #if (!is.na(ratio) && ratio > 0) abline(a=log10(ratio), b=1)
        abline(a=0, b=1)

        points(dfh$log.count.a, dfh$log.count.b, pch=19, cex=0.5, col=dfh$col)
        fig.end()

        fig.start(paste(fdir.text, "/", bin, ".pdf", sep=""), type="pdf", fdir=fdir.text, width=8, height=8)
        plot.init(xlim=xlim, ylim=ylim, xlab=id.a, ylab=id.b, main=main)

        # if (!is.na(ratio) && ratio > 0) abline(a=log10(ratio), b=1)
        abline(a=0, b=1)

        points(dfh$log.count.a, dfh$log.count.b, pch=19, cex=0.5, col=dfh$col)
        ix = dfh$class != "none"
        if (any(ix)) {
            text(dfh$log.count.a[ix], dfh$log.count.b[ix], dfh$element[ix], pos=3, pch=".", cex=0.4)
        }
        fig.end()

        fig.start(paste(fdir.text.full, "/", bin, ".pdf", sep=""), type="pdf", fdir=fdir.text.full, width=8, height=8)
        plot.init(xlim=xlim, ylim=ylim, xlab=id.a, ylab=id.b, main=main)

        abline(a=0, b=1)

        points(dfh$log.count.a, dfh$log.count.b, pch=19, cex=0.5, col=dfh$col)
        ix = dfh$log.count.a > 0.5 | dfh$log.count.b > 0.5
        if (any(ix)) {
            text(dfh$log.count.a[ix], dfh$log.count.b[ix], dfh$element[ix], pos=3, pch=".", cex=0.4)
        }
        fig.end()
    }
}

plot.host.summary=function(ifn, id.a, id.b, fdir)
{
    df = load.table(ifn)
    df$col = ifelse(df$fix.count == 0, "darkgray", "blue")
    df$log.base.cov = log10(df$base.cov)
    df$log.set.cov = log10(df$set.cov)

    main = "x-coverage"
    xlim = range(df$log.base.cov)
    ylim = range(df$log.set.cov)

    height = 5.5
    cex = 0.8

    fig.start(paste(fdir, "/summary_clean.pdf", sep=""), type="pdf", fdir=fdir, width=5, height=height)
    plot.init(xlim=xlim, ylim=ylim, xlab=id.a, ylab=id.b, main=main)
    abline(a=log10(8/5), b=1, lty=3)
    points(df$log.base.cov, df$log.set.cov, pch=19, cex=cex, col="darkgray")
    fig.end()

    fig.start(paste(fdir, "/summary.pdf", sep=""), type="pdf", fdir=fdir, width=5, height=height)
    plot.init(xlim=xlim, ylim=ylim, xlab=id.a, ylab=id.b, main=main)
    abline(a=log10(8/5), b=1, lty=3)
    points(df$log.base.cov, df$log.set.cov, pch=19, cex=cex, col=df$col)
    fig.end()

    fig.start(paste(fdir, "/summary_text.pdf", sep=""), type="pdf", fdir=fdir, width=5, height=height)
    plot.init(xlim=xlim, ylim=ylim, xlab=id.a, ylab=id.b, main=main)
    abline(a=log10(8/5), b=1, lty=3)
    points(df$log.base.cov, df$log.set.cov, pch=19, cex=cex, col=df$col)
    text(df$log.base.cov, df$log.set.cov, df$bin, pos=1, cex=0.2)
    fig.end()

    df$change = abs(df$log.set.cov - df$log.base.cov)
    df$fix.class = ifelse(df$fix.count == 0, "no.fix", "fix")
    ss = split(df$change, df$fix.class)
    fig.start(paste(fdir, "/sweep_vs_stable.pdf", sep=""), type="pdf", fdir=fdir, width=3, height=5)
    plot(density(ss$no.fix))
    lines(density(ss$fix), col=2)
    fig.end()

}
