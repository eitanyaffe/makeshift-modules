plot.scatter=function(df, field.x, field.y, log.x=F, log.y=F, field.col=NA, field.label="anchor.id", fdir, plot.label=F)
{
    if (log.x) {
        xlab = paste("log10(", field.x, ")", sep="")
        df$x = log10(df[,field.x])
    } else {
        xlab = field.x
        df$x = df[,field.x]
    }
    if (log.y) {
        ylab = paste("log10(", field.y, ")", sep="")
        df$y = log10(df[,field.y])
    } else {
        ylab = field.y
        df$y = df[,field.y]
    }

    df$col = 1
    if (!is.na(field.col)) {
        main = paste("color by", field.col)
        df$col = df[,field.col]
    } else {
        main = ""
        field.col = "none"
    }

    xlim = range(df$x)
    ylim = range(df$y)
    fig.start(fdir=fdir, ofn=paste(fdir, "/", field.x, "_", field.y, "_", field.col, ".pdf", sep=""), type="pdf", height=6, width=6)
    plot.init(xlim=xlim, ylim=ylim, xlab=xlab, ylab=ylab, main=main)
    points(df$x, df$y, col=df$col, pch=19)
    fig.end()

    if (plot.label) {
        fig.start(fdir=fdir, ofn=paste(fdir, "/", field.x, "_", field.y, "_", field.label, ".pdf", sep=""), type="pdf", height=10, width=10)
        plot.init(xlim=xlim, ylim=ylim, xlab=xlab, ylab=ylab, main=main)
        points(df$x, df$y, col=df$col, pch=19)
        text(df$x, df$y, df[,field.label], pos=1, cex=0.75)
        fig.end()
    }
}

plot.host.scatters=function(ifn, ifn.taxa, fdir)
{
    cores = load.table(ifn)
    taxa = load.table(ifn.taxa)

    cores$anchor.id = taxa$anchor.id[match(cores$anchor, taxa$anchor)]

    cores$log.fixed.density = log10(cores$fixed.density)
    cores$log.live.density = log10(cores$live.density)

    cores$log.cov = log10(cores$median.cov+1)

    colors = c("green", "blue", "red")
    breaks = c(-5, -3.5, -2.5)
    panel = make.color.panel(colors)
    wlegend2(fdir=fdir, panel=panel, breaks=breaks, title="identity")
    cores$fix.col = panel[vals.to.cols(cores$log.fixed.density, breaks)]

    # fix vs detection
    plot.scatter(cores, field.x="log.fixed.density", field.y="detected.fraction", plot.label=T, fdir=fdir)
    plot.scatter(cores, field.x="log.fixed.density", field.y="detected.fraction", field.label="live.count", plot.label=T, fdir=fdir)

    # live vs xcov
    plot.scatter(cores, field.x="log.live.density", field.y="log.cov", plot.label=T, fdir=fdir)
    plot.scatter(cores, field.x="log.live.density", field.y="log.cov", field.label="live.count", plot.label=T, fdir=fdir)

    # cov vs detection
    plot.scatter(cores, field.x="log.cov", field.y="detected.fraction", field.col="fix.col", plot.label=T, fdir=fdir)
}

plot.element.scatters=function(ifn, min.length, fdir)
{
    elements = load.table(ifn)
    elements = elements[elements$median.cov > 0 & elements$effective.length > min.length & is.element(elements$class,c("complex", "simple")),]

    elements$col.type = ifelse(elements$type == "shared", "orange", "black")
    elements$col.class = ifelse(elements$class == "simple", 1, ifelse(elements$class == "complex", 2, "gray"))

    field.label = "element.id"

    plot.scatter(elements,
                 field.x="effective.length", log.x=T,
                 field.y="median.cov", log.y=T,
                 field.col="col.type",
                 plot.label=T, fdir=fdir, field.label=field.label)

    plot.scatter(elements,
                 field.x="live.density", log.x=T,
                 field.y="effective.length", log.y=T,
                 field.col="col.type",
                 plot.label=T, fdir=fdir, field.label=field.label)
}
