bin.order=function(ifn.bins, ifn.median, ifn.detection, class.count, max.height, type, ofn, base.ids)
{
    bins = load.table(ifn.bins)$bin
    all.patterns = load.table(ifn.median)

    min.score = log10(load.table(ifn.detection)[1,1])
    min.drop = -2

    xx = as.matrix(all.patterns[match(bins, all.patterns$bin),-(1:2)])
    detected = as.matrix(log10(xx) > min.score)

    if (length(base.ids) > 1) {
        base = rowSums(xx[,base.ids]) / length(base.ids)
    } else {
        base = xx[,base.ids]
    }

    patterns = ifelse(detected, log10(xx / base), min.drop)
    M = dim(patterns)[2]

    cc = cor(t(patterns))
    cc[is.na(cc)] = -1
    hh = hclust(as.dist(1-cc), method="average")

    ct = switch(type,
        count=cutree(hh, k=class.count),
        height=cutree(hh, h=max.height),
        stop(paste("unknown type")))
    bins = bins[hh$order]
    result = data.frame(bin=bins, class=ct)
    cat(sprintf("number of classes: %d\n", length(unique(result$class))))
    save.table(result, ofn)
}
