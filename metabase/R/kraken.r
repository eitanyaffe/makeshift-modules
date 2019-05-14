kraken.merge=function(idir, kraken.ver, order.ifn, ids, odir)
{
    order.table = load.table(order.ifn)
    sorted.ids = ids[order(order.table$order[match(ids,order.table$id)])]
    ll = list()
    ranks = NULL
    taxa2name = NULL
    for (id in ids) {
        df = load.table(paste(idir, "/libs/", id, "/kraken/", kraken.ver, "/report", sep=""), header=F)
        names(df) = c("percent", "count.clade", "count.taxa", "rank", "taxa.id", "name")
        taxa2name = rbind(taxa2name, data.frame(taxa.id=df$taxa.id, name=df$name))
        ll[[id]] = df
    }
    taxa2name = taxa2name[!duplicated(taxa2name$taxa.id),]

    system(paste("mkdir -p", odir))
    ranks = sort(unique(ll[[1]]$rank))
    for (rank in ranks) {
        cc = unlist(strsplit(rank, ""))
        if (any(suppressWarnings(!is.na(as.numeric(cc)))))
            next

        # get all tax.ids
        taxa.ids = NULL
        for (id in sorted.ids) {
            df = ll[[id]]
            df = df[df$rank == rank,]
            taxa.ids = unique(c(taxa.ids, df$taxa.id))
        }

        # get percent
        result = data.frame(taxa.id=taxa.ids, name=taxa2name$name[match(taxa.ids,taxa2name$taxa.id)])
        for (id in sorted.ids) {
            df = ll[[id]]
            df = df[df$rank == rank,]
            ix = match(taxa.ids, df$taxa.id)
            result[[id]] = ifelse(!is.na(ix), df$percent[ix], 0)
        }
        result = result[rowSums(result[,-(1:2)]) > 0,]
        result = result[order(-rowSums(result[,-(1:2)])),]
        result$name = trimws(result$name)

        ofn = paste(odir, "/table_", rank, ".txt", sep="")
        save.table(result, ofn)
    }
}
