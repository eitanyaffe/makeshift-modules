element.genes=function(ifn.uniref, ifn.elements, ifn.ge, ofn)
{
    genes = load.table(ifn.ge)
    elements = load.table(ifn.elements)
    uniref = load.table(ifn.uniref)

    genes = genes[order(match(genes$element.id, elements$element.id), match(genes$gene, genes$gene)),]

    ix = match(genes$gene, uniref$gene)
    add.field=function(field, default) {
        genes[,field] = ifelse(!is.na(ix), uniref[ix,field], default)
        genes
    }

    genes = add.field("uniref", "none")
    genes = add.field("identity", 0)
    genes = add.field("coverage", 0)
    genes = add.field("prot_desc", 0)
    genes = add.field("tax", 0)

    save.table(genes, ofn)
}
