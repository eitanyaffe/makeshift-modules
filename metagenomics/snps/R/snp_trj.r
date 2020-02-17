extract.trj=function(ifn.pos2gene, ifn.gene2contig, ifn.contig2bin, ifn.bins, prefix, ofn.base, ofn.set, ofn.positions)
{
    df = load.table(ifn.pos2gene)
    gene2contig = load.table(ifn.gene2contig)
    contig2bin = load.table(ifn.contig2bin)
    bins = load.table(ifn.bins)

    # limit to fixated sites
    df = df[df$fix,]

    # append bin at start
    gene2contig$bin = contig2bin$bin[match(gene2contig$contig, contig2bin$contig)]
    df = cbind(data.frame(bin=gene2contig$bin[match(df$gene, gene2contig$gene)]), df)

    result = list(base_nt=NULL, set_nt=NULL)
    for (nt in c("A", "C", "G", "T")) {
        trj.nt = load.table(paste(prefix, ".", nt, sep=""))
        trj.nt.key = paste(trj.nt$contig, trj.nt$coord)
        for (type in c("base_nt", "set_nt")) {
            df.nt = df[df[,type] == nt,]
            df.nt$key = paste(df.nt$contig, df.nt$coord)
            ix = match(df.nt$key, trj.nt.key)
            if (any(is.na(ix)))
                stop("internal")
            result.nt = trj.nt[ix,]
            result[[type]] = rbind(result[[type]], result.nt)
        }
    }
    save.table(result[["base_nt"]], ofn.base)
    save.table(result[["set_nt"]], ofn.set)
    save.table(df, ofn.positions)
}
