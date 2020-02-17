get.temporal.table=function(tables, ids, contigs, field="count", baseline.idx=1)
{
    N = length(tables)

    cat(sprintf("uniting %d profiles\n", length(tables)))
    table = data.frame(contig=contigs)

    for (i in 1:N) {
        p = load.table(tables[i])
        p$value = p[,field]
        df = data.frame(contig=p$contig, value=p$value)
        id = ids[i]
        table[[id]] = p$value[match(contigs, p$contig)]
    }
    table
}

compute.contig.trj=function(ifn, min.detected, map.dir, ids, ofn.observed, ofn.expected, ofn.norm, ofn.min.score)
{
    contigs = load.table(ifn)
    ttables = paste(map.dir, "/", ids, "/coverage.table", sep="")

    observed.table = get.temporal.table(ttables, ids=ids, contigs=contigs$contig, field="count")
    save.table(observed.table, ofn.observed)

    min.score = 1

    # uniform expected values
    expected.table = data.frame(contig=contigs$contig)
    total.length = sum(contigs$length)
    for (i in 2:dim(observed.table)[2]) {
        total.reads = sum(observed.table[,i])
        expected = total.reads * (contigs$length / total.length)
        expected.table = cbind(expected.table, expected)
        min.score = min(min.score, min.detected/min(expected))
    }
    names(expected.table) = names(observed.table)
    save.table(expected.table, ofn.expected)

    save.table(data.frame(score=min.score), ofn.min.score)

    # uniform expected values
    scores = (observed.table[,-1]) / (expected.table[,-1])
    scores[scores<min.score] = min.score

    norm.table = data.frame(contig=contigs$contig, scores)
    save.table(norm.table, ofn.norm)
}
