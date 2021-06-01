libs.select=function(ifn.input, ifn.input.field, ifn.libs,
                     ifn.reads.count, ifn.reads.yield, ifn.bps.count, ifn.bps.yield,
                     min.read.count.m, min.trimmo.bp.yield, min.dup.read.yield, min.deconseq.read.yield,
                     ofn.selected, ofn.missing)
{
    df.all = load.table(ifn.input)
    df.libs = load.table(ifn.libs)
    read.count = load.table(ifn.reads.count)
    bp.count = load.table(ifn.bps.count)
    read.yield = load.table(ifn.reads.yield)
    bp.yield = load.table(ifn.bps.yield)

    # read count table
    count.ids = read.count[read.count$final >= 10^6 * min.read.count.m,"id"]

    # read yield table
    dup.ids = read.yield[read.yield$duplicate >= min.dup.read.yield,"id"]
    human.ids = read.yield[read.yield$deconseq >= min.deconseq.read.yield,"id"]

    # bp yield table
    trimmo.ids = bp.yield[bp.yield$trimmomatic >= min.trimmo.bp.yield,"id"]

    # selected ids must match all criteria
    intersect.sets=function(sets) {
        rr = sets[[1]]
        for (i in 1:length(sets))
            rr = intersect(rr, sets[[i]])
        rr
    }
    ids = intersect.sets(list(count.ids, dup.ids, human.ids, trimmo.ids))
    cat(sprintf("number of libraries filtered for quality: %d\n", dim(df.libs)[1] - length(ids)))
    
    rrs = data.frame(id=ids)
    save.table(rrs, ofn.selected)

    rrm = data.frame(id=setdiff(df.all[,ifn.input.field], ids))
    rrm$sequenced = is.element(rrm$id, read.count$id)
    rrm$read.count.ok = is.element(rrm$id, count.ids)
    rrm$dup.ok = is.element(rrm$id, dup.ids)
    rrm$human.ok = is.element(rrm$id, human.ids)
    rrm$trimmo.ok = is.element(rrm$id, trimmo.ids)
    save.table(rrm, ofn.missing)

    cat(sprintf("total number of missing libraries: %d\n", dim(rrm)[1]))
}
