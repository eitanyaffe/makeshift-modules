rna.compare=function(ifn.bins, ifn.genes, idir, lib.ifn, libdef.ifn, set1, set2, ofn)
{
    genes = load.table(ifn.genes)
    bins = load.table(ifn.bins)
    bins = bins[bins$class == "host",]

    lib.df = load.table(lib.ifn)
    libdef.df = load.table(libdef.ifn)

    ids1 = lib.df$Meas_ID[match(libdef.df$sample[libdef.df$group == set1], lib.df$Samp_ID)]
    ids2 = lib.df$Meas_ID[match(libdef.df$sample[libdef.df$group == set2], lib.df$Samp_ID)]

    if ((length(ids1) == 0 || length(ids2) == 0)) {
        stop("no ids found")
    }

    result = NULL
    for (bin in bins$bin) {
        df = load.table(paste(idir, "/", bin, sep=""))
        ll = genes$length[match(df$gene,genes$gene)]
        r1 = rowSums(df[,is.element(colnames(df), ids1)])
        r2 = rowSums(df[,is.element(colnames(df), ids2)])
        result = rbind(result, data.frame(bin=bin, gene=df$gene, length=ll, count1=r1, count2=r2))
    }
    save.table(result, ofn)
}
