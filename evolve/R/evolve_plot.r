plot.snp.density=function(
    ifn.elements, ifn.cores, ifn.taxa, ifn.anchors,
    min.cov, min.length, min.detect, fdir)
{
    cores = load.table(ifn.cores)
    elements = load.table(ifn.elements)
    taxa = load.table(ifn.taxa)
    anchor.table = load.table(ifn.anchors)
    cores$anchor.id = anchor.table$id[match(cores$anchor, anchor.table$set)]

    cores$col = taxa$col[match(cores$anchor, taxa$anchor)]
    cores$anchor.id = taxa$anchor.id[match(cores$anchor, taxa$anchor)]

    cores = cores[cores$detected.fraction >= min.detect & cores$median.cov >= min.cov ,]
    elements = elements[elements$detected.fraction >= min.detect & elements$effective.length >= min.length & elements$median.cov >= min.cov,]

    elements$live.density = ifelse(elements$live.count > 0, elements$live.density, 0)
    elements$fixed.density = ifelse(elements$fixed.count > 0, elements$fixed.density, 0)

    main = sprintf("n=%d, m=%d", dim(cores)[1], dim(elements)[1])

    ########################################################################################################
    # functions
    ########################################################################################################

    # density
    plot.density=function(field, include.elements=T) {
        d.cores = density(log10(cores[,field]))
        d.elements = density(log10(elements[,field]))

        xlim = range(c(d.cores$x, d.elements$x))
        xlim = c(-6,-2)
        ylim = range(c(d.cores$y, d.elements$y))

        prefix = if (!include.elements) "hosts_" else "all_"
        fig.start(fdir=fdir, ofn=paste(fdir, "/", prefix, field, "_density_distrib.pdf", sep=""), type="pdf", height=5, width=5)
        plot.init(xlim=xlim, ylim=ylim, xlab="log10(snp/bp)", ylab="density", main=main)
        # abline(v=log10(snp.estimate.100y), lty=2)
        lines(d.cores, lwd=2)
        if (include.elements)
            lines(d.elements, lwd=2, col=3)
        fig.end()
    }

    # ecdf
    plot.ecdf=function(field, include.elements=T, add.text=F) {
        d.cores = ecdf(log10(cores[,field]))
        d.elements = ecdf(log10(elements[,field]))

        smin = min(log10(cores[,field]))
        smed = median(log10(cores[,field]))
        smax = max(log10(cores[,field]))
        main = sprintf("%s\n(min/med/max)=(%.1f/%.1f/%.1f)", main, smin, smed, smax)

        xlim = range(c(log10(cores[,field]), log10(elements[,field])))
        xlim = c(-6,-2)
        ylim = c(0,1)


        prefix = if (!include.elements) "hosts_" else "all_"
        ofn=paste(fdir, "/", prefix, field, "_ecdf_distrib", if (add.text) "_text", ".pdf", sep="")
        fig.start(fdir=fdir, ofn=ofn, type="pdf", height=5, width=5)
        plot.init(xlim=xlim, ylim=ylim, xlab="log10(snp/bp)", ylab="fraction", main=main)
        # abline(v=log10(snp.estimate.100y), lty=2)
        if (include.elements)
            lines(d.elements, lwd=2, col=3)
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

    plot.density(field="live.density", include.elements=F)
    plot.ecdf(field="live.density", include.elements=F)
    plot.ecdf(field="live.density", include.elements=F, add.text=T)

    plot.density(field="live.density")
    plot.ecdf(field="live.density")

    plot.density(field="fixed.density")
    plot.ecdf(field="fixed.density")
}
