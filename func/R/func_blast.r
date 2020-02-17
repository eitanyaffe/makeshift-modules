blast.analysis=function(title, ifn.uniref, ifn.genes, breaks, ofn.summary, ofn.poor)
{
    uniref = load.table(ifn.uniref)
    genes = load.table(ifn.genes)$gene

    no.hit = length(setdiff(genes, uniref$gene))
    values = uniref$identity[is.element(uniref$gene, genes)]
    ss = sapply(split(values, cut(values, breaks=breaks)), length)
    df = as.data.frame(t(ss))
    names(df) = paste("i", breaks[-1], sep="")
    result = t(data.frame(i0=no.hit, df))
    colnames(result)[1] = title

    save.table(result, ofn.summary)

    df = uniref[is.element(uniref$gene, genes),]
    words = c("Uncharacterized protein", "hypothetical protein", "Uncharacterized conserved protein")
    df$poor = F
    for (word in words)
        df$poor = df$poor | grepl(word, df$prot_desc, ignore.case=T)
    poor.count = sum(df$poor) + no.hit
    poor.rate = poor.count/length(genes)
    save.table(poor.rate, ofn.poor)
}

plot.blast=function(idir, ids, colors, func.blast.ver, breaks, fdir)
{
    table.blast = NULL
    table.rate = NULL
    for (i in 1:length(ids)) {
        id = ids[i]
        df = load.table(paste(idir, "/geneset/", id, "/blast_summary_", func.blast.ver, sep=""))
        if (i > 1)
            table.blast = cbind(table.blast, df)
        else
            table.blast = df

        rate = 100*load.table(paste(idir, "/geneset/", id, "/poor_rate", sep=""))[1,1]
        table.rate = rbind(table.rate, data.frame(id=id, rate=rate))
    }

    #########################################################################################################
    # plot poor rate
    #########################################################################################################

    fig.start(fdir=fdir, ofn=paste(fdir, "/poor_rate.pdf", sep=""), type="pdf", height=4, width=1+0.5*length(ids))
    plot.init(xlim=c(0, 2+length(ids)) ,ylim=c(0, 1.1*max(table.rate$rate)), y.axis=F, x.axis=F, grid.nx=0)
    barplot(table.rate$rate, col=colors, names.arg=table.rate$id, border=NA, las=2, ylab="% poor", main="no|poor hits", add=T)
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/poor_rate_text.pdf", sep=""), type="pdf", height=4, width=1+0.5*length(ids))
    plot.init(xlim=c(0, 2.5+length(ids)) ,ylim=c(0, 1.1*max(table.rate$rate)), y.axis=F, x.axis=F, grid.nx=0)
    mx = barplot(table.rate$rate, col=colors, names.arg=table.rate$id, border=NA, las=2, ylab="% poor", main="no|poor hits", add=T)
    text(x=mx, y=table.rate$rate, round(table.rate$rate), pos=3)
    fig.end()

    #########################################################################################################
    # plot blast breakdown
    #########################################################################################################

    mm = t(as.matrix(table.blast))
    wlegend(fdir=fdir, names=ids, cols=colors, title="sets")

    mm = 100 * mm / rowSums(mm)
    fig.start(fdir=fdir, ofn=paste(fdir, "/blast_breakdown.pdf", sep=""), type="pdf", height=4, width=1+length(ids))
    plot.init(xlim=c(0, 1+(1+dim(mm)[1])*dim(mm)[2]), ylim=c(0, 1.1*max(mm)), y.axis=F, x.axis=F, grid.nx=0)
    barplot(mm, beside=T, col=colors, names.arg=breaks, border=NA, las=2, ylab="% genes", main="blast breakdown by identity %", add=T)
    fig.end()
}
