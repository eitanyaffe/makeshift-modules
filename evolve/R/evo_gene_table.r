make.gene.table=function(ifn.anchors, ifn.elements, ifn.gene2element, ifn.uniref, ofn.all, ofn.select)
{
    anchor.table = load.table(ifn.anchors)
    et = load.table(ifn.elements)
    g2e = load.table(ifn.gene2element)
    uni = load.table(ifn.uniref)

    result = NULL
    for (anchor in unique(et$anchor)) {
        anchor.id = anchor.table$id[match(anchor, anchor.table$set)]
        eta = et[et$anchor == anchor,]
        core.fate = eta$core.fate[1]
        ids = eta$element.id
        genes = g2e$gene[is.element(g2e$element.id, ids)]

        df = data.frame(anchor.id=anchor.id, anchor=anchor, core.fate=core.fate, gene=genes)
        df$element.id = g2e$element.id[match(genes,g2e$gene)]
        df$element.fate = eta$element.fate[match(df$element.id,eta$element.id)]
        df$element.type = eta$type[match(df$element.id,eta$element.id)]

        # add uniref
        ix = match(df$gene, uni$gene)
        df$uniref = ifelse(!is.na(ix), uni$uniref[ix], "")
        df$desc = ifelse(!is.na(ix), uni$prot_desc[ix], "")
        df$taxa = ifelse(!is.na(ix), uni$tax[ix], "")
        df$identity = ifelse(!is.na(ix), uni$identity[ix], "")

        result = rbind(result, df)
    }

    save.table(result, ofn.all)

    result = result[result$core.fate == "persist" & (result$element.fate == "turnover" | result$element.fate == "not.detected"),]
    save.table(result, ofn.select)
}
