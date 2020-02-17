bin.table=function(ifn.genes, ifn.bins, ifn.contigs, min.cov, ofn)
{
    genes = load.table(ifn.genes)
    bins = load.table(ifn.bins)
    contigs = load.table(ifn.contigs)

    genes$bin = contigs$bin[match(genes$contig, contigs$contig)]
    ss = split(genes, genes$bin)

    get.value=function(keys, ss, func) {
        sss = sapply(ss, func)
        sss[match(keys, names(sss))]
    }

    get.density=function(count, length) {
        ifelse(count > 0, count/length, (count+1)/length)
    }

    result = bins[,c("bin", "contig.count", "class")]
    result$gene.count = get.value(result$bin, ss, function(x) {dim(x)[1] })
    result$effective.length = get.value(result$bin, ss, function(x) { sum(x$length) })

    result$base.cov = get.value(result$bin, ss, function(x) { median(x$base_cov) })
    result$set.cov = get.value(result$bin, ss, function(x) { median(x$set_cov) })

    result$base.detect.fraction = get.value(result$bin, ss, function(x) { sum(x$base_cov>=min.cov) }) / result$gene.count
    result$set.detect.fraction = get.value(result$bin, ss, function(x) { sum(x$set_cov>=min.cov) }) / result$gene.count

    result$base.live.count = get.value(result$bin, ss, function(x) { sum(x$live_base) })
    result$base.live.density = get.density(result$base.live.count, result$effective.length)

    result$set.live.count = get.value(result$bin, ss, function(x) { sum(x$live_set) })
    result$set.live.density = get.density(result$set.live.count, result$effective.length)

    result$fix.count = get.value(result$bin, ss, function(x) { sum(x$fix) })
    result$fix.density = get.density(result$fix.count, result$effective.length)

    save.table(result, ofn)

}
