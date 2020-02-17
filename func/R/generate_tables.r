gen.tables=function(
    taxa.ifn, ref.ifn, cores.ifn,
    evo.host.current.ifn, evo.host.10y.ifn, evo.element.current.ifn, evo.element.10y.ifn, evo.element.host.10y.ifn,
    pop.ifn,
    ea.ifn,
    odir)
{
    ############################################################################
    # anchors/cores
    ############################################################################

    taxa = load.table(taxa.ifn)
    ref = load.table(ref.ifn)
    cores = load.table(cores.ifn)

    evo.host.current = load.table(evo.host.current.ifn)
    evo.host.10y = load.table(evo.host.10y.ifn)

    ref = ref[is.element(ref$anchor,cores$anchor),]
    ref$taxa.id = taxa$tax_id[match(ref$anchor,taxa$anchor)]
    ref$taxa.name = taxa$name[match(ref$anchor,taxa$anchor)]

    df = data.frame(anchor.id=ref$anchor.id,
        taxa.id=ref$taxa.id, taxa.name=ref$taxa.name,
        ref.accession=ref$ref, ref.name=ref$ref.name, ref.strain=ref$ref.strain.name,
        core.identity=ref$anchor.identity, core.fraction=ref$anchor.coverage)
    anchors = ref$anchor[match(df$anchor.id,ref$anchor.id)]

    df$complete = evo.host.10y$complete[match(anchors, evo.host.10y$anchor)]
    df$contaminated = evo.host.10y$contam[match(anchors, evo.host.10y$anchor)]

    ix = match(anchors, evo.host.current$anchor)
    df$snp.count.current = evo.host.current$live.count[ix]
    df$snp.density.current = evo.host.current$live.density[ix]
    df$strain.class = evo.host.current$class[ix]

    ix = match(anchors, evo.host.10y$anchor)
    df$core.fraction.10y = evo.host.10y$core.fraction[ix]
    df$substitute.count.10y = evo.host.10y$fixed.count[ix]
    df$substitute.density.10y = evo.host.10y$fixed.density[ix]
    df$history.class.10y = evo.host.10y$fate[ix]

    save.table(df, paste(odir, "/hosts.txt", sep=""))

    ############################################################################
    # elements
    ############################################################################

    evo.element.current = load.table(evo.element.current.ifn)
    evo.element.10y = load.table(evo.element.10y.ifn)
    evo.element.host.10y = load.table(evo.element.host.10y.ifn)

    pop = load.table(pop.ifn)

    ea = load.table(ea.ifn)
    ea$anchor.id = ref$anchor.id[match(ea$anchor, ref$anchor)]
    save.table(ea[,c("element.id", "anchor.id")], paste(odir, "/element_to_host.txt", sep=""))
    ea = ea[order(match(ea$anchor.id,taxa$anchor.id)),]

    ss = sapply(split(ea$anchor.id, ea$element.id) , function(x) { paste(x, collapse=",") })
    ht = data.frame(element.id=names(ss), hosts=ss)
    ss = sapply(split(ea$anchor.id, ea$element.id) , length)
    ht.count = data.frame(element.id=names(ss), host.count=ss)

    df = data.frame(element.id=evo.element.current$element.id, gene.count=evo.element.current$gene.count)
    df$host.count = ht.count$host.count[match(df$element.id,ht.count$element.id)]
    df$hosts = ht$hosts[match(df$element.id,ht$element.id)]

    ids = df$element.id

    ix = match(ids, evo.element.current$element.id)
    df$length.bp = evo.element.current$effective.length[ix]
    df$snp.count.current = evo.element.current$live.count[ix]
    df$snp.density.current = evo.element.current$live.density[ix]
    df$strain.class = evo.element.current$class[ix]

    ix = match(ids, evo.element.10y$element.id)
    df$substitute.count.10y = evo.element.10y$fixed.count[ix]
    df$substitute.density.10y = evo.element.10y$fixed.density[ix]
    df$history.class.10y = evo.element.10y$fate[ix]

    ix = match(ids, evo.element.host.10y$element.id)
    df$history.host.class.10y = gsub("core", "host", evo.element.host.10y$host.fate[ix])

    ix = match(df$element.id, pop$element.id)
    df$pop.class = pop$pclass[ix]
    df$host.pearson = pop$pearson[ix]
    df$prevalence = pop$subject.ratio[ix]

    save.table(df, paste(odir, "/elements.txt", sep=""))
}
