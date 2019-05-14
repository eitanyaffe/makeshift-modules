make.segments=function(ifn,ofn)
{
    segments = load.table(ifn)
    segments$cluster = segments$set
    fields = c("type", "cluster", "contig", "start", "end")
    result = segments[,fields]
    save.table(result, ofn)
}

set.fends=function(ifn.sets, ifn.fends, ofn)
{
    sets = load.table(ifn.sets)
    fends = load.table(ifn.fends)
    tt = table(fends$cluster)
    ix = match(sets$set, names(tt))
    counts = ifelse(is.na(ix), 0, tt[ix])
    sets$fend.count = counts

    save.table(sets, ofn)
}

make.anchor.matrix=function(ifn.sets, ifn.mat, ifn.anchors,
    min.contacts, min.enrichment,
    separate.min.contacts, separate.max.enrichment,
    ofn)
{
    sets = load.table(ifn.sets)
    mat = load.table(ifn.mat)
    atable = load.table(ifn.anchors)
    anchors = sort(atable$set)

    element.ids = sets$set[sets$type == "element" & sets$fend.count>0]
    anchor.ids = sets$set[sets$type == "core" & sets$fend.count>0]
    result = NULL
    cat(sprintf("processing anchors, n=%d\n", length(anchors)))
    for (anchor.id in anchor.ids) {
        anchor = atable$set[match(anchor.id,atable$id)]
        amat = mat[mat[,1] == anchor.id,]
        amat$target = amat[,2]
        amat$type = sets$type[match(amat$target, sets$set)]
        amat = amat[amat$type == "element",]
        ix = match(element.ids, amat$target)
        if (any(is.na(ix)))
            stop("internal")
        df = data.frame(anchor=anchor, anchor.id=anchor.id, element.id=element.ids, cluster=element.ids)
        df$observed = amat$observed[ix]
        df$expected = amat$expected[ix]
        result = rbind(result, df)
    }
    result$score = ifelse(result$observed>0,log10(result$observed/result$expected),0)
    result$high.score = ifelse(result$observed>1,log10((result$observed+sqrt(result$observed))/result$expected),0)
    result$low.score = ifelse(result$observed>1,log10((result$observed-sqrt(result$observed))/result$expected),0)
    result$type = ifelse(result$score >= min.enrichment & result$observed >= min.contacts, "connected",
        ifelse(result$score <= separate.max.enrichment & result$expected*10^separate.max.enrichment >= separate.min.contacts, "separated", "unknown"))

    cat(sprintf("number of elements with fends: %d\n", length(unique(result$element.id))))
    cat(sprintf("association breakdown:\n"))
    cat(sprintf(" unknown: %d\n", sum(result$type == "unknown")))
    cat(sprintf(" connected: %d\n", sum(result$type == "connected")))
    cat(sprintf(" separated: %d\n", sum(result$type == "separated")))

    save.table(result, ofn)
}

anchor.elements=function(ifn.anchor.order, ifn.matrix, ifn.means, ofn)
{
    atable = load.table(ifn.anchor.order)
    ea = load.table(ifn.matrix)
    means = load.table(ifn.means)
    anchors = sort(unique(ea$anchor))

    ea = ea[ea$type == "connected",]

    result = NULL
    for (anchor in anchors) {
        anchor.id = atable$id[match(anchor,atable$set)]
        e.major = means[means$cluster == anchor.id,-(1:2)]
        if (!any(ea$anchor == anchor)) {
            next
        }
        clusters = ea$cluster[ea$anchor == anchor]
        ix = match(clusters, means$cluster)
        if (any(is.na(ix)))
            stop("internal")
        e.minors = means[ix,-(1:2)]
        cc = cor(t(e.major), t(e.minors))
        cc[is.na(cc) | !is.finite(cc)] = -1
        df = data.frame(anchor=anchor, anchor.id=anchor.id, cluster=clusters, round(t(cc),4))
        names(df)[4] = "pearson"
        df$major = df$cluster == anchor
        df = df[order(df$pearson),]
        result = rbind(result, df)
    }
    save.table(result, ofn)
}
