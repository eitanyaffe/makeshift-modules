plot.host.response=function(
    ifn.order,
    ifn.median, ifn.top95, ifn.top75, ifn.bottom25, ifn.bottom05,
    ifn.taxa, ifn.taxa.legend, ifn.detection, labels, base.ids, disturb.ids, fdir)
{
    anchor.table = load.table(ifn.order)
    all.patterns = load.table(ifn.median)
    all.top95 = load.table(ifn.top95)
    all.top75 = load.table(ifn.top75)
    all.bottom25 = load.table(ifn.bottom25)
    all.bottom05 = load.table(ifn.bottom05)

    anchor.table = anchor.table[is.element(anchor.table$id,all.patterns$cluster),]
    anchor.ids = anchor.table$id

    min.score = log10(load.table(ifn.detection)[1,1])
    min.drop = -2

    xx = as.matrix(all.patterns[match(anchor.ids, all.patterns$cluster),-(1:2)])
    detected = as.matrix(log10(xx) > min.score)
    base = rowSums(xx[,base.ids]) / length(base.ids)
    patterns = ifelse(detected, log10(xx / base), min.drop)
    M = dim(patterns)[2]

    dindex = which(is.element(colnames(patterns), disturb.ids))
    drange = c(min(dindex)-1, max(dindex))

    cc = cor(t(patterns))
    cc[is.na(cc)] = -1
    colnames(cc) = anchor.ids
    rownames(cc) = anchor.ids

    hh = hclust(as.dist(1-cc), method="average")
    cc = cc[hh$order,hh$order]
    patterns = patterns[hh$order,]
    base = base[hh$order]

    aai.anchor.ids = anchor.ids
    cr.anchor.ids = anchor.ids[hh$order]
    cr.anchors = anchor.table$set[match(cr.anchor.ids,anchor.table$id)]

    N = length(cr.anchor.ids)

    taxa.legend = load.table(ifn.taxa.legend)
    taxa.legend = taxa.legend[match(cr.anchors, taxa.legend$anchor),]
    taxa.legend$text = taxa.legend$letter

    taxa = load.table(ifn.taxa)
    taxa = taxa[match(cr.anchors, taxa$anchor),]

    ################################################################
    # plot clustering dendrogram
    ################################################################

    fig.start(fdir=fdir, ofn=paste(fdir, "/dendrogram.pdf", sep=""), type="pdf", height=4, width=1+M*0.75)
    plot(hh, hang=-1, ylab="1-r")
    fig.end()

    ################################################################
    # plot correlation matrix
    ################################################################

    colors = c("blue", "white", "red")
    breaks = c(-1, 0, 1)
    panel = make.color.panel(colors=colors)
    wlegend2(fdir=fdir, panel=panel, breaks=breaks, title="anchor_matrix")
    sm = matrix2smatrix(cc)
    sm$col = panel[vals.to.cols(sm$value, breaks)]

    fig.start(fdir=fdir, ofn=paste(fdir, "/anchor_matrix.pdf", sep=""), type="pdf", height=8, width=8)
    plot.new()
    plot.window(xlim=c(0,N), ylim=c(0,N))
    rect(sm$i-1, sm$j-1, sm$i, sm$j, col=sm$col, border=sm$col)
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/anchor_matrix_text.pdf", sep=""), type="pdf", height=16, width=16)
    plot.new()
    plot.window(xlim=c(0,N), ylim=c(0,N))
    rect(sm$i-1, sm$j-1, sm$i, sm$j, col=sm$col, border=sm$col)
    text(sm$i-0.5, sm$j-0.5, round(sm$value,2), cex=0.5)
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/pairwise_host_pearson_analysis.pdf", sep=""), type="pdf", height=6, width=6)
    smx = sm[sm$i != sm$j,]
    s = sapply(split(smx$value, smx$i), max)
    plot(ecdf(s), xlab="pearson", main="closest host (max pearson)")
    grid()
    fig.end()

    ################################################################
    # plot colored summary
    ################################################################

    major.colors = c("white", "darkgray")
    major.breaks = c(0, 1)
    major.panel = make.color.panel(colors=major.colors)
    wlegend2(fdir=fdir, panel=major.panel, breaks=major.breaks, title="major_anchor")

    base.colors = c("blue", "red", "orange")
    base.breaks = c(-1, 0, 1)
    base.panel = make.color.panel(colors=base.colors)
    wlegend2(fdir=fdir, panel=base.panel, breaks=base.breaks, title="base_anchor")

    colors = c("darkblue", "blue", "white", "red")
    breaks = c(-2, -1, 0, 1)
    panel = make.color.panel(colors=colors)
    wlegend2(fdir=fdir, panel=panel, breaks=breaks, title="anchor_trend")

    sm = matrix2smatrix(patterns)
    sm$col = ifelse(sm$value != min.drop, panel[vals.to.cols(sm$value, breaks)], "black")

    fig.start(fdir=fdir, type="pdf", ofn=paste(fdir, "/anchor_trend.pdf", sep=""), height=1+N*0.2, width=5+0.25*M)
    par(mai=c(2, 1, 1, 4))
    plot.new()
    plot.window(xlim=c(0,M+7), ylim=c(1,N))

    rect(sm$j-1+3, sm$i-1, sm$j+3, sm$i, col=sm$col, border=NA)
    rect(xleft=1.5, xright=2.5, ybottom=1:N-1, ytop=1:N, col=base.panel[vals.to.cols(log10(base), base.breaks)], border=NA)
    axis(side=1, labels="base", at=2, las=2)

    rect(xleft=M+3.5, xright=M+5.5, ybottom=1:N-1, ytop=1:N, border=NA, col=taxa.legend$color)
    text(x=M+4.5, y=1:N-0.5, labels=taxa.legend$text)
    axis(side=1, labels="taxa", at=M+4.5, las=2)

    text(x=M+5.7, y=1:N-0.5, adj=0, labels=cr.anchor.ids)
    axis(side=1, labels="anchor", at=M+6.5, las=2)

    abline(v=drange+3, lwd=2)
    axis(side=1, labels=labels, at=1:M-0.5+3, las=2)
    axis(side=4, labels=taxa$name, at=1:N-0.5, las=2)
    fig.end()

    ################################################################
    # plot detailed line plots
    ################################################################

    ylim = c(min.score, 1.5)
    plot.anchor=function(i, multi=F, sorted=F) {
        if (sorted)
            anchor.id = aai.anchor.ids[i]
        else
            anchor.id = cr.anchor.ids[i]
        cluster = anchor.id
        x.median = all.patterns[match(cluster, all.patterns$cluster),-(1:2)]
        x.top95 = all.top95[match(cluster, all.top95$cluster),-(1:2)]
        x.top75 = all.top75[match(cluster, all.top75$cluster),-(1:2)]
        x.bottom25 = all.bottom25[match(cluster, all.bottom25$cluster),-(1:2)]
        x.bottom05 = all.bottom05[match(cluster, all.bottom05$cluster),-(1:2)]

        high.5 = log10(x.top95)
        low.5 = log10(x.bottom05)
        high.25 = log10(x.top75)
        low.25 = log10(x.bottom25)

        main = anchor.id
        x = 1:M
        plot.init(xlim=c(1,M), ylim=ylim,
                  main=main,
                  x.axis=F, y.axis=F, xaxs="i", yaxs="i", add.grid=F)

        if (!multi)
            axis(side=2, las=2)

        abline(h=0, lty=3)

        color.5 = colors()[431]
        color.25 = colors()[563]
        polygon(x=c(x,rev(x)), y=c(high.5, rev(low.5)), col=color.5, border=NA)
        polygon(x=c(x,rev(x)), y=c(high.25, rev(low.25)), col=color.25, border=NA)
        grid()
        lines(x=x, y=log10(x.median), lwd=1)
        at = drange+0.5
        abline(v=at, lwd=2, lty=2)
        if (!multi) {
            segments(x0=x, y0=t(low.5), x1=x, y1=t(high.5))
            axis(side=1, labels=labels, at=1:M, las=2)
        }
    }

    Ny = ceiling(sqrt(N))
    Nx = ceiling(N/Ny)
    NN = c(1:N,rep(N+1,Nx*Ny-N))

    # all together
    fig.start(fdir=fdir, ofn=paste(fdir, "/anchor_summary.pdf", sep=""), type="pdf", width=10, height=10)
    layout(matrix(NN, Nx, Ny, byrow=T))
    par(mai=c(0.05, 0.1, 0.2, 0.1))
    for (i in N:1)
        plot.anchor(i, multi=T, sorted=F)
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/anchor_summary_sorted.pdf", sep=""), type="pdf", width=10, height=10)
    layout(matrix(NN, Nx, Ny, byrow=T))
    par(mai=c(0.05, 0.1, 0.2, 0.1))
    for (i in 1:N)
        plot.anchor(i, multi=T, sorted=T)
    fig.end()

    ffdir = paste(fdir, "/anchors", sep="")
    for (i in 1:N) {
        anchor.id = cr.anchor.ids[i]
        fig.start(fdir=ffdir, ofn=paste(ffdir, "/", anchor.id, ".pdf", sep=""), type="pdf", width=6, height=3)
        plot.anchor(i, multi=F, sorted=F)
        fig.end()
    }
}
