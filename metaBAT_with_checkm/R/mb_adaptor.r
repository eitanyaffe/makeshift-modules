create.gene.table=function(
    ifn.cg, ifn.ce, ifn.genes,
    ofn.gene.table, ofn.core.table, ofn.element.table, ofn.gene2core, ofn.gene2element)
{
    cg = load.table(ifn.cg)
    ce = load.table(ifn.ce)
    genes = load.table(ifn.genes)

    cg$type = "anchor"
    ce$type = "element"
    cc = rbind(cg, ce)
    contigs = unique(cc$contig)

    # gene table
    genes = genes[is.element(genes$contig,contigs),]
    genes = data.frame(gene=genes$gene, contig=genes$contig)
    ix = match(genes$contig,cc$contig)
    genes$type = cc$type[ix]
    genes$bin = cc$bin[ix]
    save.table(genes, ofn.gene.table)

    bin.count = sapply(split(genes$gene, genes$bin), length)

    # cores
    gene2core = genes[genes$type == "anchor",]
    core.bins = unique(gene2core$bin)
    core.table = data.frame(anchor=core.bins)
    ix = match(core.table$anchor,names(bin.count))
    core.table$gene.count = ifelse(!is.na(ix),bin.count[ix],0)
    save.table(data.frame(gene=gene2core$gene, anchor=gene2core$bin), ofn.gene2core)
    save.table(core.table, ofn.core.table)

    # elements
    gene2element = genes[genes$type == "element",]
    element.bins = unique(gene2element$bin)
    element.table = data.frame(element.id=element.bins)
    ix = match(element.table$element.id,names(bin.count))
    element.table$gene.count = ifelse(!is.na(ix),bin.count[ix],0)
    save.table(data.frame(gene=gene2element$gene, element.id=gene2element$bin), ofn.gene2element)
    save.table(element.table, ofn.element.table)

}
