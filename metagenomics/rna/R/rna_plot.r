plot.mat=function(ifn.bins, ifn.genes, ifn.libs, ifn.libdef, set1, set2, idir, fdir)
{
    genes = load.table(ifn.genes)
    bins = load.table(ifn.bins)
    libs = load.table(ifn.libs)
    libdef = load.table(ifn.libdef)

    # pre/post
    ids1 = libs$Meas_ID[match(libdef$sample[libdef$group == set1], libs$Samp_ID)]
    ids2 = libs$Meas_ID[match(libdef$sample[libdef$group == set2], libs$Samp_ID)]

    # abx
    abx.ids = libs$Meas_ID[libs$Abx_Interval == "MidAbx"]

    bins = bins[bins$class == "host",]

    rank.norm=function(mm) {
        result = NULL
        for (i in 1:dim(mm)[2]) {
            rr = rank(mm[,i], ties.method="min")
            result = cbind(result, rr/max(rr))
        }
        colnames(result) = colnames(mm)
        result
    }

    for (bin in bins$bin) {
        df = load.table(paste(idir, "/", bin, sep=""))
        ll = genes$length[match(df$gene,genes$gene)]
        mm.raw = as.matrix(df[,-1])
        mm.rpk = 1000 * as.matrix(df[,-1]) / ll
        mm.rank = rank.norm(mm.rpk)
        mm.max = apply(mm.raw, 1, max)

        ii = mm.max>=10
        mm.rank = mm.rank[ii,]
        mm.raw = mm.raw[ii,]
        mm.rpk = mm.rpk[ii,]

        xvalues1 = which(is.element(colnames(mm.raw), ids1))
        xvalues2 = which(is.element(colnames(mm.raw), ids2))
        abx.xvalues = which(is.element(colnames(mm.raw), abx.ids))

        # cc = cor(t(mm.rank[,c(xvalues1, xvalues2)]))
        # cc[is.na(cc)] = -1
        # hh = hclust(as.dist(1-cc), method="average")
        # oo = hh$order
        oo = order(rowSums(mm.rpk))
        plot.mm=function(mm, colors, breaks, fdir) {
            Ny = dim(mm)[1]
            Nx = dim(mm)[2]
            width = 1 +  Nx*0.05
            height = 1 + Ny*0.003
            xlim = c(0, Nx)
            ylim = c(0, Ny)

            mm.order = mm[oo,]
            sm = matrix2smatrix(mm.order)

            panel = make.color.panel(colors)
            sm$col = panel[vals.to.cols(sm$value, breaks=breaks)]

            fig.start(fdir=fdir, ofn=paste(fdir, "/", bin, ".pdf", sep=""), type="pdf", width=width, height=height)
            plot.init(xlim=xlim, ylim=ylim, xlab="", ylab="", add.box=F, x.axis=F, y.axis=F, add.grid=F)
            rect(xleft=sm$j-1, xright=sm$j, ybottom=sm$i-1, ytop=sm$i, col=sm$col, border=NA)
            abline(v=c(min(abx.xvalues-1), max(abx.xvalues)))
            abline(v=c(min(xvalues1-1), max(xvalues1)))
            abline(v=c(min(xvalues2-1), max(xvalues2)))
            fig.end()
        }

        colors.rank = c("white", "blue", "red", "orange")
        breaks.rank = c(0, 0.9, 0.99, 1)
        plot.mm(mm=mm.rank, colors=colors.rank, breaks=breaks.rank, fdir=paste(fdir, "/rank", sep=""))

        colors.raw = c("white", "blue", "red", "orange")
        breaks.raw = c(0, 1, 10, 1000)
        plot.mm(mm=mm.raw, colors=colors.raw, breaks=breaks.raw, fdir=paste(fdir, "/raw", sep=""))

    }
}
