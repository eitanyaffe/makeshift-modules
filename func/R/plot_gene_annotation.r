plot.internal=function(df, count.field, enrichment.field, desc.field, title, xlim, ylim, cex, fdir, width=10, height=6)
{
    df$count.field = df[,count.field]
    df$desc.field = df[,desc.field]
    df$enrichment.field = log2(df[,enrichment.field])

    xcolor = 0.75

    fig.start(fdir=fdir, ofn=paste(fdir, "/GO_", title, "_", desc.field, "_diagram.pdf", sep=""), type="pdf", width=width, height=height)

    par(xaxs="i")
    par(yaxs="i")
    plot.init(xlim=xlim, ylim=ylim, xlab="gene count (log scale)", ylab="enrichment (log2)", log="x", axis.las=1, y.axis=F, x.axis=F, add.grid=F, main=title)
    # at.y = axTicks(2)
    at.x = unique(sort(c(1:4, 1:5*2, 1:10*10)))
    at.y = -10:10
    axis(1, at=at.x)
    axis(2, at=at.y, las=1)
    # rect(xleft=0.01, xright=xlim[2]*100, ybottom=0, ytop=ylim[2]+1, col=rgb(1,xcolor,xcolor), border=NA)
    # rect(xleft=0.01, xright=xlim[2]*100, ybottom=ylim[1]-1, ytop=0, col=rgb(xcolor,xcolor,1), border=NA)
    abline(h=at.y, v=at.x, col="darkgray", lty=3)
    abline(h=0, col=1)
    box()
    points(df$count.field, df$enrichment.field, col="lightgray", pch=19, cex=1.1)
    points(df$count.field, df$enrichment.field, col=1, cex=1.1)
    text(df$count.field, df$enrichment.field, df$desc.field, pos=df$pos, cex=cex)

    fig.end()
}

plot.bars=function(df, count.field, enrichment.field, desc.field, title, fdir)
{
    df$count.field = df[,count.field]
    df$desc.field = df[,desc.field]
    df$enrichment.field = log2(df[,enrichment.field])
    df = df[df$enrichment.field > log2(3),]
    df = df[order(df$enrichment.field, decreasing=F),]

    par(xpd=NA)
    xlim = c(0, 1.5*max(df$enrichment.field))
    fig.start(fdir=fdir, ofn=paste(fdir, "/GO_", title, "_", desc.field, "_barplot.pdf", sep=""), type="pdf", width=10, height=dim(df)[1]*0.2+2)
    par(mai=c(1,8,1,1))
    mp = barplot(df$enrichment.field, names.arg=df$desc.field, horiz=T, las=2, xlim=xlim, border=NA, xlab="log2(enrichment)")
    text(x=df$enrichment.field, y=mp, pos=4, labels=df$count.field)
    fig.end()
}

plot.GO=function(ifn, fdir)
{
    df = load.table(ifn)

    df$stats = sprintf("%s,%.1f", df$count, df$enrichment)
    cex = 0.6

    min.count = min(df$count)

    types = c("func", "component", "process")
    for (type in types) {
        df.type = df[df$type == type,]

        df.type$pos = 4
        df.type$pos[df.type$count == min.count] = 2
        df.type$pos[which.max(df.type$count)] = 2

        s1 = c("methyltransferase activity", "phosphorelay signal transduction system")
        s2 = c("integral component of membrane", "sigma factor activity", "DNA-templated transcription, initiation", "nucleic acid phosphodiester bond hydrolysis", "C-5 methylation of cytosine", "cytoplasm")
        s3 = c("kinase activity", "regulation of transcription, DNA-templated")
        s4 = c("DNA (cytosine-5-)-methyltransferase activity", "membrane")
        df.type$pos[is.element(df.type$desc, s1)] = 1
        df.type$pos[is.element(df.type$desc, s2)] = 2
        df.type$pos[is.element(df.type$desc, s3)] = 3
        df.type$pos[is.element(df.type$desc, s4)] = 4

        count.field = "count"
        enrichment.field = "enrichment"
        title = type

        xlim = c(1, max(df.type$count) * 2)
        ylim = range(log2(df.type$enrichment))

        ylim[1] = 0

        plot.internal(df=df.type, title=title, count.field=count.field, desc.field="desc", enrichment.field=enrichment.field, fdir=fdir, xlim=xlim, ylim=ylim, cex=cex)
        plot.internal(df=df.type, title=title, count.field=count.field, desc.field="id", enrichment.field=enrichment.field, fdir=fdir, xlim=xlim, ylim=ylim, cex=cex)
        plot.internal(df=df.type, title=title, count.field=count.field, desc.field="stats", enrichment.field=enrichment.field, fdir=fdir, xlim=xlim, ylim=ylim, cex=cex)
        plot.bars(df=df.type, title=title, count.field=count.field, desc.field="desc", enrichment.field=enrichment.field, fdir=fdir)

        ## enrichment.field = "enrichment.shared"
        ## title = paste("shared", title, sep="_")
        ## plot.internal(df=df.type, title=title, count.field=count.field, desc.field="desc", enrichment.field=enrichment.field, fdir=fdir, xlim=xlim, ylim=ylim, cex=cex)
        ## plot.internal(df=df.type, title=title, count.field=count.field, desc.field="id", enrichment.field=enrichment.field, fdir=fdir, xlim=xlim, ylim=ylim, cex=cex)
        ## plot.internal(df=df.type, title=title, count.field=count.field, desc.field="stats", enrichment.field=enrichment.field, fdir=fdir, xlim=xlim, ylim=ylim, cex=cex)
        ## plot.bars(df=df.type, title=title, count.field=count.field, desc.field="desc", enrichment.field=enrichment.field, fdir=fdir)
    }
}

plot.words=function(ifn, filter.words, min.count, fdir)
{
    df = load.table(ifn)

    for (i in 1:length(filter.words))
        filter.words[i] = gsub("_", " ", filter.words[i])
    df = df[!is.element(df$word, filter.words),]
    df = df[df$gene_count >= min.count,]

    width = 12
    height = 12
    cex = 0.4

    df$pos = 4
    df$pos[df$gene_count == min.count] = 2
    df$pos[which.max(df$gene_count)] = 2

    s2 = c("Recombinase", "Tail", "Chromosome", "Hydrolase", "30S", "Synthase", "Phosphate")
    s3 = c("Tail")
    s4 = c("Recombination")
    df$pos[is.element(df$word, s2)] = 2
    df$pos[is.element(df$word, s3)] = 3
    df$pos[is.element(df$word, s4)] = 4
    df$stats = sprintf("%s,%.1f", df$gene_count, df$enrichment)

    xlim = c(min.count-1, max(df$gene_count) * 1.5)
    ylim = range(log2(df$enrichment))

    count.field = "gene_count"
    enrichment.field = "enrichment"
    title = "words"
    plot.internal(df=df, title=title, count.field=count.field, desc.field="word", enrichment.field=enrichment.field, fdir=fdir, xlim=xlim, ylim=ylim, cex=cex, width=width, height=height)
    plot.internal(df=df, title=title, count.field=count.field, desc.field="stats", enrichment.field=enrichment.field, fdir=fdir, xlim=xlim, ylim=ylim, cex=cex, width=width, height=height)
}
