compute.anchor.order=function(ifn.segments, ifn.median, ifn.detection, class.count, max.height, type, ofn, base.ids)
{
    df = load.table(ifn.segments)
    anchors = unique(df$set[df$type == "core"])

    all.patterns = load.table(ifn.median)

    min.score = log10(load.table(ifn.detection)[1,1])
    min.drop = -2

    xx = as.matrix(all.patterns[match(anchors, all.patterns$cluster),-(1:2)])
    detected = as.matrix(log10(xx) > min.score)
    base = rowSums(xx[,base.ids]) / length(base.ids)
    patterns = ifelse(detected, log10(xx / base), min.drop)
    M = dim(patterns)[2]

    cc = cor(t(patterns))
    cc[is.na(cc)] = -1
    hh = hclust(as.dist(1-cc), method="average")

    ct = switch(type,
        count=cutree(hh, k=class.count),
        height=cutree(hh, h=max.height),
        stop(paste("unknown type")))
    result = data.frame(anchor=anchors, class=ct)
    result = result[hh$order,]

    cat(sprintf("number of classes: %d\n", length(unique(result$class))))
    save.table(result, ofn)
}
