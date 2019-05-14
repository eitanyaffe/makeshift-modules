plot.poly=function(
    ifn.elements, ifn.cores, ifn.taxa, ifn.anchors,
    min.cov, min.length, min.detect, fdir)
{
    cores = load.table(ifn.cores)
    elements = load.table(ifn.elements)
    taxa = load.table(ifn.taxa)
    anchor.table = load.table(ifn.anchors)
    cores$anchor.id = anchor.table$id[match(cores$anchor, anchor.table$set)]

    min.density = 10^-4
    elements$live.density = ifelse(elements$live.count > 0, elements$live.density, min.density)

    cores$col = taxa$col[match(cores$anchor, taxa$anchor)]
    cores$anchor.id = taxa$anchor.id[match(cores$anchor, taxa$anchor)]

    cores = cores[cores$detected.fraction >= min.detect & cores$median.cov >= min.cov ,]
    high = elements[elements$detected.fraction >= min.detect & elements$median.cov >= min.cov & elements$effective.length >= min.length,]
    singles = high[high$type == "single",]
    shared = high[high$type == "shared",]


    main = sprintf("cores=%d, single=%d shared=%d", dim(cores)[1], dim(singles)[1], dim(shared)[1])

    ########################################################################################################
    # functions
    ########################################################################################################

    # ecdf
    plot.ecdf=function(field, include.elements=T, add.text=F) {
        d.cores = ecdf(log10(cores[,field]))
        d.singles = ecdf(log10(singles[,field]))
        d.shared = ecdf(log10(shared[,field]))

        xlim = range(c(log10(cores[,field]), log10(singles[,field]), log10(shared[,field])))
        xlim = c(-6,-2)
        ylim = c(0,1)

        prefix = if (!include.elements) "hosts_" else "all_"
        ofn=paste(fdir, "/", prefix, field, "_ecdf_distrib", if (add.text) "_text", ".pdf", sep="")
        fig.start(fdir=fdir, ofn=ofn, type="pdf", height=5, width=5)
        plot.init(xlim=xlim, ylim=ylim, xlab="log10(snp/bp)", ylab="fraction", main=main)
        if (include.elements) {
            lines(d.singles, lwd=2, col=3)
            lines(d.shared, lwd=2, col=4)
        }
        lines(d.cores, lwd=2)

        if (add.text) {
            x = log10(cores[, field])
            y = d.cores(log10(cores[, field]))
            text(x,y,cores$anchor.id, pos=2, cex=0.5)
        }

        fig.end()
    }

    ########################################################################################################
    # main
    ########################################################################################################

    plot.ecdf(field="live.density", include.elements=T)
    plot.ecdf(field="live.density", include.elements=F)
    plot.ecdf(field="live.density", include.elements=F, add.text=T)
}
