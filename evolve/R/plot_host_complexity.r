plot.host.complexity=function(ifn.elements, ifn.element2core, fdir)
{
    elements = load.table(ifn.elements)
    ea = load.table(ifn.element2core)
#    ids = elements$element.id[elements$class != "chimeric"]
    ids = elements$element.id

    ea = ea[is.element(ea$element.id, ids),]

    df = field.count(ea, field="element.id")
    df$gene.count = elements$gene.count[match(df$element.id, elements$element.id)]
    df = df[df$count>1,]
    ss = sapply(split(df$gene.count, df$count), sum)

    min.genes = 3

    # collect last values of only one gene
    ix = which.min(ss>min.genes)
    vals = c(ss[1:(ix-1)], sum(ss[ix:length(ss)]))
    names(vals) = c(names(ss)[1:(ix-1)], paste(">", names(ss)[ix-1], sep=""))

    cex = 0.75
    width = 2.75

    ylim = c(0, 1.4*max(vals))
    fig.start(fdir=fdir, ofn=paste(fdir, "/shared.pdf", sep=""), type="pdf", width=width, height=4)
    par(mai=c(0.5, 1, 0.5, 0.1))
    m = barplot(vals, names.arg=names(vals), col="darkblue", border=NA, ylim=ylim, las=1, ylab="#genes", cex.names=cex, cex.axis=cex)
    title(main=paste("all=",sum(vals), sep=""))
    text(x=m, y=vals, pos=3, labels=vals, cex=cex)
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/shared_clean.pdf", sep=""), type="pdf", width=width, height=4)
    par(mai=c(0.5, 1, 0.5, 0.1))
    m = barplot(vals, names.arg=names(vals), col="darkblue", border=NA, ylim=ylim, las=1, ylab="#genes", cex.names=cex, cex.axis=cex)
    fig.end()
}
