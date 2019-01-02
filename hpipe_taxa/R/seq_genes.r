seq.genes=function(ifn.unique, ifn.genes, anchor2ref.dir, ref2anchor.dir, odir)
{
    table = load.table(ifn.unique)
    gene.table = load.table(ifn.genes)

    for (i in 1:dim(table)[1]) {
        anchor = table$anchor[i]
        anchor.id = table$anchor.id[i]
        ref = table$ref[i]
        df = read.delim(paste(anchor2ref.dir, "/", anchor, "_", ref, "/src_table", sep=""))
        df$bin = floor(df$coord/binsize) + 1
    }
}
