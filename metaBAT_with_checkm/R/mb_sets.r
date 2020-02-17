create.sets=function(ifn.cg, ifn.ce, ifn.contigs, ofn.sets, ofn.segments)
{
    cg = load.table(ifn.cg)
    ce = load.table(ifn.ce)
    contigs = load.table(ifn.contigs)

    cg$type = "anchor"
    ce$type = "element"

    cg$bin = paste("b", cg$bin, sep="")
    ce$bin = paste("e", ce$bin, sep="")

    df = rbind(cg, ce)
    df$set = df$bin
    df$start = 1
    df$end = contigs$length[match(df$contig,contigs$contig)]

    result = df[,c("set", "type", "contig", "start", "end")]
    save.table(result, ofn.segments)

    sets = unique(result$set)
    ss.length = sapply(split(result$end,result$set), sum)
    ss.count = sapply(split(result$end,result$set), length)
    result.sets = data.frame(set=sets)
    result.sets$type = result$type[match(result.sets$set,result$set)]
    result.sets$segment.count = ss.count[match(result.sets$set,names(ss.count))]
    result.sets$length = ss.length[match(result.sets$set,names(ss.length))]
    save.table(result.sets, ofn.sets)
}
