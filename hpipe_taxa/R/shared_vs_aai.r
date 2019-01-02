plot.shared.aai=function(mat.ifn, host.matrix.ifn, core.ifn, aai.breaks, fdir)
{
    aai = load.table(mat.ifn)
    smat = load.table(host.matrix.ifn)
    cores = load.table(core.ifn)

    smat$key = paste(smat$anchor.x, smat$anchor.y, sep="_")
    aai$key = paste(aai$set1, aai$set2, sep="_")

    ids = cores$anchor
    df = expand.grid(ids, ids)
    names(df) = c("id1", "id2")
    df = df[df$id1 != df$id2,]
    df$key = paste(df$id1, df$id2, sep="_")

    ix = match(df$key, smat$key)
    df$gene.count = ifelse(!is.na(ix), smat$gene.count[ix], 0)

    ix = match(df$key, aai$key)
    if (any(is.na(ix)))
        stop("internal error")
    df$identity = aai$identity[ix]

    ss = split(df, cut(df$identity, aai.breaks))

    ss.count = sapply(ss, function(x) { sum(x$gene.count > 0) })
    ss.total = sapply(ss, function(x) { dim(x)[1] })
    ss.gene.count = sapply(ss, function(x) { median(x$gene.count[x$gene.count > 0]) })

    res = data.frame(label=names(ss), count=100*ss.count, total=100*ss.total, gene.count=ss.gene.count)
    res$percent = 100 * res$count / res$total
    res$high = 100 * (res$count + sqrt(res$count)) / res$total
    ylim = c(0, max(res$high)*1.1)

    fig.start(fdir=fdir, ofn=paste(fdir, "/percent.pdf", sep=""), type="pdf", height=4, width=3)
    mx = barplot(res$percent, col="darkblue", names.arg=res$label, las=2, ylab="%", ylim=ylim, border=NA)
    segments(x0=mx, x1=mx, y0=res$percent, y1=res$high)
    segments(x0=mx-0.2, x1=mx+0.2, y0=res$high, y1=res$high)
    title(main="shared fraction")
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/percent_labels.pdf", sep=""), type="pdf", height=4, width=3)
    mx = barplot(res$percent, col="darkblue", names.arg=res$label, las=2, ylab="%", ylim=ylim, border=NA)
    text(mx, res$percent, round(res$percent,1), pos=3)
    title(main="shared fraction")
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/gene.count.pdf", sep=""), type="pdf", height=4, width=3)
    mx = barplot(res$gene.count, col="darkblue", names.arg=res$label, las=2, ylab="#genes", ylim=ylim, border=NA)
    title(main="median shared gene count")
    fig.end()

}
