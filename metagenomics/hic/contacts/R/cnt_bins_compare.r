cnt.maps.merge=function(ifn.map1, ifn.map2, ifn.contigs, ifn.bins, min.support, ofn.map, ofn.bins)
{
    contigs = load.table(ifn.contigs)
    bins = load.table(ifn.bins)

    get.length=function(map) {
    }
    map1 = load.table(ifn.map1)
    map2 = load.table(ifn.map2)

    mm = merge(map1, map2, by=c("host", "bin"))
    map = data.frame(host=mm$host, bin=mm$bin, type=mm$type.x, count1=mm$count.x, count2=mm$count.y)
    map$length = ifelse(map$type == "contig", contigs$length[match(map$bin, contigs$contig)], bins$length[match(map$bin, bins$bin)])

    map$score1 = map$count1 / map$length
    map$score2.raw = map$count2 / map$length

    result.hosts = NULL
    hosts = sort(unique(mm$host))
    s = split(map, map$host)
    for (i in 1:length(s)) {
        host = names(s)[i]
        imap = s[[i]]
        ix = imap$count1 > 10 & imap$count2 > 10
        support = sum(ix)
        score.factor = 1
        if (support >= min.support) {
            imap = imap[ix,]
            fit = lm(imap$score2 ~ 0 + imap$score1)
            score.factor = fit$coefficient
            names(score.factor) = NULL
        }
        result.hosts = rbind(result.hosts, data.frame(host=host, score.factor=score.factor, support=support))
    }
    map$score2 = map$score2.raw / result.hosts$score.factor[match(map$host, result.hosts$host)]

    save.table(result.hosts, ofn.bins)
    save.table(map, ofn.map)
}
