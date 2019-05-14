snp.table.elements=function(
    ifn, ifn.core.table, ifn.element.table, ifn.gene2element, ifn.gene2core,
    detection.cov, read.length,
    ofn.elements, ofn.cores)
{
    df = load.table(ifn)
    cores = load.table(ifn.core.table)
    elements = load.table(ifn.element.table)
    gene2element = load.table(ifn.gene2element)
    gene2core = load.table(ifn.gene2core)

    if (!all(is.element(gene2core$gene, df$gene)))
        stop("internal error")
    if (!all(is.element(gene2element$gene, df$gene)))
        stop("internal error")

    fields = c("effective.length", "live.count", "fixed.count", "cov")
    gene2element[,fields] = df[match(gene2element$gene, df$gene),fields]
    gene2core[,fields] = df[match(gene2core$gene, df$gene),fields]

    append.cov.sd=function(x) {
        x$read.count = x$cov * (x$effective.length/read.length)
        x$cov.sd = ifelse(x$effective.length>0, sqrt(x$read.count) * (read.length/x$effective.length), 0)
        x
    }
    gene2element = append.cov.sd(gene2element)
    gene2core = append.cov.sd(gene2core)

    get.value=function(keys, ss, func) {
        sss = sapply(ss, func)
        sss[match(keys, names(sss))]
    }

    get.density=function(count, length) {
        ifelse(count > 0, count/length, (count+1)/length)
    }

    get.table=function(gene.map, group.table, group.field) {
        result = group.table
        ss = split(gene.map, gene.map[,group.field])

        # cov
        result$mean.cov = get.value(result[,group.field], ss, function(x) { mean(x$cov) })
        result$median.cov = get.value(result[,group.field], ss, function(x) { median(x$cov) })
        result$detected.fraction = get.value(result[,group.field], ss, function(x) { sum(x$cov>=detection.cov) }) / result$gene.count

        # max gene coverage z-score
        result$max.zscore = get.value(result[,group.field], ss, function(x) {
            x$zscore = ifelse(x$cov.sd > 0, abs(x$cov - median(x$cov)) / x$cov.sd, 0)
            max(x$zscore)
        })
        result$sd.zscore = get.value(result[,group.field], ss, function(x) {
            x$zscore = ifelse(x$cov.sd > 0, abs(x$cov - median(x$cov)) / x$cov.sd, 0)
            ifelse(dim(x)[1] > 1, sd(x$zscore), 0)
        })

        # snps
        result$effective.length = get.value(result[,group.field], ss, function(x) { sum(x$effective.length) })
        result$live.count = get.value(result[,group.field], ss, function(x) { sum(x$live.count) })
        result$fixed.count = get.value(result[,group.field], ss, function(x) { sum(x$fixed.count) })
        result$live.density = get.density(result$live.count, result$effective.length)
        result$fixed.density = get.density(result$fixed.count, result$effective.length)

        result
    }

    result.cores = get.table(gene.map=gene2core, group.table=cores, group.field="anchor")
    save.table(result.cores, ofn.cores)

    result.elements = get.table(gene.map=gene2element, group.table=elements, group.field="element.id")
    save.table(result.elements, ofn.elements)
}
