FDR.GO.tables=function(ifn.genes.bg, ifn.genes, ea.ifn, count, dry, odir)
{
    ea = load.table(ea.ifn)
    dummy.element.id = ea$element.id[1]
    dummy.anchor = ea$anchor[1]

    genes = load.table(ifn.genes.bg)$gene
    N = dim(load.table(ifn.genes))[1]

    for (i in 1:count) {
        set.dir = paste(odir, "/", i, sep="")
        pfn = paste(set.dir, "/source_genes", sep="")
        system(paste("mkdir -p", set.dir))

        # genes
        genes.i = data.frame(gene=sample(genes, N), element.id=dummy.element.id, anchor=dummy.anchor)
        save.table(genes.i, pfn)

        command = sprintf("make m=func GO_select FUNC_SET_DIR=%s FUNC_INPUT_GENES=%s", set.dir, pfn)
        if (dry) {
            command = paste(command, "-n")
        }
        if (system(command) != 0)
            stop(paste("error in command:", command))
    }
}

FDR.qvalues=function(ifn, idir, count, min.gene.count, min.enrichment, min.ml.pvalue, ofn)
{
    df = load.table(ifn)

    rnd = NULL
    cat(sprintf("going over %d permutations in directory: %s\n", count, idir))
    for (i in 1:count) {
        set.dir = paste(idir, "/", i, sep="")
        rnd = rbind(rnd, read.delim(paste(set.dir, "/merge", sep="")))
    }
    rnd = rnd[rnd$count >= min.gene.count & rnd$enrichment >= min.enrichment & rnd$minus.log.p >= min.ml.pvalue,]

    result = NULL
    for (type in c("func", "component", "process")) {
        dft = df[df$type == type,]
        dft = dft[order(dft$minus.log.p, decreasing=T),]
        rnd.values = rnd$minus.log.p[rnd$type == type]
        ff = ecdf(rnd.values)
        dft$index = 1:dim(dft)[1]
        dft$false.count = ((1-ff(dft$minus.log.p)) * length(rnd.values)) / count
        dft$q.value = dft$false.count / dft$index
        ii = match(c("index", "false.count"), names(dft))
        result = rbind(result, dft[,-ii])
    }
    save.table(result, ofn)

#    cat(sprintf("computing per GO type a P-value that matches an FDR: %f\n", fdr.value))
#    result = NULL
#    for (type in c("function", "component", "process")) {
#        x = ll[[type]]
#        result = rbind(result, data.frame(type=type, pvalue=quantile(unlist(x[,-1]), 1-fdr.value)))
#    }
#    save.table(result, ofn)
}
