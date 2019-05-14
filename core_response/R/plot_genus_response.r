plot.anchors=function(rep.table, anchor.ids, medians, min.score, main, drange, labels)
{
    M = dim(medians)[2] - 2
    ylim = c(min.score, 1.5)
    coords = 1:M

    names = paste(rep.table$anchor.id[match(anchor.ids, rep.table$anchor.id)], ": ", rep.table$name[match(anchor.ids, rep.table$anchor.id)], sep="")

    layout(matrix(1:2, 1, 2), widths=c(1,1.3))
    par(mai=c(0.6,0.6,0.4,0.05))
    plot.init(xlim=c(1,M), ylim=ylim,
              main=main,
              x.axis=F, y.axis=F, xaxs="i", yaxs="i")
    abline(h=0, lty=3)
    at = drange+0.5
    abline(v=at, lwd=2, lty=2)
    axis(side=1, labels=labels, at=1:M, las=2)
    axis(side=2, las=2)

    N = length(anchor.ids)
    colors = if (N <= 3) 1:N+1 else rainbow(N)
    for (i in 1:N) {
        anchor.id = anchor.ids[i]
        x.median = medians[match(anchor.id, medians$cluster),-(1:2)]
        lines(x=coords, y=log10(x.median), lwd=2, col=colors[i])
    }
    if (length(anchor.ids) > 3) {
        group.median = apply(medians[match(anchor.ids, medians$cluster),-(1:2)], 2, median)
        lines(x=coords, y=log10(group.median), lwd=4)
        colors = c(colors, 1)
        names = c(names, "median")
    }

    par(mai=c(0,0,0,0))
    plot.new()
    plot.window(0:1, 0:1)
    legend(x=0.05, y=0.95, fill=colors, legend=names, border=NA, bty="n")
}

plot.genus.response=function(
    ifn.rep, ifn.median,
    ifn.taxa, ifn.taxa.legend, ifn.detection, disturb.ids, labels, fdir)
{
    system(paste("rm -rf", fdir))
    rep.table = load.table(ifn.rep)
    medians = load.table(ifn.median)
    taxa = load.table(ifn.taxa)
    min.score = log10(load.table(ifn.detection)[1,1])
    taxa.legend = load.table(ifn.taxa.legend)

    dindex = which(is.element(colnames(medians[,-(1:2)]), disturb.ids))
    drange = c(min(dindex)-1, max(dindex))

    taxa.legend = taxa.legend[is.element(taxa.legend$anchor.id, medians$cluster),]
    s = split(taxa.legend$anchor.id, taxa.legend$sub.group.id)

    for (i in 1:length(s)) {
        id = names(s)[i]
        anchor.ids = s[[i]]
        name = taxa$name[match(id, taxa$tax_id)]
        level = taxa$level[match(id, taxa$tax_id)]
        fig.start(fdir=fdir, ofn=paste(fdir, "/", name, "_", level, ".pdf", sep=""), type="pdf", width=14, height=3)
        main = paste(name, " ", level, ", n=", length(anchor.ids), sep="")
        plot.anchors(rep.table=rep.table, anchor.ids=anchor.ids, medians=medians, min.score=min.score, main=main, labels=labels, drange=drange)
        fig.end()
    }
}

