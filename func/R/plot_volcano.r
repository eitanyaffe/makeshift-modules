plot.volcano=function(id, idir, select.ver, compare.dir, min.enrichment, min.ml.pvalue, fdir)
{
    ifn = paste(idir, "/geneset/", id, "/final", sep="")
    ifn.selected = paste(idir, "/geneset/", id, "/significant_", select.ver, "/table", sep="")

    df = load.table(ifn)
    df.sel = load.table(ifn.selected)
    shared = load.table(paste(compare.dir, "/all_", id, ".txt", sep=""))

    df$enrich.log2 = log2(df$enrichment)
    df = df[is.finite(df$minus.log.p) & is.finite(df$enrich.log2) & df$enrich.log2 > 0 & df$count > 1,]
    df$selected = is.element(df$id, df.sel$id)
    df$shared = is.element(df$id, shared$id)
    df$col = ifelse(df$shared, "orange", ifelse(df$selected, "red", "darkgray"))

    xlim = range(df$enrich.log2)
    ylim = range(df$minus.log.p)

    height = 2.8
    width = 3.5

    plot.type=function(type) {
        dft = df[df$type==type,]
        dft$index = 1:dim(dft)[1]
        dft$xbin = round(dft$enrich.log2,1)
        xbins = unique(dft$xbin)
        dft$xbin.index = match(dft$xbin, xbins)
        dft$pos = 2
        ss = split(dft$id, dft$xbin.index)
        for (xbin in names(ss)) {
            ids = ss[[xbin]]
            if (length(ids) == 1)
                next
            dft$pos[match(ids, dft$id)] = 2 + seq_along(ids) %% 4 - 1

        }
        plot.f=function(style) {
            fig.start(fdir=fdir, ofn=paste(fdir, "/", type, "_", style, ".pdf", sep=""), type="pdf", height=height, width=width)
            par(mai=c(0.8, 0.8, 0.3, 0.05))
            plot.init(xlim=xlim, ylim=ylim, x.axis=F, y.axis=F, add.grid=F)
            axis(1, las=1, cex.axis=0.7)
            axis(2, las=1, cex.axis=0.7)
            title(main=paste(id ,type), cex.main=0.7)
            title(xlab="log2(enrichment)", ylab="-log10(P-value)", main=paste(id ,type), cex.lab=0.7, line=2)
            # grid()
            abline(h=min.ml.pvalue, col="lightblue")
            abline(v=log2(min.enrichment), col="lightblue")
            points(dft$enrich.log2, dft$minus.log.p, pch=19, col=dft$col, cex=0.5)
            switch (style,
                    text=text(dft$enrich.log2, dft$minus.log.p, dft$desc, pos=dft$pos, cex=0.5),
                    index=text(dft$enrich.log2, dft$minus.log.p, dft$index, pos=dft$pos, cex=0.5, offset=0.1)
                    )
            fig.end()
        }
        plot.f("std")
        plot.f("text")
        plot.f("index")
        ## fig.start(fdir=fdir, ofn=paste(fdir, "/", type, ".pdf", sep=""), type="pdf", height=height, width=width)
        ## plot.init(xlim=xlim, ylim=ylim, xlab="log2(enrichment)", ylab="-log10(P)", main="", axis.las=1)
        ## grid()
        ## abline(h=min.ml.pvalue, lty=3)
        ## abline(v=log2(min.enrichment), lty=3)
        ## points(dft$enrich.log2, dft$minus.log.p, pch=19, col=dft$col, cex=0.5)
        ## fig.end()

        ## fig.start(fdir=fdir, ofn=paste(fdir, "/", type, "_text.pdf", sep=""), type="pdf", height=height, width=width)
        ## plot.init(xlim=xlim, ylim=ylim, xlab="log2(enrichment)", ylab="-log10(P)", main="", axis.las=1)
        ## grid()
        ## abline(h=min.ml.pvalue, lty=3)
        ## abline(v=log2(min.enrichment), lty=3)
        ## points(dft$enrich.log2, dft$minus.log.p, pch=19, col=dft$col, cex=0.5)
        ## text(dft$enrich.log2, dft$minus.log.p, dft$desc, pos=dft$pos, cex=0.5)
        ## fig.end()

        ## fig.start(fdir=fdir, ofn=paste(fdir, "/", type, "_index.pdf", sep=""), type="pdf", height=height, width=width)
        ## plot.init(xlim=xlim, ylim=ylim, xlab="log2(enrichment)", ylab="-log10(P)", main="", axis.las=1)
        ## grid()
        ## abline(h=min.ml.pvalue, lty=3)
        ## abline(v=log2(min.enrichment), lty=3)
        ## points(dft$enrich.log2, dft$minus.log.p, pch=19, col=dft$col, cex=0.5)
        ## text(dft$enrich.log2, dft$minus.log.p, dft$index, pos=dft$pos, cex=0.5)
        ## fig.end()

        save.table(dft[,c("index", "id", "desc")], paste(fdir, "/", type, "_index.txt", sep=""))
    }
    plot.type("func")
    plot.type("component")
    plot.type("process")
}
