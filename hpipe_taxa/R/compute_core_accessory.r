compute.core.accessory=function(
    ifn, ifn.ga, uniref.ifn, min.core.percent, identity.threshold,
    ofn.summary, ofn.core, ofn.accessory, ofn.accessory.shared)
{
    df = load.table(ifn)
    uniref = load.table(uniref.ifn)
    ix = match(df$gene, uniref$gene)
    df$uniref = ifelse(!is.na(ix), uniref$uniref[ix], "none")
    df$uniref.identity = ifelse(!is.na(ix), uniref$identity[ix], 0)
    df$prot_desc = ifelse(!is.na(ix), uniref$prot_desc[ix], "none")

    result = data.frame(anchor.id=df$anchor.id, anchor=df$anchor, gene=df$gene,
        uniref=df$uniref, identity=df$uniref.identity, prot_desc=df$prot_desc, ref.identity=df$identity)

    result$type = ifelse(result$ref.identity >= identity.threshold/100, "core", "accessory")
    tt = table(result$anchor, result$type)

    anchors = rownames(tt)
    anchor.ids = df$anchor.id[match(anchors, df$anchor)]
    summary = data.frame(anchor=anchors, anchor.id=anchor.ids, core=tt[,match("core", colnames(tt))], accessory=tt[,match("accessory", colnames(tt))])
    summary$core.fraction = summary$core / (summary$core + summary$accessory)
    summary$selected = summary$core.fraction > min.core.percent/100
    save.table(summary, ofn.summary)

    # accessory
    selected.anchors = summary$anchor[summary$selected]
    result = result[is.element(result$anchor, selected.anchors),]

    result.core = result[result$type == "core",]
    result.accessory = result[result$type == "accessory",]

    save.table(result.core, ofn.core)
    save.table(result.accessory, ofn.accessory)

    ga = load.table(ifn.ga)
    fc = field.count(ga, "gene")
    shared.genes = fc$gene[fc$count>1]

    result.accessory.shared = result.accessory[is.element(result.accessory$gene, shared.genes),]
    save.table(result.accessory.shared, ofn.accessory.shared)
}
