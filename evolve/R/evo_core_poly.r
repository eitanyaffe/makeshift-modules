evo.core.poly=function(ifn, ifn.core.table, ifn.gene2core, ofn.poly, ofn.fixed)
{
    df = load.table(ifn)
    cores = load.table(ifn.core.table)
    gene2core = load.table(ifn.gene2core)

    fields = c("effective.length", "live.count", "fixed.count", "cov")
    gene2core[,fields] = df[match(gene2core$gene, df$gene),fields]

    process.field=function(field, ofn) {
        result = NULL
        breaks = c(-1:9,max(c(10,gene2core[,field])))
        names = c(0:9,">=10")
        for (anchor in cores$anchor) {
            xx = gene2core[gene2core$anchor == anchor,]
            tt = table(cut(xx[,field], breaks=breaks, include.lowest=T))
            names(tt) = names
            result = rbind(result, as.data.frame(cbind(anchor=anchor, t(tt))))
        }
        save.table(result, ofn)
    }
    process.field(field="live.count", ofn=ofn.poly)
    process.field(field="fixed.count", ofn=ofn.fixed)
}
