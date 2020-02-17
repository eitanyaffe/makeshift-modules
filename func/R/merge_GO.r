
merge.GO=function(ifn.genes, ifn.genes.ctrl, ifn.prefix, ifn.prefix.ctrl, ofn)
{
    genes = load.table(ifn.genes)
    genes.ctrl = load.table(ifn.genes.ctrl)

    ll = list(
#        AMR = load.table(paste(ifn.prefix, "_AMR", sep="")),
        func = load.table(paste(ifn.prefix, "_function", sep="")),
        process = load.table(paste(ifn.prefix, "_process", sep="")),
        component = load.table(paste(ifn.prefix, "_component", sep="")))

    ll.ctrl = list(
#        AMR = load.table(paste(ifn.prefix.ctrl, "_AMR", sep="")),
        func = load.table(paste(ifn.prefix.ctrl, "_function", sep="")),
        process = load.table(paste(ifn.prefix.ctrl, "_process", sep="")),
        component = load.table(paste(ifn.prefix.ctrl, "_component", sep="")))

    result = NULL
    for (i in 1:length(ll)) {
        name = names(ll)[i]
        table.ctrl = ll.ctrl[[i]]

        table = ll[[i]]

        m = merge(table, table.ctrl, by="id")
        df = data.frame(
            id=m$id, desc=m$desc.x,
            count=m$count.x, count.contig=m$contig_count.x,
            count.ctrl=m$count.y, count.contig.ctrl=m$contig_count.y)

        df$count.total = dim(genes)[1]
        df$count.ctrl.total = dim(genes.ctrl)[1]

        df$percent = df$count / df$count.total
        df$percent.ctrl = df$count.ctrl / df$count.ctrl.total
        df$enrichment = df$percent / df$percent.ctrl

        percent.minus = pmax(0,(df$count-sqrt(df$count))) / df$count.total
        percent.plus = (df$count+sqrt(df$count)) / df$count.total
        df$enrichment.minus = percent.minus / df$percent.ctrl
        df$enrichment.plus = percent.plus / df$percent.ctrl

        result = rbind(result, data.frame(type=name, df))
    }

    # append hyper-geometric p-value

    # white balls == matches

    x = result$count-1
    k = result$count.total
    m = result$count.ctrl
    n = result$count.ctrl.total - result$count.ctrl
    result$minus.log.p = -log10(phyper(q=x, k=k, m=m, n=n, lower.tail=F, log.p=F))

    save.table(result, ofn)
}
