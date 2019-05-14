plot.matrix.compare.anchor.details=function(ifn.anchors, ifn.sets, ifn.set.stats, min.element.genes, max.element.sd, ifn.map, min.contacts, legend1, legend2, fdir)
{
    map = load.table(ifn.map)
    atable = load.table(ifn.anchors)
    etable = load.table(ifn.sets)
    etable = etable[etable$type == "element",]

    # fix this
    if (F && file.exists(ifn.set.stats)) {
        etable = etable[etable$gene.count >= min.element.genes,]
        set.stats = load.table(ifn.set.stats)
        etable$sd = set.stats$sd[match(etable$set,set.stats$set)]
        etable = etable[etable$sd <= max.element.sd,]
    }

    if (!is.element("anchor", names(atable))) {
        atable$anchor = atable$set
    }

    element.ids = etable$set
    cat(sprintf("number of elements: %d\n", length(element.ids)))

    system(paste("rm -rf", fdir))

    map$element.id = paste("e", map$element.id, sep="")
    map = map[map$observed1 >= min.contacts | map$observed2 >= min.contacts,]
    map$col = "black"
    map = map[is.element(map$anchor, atable$anchor) & is.element(map$element.id, element.ids),]

    global.lim = range(c(map$score1, map$score2))
    plot.map=function(imap, add.labels=F, main, multi=F) {
        ilim = ifelse(rep(multi,2), global.lim, 1.1*range(c(0, imap$score1, imap$score2)))
        if (ilim[2] < 1) ilim[2] = 1
        plot.init(xlim=ilim, ylim=ilim, xlab=legend1, ylab=legend2, main=main, x.axis=!multi, y.axis=!multi)
        if (multi) {
            axis(1, labels=F)
            axis(2, labels=F)
        }
        abline(a=0, b=1, col=1, lty=3)
        abline(h=0, col=1, lty=3)
        abline(v=0, col=1, lty=3)

        left = ifelse(imap$score1 != 0, imap$score1 - imap$sd.score1, 0)
        right = imap$score1 + imap$sd.score1
        bottom = ifelse(imap$score2 != 0, imap$score2 - imap$sd.score2, 0)
        top = imap$score2 + imap$sd.score2
        segments(x0=imap$score1, x1=imap$score1, y0=bottom, y1=top, col="gray", lwd=2)
        segments(x0=left, x1=right, y0=imap$score2, y1=imap$score2, col="gray", lwd=2)

        points(x=imap$score1, y=imap$score2, col=imap$col, pch=19, cex=0.5)

        if (add.labels && dim(imap)[1] > 0 && is.element("label", colnames(imap)))
            text(x=imap$score1, y=imap$score2, pos=4, labels=imap$label, cex=0.75)
    }

    height = 6
    width = 5

    height.clean = height * 0.75
    width.clean = width * 0.75

    fdir.anchors.clean = paste(fdir, "/anchors/clean", sep="")
    fdir.anchors.labels = paste(fdir, "/anchors/labels", sep="")
    system(sprintf("mkdir -p %s %s", fdir.anchors.clean, fdir.anchors.labels))

    anchors = sort(unique(map$anchor))
    anchor.ids = map$anchor.id[match(anchors,map$anchor)]
    N = length(anchors)
    for (i in 1:N) {
        anchor = anchors[i]
        anchor.id = anchor.ids[i]

        main = anchor.id
        imap = map[map$anchor == anchor,]
        imap$label = imap$element.id

        fig.start(fdir=fdir.anchors.clean, ofn=paste(fdir.anchors.clean, "/", anchor.id, ".pdf", sep=""),
                  type="pdf", height=height.clean, width=width.clean)
        plot.map(imap=imap, add.labels=F, main=main)
        fig.end()

        fig.start(fdir=fdir.anchors.labels, ofn=paste(fdir.anchors.labels, "/", anchor.id, ".pdf", sep=""),
                  type="pdf", height=height, width=width)
        plot.map(imap=imap, add.labels=T, main=main)
        fig.end()
    }

    # one anchor large plot
    Ny = ceiling(sqrt(N))
    Nx = ceiling(N/Ny)
    NN = c(1:N,rep(N+1,Nx*Ny-N))
    fig.start(fdir=fdir, ofn=paste(fdir, "/anchor_summary.pdf", sep=""), type="pdf", height=Ny*1, width=Nx*1)
    layout(matrix(NN, Nx, Ny, byrow=T))
    par(mai=c(0.1, 0.1, 0.25, 0.05))
    for (i in 1:N) {
        anchor = anchors[i]
        anchor.id = anchor.ids[i]
        imap = map[map$anchor == anchor,]
        plot.map(imap=imap, add.labels=F, main=anchor.id, multi=T)
    }
    fig.end()
}
