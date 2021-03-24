tcol = function(color, percent = 50, name = NULL) {
    rgb.val = col2rgb(color)
    t.col = rgb(red=rgb.val[1,], green=rgb.val[2,], blue=rgb.val[3,],
                max = 255,
                alpha = (100 - percent) * 255 / 100)
    invisible(t.col)
}

plot.tsne.density=function(ifn, nbins, fdir)
{
    df = load.table(ifn)
    xlim = range(df$x)
    ylim = range(df$y)

    xbreaks = seq(xlim[1], xlim[2], length.out=nbins)
    ybreaks = seq(ylim[1], ylim[2], length.out=nbins)

    xstep = diff(xlim) / nbins
    ystep = diff(ylim) / nbins
    df$x.bin = pmax(1, ceiling((df$x - xlim[1]) / xstep))
    df$y.bin = pmax(1, ceiling((df$y - ylim[1]) / ystep))
    ss = sapply(split(df$length, list(df$x.bin, df$y.bin)), sum)

    mm = expand.grid(xbin=1:nbins, ybin=1:nbins)
    mm$key = paste0(mm$xbin, ".", mm$ybin)
    ix = match(mm$key, names(ss))
    mm$length = ifelse(!is.na(ix), ss[ix], 0)

    mm$xleft = (mm$xbin-1) * xstep + xlim[1]
    mm$xright = mm$xleft + xstep

    mm$ybottom = (mm$ybin-1) * ystep + ylim[1]
    mm$ytop = mm$ybottom + ystep

    colors = c("white", "white", "blue", "orange")
    breaks = c(0, 10000, 100000, 1000000)
    panel = make.color.panel(colors=colors)
    mm$col = panel[vals.to.cols(mm$length, breaks=breaks)]
    wlegend2(fdir=fdir, panel=panel, breaks=breaks, title="length")

    fig.start(fdir=fdir, ofn=paste(fdir, "/density.pdf", sep=""), type="pdf", height=6, width=6)
    par(mai=c(0.2, 0.2, 0.2, 0.2))
    plot.init(xlim=xlim, ylim=ylim, log="", main="", xlab="", ylab="", add.box=F, x.axis=F, y.axis=F, add.grid=F)
    rect(xleft=mm$xleft, xright=mm$xright, ybottom=mm$ybottom, ytop=mm$ytop, col=mm$col, border=NA)
    fig.end()
}

plot.tsne=function(ifn, ifn.cb, ifn.bins, percent, fdir)
{
    df = load.table(ifn)
    cb = load.table(ifn.cb)
    bins.df = load.table(ifn.bins)
    cb$class = bins.df$class[match(cb$bin, bins.df$bin)]
    cb$bin.length = bins.df$length[match(cb$bin, bins.df$bin)]

    # bins
    ix = match(df$contig, cb$contig)
    df$bin = ifelse(!is.na(ix), cb$bin[ix], 0)
    df$is.host = ifelse(!is.na(ix), cb$class[ix] == "host", F)
    df$bin.length = ifelse(!is.na(ix), cb$bin.length[ix], F)
    df$is.binned.col = ifelse(df$bin == 0 | df$bin.length<10000, "gray", "red")
    bins = unique(df$bin[df$is.host])
    bin.cols = rainbow(length(bins))
    df$bin.col = ifelse(df$bin == 0 | !df$is.host, "lightgray", bin.cols[match(df$bin, bins)])

    # length
    length.colors = c("gray", "blue", "red", "orange")
    df$length.index = pmax(1, pmin(5, floor(log10(df$length))) - 1)
    df$length.col = length.colors[df$length.index]
    wlegend(fdir, names=c("10^2", "10^3", "10^4", "10^5"), cols=length.colors, title="length")

    # number of samples
    df$nsamples.cut = cut(df$num.samples.detected, breaks=c(1,2,4,8,16,20,25), include.lowest=T)
    df$nsamples.ii = as.numeric(df$nsamples.cut)
    sample.panel = rev(rainbow(length(levels(df$nsamples.cut))))
    df$nsamples.col = sample.panel[df$nsamples.ii]
    wlegend(fdir, names=levels(df$nsamples.cut), cols=sample.panel, title="nsamples")

    df$basic.col = "darkblue"
    df = df[df$num.samples.detected > 0,]


    plot.f=function(df, field.col, title, transparent=F, fdir, xlim=xlim, ylim=ylim, width=6, height=6, cex=0.1) {
        if (transparent)
            df$col = tcol(df[,field.col], percent=percent)
        else
            df$col = df[,field.col]

        fig.start(fdir=fdir, ofn=paste(fdir, "/", title, ".pdf", sep=""), type="pdf", height=height, width=width)
        par(mai=c(0.2, 0.2, 0.2, 0.2))
        plot.init(xlim=xlim, ylim=ylim, log="", main="", xlab="", ylab="", add.box=F, x.axis=F, y.axis=F, add.grid=F)
        points(df$x, df$y, pch=21, cex=cex, col=df$col, bg=NA)
        fig.end()
    }

    xlim = range(df$x)
    ylim = range(df$y)

    # total depth
    qbreaks = 1:10 / 10
    df$depth.cut = cut(df$total.depth, breaks=quantile(df$total.depth, qbreaks))
    df$depth.ii = as.numeric(df$depth.cut)
    # df$depth.col = make.color.panel(colors=c("blue", "red"), ncols=10)[df$depth.ii]
    depth.panel = rev(rainbow(length(qbreaks)-1))
    df$depth.col = depth.panel[df$depth.ii]
    wlegend(fdir, names=levels(df$depth.cut), cols=depth.panel, title="depth")

    # df = df[1:10000,]
    df.long = df[df$length>1000,]

    # basic
    plot.f(df=df, field.col="basic.col", title="basic_all", transparent=T, fdir=fdir, xlim=xlim, ylim=ylim)
    plot.f(df=df.long, field.col="basic.col", title="basic", transparent=T, fdir=fdir, xlim=xlim, ylim=ylim)

    # contig length
    plot.f(df=df, field.col="length.col", title="length", transparent=T, fdir=fdir, xlim=xlim, ylim=ylim)

    # bins
    plot.f(df=df.long, field.col="is.binned.col", title="is_binned", transparent=T, fdir=fdir, xlim=xlim, ylim=ylim)
    plot.f(df=df.long, field.col="bin.col", title="bins", transparent=T, fdir=fdir, xlim=xlim, ylim=ylim)

    # sequencing depth
    plot.f(df=df.long, field.col="depth.col", title="depth", transparent=T, fdir=fdir, xlim=xlim, ylim=ylim)

    # nsamples
    plot.f(df=df.long, field.col="nsamples.col", title="nsamples", transparent=T, fdir=fdir, xlim=xlim, ylim=ylim)

    plot.bin=function(df, fdir, field.col, bin) {
        xlim = range(df$x[df$bin == bin])
        ylim = range(df$y[df$bin == bin])
        df = df[df$x >= xlim[1] & df$x <= xlim[2] & df$y >= ylim[1] & df$y <= ylim[2],]

        # total depth
        qbreaks = 1:10 / 10
        df$depth.cut = cut(df$total.depth, breaks=quantile(df$total.depth, qbreaks))
        df$depth.ii = as.numeric(df$depth.cut)
        # df$depth.col = make.color.panel(colors=c("blue", "red"), ncols=10)[df$depth.ii]
        depth.panel = rev(rainbow(10))
        df$depth.col = depth.panel[df$depth.ii]

        df[df$bin != bin,field.col] = "lightgray"

        # sequencing depth
        plot.f(df=df, field.col=field.col, title=bin, transparent=T, fdir=fdir, xlim=xlim, ylim=ylim, width=3, height=3, cex=0.3)
    }

    for (bin in bins) {
        width = 3
        height = 3
        cex = 0.3
        plot.bin(df=df, bin=bin, field.col="depth.col", fdir=paste0(fdir,"/bins_depth"))
        plot.bin(df=df, bin=bin, field.col="nsamples.col", fdir=paste0(fdir,"/bins_nsamples"))
    }
}
