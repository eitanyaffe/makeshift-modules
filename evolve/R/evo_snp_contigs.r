snp.table.contigs=function(anchor.ifn, ifn, idir, idir.ref, edge.margin,
    min.count, min.live.freq, max.live.freq, fixed.freq, ofn)
{
    anchor.table = load.table(anchor.ifn)
    df = load.table(ifn)
    df = df[df$selected,]
    genomes = sort(unique(df$genome))

    result = NULL
    cat(sprintf("number of genomes: %d\n", length(genomes)))
    for (genome in genomes) {
        contigs = df$contig[df$genome == genome]
        # cat(sprintf("genome: %d, contig count: %d\n", genome, length(contigs)))

        poly.live.count = 0
        poly.fixed.count = 0
        poly.length = 0
        for (contig in contigs) {
            contig.length = df$length[match(contig,df$contig)]
            poly.ifn = paste(idir, "/", contig, ".poly", sep="")
            poly = read.delim(poly.ifn)
            poly = poly[poly$coord > edge.margin & poly$coord < (contig.length - edge.margin),]
            if (dim(poly)[1] == 0)
                next

            # mask if reference library is deviates from assembly
            if (!grepl("^NA", idir.ref)) {
                poly.ref.ifn = paste(idir.ref, "/", contig, ".poly", sep="")
                poly.ref = read.delim(poly.ref.ifn)
                mask.coords = poly.ref$coord[poly.ref$percent>100*fixed.freq]
                poly = poly[!is.element(poly$coord, mask.coords),]
            }

            poly.live.count = poly.live.count +
                sum(poly$type == "snp" & poly$count >= min.count & poly$percent >= 100*min.live.freq & poly$percent <= 100*max.live.freq)
            poly.fixed.count = poly.fixed.count +
                sum(poly$type == "snp" & poly$count >= min.count & poly$percent >= 100*fixed.freq)
            poly.length = poly.length + contig.length - 2*edge.margin
        }
        if (poly.length == 0)
            next
        live.snp.freq = poly.live.count/poly.length
        fixed.snp.freq = poly.fixed.count/poly.length
        xcov = median(df$cov.median[df$genome == genome])
        result = rbind(result, data.frame(genome=genome, xcov=xcov,
            live.snp.count=poly.live.count, live.snp.freq=live.snp.freq,
            fixed.snp.count=poly.fixed.count, fixed.snp.freq=fixed.snp.freq, length=poly.length))
    }
    result$anchor.id = anchor.table$id[match(result$genome, anchor.table$set)]
   save.table(result, ofn)
}
