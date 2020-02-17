bin.summary=function(ifn.bins, ifn.genes, ifn.gene2bin, ifn.mat, ofn.genes, odir)
{
    bins = load.table(ifn.bins)
    gene2bin = load.table(ifn.gene2bin)
    mat = load.table(ifn.mat)
    genes.df = load.table(ifn.genes)

    # limit to hosts
    bins = bins[bins$class == "host",]

    for (bin in bins$bin) {
        genes = gene2bin$gene[gene2bin$bin == bin]
        mat.bin = mat[is.element(mat$gene,genes),]
        ofn = paste(odir, "/", bin, sep="")
        save.table(mat.bin, ofn)
    }

    genes.df = genes.df[is.element(genes.df$gene,gene2bin$gene),]
    save.table(genes.df, ofn.genes)
}
