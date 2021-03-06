plot.rep.analysis=function(ifn.rep, ifn.cores, mut.per.year, fdir)
{
    table = load.table(ifn.rep)
    cores = load.table(ifn.cores)
    cores$gene.gain = cores$total.gene.count - cores$gene.count
    cores = cores[cores$selected,]
    table = table[is.element(table$anchor, cores$anchor),]
    table$gene.gain = cores$gene.gain[match(table$anchor, cores$anchor)]

    table$ref.length.mb = table$ref.length/10^6
    table$anchor.length.mb = table$anchor.length/10^6
    table$col.cag = ifelse(table$is.cag, "red", "black")
    table$col.single = "black"

    table$identity.distance = 100 - (table$anchor.identity+table$ref.identity)/2
    table$content.distance = 100 -
        100 * (0.01*table$anchor.coverage*table$anchor.length + 0.01*table$ref.coverage*table$ref.length) /
            (table$anchor.length + table$ref.length)

    table$log.mut = log10(table$identity.distance/100)

    colors = c("black", "darkblue", "blue", "red", "orange", "yellow")
    breaks = c(0, 85, 90, 95, 98, 100)

    panel = make.color.panel(colors)
    wlegend2(fdir=fdir, panel=panel, breaks=breaks, title="identity")
    table$col.identity = panel[vals.to.cols((table$anchor.identity+table$ref.identity)/2, breaks)]

    height = 4.6
    width = 4
    cex = 0.75
    pch = 19

    cat(sprintf("mean anchor coverage: %.1f\n", mean(table$anchor.coverage)))
    cat(sprintf("median anchor coverage: %.1f\n", median(table$anchor.coverage)))
    cat(sprintf("max anchor coverage: %.1f\n", max(table$anchor.coverage)))
    cat(sprintf("mean ref coverage: %.1f\n", mean(table$ref.coverage)))
    cat(sprintf("median ref coverage: %.1f\n", median(table$ref.coverage)))
    cat(sprintf("max ref coverage: %.1f\n", max(table$ref.coverage)))

    plot.f.internal=function(title, xlab, ylab,
        xlim=NULL, ylim=NULL, y.start.zero=F, add.v=NULL,
        main, field.x, field.y, pre.f=NULL, post.f=NULL, field.col="col.cag", border.field=NULL, add.text)
    {
        if (is.null(xlim))
            xlim = range(table[,field.x])
        if (is.null(ylim))
            ylim = range(table[,field.y])
        if (y.start.zero)
            ylim[1] = 0

        fig.start(fdir=fdir, ofn=paste(fdir, "/", title, ifelse(add.text, "_labels", ""), ".pdf", sep=""), type="pdf", width=width, height=height)
        par(mai=c(1,1,1.2,0.5))
        plot.init(xlim=xlim, ylim=ylim, xlab=xlab, ylab=ylab, main=main, axis.las=1)
        if (!is.null(pre.f)) pre.f()
        grid()
        points(table[,field.x], table[,field.y], pch=pch, cex=cex, col=table[,field.col])
        if (!is.null(border.field))
            points(table[,field.x], table[,field.y], pch=1, cex=cex, col=ifelse(table[,border.field], 1, NA))
        if (!is.null(post.f)) post.f()
        if (add.text) {
            text(table[,field.x], table[,field.y], pos=4, labels=table$anchor.id, cex=0.5)
            cc = paste("spearman=", round(cor(table[,field.x], table[,field.y], method="spearman"),2), sep="")
            title(sub=cc)
        }
        fig.end()
    }
    plot.f=function(...) {
        plot.f.internal(add.text=F, ...)
        plot.f.internal(add.text=T, ...)
    }

    # coverage
    plot.f(title="coverage_cag", main="coverage (%)", pre.f={abline(a=0, b=1, lty=2)},
           xlab="anchors", ylab="refs",
           field.x="anchor.coverage", field.y="ref.coverage",
           xlim=c(0,100), ylim=c(0,100))
    plot.f(title="coverage_identity", main="coverage (%), col by identity", pre.f={abline(a=0, b=1, lty=2)},
           xlab="anchors", ylab="refs",
           field.x="anchor.coverage", field.y="ref.coverage",
           xlim=c(0,100), ylim=c(0,100), field.col="col.identity", border.field="is.cag")

    # identity vs coverage (anchors)
    plot.f(title="anchor_identity_vs_coverage", main="coverage vs identity (anchors)",
           xlab="coverage", ylab="identity",
           field.x="anchor.coverage", field.y="anchor.identity",
           xlim=c(0,100), ylim=c(85,100))

    # nt difference vs % accessory
    plot.f(title="ntdiff_hgt", main="sub vs content",
           xlab="substitution (%)", ylab="transfer (%)", y.start.zero=T,
           field.x="identity.distance", field.y="content.distance", field.col="col.single")

    # mutation vs gene gain rates
    plot.f(title="mut_gain", main="mut rate vs gene gain",
           xlab="log10(mut/bp)", ylab="#genes", y.start.zero=T,
           pre.f=function() {
#               at = log10(mut.per.year*10^(1:3))
#               axis(side=3, at=at, labels=paste(10^(1:3)))
           },
           post.f=function() { box() },
           field.x="log.mut", field.y="gene.gain", field.col="col.single")

    # identity vs coverage (refs)
    plot.f(title="ref_identity_vs_coverage", main="coverage vs identity (refs)",
           xlab="coverage", ylab="identity",
           field.x="ref.coverage", field.y="ref.identity",
           xlim=c(0,100), ylim=c(85,100))

    # genome length
    lim = range(c(0, table$anchor.length.mb, table$ref.length.mb))
    plot.f(title="genome_size_cag", main="genome size (mb)", pre.f={abline(a=0, b=1, lty=2)},
           xlab="anchors", ylab="refs",
           field.x="anchor.length.mb", field.y="ref.length.mb",
           xlim=lim, ylim=lim)
    plot.f(title="genome_size_identity", main="genome size (mb), col by identity", pre.f={abline(a=0, b=1, lty=2)},
           xlab="anchors", ylab="refs",
           field.x="anchor.length.mb", field.y="ref.length.mb",
           xlim=lim, ylim=lim, field.col="col.identity", border.field="is.cag")

    # coverage hists
    plot.hist=function(field) {
        fig.start(fdir=fdir, ofn=paste(fdir, "/", field, ".pdf", sep=""), type="pdf", width=4, height=4)
        main = paste("anchor coverage, mean=", round(mean(table[,field]),1),
            "\nmedian=", round(median(table[,field]),1),
            "\nrange=", round(min(table[,field]),1), " - ", round(max(table[,field]),1), sep="")
        hist(table[,field], main=main, col="darkgreen", breaks=20, xlim=c(0,100), cex.main=0.5)
        fig.end()
    }
    plot.hist(field="anchor.coverage")
    plot.hist(field="ref.coverage")
}

plot.mapping=function(ifn.pairs, anchor2ref.dir, ref2anchor.dir, length, fdir)
{
    table = load.table(ifn.pairs)
    names = paste(ifelse(table$is.cag, "C", ""), table$anchor.id)
    colors = c("black", "darkblue", "blue", "red", "orange", "yellow")
    breaks = c(0, 85, 90, 95, 98, 99.99, 100)

    identity.breakdown=function(ifn) {
        tt = read.delim(ifn)
        tt$identity = ifelse(tt$edit != -1, 100 - 100*tt$edit/length, 0)
        result = sapply(split(tt$count, cut(tt$identity, breaks, include.lowest=T)), sum)
        result = round(100 * result / sum(result),3)
        as.data.frame(t(result))
    }
    df.anchors = NULL
    df.refs = NULL
    for (i in 1:dim(table)[1]) {
        anchor = table$anchor[i]
        accession = table$ref[i]
        src.anchor.ifn = paste(anchor2ref.dir, "/", anchor, "_", accession, "/src_summary", sep="")
        tgt.anchor.ifn = paste(ref2anchor.dir, "/", anchor, "_", accession, "/tgt_summary", sep="")

        tgt.ref.ifn = paste(anchor2ref.dir, "/", anchor, "_", accession, "/tgt_summary", sep="")
        src.ref.ifn = paste(ref2anchor.dir, "/", anchor, "_", accession, "/src_summary", sep="")

        anchor.bd = (identity.breakdown(src.anchor.ifn) + identity.breakdown(tgt.anchor.ifn)) / 2
        ref.bd = (identity.breakdown(src.ref.ifn) + identity.breakdown(tgt.ref.ifn)) / 2

        df.anchors = rbind(df.anchors, anchor.bd)
        df.refs = rbind(df.refs, ref.bd)
    }

    wlegend(fdir=fdir, title="identity_breakdown", cols=colors, names=names(df.anchors))

    fig.start(fdir=fdir, ofn=paste(fdir, "/anchor_seq_identity.pdf", sep=""), type="pdf", width=12, height=4)
    barplot(t(as.matrix(df.anchors)), col=colors, border=colors, ylab="% anchor genome", xlab="anchor", las=2, names.arg=names)
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/ref_seq_identity.pdf", sep=""), type="pdf", width=12, height=4)
    barplot(t(as.matrix(df.refs)), col=colors, border=colors, ylab="% ref genome", xlab="anchor", las=2, names.arg=names)
    fig.end()
}

plot.details.internal=function(df, title, fdir)
{
    N = dim(df)[1]
    df$ycoord = 1:N-0.5
    mcoord = max(c(df$anchor.length, df$ref.length))
    size = 0.4

    # colors = c("black", "darkblue", "blue", "red", "orange", "yellow")
    # breaks = c(0, 85, 90, 95, 98, 100)
    colors = c(colors()[351], colors()[312])
    breaks = c(98, 100)

    panel = make.color.panel(colors)
    wlegend2(fdir=fdir, panel=panel, breaks=breaks, title="identity")
    df$anchor.color = panel[vals.to.cols(df$anchor.identity, breaks)]
    df$ref.color = panel[vals.to.cols(df$ref.identity, breaks)]
    df$anchor.coord = df$anchor.coverage * df$anchor.length / 100
    df$ref.coord = df$ref.coverage * df$ref.length / 100

    fig.start(fdir=fdir, ofn=paste(fdir, "/", title, ".pdf", sep=""), type="pdf", width=8, height=2 + N*0.16)

    par(mai=c(1, 1, 0.2, 4))
    par(yaxs="i")
    plot.new()
    plot.window(xlim=c(-mcoord, mcoord), ylim=c(0,N))
    title(xlab="Mbp")

    gray = colors()[300]

    # backbone
    segments(x0=rep(-mcoord,N), x1=rep(mcoord,N), y0=1:N-0.5, y1=1:N-0.5, col=gray)

    rect(xleft=-df$anchor.length, xright=0, ybottom=df$ycoord-size, ytop=df$ycoord+size, col="white")
    rect(xright=df$ref.length, xleft=0, ybottom=df$ycoord-size, ytop=df$ycoord+size, col="white")

    # identity region
    rect(xleft=-df$anchor.coord, xright=0, ybottom=df$ycoord-size, ytop=df$ycoord+size, border=NA, col=df$anchor.color)
    rect(xright=df$ref.coord, xleft=0, ybottom=df$ycoord-size, ytop=df$ycoord+size, border=NA, col=df$ref.color)

    # all genome
#    rect(xleft=-df$anchor.length, xright=0, ybottom=df$ycoord-size, ytop=df$ycoord+size, border=NA, col="lightgray")
#    rect(xright=df$ref.length, xleft=0, ybottom=df$ycoord-size, ytop=df$ycoord+size, border=NA, col="lightgray")
    rect(xleft=-df$anchor.length, xright=0, ybottom=df$ycoord-size, ytop=df$ycoord+size, border=gray, col=NA)
    rect(xright=df$ref.length, xleft=0, ybottom=df$ycoord-size, ytop=df$ycoord+size, border=gray, col=NA)

    # axis
    segments(x0=0, x1=0, y0=0, y1=N)
    axis(side=2, at=1:N-0.5, labels=df$anchor.id, las=2)
    axis(side=4, at=1:N-0.5, labels=df$ref.name, las=2)

    # coord axis
    axis.binsize = 10^6
    mm = floor(mcoord/axis.binsize)
    at = 1:mm*axis.binsize
    axis(side=1, at=-at, labels=1:mm)
    axis(side=1, at=at, labels=1:mm)
    fig.end()
}

plot.details=function(ifn.pairs, ifn.cores, fdir)
{
    df = load.table(ifn.pairs)
    cores = load.table(ifn.cores)
    plot.details.internal(df=df, fdir=fdir, title="all")

    df.limited = df[is.element(df$anchor,cores$anchor),]
    plot.details.internal(df=df.limited, fdir=fdir, title="with_strain_ref")
}
