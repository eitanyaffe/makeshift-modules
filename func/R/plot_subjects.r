plot.subject.pvals=function(ifn1, ifn2, ifn.select1, ifn.select2, fdir)
{
    df.select1 = load.table(ifn.select1)
    df.select2 = load.table(ifn.select2)
    df.select1 = df.select1[!df.select1$type == "AMR",]
    df.select2 = df.select2[!df.select2$type == "AMR",]
    ids = unique(c(df.select1$id, df.select2$id))

    df1 = load.table(ifn1)
    df2 = load.table(ifn2)

    df = data.frame(id=ids)
    ix1 = match(ids, df1$id)
    ix2 = match(ids, df2$id)
    df$val1 = ifelse(is.na(ix1), 0, df1$enrichment[ix1])
    df$val2 = ifelse(is.na(ix2), 0, df2$enrichment[ix2])
    df$desc = ifelse(!is.na(ix1), df1$desc[ix1], df2$desc[ix2])
    df$type = ifelse(!is.na(ix1), df1$type[ix1], df2$type[ix2])

    df = df[is.finite(df$val1) & is.finite(df$val2),]

    xlim = range(c(0, df$val1))
    ylim = range(c(0, df$val2))

    plot.type=function(type) {
        dft = df[df$type==type,]
        dft$index = 1:dim(dft)[1]

        fig.start(fdir=fdir, ofn=paste(fdir, "/", type, ".pdf", sep=""), type="pdf", height=6, width=6)
        plot.init(xlim=xlim, ylim=ylim, xlab="enrichment1", ylab="enrichment2", main="")
        grid()
        points(dft$val1, dft$val2, pch=19, col=1, cex=0.5)
        fig.end()

        fig.start(fdir=fdir, ofn=paste(fdir, "/", type, "_text.pdf", sep=""), type="pdf", height=6, width=6)
        plot.init(xlim=xlim, ylim=ylim, xlab="enrichment1", ylab="enrichment2", main="")
        grid()
        points(dft$val1, dft$val2, pch=19, col=1, cex=0.5)
        text(dft$val1, dft$val2, pos=4, labels=dft$desc, cex=0.25)
        fig.end()

        ii = match("index", names(dft))
        ix = setdiff(1:dim(dft)[2], ii)
        dft = dft[,c(ii, ix)]
        save.table(dft, paste(fdir, "/", type, ".txt", sep=""))
    }
    plot.type("func")
    plot.type("component")
    plot.type("process")
}
