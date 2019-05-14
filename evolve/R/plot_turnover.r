plot.halflife=function(ifn.aab, ifn.fp, fdir)
{
    aab = load.table(ifn.aab)
    fp = load.table(ifn.fp)

    aab$subject = "S1"
    fp$subject = "S2"

    df = rbind(aab, fp)
    df = df[df$core.fate == "persist",]
    df$col = ifelse(df$subject == "S1", "red", "blue")
    df$accessory.total = df$gene.not.detected + df$gene.low.detected + df$gene.turnover + df$gene.persist
    df$turn.fraction.low = df$gene.not.detected / df$accessory.total
    df$turn.fraction.high = (df$gene.not.detected + df$gene.turnover) / df$accessory.total

    df$year.low = (10 / df$turn.fraction.low)/2
    df$year.high = (10 / df$turn.fraction.high)/2

    plot.i=function(field, title, add.text) {
        df = df[is.finite(df[,field]),]
        df = df[order(df[,field]),]
        fig.start(fdir=fdir, ofn=paste(fdir, "/", title, if(add.text) "_labels", ".pdf", sep=""), type="pdf", height=4, width=4)
        values = df[,field]
        ef = ecdf(values)
        if (add.text)
            xlim = c(-10, max(df[,field]))
        else
            xlim = c(0, max(df[,field]))
        main = paste("m=", round(median(values)), ", sd=", round(sd(values)), sep="")
        ps = plot.stepfun(ef, col.points=df$col, verticals=F, pch=19, xlab=title, xlim=xlim, main=main, las=1)
        ii = -c(1,dim(df)[1]+2)
        if (add.text) text(ps$t[ii], ps$y[ii], paste(df$subject, df$anchor.id), pos=2)
        title(sub=paste("range: ", round(range(values),1), collapse=",", sep=""))
        fig.end()
    }
    plot.i(field="year.low", "nd_only", add.text=T)
    plot.i(field="year.high", "nd_and_turn", add.text=T)
    plot.i(field="year.low", "nd_only", add.text=F)
    plot.i(field="year.high", "nd_and_turn", add.text=F)

    wlegend(fdir=fdir, names=c("S1", "S2"), cols=c("red", "blue"), title="subjects")
}

plot.rate=function(ifn.aab, ifn.fp, years, fdir)
{
    aab = load.table(ifn.aab)
    fp = load.table(ifn.fp)

    aab$subject = "S1"
    fp$subject = "S2"

    df = rbind(aab, fp)
    df = df[df$core.fate == "persist",]
    df$rate = (df$gene.not.detected + df$gene.turnover) / years
    df = df[order(df$rate),]
    df$id = paste(df$subject, df$anchor.id, sep="_")

    main = sprintf("genes/year\nmin/mid/max=%.0f/%.0f/%.0f", min(df$rate), median(df$rate), max(df$rate))

    inch.per.genome = 0.22
    height = 5.5
    cex.names = 1

    ylim = c(0, max(df$rate*1.1))
    N = dim(df)[1]
    fig.start(fdir=fdir, ofn=paste(fdir, "/gene_turn_per_year_indices.pdf", sep=""), type="pdf", height=height, width=1+N*inch.per.genome)
    barplot(df$rate, names.arg=1:N, border=NA, col="darkblue", ylim=ylim, las=2, cex.names=cex.names, main=main)
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/gene_turn_per_year_names.pdf", sep=""), type="pdf", height=height, width=1+N*inch.per.genome)
    barplot(df$rate, names.arg=df$id, border=NA, col="darkblue", ylim=ylim, las=2, cex.names=cex.names, main=main)
    fig.end()
}
