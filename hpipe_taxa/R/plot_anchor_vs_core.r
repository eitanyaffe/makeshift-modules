plot.avsc=function(anchor.ifn, core.ifn, fdir)
{
    anchors = load.table(anchor.ifn)
    cores = load.table(core.ifn)

    df = NULL
    ids = sort(unique(cores$anchor))
    for (id in ids) {
        anchor = unique(anchors$gene[anchors$anchor == id & anchors$contig_anchor == id])
        union = unique(anchors$gene[anchors$anchor == id])
        core = unique(cores$gene[cores$anchor == id])

        inter.n = length(intersect(anchor, core))
        only.anchor.n = length(setdiff(anchor, core))
        only.core.n = length(setdiff(core, anchor))
        either.n = length(unique(c(anchor,core)))
        union.n = length(union)
        neither.n = union.n - length(unique(c(anchor,core)))

        N = union.n

        df = rbind(df, data.frame(id=id,
            total=N, union=1, anchor=length(anchor)/N, core=length(core)/N,
            intersect=inter.n/N, only.anchor=only.anchor.n/N, only.core=only.core.n/N, either=either.n/N, neither=neither.n/N))
    }
    df = df[order(df$intersect),]

    fields = c("intersect", "only.core", "only.anchor", "neither")
    colors = c("darkgreen", "orange", "darkgray", "lightgray")

    main = sprintf("inter=%.2f anchor.only=%.2f core.only=%.2f shell=%.2f",
        mean(df$intersect), mean(df$only.anchor), mean(df$only.core), mean(df$neither))

    mm = 100*t(as.matrix(df[,fields]))
    fig.start(fdir=fdir, ofn=paste(fdir, "/core_vs_anchor.pdf", sep=""), type="pdf", width=6, height=3)
    barplot(mm, col=colors, border=NA, axisnames=F, main=main, las=2)
    fig.end()

    wlegend(fdir, names=fields, cols=colors, title="genes")
}
