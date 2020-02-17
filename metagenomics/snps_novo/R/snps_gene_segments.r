gene.segments=function(ifn.genes, ifn.contigs, edge.margin, ofn)
{
    genes = load.table(ifn.genes)
    contigs = load.table(ifn.contigs)
    genes = genes[is.element(genes$contig,contigs$contig),]
    ix = match(genes$contig, contigs$contig)
    if (any(is.na(ix)))
        stop("internal")
    genes$contig.length = contigs$length[ix]

    genes$trim.start = pmax(edge.margin, genes$start)
    genes$trim.end = pmin(genes$contig.length-edge.margin, genes$end)
    genes$trim.length = pmax(0, genes$trim.end - genes$trim.start)
    genes = genes[genes$trim.length>0,]

    save.table(genes, ofn)
}
