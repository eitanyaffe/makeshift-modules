snp.table.genes=function(
    ifn.ga, ifn.genes, ifn.contigs,
    edge.margin, idir, idir.ref,
    min.count, min.live.freq, max.live.freq, fixed.freq,
    ofn.table, ofn.subs, ofn.poly)
{
    ga = load.table(ifn.ga)
    genes.df = load.table(ifn.genes)
    contigs.df = load.table(ifn.contigs)

    genes.df = genes.df[is.element(genes.df$gene, ga$gene),]
    contigs.df = contigs.df[is.element(contigs.df$contig, genes.df$contig),]

    result = NULL
    cat(sprintf("total contig count: %d\n", dim(contigs.df)[1]))
    cat(sprintf("total gene count: %d\n", dim(genes.df)[1]))

    result.subs = NULL
    result.poly = NULL
    for (contig in contigs.df$contig) {
        contig.length = contigs.df$length[match(contig,contigs.df$contig)]
        if (!any(genes.df$contig == contig))
            next
        cgenes = genes.df[genes.df$contig == contig,]

        # trim start and end of genes
        cgenes$trim.start = pmax(edge.margin, cgenes$start)
        cgenes$trim.end = pmin(contig.length-edge.margin, cgenes$end)
        cgenes$trim.length = pmax(0, cgenes$trim.end - cgenes$trim.start)

        # coverage
        cov.ifn = paste(idir, "/", contig, ".cov", sep="")
        cov.vec = read.delim(cov.ifn, header=F)[,1]

        # poly
        poly.ifn = paste(idir, "/", contig, ".poly", sep="")
        poly = read.delim(poly.ifn)
        poly = poly[poly$type == "snp" & poly$count >= min.count,]

        # mask poly if reference library contains snps
        if (!grepl("^NA", idir.ref)) {
            poly.ref.ifn = paste(idir.ref, "/", contig, ".poly", sep="")
            poly.ref = read.delim(poly.ref.ifn)
            poly.ref = poly.ref[poly.ref$type == "snp" & poly.ref$count >= min.count,]
            mask.coords = poly.ref$coord[poly.ref$percent >= 100*fixed.freq]
            poly = poly[!is.element(poly$coord, mask.coords),]
        }

        for (i in 1:dim(cgenes)[1]) {
            gene = cgenes$gene[i]
            start = cgenes$trim.start[i]
            end = cgenes$trim.end[i]
            effective.length = cgenes$trim.length[i]

            cov = if (effective.length > 0) median(cov.vec[start:end]) else 0
            ix = poly$coord >= start & poly$coord <= end
            if (effective.length > 0 && any(ix)) {
                gpoly = poly[ix,]
                ilive = gpoly$percent >= 100*min.live.freq & gpoly$percent <= 100*max.live.freq
                ifixed = gpoly$percent >= 100*fixed.freq
                live = sum(ilive)
                fixed = sum(ifixed)

                if (any(ilive)) {
                    result.poly = rbind(result.poly, data.frame(gene=gene, contig=contig, coord=gpoly$coord[ilive], nt=gpoly$sequence[ilive]))
                }
                if (any(ifixed)) {
                    result.subs = rbind(result.subs, data.frame(gene=gene, contig=contig, coord=gpoly$coord[ifixed], nt=gpoly$sequence[ifixed]))
                }
            } else {
                live = 0
                fixed = 0
            }
            df = data.frame(gene=gene, effective.length=effective.length, live.count=live, fixed.count=fixed, cov=cov)
            result = rbind(result, df)
        }
        if (dim(result)[1] %% 1000 == 0)
            cat(sprintf("count: %d\n", dim(result)[1]))
    }

    save.table(result, ofn.table)
    save.table(result.subs, ofn.subs)
    save.table(result.poly, ofn.poly)
}
