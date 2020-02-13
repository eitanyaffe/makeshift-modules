compute.cores=function(
    ifn.genes, ifn.ref, ifn.ga, ifn.checkm, anchor.field,
    identity.threshold, min.core.percent, min.complete, max.contam,
    ofn.core.table, ofn.core.base.table, ofn.core.genes)
{
    genes = load.table(ifn.genes)
    ref = load.table(ifn.ref)
    ga = load.table(ifn.ga)
    checkm = load.table(ifn.checkm)
    checkm$anchor = checkm[,1]

    ga$anchor = ga[,anchor.field]

    fc = field.count(ga, "gene")
    shared = fc$gene[fc$count>1]
    singles = fc$gene[fc$count==1]

    ######################################################################
    # singles
    ######################################################################

    df = genes[is.element(genes$gene, singles), c("gene", "contig")]
    df$anchor = ga$anchor[match(df$gene, ga$gene)]

    contigs = unique(df$contig)
    df$contig.index = match(df$contig, contigs)

    # add reference identity
    df$ref.key = paste(df$gene, df$anchor, sep=":")
    ref$ref.key = paste(ref$gene, ref$anchor, sep=":")
    ix = match(df$ref.key, ref$ref.key)
    df$ref.identity = ifelse(!is.na(ix), ref$identity[ix] * ref$coverage[ix], 0)

    # determine if core
    df$is.core = df$ref.identity > identity.threshold/100
    df$cs = cumsum(df$is.core)
    df$island.key = paste(df$contig.index, df$cs, sep="_")

    gene.cores = df[df$is.core,c("gene", "anchor")]

    fc = field.count(gene.cores, "anchor")
    core.table = data.frame(anchor=fc$anchor, gene.count=fc$count)

    # append checkm values
    ix = match(core.table$anchor,checkm$anchor)
    core.table$complete = checkm$Completeness[ix]
    core.table$contam = checkm$Contamination[ix]

    ga.non.shared = ga[is.element(ga$gene, singles),]
    fc = field.count(ga, "anchor")
    core.table$total.gene.count = fc$count[match(core.table$anchor,fc$anchor)]
    core.table$core.fraction = core.table$gene.count / core.table$total.gene.count
    core.table = core.table[order(as.numeric(core.table$anchor)),]
    core.table$large.core = core.table$core.fraction >= min.core.percent/100
    core.table$near.complete = core.table$complete >= min.complete & core.table$contam <= max.contam
    core.table$selected = core.table$large.core & core.table$near.complete

    # save all
    save.table(core.table, ofn.core.base.table)

    # limit to selected
    core.table = core.table[core.table$selected,]
    gene.cores = gene.cores[is.element(gene.cores$anchor,core.table$anchor),]
    save.table(core.table, ofn.core.table)
    save.table(gene.cores, ofn.core.genes)
}
