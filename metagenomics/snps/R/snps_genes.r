get.cov.ids=function(base.idir, contig, ids)
{
    result = NULL
    for (id in ids) {
        idir = paste(base.idir, "/", id, "/output_full", sep="")
        ifn = paste(idir, "/", contig, ".cov", sep="")
        cov.vec = read.delim(ifn, header=F)[,1]
        result = if (is.null(result)) cov.vec else result + cov.vec
    }
    result
}

merge.tables=function(contig, df1, df2)
{
    df1 = df1[df1$contig == contig,]
    df2 = df2[df2$contig == contig,]
    coords = sort(unique(c(df1$coord, df2$coord)))
    if (length(coords) == 0)
        return (NULL)
    result = data.frame(contig=contig, coord=coords)
    ix1 = match(result$coord, df1$coord)
    ix2 = match(result$coord, df2$coord)
    for (nt in c("A", "C", "G", "T")) {
        result[,paste(nt, "n1", sep="")] = ifelse(!is.na(ix1), df1[ix1,nt], 0)
    }
    result$total1 = result$An1 + result$Cn1 + result$Gn1 + result$Tn1
    for (nt in c("A", "C", "G", "T")) {
        result[,paste(nt, "p1", sep="")] = result[,paste(nt, "n1", sep="")] / result$total1
    }

    for (nt in c("A", "C", "G", "T")) {
        result[,paste(nt, "n2", sep="")] = ifelse(!is.na(ix2), df2[ix2,nt], 0)
    }
    result$total2 = result$An2 + result$Cn2 + result$Gn2 + result$Tn2
    for (nt in c("A", "C", "G", "T")) {
        result[,paste(nt, "p2", sep="")] = result[,paste(nt, "n2", sep="")] / result$total2
    }

    result
}

get.live=function(gpoly, index, min.count, threshold)
{
    low.freq = min(threshold, 1-threshold)
    high.freq = max(threshold, 1-threshold)
    result = rep(F, dim(gpoly)[1])
    for (nt in c("A", "C", "G", "T")) {
        result.nt = (gpoly[,paste(nt, "n", index, sep="")] >= min.count) & (gpoly[,paste(nt, "p", index, sep="")] >= low.freq) & (gpoly[,paste(nt, "p", index, sep="")] <= high.freq)
        result = result | result.nt
    }
    result
}

get.fixed=function(gpoly, min.count, threshold)
{
    low.freq = min(threshold, 1-threshold)
    high.freq = max(threshold, 1-threshold)

    result = rep(F, dim(gpoly)[1])
    cov.sufficient = gpoly$total1 >= min.count & gpoly$total2 >= min.count
    for (nt in c("A", "C", "G", "T")) {
        fixed.up1 = gpoly[,paste(nt, "p1", sep="")] > high.freq
        fixed.down1 = gpoly[,paste(nt, "p1", sep="")] < low.freq
        fixed.up2 = gpoly[,paste(nt, "p2", sep="")] > high.freq
        fixed.down2 = gpoly[,paste(nt, "p2", sep="")] < low.freq
        fixed.nt = ((fixed.up1 & fixed.down2) | (fixed.down1 & fixed.up2)) & cov.sufficient
        result = result | fixed.nt
    }
    result
}

snp.table.genes=function(
    ifn.genes, ifn.contigs, ifn.snps.base, ifn.snps.set,
    idir, lib.ids,
    edge.margin, min.count, live.threshold, fixed.threshold,
    ofn.details, ofn.summary)
{
    genes.df = load.table(ifn.genes)
    contigs.df = load.table(ifn.contigs)

    base.snps = load.table(ifn.snps.base)
    set.snps = load.table(ifn.snps.set)
    contigs.df = contigs.df[is.element(contigs.df$contig, genes.df$contig),]

    result = NULL
    result.details = NULL
    cat(sprintf("total contig count: %d\n", dim(contigs.df)[1]))
    cat(sprintf("total gene count: %d\n", dim(genes.df)[1]))

    contig.progress.count = 0
    for (contig in contigs.df$contig) {
        contig.progress.count = contig.progress.count + 1
        contig.length = contigs.df$length[match(contig,contigs.df$contig)]
        if (!any(genes.df$contig == contig))
            next
        cgenes = genes.df[genes.df$contig == contig,]

        # trim start and end of genes with safety margin
        cgenes$trim.start = pmax(edge.margin, cgenes$start)
        cgenes$trim.end = pmin(contig.length-edge.margin, cgenes$end)
        cgenes$trim.length = pmax(0, cgenes$trim.end - cgenes$trim.start)

        # coverage
        cov.vec = get.cov.ids(base.idir=idir, contig=contig, ids=lib.ids)

        poly = merge.tables(contig, base.snps, set.snps)
        if (is.null(poly))
            next
        for (i in 1:dim(cgenes)[1]) {
            gene = cgenes$gene[i]
            start = cgenes$trim.start[i]
            end = cgenes$trim.end[i]
            effective.length = cgenes$trim.length[i]

            cov = if (effective.length > 0) median(cov.vec[start:end]) else 0
            ix = poly$coord >= start & poly$coord <= end
            if (effective.length > 0 && any(ix)) {
                gpoly = poly[ix,]

                # segregated snps
                gpoly$live.base = get.live(gpoly=gpoly, index=1, min.count=min.count, threshold=live.threshold)
                gpoly$live.set = get.live(gpoly=gpoly, index=2, min.count=min.count, threshold=live.threshold)
                gpoly$live.type =
                    ifelse(gpoly$live.base & gpoly$live.set, "both",
                           ifelse(gpoly$live.base, "base",
                                  ifelse(gpoly$live.set, "set", "none")))
                live.both.count = sum(gpoly$live.type == "both")
                live.base.count = sum(gpoly$live.type == "base")
                live.set.count = sum(gpoly$live.type == "set")

                # fixed snps
                gpoly$diverged = get.fixed(gpoly=gpoly, min.count=min.count, threshold=fixed.threshold)
                fixed.count = sum(gpoly$diverged)
            } else {
                live.both.count = 0
                live.base.count = 0
                live.set.count = 0
                fixed.count = 0
            }
            df = data.frame(gene=gene, effective.length=effective.length,
                live.both=live.both.count, live.base=live.base.count, live.set=live.set.count, fixed=fixed.count, cov=cov)
            result = rbind(result, df)

            if (any(gpoly$live.type != "none" | gpoly$diverged))
                result.details = rbind(result.details, data.frame(contig=contig, gene=gene, gpoly[gpoly$live.type != "none" | gpoly$diverged,]))
        }
        if (contig.progress.count %% 100 == 0)
            cat(sprintf("number of processed contigs: %d\n", contig.progress.count))
    }
    save.table(result, ofn.summary)
    save.table(result.details, ofn.details)
}
