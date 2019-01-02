plot.poly=function(ifn.anchors, ifn.ca, assembly.dir, dataset, fdir)
{
    table = load.table(ifn.anchors)
    ca = load.table(ifn.ca)
    contigs = ca$contig[ca$anchor == ca$contig_anchor]
    anchor.ids = table$id

    ifn.poly = paste(assembly.dir, "/datasets/", dataset, "/map_F_10_40/poly_rate", sep="")
    poly = load.table(ifn.poly)

    ca = ca[ca$anchor == ca$contig_anchor,]
    ca$anchor.id = table$id[match(ca$anchor, table$set)]

    ix = match(ca$contig, poly$contig)
    ca$poly = poly$poly[ix]
    ca$coverage = poly$mean_coverage[ix]
    ca$length = poly$length[ix]
    s = split(ca,ca$anchor.id)

    poly.rate = sapply(s,function(x) { sum(x$poly) / sum(x$length) })
    coverage = sapply(s,function(x) { mean(x$coverage) })
    df = data.frame(anchor=names(s), poly.rate=poly.rate, coverage=coverage)
}
