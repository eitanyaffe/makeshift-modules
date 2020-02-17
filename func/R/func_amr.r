amr.enrichment=function(ifn.genes, ifn.amr, ofn)
{
    genes = load.table(ifn.genes)
    amr = load.table(ifn.amr)
    amr = amr[is.element(amr$target, genes$gene),]

    ss = split(amr, amr$query_accession)
    ss.count = sapply(ss, function(x) { dim(x)[1]} )
    ss.contig = sapply(ss, function(x) {length(unique(x$contig))})
    ss.desc = sapply(ss, function(x) { x$query[1] })

    df = data.frame(id=names(ss), count=ss.count, contig_count=ss.contig, desc=ss.desc)
    save.table(df, ofn)
}
