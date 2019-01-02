seq.bin=function(ifn.unique, ifn.contigs, length, binsize, anchor2ref.dir, ref2anchor.dir, odir)
{
    table = load.table(ifn.unique)
    contig.table = load.table(ifn.contigs)

    for (i in 1:dim(table)[1]) {
        anchor = table$anchor[i]
        anchor.id = table$anchor.id[i]
        ref = table$ref[i]
        df = read.delim(paste(anchor2ref.dir, "/", anchor, "_", ref, "/src_table", sep=""))
        df$bin = floor((df$coord-1)/binsize)+1
        df$key = paste(df$contig, df$bin, sep="_")
        ss = sapply(split(df$edit_distance, df$key), function(x)
        {
            if (all(x==-1)) {
                0
            } else {
                x = x[x!=-1]
                100 - 100*mean(x)/length
            }
        })
        keys = unique(df$key)
        ix = match(keys, df$key)
        result = data.frame(anchor.id=anchor.id, contig=df$contig[ix], bin=df$bin[ix], identity=ss[match(keys, names(ss))])
        result = result[order(result$contig,result$bin),]
        result$start = (result$bin-1) * binsize + 1
        result$end = result$bin * binsize
        contig.lengths = contig.table$length[match(result$contig, contig.table$contig)]
        result$end = ifelse(result$end > contig.lengths, contig.lengths, result$end)

        ofn = paste(odir, "/", anchor.id, sep="")
        save.table(result, ofn)
    }
}
