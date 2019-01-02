plot.accessory.legend=function(cores.ifn, taxa.ifn, taxa.lookup.ifn, fdir)
{
    cores = load.table(cores.ifn)
    taxa = load.table(taxa.ifn)
    taxa = taxa[is.element(taxa$anchor,cores$anchor),]
    taxa.lu = load.table(taxa.lookup.ifn)
    taxa$group.name = taxa.lu$name[match(taxa$group.id,taxa.lu$tax_id)]
    tt = table(taxa$group.name)
    df = data.frame(name=names(tt), count=as.vector(tt))
    df$color = taxa$color[match(df$name,taxa$group.name)]
    wlegend(fdir, names=paste(df$name, " (", df$count, ")", sep=""), cols=df$color, title="family")
}

plot.source.breakdown=function(ifn.resolve, ifn.cores, fdir)
{
    res = load.table(ifn.resolve)
    cores = load.table(ifn.cores)
    cores$is.env = res$is.env[match(cores$anchor,res$anchor)]
    cores$class =
        ifelse(!cores$near.complete, "partial",
               ifelse(!cores$large.core, "no-ref",
                      ifelse(cores$is.env, "metagenomic", "isolate")))
    tt = table(cores$class)

    fig.start(fdir=fdir, ofn=paste(fdir, "/source_breakdown.pdf", sep=""), type="pdf", width=2.5, height=4)
    par(mai=c(1.5,1,1,0.5))
    mx = barplot(tt, col="darkblue", border=NA, las=2, main="species-level \nreference", ylab="#genomes", ylim=c(0, 1.2*max(tt)))
    text(mx, tt, tt, pos=3, cex=0.75)
    fig.end()
}
