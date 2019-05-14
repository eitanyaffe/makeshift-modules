core.details=function(ifn.table, ifn.genes, ifn.uniref, ofn)
{
    df = load.table(ifn.table)
    gg = load.table(ifn.genes)
    uni = load.table(ifn.uniref)

    gg = gg[is.element(gg$anchor, df$anchor) & gg$non_syn.obs > 0,]
    gg$anchor.id = df$anchor.id[match(gg$anchor,df$anchor)]
    gg = gg[,c("anchor.id", "anchor", "gene")]

    ix = match(gg$gene, uni$gene)
    gg$uniref = ifelse(!is.na(ix), uni$uniref[ix], "")
    gg$desc = ifelse(!is.na(ix), uni$prot_desc[ix], "")
    gg$taxa = ifelse(!is.na(ix), uni$tax[ix], "")
    gg$identity = ifelse(!is.na(ix), uni$identity[ix], "")

    save.table(gg, ofn)
}

core.summary=function(ifn.core.genes, ifn.core.table, ifn.obs, ifn.exp, ofn.details, ofn.summary)
{
    df = load.table(ifn.core.genes)
    core.df = load.table(ifn.core.table)
    obs = load.table(ifn.obs)
    exp = load.table(ifn.exp)

    ix = match(df$gene, obs$gene)
    df$syn.obs = ifelse(!is.na(ix), obs$syn[ix], 0)
    df$non_syn.obs = ifelse(!is.na(ix), obs$non_syn[ix], 0)

    save.table(df, ofn.details)

    ix = match(df$gene, exp$gene)
    df$syn.exp = ifelse(!is.na(ix), exp$ks[ix], 0)
    df$non_syn.exp = ifelse(!is.na(ix), exp$ka[ix], 0)

    anchors = core.df$anchor
    result = NULL
    for (anchor in anchors) {
        dfa = df[df$anchor == anchor,]
        result = rbind(result, data.frame(anchor=anchor,
            syn.obs=sum(dfa$syn.obs),
            non_syn.obs=sum(dfa$non_syn.obs),
            syn.exp=sum(dfa$syn.exp),
            non_syn.exp=sum(dfa$non_syn.exp)))
    }

    result$ka.ks = ifelse(result$non_syn.obs>0&result$syn.obs, (result$non_syn.obs / result$non_syn.exp) / (result$syn.obs / result$syn.exp), -1)
    save.table(result, ofn.summary)
}

core.merge=function(ifn.core.fate,
    ifn.core.summary.current, ifn.core.summary.10y,
    ifn.taxa, ifn.genus.legend, ifn.family.legend, ifn.class, ifn.poly, ifn.fix, ofn)
{
    taxa = load.table(ifn.taxa)
    genus = load.table(ifn.genus.legend)
    family = load.table(ifn.family.legend)

    cores = load.table(ifn.core.fate)
    class = load.table(ifn.class)
    poly = load.table(ifn.poly)
    fix = load.table(ifn.fix)

    # we use current for poly values
    cores.poly.current = load.table(ifn.core.summary.current)
    cores.poly.10y = load.table(ifn.core.summary.10y)

    cores$gene.count = cores$gene.turnover + cores$gene.not.detected
    cores$element.count = cores$element.turnover + cores$element.not.detected

    taxa$family.id = taxa$group.id
    taxa$family.name = family$name[match(taxa$family.id, family$tax_id)]
    taxa$genus.id = taxa$sub.group.id
    taxa$genus.name = genus$name[match(taxa$genus.id, genus$tax_id)]

    anchors = class$anchor[class$fate == "persist"]

    # results
    df = taxa[is.element(taxa$anchor, anchors), c("anchor", "anchor.id")]

    # add taxa
    ix = match(df$anchor, taxa$anchor)
    df = cbind(df, taxa[ix, c("family.id", "family.name", "genus.id", "genus.name")])
    df$genus.taxa.id = taxa$group.id[ix]

    # add poly
    ix = match(df$anchor, poly$anchor)
    df$pN.o = poly$non_syn.obs[ix]
    df$pN.e = poly$non_syn.exp[ix]
    df$pS.o = poly$syn.obs[ix]
    df$pS.e = poly$syn.exp[ix]

    # add nt divergence
    ix = match(df$anchor, fix$anchor)
    df$dN.o = fix$non_syn.obs[ix]
    df$dN.e = fix$non_syn.exp[ix]
    df$dS.o = fix$syn.obs[ix]
    df$dS.e = fix$syn.exp[ix]

    # add gene divergence
    ix = match(df$anchor, cores$anchor)
    df$gene.count = cores$gene.count[ix]
    df$element.count = cores$element.count[ix]
    df$poly.10y.count = cores$live.count[ix]

    # add current poly density
    ix = match(df$anchor, cores.poly.current$anchor)
    df$poly.count = cores.poly.current$live.count[ix]
    df$length = cores.poly.current$effective.length[ix]

    # add 10y poly
    ix = match(df$anchor, cores.poly.10y$anchor)
    df$poly.10y.count = cores.poly.10y$live.count[ix]

    save.table(df, ofn)
}
