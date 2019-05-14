get.temporal.table=function(tables, ids, bins, field="count")
{
    N = length(tables)
    cat(sprintf("uniting %d profiles\n", N))
    table = data.frame(bin=bins)
    for (i in 1:N) {
        p = load.table(tables[i])
        if (!setequal(bins, p$bin))
            stop("missing bins")
        p$value = p[,field]
        id = ids[i]
        table[[id]] = p$value[match(bins, p$bin)]
    }
    table
}

get.total.table=function(stats, ids)
{
    result = NULL
    for (i in 1:length(ids)) {
        df = load.table(stats[i])
        result = rbind(result, data.frame(id=ids[i], total.count=df$total_count, binned.count=df$binned_count))
    }
    result
}

compute.matrix=function(ifn, min.detected, cr.dir, ids, ofn.total, ofn.observed, ofn.expected, ofn.norm, ofn.min.score)
{
    df = load.table(ifn)
    tables = paste(cr.dir, "/libs/", ids, "/table", sep="")
    stats = paste(cr.dir, "/libs/", ids, "/stats", sep="")

    observed.table = get.temporal.table(tables=tables, ids=ids, bins=df$bin, field="count")
    save.table(observed.table, ofn.observed)

    total.table = get.total.table(stats, ids)
    save.table(total.table, ofn.total)

    min.score = 1

    # uniform expected values
    expected.table = data.frame(bin=df$bin)
    total.length = sum(df$length)
    for (i in 2:dim(observed.table)[2]) {
        id = names(observed.table)[i]
        # total.reads = sum(observed.table[,i])
        total.reads = total.table$total.count[match(id,total.table$id)]
        expected = total.reads * (df$length / total.length)
        expected.table = cbind(expected.table, expected)
        min.score = min(min.score, min.detected/min(expected))
    }
    names(expected.table) = names(observed.table)
    save.table(expected.table, ofn.expected)

    save.table(data.frame(score=min.score), ofn.min.score)

    # uniform expected values
    scores = (observed.table[,-1]) / (expected.table[,-1])
    scores[scores<min.score] = min.score

    norm.table = data.frame(bin=df$bin, scores)
    save.table(norm.table, ofn.norm)
}
