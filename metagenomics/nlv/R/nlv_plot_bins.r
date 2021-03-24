plot.mat.nlv=function(mat, panel, breaks, title, no.data.value=-1, no.data.color="gray", vlines=NULL, lty, lwd=1)
{
    N = dim(mat)[2]
    M = dim(mat)[1]

    sm = matrix2smatrix(mat)
    sm$col = ifelse(sm$value != no.data.value, panel[vals.to.cols(sm$value, breaks)], no.data.color)

    plot.new()
    plot.window(xlim=c(0,N), ylim=c(0,M))
    title(main=title)
    box()
    rect(sm$j-1, sm$i-1, sm$j, sm$i, col=sm$col, border=NA)
    abline(v=vlines, lty=lty, lwd=lwd)
}

order.mm=function(mm)
{
    if (dim(mm)[1] > 10000) print("computing correlations")
    cc = cor(t(mm))
    cc[is.na(cc)] = -1
    if (dim(mm)[1] > 10000) print("clustering")
    hh = hclust(as.dist(1-cc), method="average")
    hh$order
}

plot.combo=function(ifn.libs, ifn.bins, ifn.sets, ifn.set.pairs, ifn.dist.mat, ifn.count.mat, ifn.total.mat, fdir)
{

    # !! get actual disturbance
    vlines = c(5,10)
    lty = 2

    df.libs = load.table(ifn.libs)
    df.bins = load.table(ifn.bins)
    df.all = load.table(ifn.sets)

    # df.div = load.table(ifn.set.pairs)
    df.div = load.table(ifn.dist.mat)
    df.div$log.distance = -log10(pmax(10^-7,df.div$distance))
    mat.count.all = load.table(ifn.count.mat)
    mat.total.all = load.table(ifn.total.mat)

    # make symmetric
    df.div.sym = df.div
    df.div.sym$set1 = df.div$set2
    df.div.sym$set2 = df.div$set1
    df.div = rbind(df.div, df.div.sym)

    set.ind = sort(unique(df.libs$set.index))
    sets = df.libs$set[match(set.ind,df.libs$set.index)]

    bins = df.bins$bin[df.bins$class == "host"]

    N = length(sets)

    # when it was divergent
    ## colors = c("white", "gray", "blue", "red", "orange")
    ## breaks = c(0, 1, 10, 100, 10000)
    ## panel = make.color.panel(colors=colors)
    ## wlegend2(fdir=fdir, panel=panel, breaks=breaks, title="divergence")
    ## df.div$col = panel[vals.to.cols(df.div$site.count, breaks)]

    # weighted distance
    panel = make.color.panel(colors=c("black", "orange", "red", "darkblue"))
    breaks = c(2, 3, 4, 6)
    wlegend2(fdir=fdir, panel=panel, breaks=breaks, title="w-distance")
    df.div$col = panel[vals.to.cols(df.div$log.distance, breaks)]

    box.width = 0.2

    count.colors = c("white", "gray", "darkblue", "red", "orange")
    count.breaks = c(0, 1, 10, 100, 1000)
    count.panel = make.color.panel(colors=count.colors)
    wlegend2(fdir=fdir, panel=count.panel, breaks=count.breaks, title="count")

    freq.colors = c("black", "blue", "red", "white")
    freq.breaks = c(0, 0.2, 0.8, 1)
    freq.panel = make.color.panel(colors=freq.colors)
    wlegend2(fdir=fdir, panel=freq.panel, breaks=freq.breaks, title="freq")

    for (bin in bins) {
        # segregation and coverage
        df = df.all[df.all$bin == bin,]
        df$index = match(df$set, sets)

        # divergence
        div = df.div[df.div$bin == bin,]
        div$x = match(div$set1, sets)
        div$y = match(div$set2, sets)

        # !!! skip if low coverage
#        if (median(df$cov_p50) < 10)
#            next

        df$seg = log10(pmax(10^-6, df$site.density))
        # ylim.seg = range(df$seg)
        ylim.seg = c(-6, max(df$seg) + 0.1)

        cov.max = 1.1 * max(df$cov_p95)

        # nlv
        plot.mats = sum(mat.count.all$bin == bin) > 0 && sum(mat.count.all$bin == bin) < 5000
        if (plot.mats) {
            mm.count = as.matrix(mat.count.all[mat.count.all$bin == bin,sets])
            mm.total = as.matrix(mat.total.all[mat.total.all$bin == bin,sets])
            mm = mm.count / (mm.total+1)
            if (dim(mm)[1] > 2) {
                oo = order.mm(mm)
                mm.count = mm.count[oo,]
                mm.total = mm.total[oo,]
                mm = mm[oo,]
            }
        }

        fig.start(fdir=fdir, ofn=paste(fdir, "/", bin, ".pdf", sep=""), type="pdf", height=2+0.2*N+2, width=2+0.1*N)
        par(mai=c(0.2, 0.6, 0.2, 0.2))
        layout(matrix(1:5, 5, 1), heights=c(4,2,2,1,1))

        ########################################################################
        # plot divergence matrix
        ########################################################################

        plot.new()
        plot.window(xlim=c(0,N), ylim=c(0,N))
        rect(div$x-1, div$y-1, div$x, div$y, col=div$col, border=div$col)
        rect(1:N-1, 1:N-1, 1:N, 1:N, col="darkblue", border="darkblue")
        title(main="")
        abline(v=vlines, lty=1, lwd=2)
        abline(h=vlines, lty=1, lwd=2)
        box()

        par(mai=c(0.1, 0.6, 0.1, 0.2))

        ########################################################################
        # plot nlv mats
        ########################################################################

        if (plot.mats) {
            plot.mat.nlv(mat=mm, panel=freq.panel, breaks=freq.breaks, title="allele frequency", vlines=vlines, lty=1, lwd=3)
            # plot.mat.nlv(mat=mm.count, panel=count.panel, breaks=count.breaks, title="raw counts", vlines=vlines, lty=1, lwd=3)
            plot.mat.nlv(mat=mm.total, panel=count.panel, breaks=count.breaks, title="raw total coverage", vlines=vlines, lty=1, lwd=3)
        } else {
            plot.empty(paste("N=", sum(mat.count.all$bin == bin), sep=""))
            plot.empty("NA")
            # plot.empty("NA")
        }

        ########################################################################
        # plot segregation density
        ########################################################################

        plot.init(xlim=c(0,N), ylim=ylim.seg, ylab="snps/bp\n(log10)", axis.las=2, x.axis=F)
        abline(v=vlines, lty=lty)
        points(x=df$index-0.5, y=df$seg, pch=19, cex=1)

        ########################################################################
        # plot coverage boxplots
        ########################################################################

        plot.new()
        plot.window(xlim=c(0,N), ylim=c(0,cov.max))
        abline(v=vlines, lty=lty)
        box()
        grid()
        axis(2, las=2)
        title(ylab="x-coverage")
        segments(x0=df$index-0.5, x1=df$index-0.5, y0=df$cov_p5, y1=df$cov_p95, col=1)
        rect(df$index-0.5-box.width, df$cov_p25, df$index-0.5+box.width, df$cov_p75, col="gray")
        segments(x0=df$index-0.5-box.width, x1=df$index-0.5+box.width, y0=df$cov_p50, y1=df$cov_p50, col=1, lwd=2)

        fig.end()
    }
}

plot.mat=function(ifn.libs, ifn.bins, ifn.count.mat, ifn.total.mat, fdir)
{
    df.libs = load.table(ifn.libs)
    df.bins = load.table(ifn.bins)
    mat.count.all = load.table(ifn.count.mat)
    mat.total.all = load.table(ifn.total.mat)

    # !!!
    vlines = c(5,10)
    lty = 1
    lwd = 3

    set.ind = sort(unique(df.libs$set.index))
    sets = df.libs$set[match(set.ind,df.libs$set.index)]
    bins = df.bins$bin[df.bins$class == "host"]

    N = length(sets)

    count.colors = c("white", "gray", "darkblue", "red", "orange")
    count.breaks = c(0, 1, 10, 100, 1000)
    count.panel = make.color.panel(colors=count.colors)
    wlegend2(fdir=fdir, panel=count.panel, breaks=count.breaks, title="count")

    freq.colors = c("black", "blue", "red", "white")
    freq.breaks = c(0, 0.2, 0.8, 1)
    freq.panel = make.color.panel(colors=freq.colors)
    wlegend2(fdir=fdir, panel=freq.panel, breaks=freq.breaks, title="freq")

    for (bin in bins) {
        if (!any(mat.count.all$bin == bin) || sum(mat.count.all$bin == bin) > 5000)
            next
        mm.count = as.matrix(mat.count.all[mat.count.all$bin == bin,sets])
        mm.total = as.matrix(mat.total.all[mat.total.all$bin == bin,sets])
        mm = mm.count / (mm.total+1)
        if (dim(mm)[1] > 2) {
            oo = order.mm(mm)
            mm.count = mm.count[oo,]
            mm.total = mm.total[oo,]
            mm = mm[oo,]
        }

        fig.start(fdir=fdir, ofn=paste(fdir, "/", bin, ".pdf", sep=""), type="pdf", height=8, width=2+0.2*N)
        par(mai=c(0.2, 0.5, 0.2, 3))
        layout(matrix(1:3, 3, 1))
        plot.mat.nlv(mat=mm.count, panel=count.panel, breaks=count.breaks, title="count", vlines=vlines, lty=lty ,lwd=lwd)
        plot.mat.nlv(mat=mm.total, panel=count.panel, breaks=count.breaks, title="total", vlines=vlines, lty=lty ,lwd=lwd)
        plot.mat.nlv(mat=mm, panel=freq.panel, breaks=freq.breaks, title="freq", vlines=vlines, lty=lty ,lwd=lwd)
        fig.end()
    }
}
