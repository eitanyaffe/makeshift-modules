host.fate.summary=function(ifn.cores, ifn.elements, ifn.gene2element, ifn.element2core, years, ofn.details, ofn.summary)
{
    cores = load.table(ifn.cores)
    elements = load.table(ifn.elements)
    gene2element = load.table(ifn.gene2element)
    element2core = load.table(ifn.element2core)

    cores$mut.mb.year = (cores$fixed.density*10^6) / years

    # omit chimeric from gene gain analysis
    # elements = elements[elements$fate != "chimeric",]

    levels = c("not.detected", "low.detected", "turnover", "persist")
    result.summary = NULL
    result.details = NULL
    for (anchor in cores$anchor) {
        ix = match(anchor, cores$anchor)
        core.fate = cores$fate[ix]

        ids = element2core$element[element2core$anchor == anchor]
        df = elements[is.element(elements$element.id, ids),]
        result.details = rbind(result.details, data.frame(anchor=anchor, core.fate=core.fate, df))

        ss = split(df, factor(df$fate, levels))
        element.count = t(as.data.frame(sapply(ss, function(x) { dim(x)[1] })))
        gene.count = t(as.data.frame(sapply(ss, function(x) { sum(x$gene.count) })))
        colnames(element.count) =  paste("element", colnames(element.count), sep=".")
        colnames(gene.count) =  paste("gene", colnames(gene.count), sep=".")

        result.core = data.frame(
            anchor=anchor, anchor.id=cores$anchor.id[ix],
            core.fate=core.fate, mut.count=cores$fixed.count[ix], mut.density=cores$fixed.density[ix], mut.mb.year=cores$mut.mb.year[ix],
            element.count, gene.count)
        result.summary = rbind(result.summary, result.core)
    }

    save.table(result.summary, ofn.summary)

    names(result.details)[names(result.details) == "fate"] = "element.fate"
    save.table(result.details, ofn.details)
}

host.detect.summary=function(ifn.genes, ifn.cores, ifn.ga, ofn)
{
    genes =load.table(ifn.genes)
    cores = load.table(ifn.cores)
    ga = load.table(ifn.ga)
    result = NULL
    for (anchor in cores$anchor) {
        genes.anchor = ga$gene[ga$anchor == anchor]
        n.detected = sum(genes$cov[is.element(genes$gene, genes.anchor)] > 0)
        ix = match(anchor, cores$anchor)
        df = data.frame(
            anchor=anchor, anchor.id=cores$anchor.id[ix],
            core.fate=cores$fate[ix], mut.count=cores$fixed.count[ix], mut.density=cores$fixed.density[ix],
            total.genes=length(genes.anchor), detected.genes=n.detected)
        result = rbind(result, df)
    }
    save.table(result, ofn)
}

plot.host.fate.summary=function(ifn, ifn.taxa, mut.per.year, mut.threshold, fdir)
{
    taxa = load.table(ifn.taxa)
    df = load.table(ifn)
    df = df[df$core.fate != "not.detected" & df$core.fate != "low.detected",]

    fates = c("turnover", "persist")
    colors = c("red", "green")
    wlegend(fdir=fdir, names=fates, cols=colors, title="fate")
    df$color = colors[match(df$core.fate, fates)]
    df$color = "darkblue"
    df$color = taxa$color[match(df$anchor, taxa$anchor)]
    df$anchor.id = taxa$anchor.id[match(df$anchor, taxa$anchor)]

    df$color = ifelse(df$core.fate == "persist", "darkgreen", "orange")

    df$log.rate = log10(df$mut.density)
    df$gene.gain = 1 + df$gene.turnover + df$gene.not.detected
    df$element.gain = 1 + df$element.turnover + df$element.not.detected

    xlim = range(c(df$log.rate, -6.1, -1.8))

    pplot=function(field, ylab, add.text) {
        ix = df$core.fate == "turnover"
        main = paste("spearman of turned:", round(cor(df[ix,field], df$mut.density[ix], method="spearman"),2))
        ylim = range(c(0, df[,field]))
        fig.start(fdir=fdir, ofn=paste(fdir, "/", field, if(add.text) "_text" else "", ".pdf", sep=""), type="pdf", height=4.8, width=4)
        par(mai=c(1,1,1.5,0.5))
        plot.init(xlim=xlim, ylim=ylim, xlab="mut/bp", ylab=ylab, main=main, axis.las=1)

        box()
        grid()
        abline(v=log10(mut.threshold), lty=3)
        points(df$log.rate, df[,field], pch=19, col=df$color, cex=0.5)
        if (add.text) {
            ix = df$core.fate == "persist"
            # text(df$log.rate[ix], df[ix,field], df[ix,field], pos=4)
            text(df$log.rate[ix], df[ix,field], df[ix,"anchor.id"], pos=3, cex=0.4)
        }
        fig.end()
    }

    pplot(field="gene.gain", ylab="#genes", add.text=F)
    pplot(field="gene.gain", ylab="#genes", add.text=T)

    pplot(field="element.gain", ylab="#elements", add.text=F)
    pplot(field="element.gain", ylab="#elements", add.text=T)
}

plot.host.detect.summary=function(ifn, fdir)
{
    df = load.table(ifn)
    df = df[df$core.fate != "not.detected" & df$core.fate != "low.detected",]

    fates = c("not.detected", "low.detected", "turnover", "persist")
    #colors = c("black", "gray", "red", "green")
    colors = c("blue", "gray", "orange", "darkgreen")
    wlegend(fdir=fdir, names=fates, cols=colors, title="fate")
    df$color = colors[match(df$core.fate, fates)]

    df$log.rate = log10(df$mut.density)
    df$per = 100 * (1 - df$detected.genes / df$total.genes)
    df$gained = df$total.genes - df$detected.genes
    df$text.x = paste(df$mut.count)
    df$text.y = paste(df$gained)

    xlim = range(df$log.rate)

   pplot=function(field, ylab, add.text, main="") {
        ylim = range(c(0, df[,field]))
        fig.start(fdir=fdir, ofn=paste(fdir, "/", field, if(add.text) "_text" else "", ".pdf", sep=""), type="pdf", height=6, width=6)
        plot.init(xlim=xlim, ylim=ylim, xlab="mut/bp", ylab=ylab, main=main)
        grid()
        points(df$log.rate, df[,field], pch=19, col=df$color)
        if (add.text) {
            ix = df$core.fate == "persist"
            text(df$log.rate[ix], df[ix,field], df$text.x[ix], pos=3, cex=0.75)
            text(df$log.rate[ix], df[ix,field], df$text.y[ix], pos=4, cex=0.75)
        }
        fig.end()
    }

    pplot(field="per", ylab="%not.detected", add.text=F)

    pplot(field="gained", ylab="#added.genes", add.text=F)
    pplot(field="gained", ylab="#added.genes", add.text=T, main="up:#snps, right:#genes")
}
