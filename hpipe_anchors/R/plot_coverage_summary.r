plot.coverage.summary=function(ifn.ca, ifn.cov, fdir)
{
    ca = load.table(ifn.ca)
    cov = load.table(ifn.cov)

    df = field.count(ca, "contig")
    ca$multi.anchor = ifelse(is.na(match(ca$contig, df$contig)), F, df$count[match(ca$contig, df$contig)] > 1)
    ca$type = ifelse(ca$contig_anchor == 0,
        ifelse(ca$multi.anchor, "extended.multi", "extended.single"),
        ifelse(ca$contig_anchor == ca$anchor, "intra", "inter"))
    ca$col = ifelse(ca$type == "intra", "red", ifelse(ca$type == "inter", "blue", ifelse(ca$type == "extended.multi", "orange", "lightgray")))
    ca$cov = cov$abundance.enrichment[match(ca$contig, cov$contig)]

    # contact score
    ca$score = ca$contig_total_count / ca$contig_expected_cell

    # limit to anchored
    cov = cov[is.element(cov$contig, ca$contig),]

    # anchor coverage
    ca.anchors = ca[ca$contig_anchor != 0,]
    anchor.cov = sapply(split(ca.anchors$cov, ca.anchors$anchor), median)

    # host coverage
    ca$host.cov = anchor.cov[match(ca$anchor, names(anchor.cov))]

    # correct host coverage according contact score
    ca$host.cov.d = 10^ca$host.cov
    ca$host.cov.n = 10^ca$host.cov * ca$score

    # summary per contig
    host.cov.d = log10(sapply(split(ca$host.cov.d, ca$contig), sum))
    host.cov.n = log10(sapply(split(ca$host.cov.n, ca$contig), sum))

    contigs = unique(ca$contig)
    df = data.frame(contig=contigs)
    df$contig.cov = cov$abundance.enrichment[match(df$contig, cov$contig)]
    df$host.cov.n = host.cov.n[match(df$contig, names(host.cov.n))]
    df$host.cov.d = host.cov.d[match(df$contig, names(host.cov.d))]

    # df$col = ca$col[match(df$contig, ca$contig)]
    df$multi = ca$multi.anchor[match(df$contig,ca$contig)]
    df$col = ifelse(df$multi, "orange", "gray")
    df = df[order(df$multi),]

    size = 5

    ####################################################################################################
    # scatter all
    ####################################################################################################

    xlim = range(df$contig.cov)
    ylim = range(df$host.cov.n)
    fig.start(fdir=fdir, ofn=paste(fdir, "/all.pdf", sep=""), type="pdf", height=size, width=size)
    plot.init(xlim=xlim, ylim=ylim, xlab="contig abundance", ylab="sum host abundances", add.grid=T, main="")
    abline(a=0, b=1, lty=3)
    points(df$contig.cov, df$host.cov.n, pch=".", cex=ifelse(df$multi,3,1), col=df$col)
    fig.end()

    ####################################################################################################
    # limit to shared, scatter with pearson
    ####################################################################################################

    df = df[df$multi,]

    main.d = round(cor(df$host.cov.d, df$contig.cov),2)
    main.n = round(cor(df$host.cov.n, df$contig.cov),2)

    xlim = range(df$contig.cov)
    ylim = range(df$host.cov.d)
    fig.start(fdir=fdir, ofn=paste(fdir, "/shared_no_score_correction.pdf", sep=""), type="pdf", height=size, width=size)
    plot.init(xlim=xlim, ylim=ylim, xlab="contig abundance", ylab="sum host abundances", add.grid=T, main=main.d)
    abline(a=0, b=1, lty=3)
    points(df$contig.cov, df$host.cov.d, pch=".", cex=2, col=df$col)
    fig.end()

    xlim = range(df$contig.cov)
    ylim = range(df$host.cov.n)
    fig.start(fdir=fdir, ofn=paste(fdir, "/shared.pdf", sep=""), type="pdf", height=size, width=size)
    plot.init(xlim=xlim, ylim=ylim, xlab="contig abundance", ylab="sum host abundances", add.grid=T, main=main.n)
    abline(a=0, b=1, lty=3)
    points(df$contig.cov, df$host.cov.n, pch=".", cex=2, col=df$col)
    fig.end()

    ####################################################################################################
    # ecdf of cov over host coverage
    ####################################################################################################

    fig.start(fdir=fdir, ofn=paste(fdir, "/ecdf.pdf", sep=""), type="pdf", height=size, width=size)
    plot(ecdf(df$contig.cov - df$host.cov.n), main="", xlab="log10(contig_cov/host_covs)")
    abline(v=0, lty=3)
    fig.end()


}
