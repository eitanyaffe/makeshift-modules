plot.cell.summary=function(ifn.ca, ifn.order, ifn.coverage, fdir)
{
    anchor.table = load.table(ifn.order)
    table = load.table(ifn.ca)
    cov = load.table(ifn.coverage)
    table$cov = cov$abundance.enrichment[match(table$contig, cov$contig)]

    df = field.count(table, "contig")
    table$multi.anchor = ifelse(is.na(match(table$contig, df$contig)), F, df$count[match(table$contig, df$contig)] > 1)

    table$exp = table$contig_expected_cell
    table$obs = table$contig_total_count
    table$type = ifelse(table$contig_anchor == 0,
        ifelse(table$multi.anchor, "extended.multi", "extended.single"),
        ifelse(table$contig_anchor == table$anchor, "intra", "inter"))

    table$col = ifelse(table$type == "intra", "red", ifelse(table$type == "inter", "blue", ifelse(table$type == "extended.multi", "orange", "lightgray")))
    table$enr = log10(table$obs / table$exp)

    anchors = anchor.table$set
    contigs = unique(table$contig)

    xlim = range(table$enr)
    ylim = range(table$cov)

    N = length(anchors)
    Ny = ceiling(sqrt(N))
    Nx = ceiling(N/Ny)

    for (only.anchor in c(T,F)) {
        only.anchor.suffix = ifelse(only.anchor, "_only_anchor", "_all")
        # all together
        fig.start(ofn=paste(fdir, "/summary", only.anchor.suffix, ".pdf", sep=""), type="pdf", fdir=fdir, width=1 + 1*Nx, height=1 + 1*Ny)
        par(mai=c(0.05, 0.05, 0.15, 0.05))
        layout(matrix(1:(Nx*Ny), Nx, Ny))
        for (anchor in anchors) {
            ttable = table[table$anchor == anchor,]
            ix = ttable$type == "extended.multi" | ttable$type == "extended.single"
            plot.init(xlim=xlim, ylim=ylim, main=make.anchor.id(anchor, anchor.table), x.axis=F, y.axis=F, grid.lty=1)
            abline(v=0, lty=2)
            if (!only.anchor)
                points(ttable$enr[ix], ttable$cov[ix], pch=".", col=ttable$col[ix], cex=2)
            points(ttable$enr[!ix], ttable$cov[!ix], pch=".", col=ttable$col[!ix], cex=2)
        }
        fig.end()

        # separate
        ffdir = paste(fdir, "/anchors", only.anchor.suffix, sep="")
        for (anchor in anchors) {
            ttable = table[table$anchor == anchor,]
            ix = ttable$type == "extended.multi" | ttable$type == "extended.single"
            fig.start(ofn=paste(ffdir, "/", make.anchor.id(anchor, anchor.table), ".pdf", sep=""), type="pdf", fdir=ffdir, width=4, height=4.5)
            par(mai=c(1, 0.6, 0.3, 0.1))
            plot.init(xlim=xlim, ylim=ylim, main=paste(make.anchor.id(anchor, anchor.table), anchor), grid.lty=1, axis.las=2)
            abline(v=0, lty=2)
            if (!only.anchor)
                points(ttable$enr[ix], ttable$cov[ix], pch=".", col=ttable$col[ix], cex=2)
            points(ttable$enr[!ix], ttable$cov[!ix], pch=".", col=ttable$col[!ix], cex=2)
            fig.end()
        }
    }
}
