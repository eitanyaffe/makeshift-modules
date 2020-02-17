associated.genes=function(ifn.core.genes, ifn.element.genes, ofn)
{
    cores = load.table(ifn.core.genes)
    elements = load.table(ifn.element.genes)
    result = data.frame(gene=unique(c(cores$gene, elements$gene)))
    save.table(result, ofn)

}
