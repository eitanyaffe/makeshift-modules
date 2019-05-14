plot.element.summary=function(ifn.reps, ifn.anchors, ifn.element2anchor, ifn.obs, ifn.exp, ifn.detection, labels, fdir)
{
    rep.table = load.table(ifn.reps)
    anchor.table = load.table(ifn.anchors)
    obs = load.table(ifn.obs)
    exp = load.table(ifn.exp)
    min.score = log10(load.table(ifn.detection)[1,1])

    element2anchor = load.table(ifn.element2anchor)
    fc = field.count(element2anchor, "element.id")
    selected = fc$element.id[fc$count > 1]
    element2anchor = element2anchor[is.element(element2anchor$element.id, obs$cluster) & is.element(element2anchor$element.id,selected),]
    elements = element2anchor$element.id

    cat(sprintf("number of elements: %d\n", length(elements)))
    result = NULL
    for (element in elements) {
        anchors = element2anchor$anchor[element2anchor$element.id == element]
        ids = anchor.table$id[match(anchors,anchor.table$set)]

        anchor.obs = obs[match(ids, obs$cluster), -1]
        anchor.exp = exp[match(ids, exp$cluster), -1]
        anchor.norm = log10(anchor.obs/anchor.exp)
        anchor.norm[anchor.norm<min.score] = min.score
        anchor.norm.sum = log10(colSums(ifelse(anchor.norm>min.score,10^anchor.norm,0)))
        anchor.norm.sum[anchor.norm.sum<min.score] = min.score

        element.obs = unlist(obs[element == obs$cluster, -1])
        element.exp = unlist(exp[element == exp$cluster, -1])
        element.norm = log10(element.obs/element.exp)
        element.norm[element.norm<min.score] = min.score

        delta = element.norm - anchor.norm.sum
        delta = delta - delta[1]
        delta = log2(10^delta)
        result = rbind(result, delta)
    }

    mm = sapply(as.data.frame(result), mean)
    sd = sapply(as.data.frame(result), sd)
    top = mm + sd
    bottom = mm - sd
    middle = mm

    N = length(labels)
    ylim = range(c(top, bottom))
    coord = 1:N-0.5
    width = 0.5
    xleft = coord-width/2
    xright = coord+width/2
    fig.start(fdir=fdir, ofn=paste(fdir, "/element_trend.pdf", sep=""), type="pdf", height=4, width=4)
    plot.init(xlim=c(0,N), ylim=ylim, x.axis=F, y.axis=F)
    grid()

    segments(x0=xleft, x1=xright, y0=top, y1=top, col=1, lwd=1)
    segments(x0=xleft, x1=xright, y0=bottom, y1=bottom, col=1, lwd=1)
    segments(x0=coord, x1=coord, y0=bottom, y1=top, col=1, lwd=1)
    points(x=coord, y=middle, pch=15, col=1, cex=1)
    axis(2, las=2)
    axis(side=1, labels=labels, at=1:N, las=2)
    fig.end()
}

