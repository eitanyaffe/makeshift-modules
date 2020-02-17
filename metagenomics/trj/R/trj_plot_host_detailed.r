plot.bin.details=function(
    ifn.order, ifn.median, ifn.sample.defs, ifn.c2b,
    ifn.detection, lib.ids, base.ids, disturb.ids, subject.id, annotate.libs, fdir)
{
    df = load.table(ifn.order)
    all.patterns = load.table(ifn.median)
    c2b = load.table(ifn.c2b)

    # default values
    lib.labels = lib.ids

    if (annotate.libs) {
        sample.defs = load.table(ifn.sample.defs)

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
    all.patterns = all.patterns[,c(1,ix)]

    min.score = log10(load.table(ifn.detection)[1,1])
    min.drop = -2
    min.drop.abs = -100

    bins = df$bin

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


    # compute annotation segments
    ann = NULL
    if (annotate.libs) {
        add.segment=function(ids, label) {
            ix = match(ids, colnames(all.patterns))
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
            if (any(!is.na(sample.defs$CC_Interval))) {
                ix = which(diff(match(sample.defs$CC_Interval,unique(sample.defs$CC_Interval))) == 1)
                ids = sample.defs$lib[c(ix,ix+1)]
                add.segment(ids, "cc")
            }
        }
        if (is.element("group", colnames(sample.defs))) {
            groups = unique(sample.defs$group)
            for (group in groups) {
                add.segment(sample.defs$lib[sample.defs$group==group], group)
            }
        }
    }

    # due to base
    xoffset = 3

    plot.mat=function(bin, is.relative) {
        contigs = c2b$contig[c2b$bin == bin]
        if (!all(is.element(contigs, all.patterns$contig))) {
            stop(sprintf("missing contig %s of bin %d in contig response matrix", setdiff(contigs, all.patterns$contig)[1], bin))
        }
        xx = as.matrix(all.patterns[is.element(all.patterns$contig, contigs),-1])
        detected = as.matrix(log10(xx) > min.score)
        if (length(base.ids) > 1) {
            base = rowSums(xx[,base.ids]) / length(base.ids)
        } else {
            base = xx[,base.ids]
        }
        patterns = ifelse(detected, log10(xx / base), min.drop)
        patterns.abs = ifelse(detected, log10(xx), min.drop.abs)
        M = dim(patterns)[2]

        cc = cor(t(patterns))
        cc[is.na(cc)] = -1
        colnames(cc) = contigs
        rownames(cc) = contigs

        hh = hclust(as.dist(1-cc), method="average")
        df = df[hh$order,]
        cc = cc[hh$order,hh$order]
        patterns = patterns[hh$order,]
        base = base[hh$order]

        mat = if (is.relative) patterns else patterns.abs

        N = length(contigs)

        sm = matrix2smatrix(mat)

        if (is.relative) {
            sm$col = ifelse(sm$value != min.drop, panel[vals.to.cols(sm$value, breaks)], "black")
        } else {
            sm$col = ifelse(sm$value != min.drop, abs.panel[vals.to.cols(sm$value, abs.breaks)], "black")
        }

        rel.str = ifelse(is.relative, "relative", "absolute")
        fig.start(fdir=fdir, type="pdf", ofn=paste(fdir, "/", bin, "_", rel.str, ".pdf", sep=""), height=2+N*0.2, width=2+0.4*M)
        par(mai=c(2, 1, 1, 3))
        plot.new()
        plot.window(xlim=c(0,M+16), ylim=c(1,N))
        title(main=paste(subject.id, bin))
        rect(sm$j-1+xoffset, sm$i-1, sm$j+xoffset, sm$i, col=sm$col, border=NA)

        if (is.relative) {
            rect(xleft=1.5, xright=2.5, ybottom=1:N-1, ytop=1:N, col=base.panel[vals.to.cols(log10(base), base.breaks)], border=NA)
            axis(side=1, labels="base", at=2, las=2)
        }

        text(x=M+4, y=1:N-0.5, adj=0, labels=contigs, cex=0.8)
        axis(side=1, labels="contig", at=M+4.5, las=2)

        # plot annotations
        if (!is.null(ann)) {
            rect(ann$start-1+xoffset, -1, ann$end-1+xoffset, -0.5, col="darkgreen", border=NA)
            text(x=(ann$start+ann$end-2)/2+xoffset, y=-0.5, labels=ann$label, pos=1)
            abline(v=ann$start-1+xoffset, lwd=1)
            abline(v=ann$end-1+xoffset, lwd=2)
        }

        axis(side=1, labels=lib.labels, at=1:M-0.5+3, las=2)
        fig.end()
    }
    for (bin in bins) {
        plot.mat(bin, is.relative=T)
        plot.mat(bin, is.relative=F)
    }
}
