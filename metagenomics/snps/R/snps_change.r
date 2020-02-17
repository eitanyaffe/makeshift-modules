get.change=function(ifn.genes, ifn.bins, ifn.uniref, ifn.contigs, max.fix.density, min.cov, ofn.summary, ofn.genes)
{
    genes = load.table(ifn.genes)
    bins = load.table(ifn.bins)
    contigs = load.table(ifn.contigs)
    uniref = load.table(ifn.uniref)

    genes$bin = contigs$bin[match(genes$contig, contigs$contig)]

    ix = match(genes$gene, uniref$gene)
    genes$desc = ifelse(!is.na(ix), uniref$prot_desc[ix], "no.hit")

    bins = bins[bins$class == "host" & bins$base.cov >= min.cov & bins$set.cov >= min.cov & bins$fix.density <= max.fix.density,]
    bins = bins[order(bins$fix.count),]

    save.table(bins, ofn.summary)

    result = NULL
    for (bin in bins$bin) {
        ix = (genes$bin == bin) & genes$fix
        if (!any(ix))
            next
        df = genes[ix,c("bin", "gene", "contig", "fix", "desc")]
        result = rbind(result, df)
    }
    save.table(result, ofn.genes)
}
