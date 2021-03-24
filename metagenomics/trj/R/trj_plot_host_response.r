plot.bin.patterns=function(
    ifn.order, ifn.median, ifn.top95, ifn.top75, ifn.bottom25, ifn.bottom05,
    ifn.selected.bins, select.bins,
    ifn.detection, lib.ids, base.ids, disturb.ids, sample.defs.ifn, subject.id, annotate.libs, fdir)
{
    df = load.table(ifn.order)
    all.patterns = load.table(ifn.median)
    all.top95 = load.table(ifn.top95)
    all.top75 = load.table(ifn.top75)
    all.bottom25 = load.table(ifn.bottom25)
    all.bottom05 = load.table(ifn.bottom05)

    # default values
    lib.labels = lib.ids

    if (annotate.libs) {
        sample.defs = load.table(sample.defs.ifn)
        if (!is.element("group", colnames(sample.defs))) {
            if (!all(is.element(lib.ids, sample.defs$lib)))
                stop("missing libs in sample def table")
            df.libs = sample.defs[is.element(sample.defs$lib, lib.ids),]
            df.libs$date = as.Date(df.libs$Samp_Date, "%d-%b-%Y")

            if (any(table(df.libs$Samp_Date) != 1)) {
                ss = split(df.libs, df.libs$Samp_Date)
                new.df.libs = NULL
            for (i in 1:length(ss)) {
                df.lib = ss[[i]]
                df.lib = df.lib[order(df.lib$Samp_Type),]
                df.lib = df.lib[1,]
                new.df.libs = rbind(new.df.libs, df.lib)
            }
                df.libs = new.df.libs
            }
            df.libs = df.libs[order(df.libs$date),]

            lib.ids = df.libs$lib
            lib.labels = paste(df.libs$SampID, df.libs$Samp_Date)
        }
    }

    # order libs by time
    ix = match(lib.ids,colnames(all.patterns))
    all.patterns = all.patterns[,c(1,2,ix)]
    all.top95 = all.top95[,c(1,2,ix)]
    all.top75 = all.top75[,c(1,2,ix)]
    all.bottom25 = all.bottom25[,c(1,2,ix)]
    all.bottom05 = all.bottom05[,c(1,2,ix)]

    min.score = log10(load.table(ifn.detection)[1,1])
    min.drop = -2
    min.drop.abs = -100

    xx = as.matrix(all.patterns[match(df$bin, all.patterns$bin),-(1:2)])
    detected = as.matrix(log10(xx) > min.score)
    if (length(base.ids) > 1) {
        base = rowSums(xx[,base.ids]) / length(base.ids)
    } else {
        base = xx[,base.ids]
    }
    patterns = ifelse(detected, log10(xx / base), min.drop)
    patterns.abs = ifelse(detected, log10(xx), min.drop.abs)
    M = dim(patterns)[2]

    dindex = which(is.element(colnames(patterns), disturb.ids))
    drange = c(min(dindex)-1, max(dindex))

    cc = cor(t(patterns))
    cc[is.na(cc)] = -1
    colnames(cc) = df$bin
    rownames(cc) = df$bin

    hh = hclust(as.dist(1-cc), method="average")
    df = df[hh$order,]
    cc = cc[hh$order,hh$order]
    patterns = patterns[hh$order,]
    base = base[hh$order]


    # limit bins if requested
    if (select.bins) {
        sbins = load.table(ifn.selected.bins)$bin
        ix = is.element(df$bin, sbins)
        df = df[ix,]
        cc = cc[ix,ix]
        patterns = patterns[ix,]
        base = base[ix]
    }

    bins = df$bin
    N = length(bins)

    # compute annotation segments
    ann = NULL
    if (annotate.libs) {
        add.segment=function(ids, label) {
            ix = match(ids, colnames(xx))
            xx = data.frame(label=label, start=min(ix), end=max(ix)+1)
            if (!is.na(xx$start) && !is.na(xx$end)) ann <<- rbind(ann, xx)
        }
        if (is.element("Meas_Type", colnames(sample.defs))) {
            sample.defs = sample.defs[sample.defs$Meas_Type == "MetaG",]
        }
        if (is.element("Abx_Interval", colnames(sample.defs))) {
            ids = sample.defs$lib[sample.defs$Abx_Interval == "MidAbx"]
            add.segment(ids, "abx")
        }
        if (is.element("Diet_Interval", colnames(sample.defs))) {
            ids = sample.defs$lib[sample.defs$Diet_Interval == "MidDiet"]
        add.segment(ids, "diet")
        }
        if (is.element("CC_Interval", colnames(sample.defs))) {
            ix = which(diff(match(sample.defs$CC_Interval,unique(sample.defs$CC_Interval))) == 1)
            ids = sample.defs$lib[c(ix,ix+1)]
            add.segment(ids, "cc")
        }
        if (is.element("group", colnames(sample.defs))) {
            groups = unique(sample.defs$group)
            for (group in groups) {
                add.segment(sample.defs$lib[sample.defs$group==group], group)
            }
        }
    }

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
    wlegend2(fdir=fdir, panel=panel, breaks=breaks, title="bin_matrix")
    sm = matrix2smatrix(cc)
    sm$col = panel[vals.to.cols(sm$value, breaks)]

    fig.start(fdir=fdir, ofn=paste(fdir, "/bin_matrix.pdf", sep=""), type="pdf", height=8, width=8)
    plot.new()
    plot.window(xlim=c(0,N), ylim=c(0,N))
    rect(sm$i-1, sm$j-1, sm$i, sm$j, col=sm$col, border=sm$col)
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/bin_matrix_text.pdf", sep=""), type="pdf", height=16, width=16)
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

    # due to base
    xoffset = 3

    base.colors = c("blue", "red", "orange")
    base.breaks = c(-1, 0, 1)
    base.panel = make.color.panel(colors=base.colors)
    wlegend2(fdir=fdir, panel=base.panel, breaks=base.breaks, title="base_bin")

    colors = c("darkblue", "blue", "white", "red")
    breaks = c(-2, -1, 0, 1)
    panel = make.color.panel(colors=colors)
    wlegend2(fdir=fdir, panel=panel, breaks=breaks, title="bin_trend")

    # abs.colors = c("white", "darkblue", "orange")
    # abs.breaks = c(-2, 0, 1)
    abs.colors = c("black", "blue", "white", "red", "orange")
    abs.breaks = c(-2, -1, 0, 1, 2)
    abs.panel = make.color.panel(colors=abs.colors)
    wlegend2(fdir=fdir, panel=abs.panel, breaks=abs.breaks, title="bin_trend_abs")

    # y-gap between bins
    gap = 0
    plot.mat=function(mat, is.relative) {

        sm = matrix2smatrix(mat)

        if (is.relative) {
            sm$col = ifelse(sm$value != min.drop, panel[vals.to.cols(sm$value, breaks)], "black")
        } else {
            sm$col = ifelse(sm$value != min.drop, abs.panel[vals.to.cols(sm$value, abs.breaks)], "black")
        }

        ww = 1+0.3*M
        hh = 1+N*0.2
        # !!!
        if (select.bins) {
            ww = 2
            hh = 12.5
        }

        rel.str = ifelse(is.relative, "relative", "absolute")
        fig.start(fdir=fdir, type="pdf", ofn=paste(fdir, "/bin_trend_", rel.str, ".pdf", sep=""), height=hh, width=ww)
        par(mai=c(2, 0.5, 0.5, 0.5))
        plot.new()
        plot.window(xlim=c(0,M+16), ylim=c(1,N))
        title(main=paste(subject.id, length(bins)))
        rect(sm$j-1+xoffset, sm$i-1+gap, sm$j+xoffset, sm$i-gap, col=sm$col, border=NA)

        if (select.bins) {
            segments(x0=1, x1=3, y0=1:N-0.5, y1=1:N-0.5)
            text(x=4, y=1:N-0.5, pos=2, labels=rev(seq_along(bins)), cex=0.5, xpd=T)

        } else {


            if (is.relative) {
                rect(xleft=1.5, xright=2.5, ybottom=1:N-1, ytop=1:N, col=base.panel[vals.to.cols(log10(base), base.breaks)], border=NA)
                axis(side=1, labels="base", at=2, las=2)
            }

            text(x=M+4, y=1:N-0.5, adj=0, labels=bins, cex=0.5)
            axis(side=1, labels="bin", at=M+4.5, las=2)
        }

        # plot annotations
        if (!is.null(ann)) {
            rect(ann$start-1+xoffset, -1, ann$end-1+xoffset, -0.5, col="darkgreen", border=NA)
            text(x=(ann$start+ann$end-2)/2+xoffset, y=-0.5, labels=ann$label, pos=1)
            abline(v=ann$start-1+xoffset, lty=2, col="darkgreen")
            abline(v=ann$end-1+xoffset, lty=2, col="darkgreen")
        }

        axis(side=1, labels=lib.labels, at=1:M-0.5+3, las=2)
        fig.end()
    }

    plot.mat(patterns, is.relative=T)
    plot.mat(patterns.abs, is.relative=F)

    ################################################################
    # plot detailed line plots
    ################################################################

    ylim = c(min.score, 1.5)
    plot.bin=function(i, multi=F) {
        bin = bins[i]
        bin = df$bin[match(bin, df$bin)]
        x.median = all.patterns[match(bin, all.patterns$bin),-(1:2)]
        x.top95 = all.top95[match(bin, all.top95$bin),-(1:2)]
        x.top75 = all.top75[match(bin, all.top75$bin),-(1:2)]
        x.bottom25 = all.bottom25[match(bin, all.bottom25$bin),-(1:2)]
        x.bottom05 = all.bottom05[match(bin, all.bottom05$bin),-(1:2)]

        high.5 = log10(x.top95)
        low.5 = log10(x.bottom05)
        high.25 = log10(x.top75)
        low.25 = log10(x.bottom25)

        main = bin
        x = 1:M
        plot.init(xlim=c(1,M), ylim=ylim,
                  main=main,
                  x.axis=F, y.axis=F, xaxs="i", yaxs="i")

        if (!multi)
            axis(side=2, las=2)

        abline(h=0, lty=3)

        color.5 = colors()[121]
        color.25 = colors()[563]
        polygon(x=c(x,rev(x)), y=c(high.5, rev(low.5)), col=color.5, border=NA)
        polygon(x=c(x,rev(x)), y=c(high.25, rev(low.25)), col=color.25, border=NA)
        lines(x=x, y=log10(x.median), lwd=2)
        at = drange+0.5
        abline(v=at, lwd=2, lty=2)
        if (!multi) {
            segments(x0=x, y0=t(low.5), x1=x, y1=t(high.5))
            axis(side=1, labels=lib.labels, at=1:M, las=2, cex.axis=0.5)
        }
    }

    Ny = ceiling(sqrt(N))
    Nx = ceiling(N/Ny)
    NN = c(1:N,rep(N+1,Nx*Ny-N))

    # all together
    fig.start(fdir=fdir, ofn=paste(fdir, "/bin_summary.pdf", sep=""), type="pdf", width=10, height=10)
    layout(matrix(NN, Nx, Ny, byrow=T))
    par(mai=c(0.05, 0.1, 0.2, 0.1))
    for (i in N:1)
        plot.bin(i, multi=T)
    fig.end()

    ffdir = paste(fdir, "/bins", sep="")
    for (i in 1:N) {
        bin = df$bin[i]
        fig.start(fdir=ffdir, ofn=paste(ffdir, "/", bin, ".pdf", sep=""), type="pdf", width=8, height=3)
        plot.bin(i, multi=F)
        fig.end()
    }
}
