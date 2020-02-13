compute.elements=function(
    ifn.genes, ifn.ga, anchor.field,
    ifn.core.table, ifn.core.genes,
    ofn.element.table, ofn.ge, ofn.ge.shared, ofn.ea)
{
    genes = load.table(ifn.genes)
    ga = load.table(ifn.ga)
    core.genes = load.table(ifn.core.genes)
    core.table = load.table(ifn.core.table)

    ga$anchor = ga[,anchor.field]

    # limit to selected cores
    ga = ga[is.element(ga$anchor, core.table$anchor),]

    fc = field.count(ga, "gene")
    shared = fc$gene[fc$count>1]
    singles = fc$gene[fc$count==1]

    ######################################################################
    # shared
    ######################################################################

    if (any(fc$count>1)) {
        ge.shared = genes[is.element(genes$gene, shared),]
        contig.shared = unique(ge.shared$contig)
        ge.shared$element = match(ge.shared$contig, contig.shared)
        ge.shared = ge.shared[,c("gene", "element")]
        ge.shared$type = "shared"
        shared.max = max(ge.shared$element)
    } else {
        shared.max = 0
        ge.shared = NULL
    }

    ######################################################################
    # singles
    ######################################################################

    df = genes[is.element(genes$gene, singles), c("gene", "contig")]
    df$anchor = ga$anchor[match(df$gene, ga$gene)]

    contigs = unique(df$contig)
    df$contig.index = match(df$contig, contigs)

    # determine if core
    df$is.core = is.element(df$gene, core.genes$gene)
    df$cs = cumsum(df$is.core)
    df$island.key = paste(df$contig.index, df$cs, sep="_")

    # define element per non-core contig island
    df.acc = df[!df$is.core, c("gene", "anchor", "island.key")]
    island.keys = unique(df.acc$island.key)
    ge.single = data.frame(gene=df.acc$gene, element.base=match(df.acc$island.key, island.keys))
    ge.single$element = ge.single$element.base + shared.max
    ge.single = ge.single[,c("gene", "element")]
    ge.single$type = "single"

    ######################################################################
    # element table
    ######################################################################

    ge = rbind(ge.shared, ge.single)
    fc = field.count(ge, "element")
    element.table = data.frame(element=fc$element, gene.count=fc$count)
    element.table$type = ge$type[match(element.table$element, ge$element)]

    ######################################################################
    # element-anchor table
    ######################################################################

    df = ga[is.element(ga$gene, ge$gene),]
    df$element = ge$element[match(df$gene,ge$gene)]
    ea = df[,c("element", "anchor")]
    ea = ea[!duplicated(ea),]

    ######################################################################
    # rename elements sorted by size
    ######################################################################

    element.table$element.id = paste("e", 1:dim(element.table)[1], sep="_")
    ea$element.id = element.table$element.id[match(ea$element, element.table$element)]
    ge$element.id = element.table$element.id[match(ge$element, element.table$element)]

    ea = ea[is.element(ea$anchor, core.table$anchor),]

    save.table(ge[,c("gene", "element.id")], ofn.ge)
    save.table(ea[,c("element.id", "anchor")], ofn.ea)
    save.table(element.table[,c("element.id", "type", "gene.count")], ofn.element.table)

    ge.shared = ge[ge$type == "shared",]
    save.table(ge.shared[,c("gene", "element.id")], ofn.ge.shared)
}

