plot.host.details=function(ifn.cores, ifn.elements, ifn.ea, min.length=1000, fdir)
{
    cores = load.table(ifn.cores)
    elements = load.table(ifn.elements)
    ea = load.table(ifn.ea)

    # elements = elements[elements$fate != "chimeric" & elements$effective.length > min.length,]
    elements = elements[elements$effective.length > min.length,]

    elements$col =
        ifelse(elements$fate == "not.detected", "darkblue",
               ifelse(elements$fate == "low.detected", "gray",
                      ifelse(elements$fate == "turnover", "red", "green")))

    elements$fixed.density = ifelse(elements$fixed.count == 0, 10^-6, elements$fixed.density)
    elements$x = log10(elements$fixed.density)
    elements$y = log10(elements$effective.length)

    xlim = range(elements$x)
    ylim = range(elements$y)

    for (anchor.id in cores$anchor.id) {
        anchor = cores$anchor[cores$anchor.id == anchor.id]
        ids = ea$element.id[ea$anchor == anchor]
        df = elements[is.element(elements$element.id, ids),]

        ofn = paste(fdir, "/", anchor.id, ".pdf", sep="")
        fig.start(fdir=fdir, ofn=ofn, type="pdf", height=6, width=6)
        plot.init(xlim=xlim, ylim=ylim, xlab="mut/bp", ylab="length", main=anchor.id)
        points(df$x, df$y, col=df$col, pch=19)
        fig.end()
    }
}
