plot.strain.tsne=function(ifn.bins, ifn.sites, bin.template, ifn.class.template, fdir)
{
    df.bins = load.table(ifn.bins)
    df.sites = load.table(ifn.sites)

    for (i in 1:dim(df.bins)[1]) {
        bin = df.bins$bin[i]
        main = sprintf("bin=%d nsites=%d perplexity=%d", bin, df.bins$nsites[i], df.bins$perplexity[i])

        ifn = gsub(bin.template, bin, ifn.class.template)
        if (!file.exists(ifn))
            next
        df.class = load.table(ifn)
        rr = df.sites[df.sites$bin == bin,]

        df.class$key = paste(df.class$index, df.class$contig, df.class$coord)
        rr$key = paste(rr$index, rr$contig, rr$coord)
        ix = match(rr$key, df.class$key)
        rr$label = ifelse(!is.na(ix), df.class$short.label[ix], "none")

        rr = rr[rr$label != "",]
        classes = sort(unique(rr$label))
        cols = rainbow(length(classes))
        rr$col = cols[match(rr$label, classes)]

        xlim = range(rr$x)*1.2
        ylim = range(rr$y)*1.2

        fig.start(fdir=fdir, ofn=paste(fdir, "/", bin, ".pdf", sep=""), type="pdf", height=4, width=4)
        par(mai=c(0.2, 0.2, 0.2, 0.2))
        plot.init(xlim=xlim, ylim=ylim, log="", main="", xlab="", ylab="", add.box=F, x.axis=F, y.axis=F, add.grid=F)
        points(rr$x, rr$y, pch=21, cex=0.5, col=rr$col, bg=rr$col)

        ## fig.start(fdir=fdir, ofn=paste0(fdir, "/", bin, ".pdf"), type="pdf", height=4, width=4)
        ## plot(rr$x, rr$y, main=main, pch=19, cex=0.5, col=rr$col)
        legend("topright", fill=cols, legend=classes, box.lty=0, cex=0.75, border=NA)
        fig.end()
    }
}
