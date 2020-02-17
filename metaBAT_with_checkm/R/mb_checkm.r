print.checkm=function(ifn, dummy)
{
    source('http://portal.nersc.gov/dna/RD/Metagenome_RD/MetaBAT/Files/benchmark.R')
    printPerf(list(calcPerfBySCG(ifn, removeStrain=F)), rec=c(seq(.1,.9,.1),.95), prec=c(seq(.6,.9,.1),.95,.99))
}

plot.checkm.summary=function(idir, ids, min.complete, max.contam, fdir)
{
    result = NULL
    for (id in ids) {
        ifn = paste(idir, "/output/", id, "/checkm/CheckM.txt", sep="")
        qa = load.table(ifn)
        count = sum(qa$Completeness >= min.complete & qa$Contamination <= max.contam)
        result = rbind(result, data.frame(id=id, count=count))
    }
    width = 2 + dim(result)[1] * 0.15
    fig.start(fdir=fdir, ofn=paste(fdir, "/checkm_summary.pdf", sep=""), type="pdf", width=width, height=5)
    par(mai=c(2,1,1,1))
    barplot(result$count, names.arg=result$id, border=NA, col="darkblue", las=2, cex.names=0.8)
    fig.end()
}

plot.checkm=function(ifn, min.complete, max.contam, fdir)
{
    # source('http://portal.nersc.gov/dna/RD/Metagenome_RD/MetaBAT/Files/benchmark.R')
    qa = load.table(ifn)
    # qa = calcPerfBySCG(ifn, removeStrain=F)
    # qa$Completeness = qa$Recall * 100
    # qa$Contamination = 100*(1-qa$Precision)

    N = dim(qa)[1]
    width = 1+N*0.15

    fig.start(fdir=fdir, ofn=paste(fdir, "/checkm_diagram.pdf", sep=""), type="pdf", width=width, height=5)
    ix = order(qa$Completeness, decreasing=T)
    plot.init(xlim=c(1,dim(qa)[1]), ylim=c(0,100), xlab="genome", ylab="%", axis.las=1)
    # plot(1:dim(qa)[1], qa$Completeness[ix], type="p", pch=19, col=1, ylim=c(0,100), las=2, xlab="genome", ylab="%")
    points(1:dim(qa)[1], qa$Contamination[ix], pch=19, col=2)
    points(1:dim(qa)[1], qa$Completeness[ix], pch=19, col=1)
    grid()
    abline(h=min.complete, col=1, lty=2)
    abline(h=max.contam, col=2, lty=2)
    fig.end()
}

checkm.parse=function(ifn.checkm, ifn.bin.table, ofn)
{
    checkm = load.table(ifn.checkm)
    df = load.table(ifn.bin.table)
    checkm$bin = gsub("bin.", "", checkm$Bin.Id)

    ix = match(df$bin, checkm$bin)
    df$is.checkm = !is.na(ix)
    df$Completeness = ifelse(df$is.checkm, checkm$Completeness[ix], 0)
    df$Contamination = ifelse(df$is.checkm, checkm$Contamination[ix], 0)
    save.table(df, ofn)
}

checkm.select=function(ifn.bin.table, ifn.cb, min.genome.complete, max.genome.contam, max.element.complete,
    ofn.genome.table, ofn.cg, ofn.element.table, ofn.ce)
{
    bin.table = load.table(ifn.bin.table)
    cb = load.table(ifn.cb)

    # genomes
    genome.table = bin.table[bin.table$Completeness >= min.genome.complete & bin.table$Contamination <= max.genome.contam,]
    save.table(genome.table, ofn.genome.table)
    cg = cb[is.element(cb$bin, genome.table$bin),]
    save.table(cg, ofn.cg)

    # elements
    element.table = bin.table[bin.table$Completeness <= max.element.complete,]
    save.table(element.table, ofn.element.table)
    ce = cb[is.element(cb$bin, element.table$bin),]
    save.table(ce, ofn.ce)
}

checkm.select.genes=function(ifn.cg, ifn.genes, ofn)
{
    cg = load.table(ifn.cg)
    genes = load.table(ifn.genes)
    genes = genes[is.element(genes$contig,cg$contig),]
    result = genes[,c("gene", "contig")]
    ix = match(result$contig, cg$contig)
    result$bin = cg$bin[ix]
    save.table(result, ofn)
}
