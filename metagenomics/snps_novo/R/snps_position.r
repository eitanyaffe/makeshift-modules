bin.pos=function(ifn.snps, ifn.contigs, ofn)
{
    snps = load.table(ifn.snps)
    contigs = load.table(ifn.contigs)
    snps = snps[is.element(snps$contig, contigs$contig),]
    result = cbind(data.frame(bin=contigs$bin[match(snps$contig, contigs$contig)], snps))

    result=result[result$fixed_count>1 | result$segrating_count>1,]

    save.table(result, ofn)
}
