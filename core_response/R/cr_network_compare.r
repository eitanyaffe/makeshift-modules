network.compare=function(ifn.map1, ifn.map2, min.support, ofn.map, ofn.anchors)
{
    map1 = load.table(ifn.map1)
    map2 = load.table(ifn.map2)

    mm = merge(map1, map2, by=c("anchor", "cluster"))
    map = data.frame(
        anchor=mm$anchor, anchor.id=mm$anchor.id.x, element.id=mm$cluster, cluster=mm$cluster,
        observed1=mm$observed.x, expected1=mm$expected.x, score1=mm$score.x, sd.score1=abs(mm$high.score.x-mm$low.score.x)/2, type1=mm$type.x,
        observed2=mm$observed.y, expected2=mm$expected.y, raw.score2=mm$score.y, sd.score2=abs(mm$high.score.y-mm$low.score.y)/2, type2=mm$type.y)

    result.anchors = NULL
    anchors = sort(unique(mm$anchor))
    s = split(map, map$anchor)
    for (i in 1:length(s)) {
        anchor = names(s)[i]
        imap = s[[i]]
        ix = imap$score1 > 0 & imap$raw.score2 > 0
        support = sum(ix)
        score.factor = 1
        if (support >= min.support) {
            imap = imap[ix,]
            fit = lm(imap$raw.score2 ~ 0 + imap$score1)
            score.factor = fit$coefficient
            names(score.factor) = NULL
        }
        result.anchors = rbind(result.anchors, data.frame(anchor=anchor, score.factor=score.factor, support=support))
    }
    map$score2 = map$raw.score2 / result.anchors$score.factor[match(map$anchor, result.anchors$anchor)]

    map$sd.score1
    save.table(result.anchors, ofn.anchors)
    save.table(map, ofn.map)
}
