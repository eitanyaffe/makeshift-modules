snp.table.basic=function(base.idir, ids, ofn)
{
    result = NULL
    for (id in ids) {
        ifn = paste(base.idir, "/", id, "/vari/out_snp_full.tab", sep="")
        df = load.table(ifn)
        if (is.null(result)) {
            result = df
            next
        }

        ix = match(paste(result$contig,result$coord),paste(df$contig,df$coord))
        # add to entries that already exist
        for (nt in c("A", "C", "G", "T"))
            result[,nt] = result[,nt] + ifelse(!is.na(ix), df[,nt], 0)

        # add new entries
        ix = match(paste(df$contig,df$coord),paste(result$contig,result$coord))
        result = rbind(result, df[is.na(ix),])
    }
    save.table(result, ofn)
}
