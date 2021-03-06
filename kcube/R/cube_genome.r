genome.profile=function(ifn.matrix, ifn.genes, gene.field, genome.field, ofn)
{
    mat = load.table(ifn.matrix)
    df = load.table(ifn.genes)
    df$gene = df[,gene.field]
    df$genome = df[,genome.field]

    genomes = unique(df$genome)
    result = NULL
    for (genome in genomes) {
        genes = df$gene[df$genome == genome]
        mat.g = mat[is.element(mat$item, genes),-1]

        result.g = data.frame(genome=genome, count=dim(mat.g)[1], as.data.frame(t(apply(mat.g, 2, median))))
        result = rbind(result, result.g)
    }
    save.table(result, ofn)
}

core.score=function(ifn.matrix, ifn.genome.profile, ifn.genes, gene.field, genome.field, ofn)
{
    mat = load.table(ifn.matrix)
    genome.profile = load.table(ifn.genome.profile)
    df = load.table(ifn.genes)
    df$gene = df[,gene.field]
    df$genome = df[,genome.field]

    genomes = unique(df$genome)
    result = NULL
    for (genome in genomes) {
        profile = as.vector(genome.profile[genome.profile$genome == genome, -(1:2)])
        mat.g = mat[is.element(mat$item, df$gene[df$genome == genome]),]
        genes = mat.g$item
        mm = as.matrix(mat.g[,-1])
        cc = as.vector(suppressWarnings(cor(t(mm), t(profile))))
        result.g = data.frame(genome=genome, gene=genes, pearson=cc)
        result = rbind(result, result.g)
    }
    save.table(result, ofn)
}

contig.profile=function(ifn.matrix, ifn.genes, ofn)
{
    mat = load.table(ifn.matrix)
    genes = load.table(ifn.genes)
    mat.contigs = genes$contig[match(mat$item, genes$gene)]
    ids = names(mat)[-1]
    result = data.frame(contig=unique(mat.contigs))
    cat(sprintf("going over %d samples\n", length(ids)))
    for (id in ids) {
        mat.id = mat[,id]
        ss = sapply(split(mat.id, mat.contigs), median)
        df = data.frame(contig=names(ss), value=ss)
        result[,id] = df$value[match(result$contig, df$contig)]
    }
    save.table(result, ofn)
}

contig.summary=function(ifn, ofn)
{
    mat.xcov = load.table(ifn)
    result = data.frame(item=mat.xcov$contig)

    mm.xcov = as.matrix(mat.xcov[,-1])
    mm.presence = mm.xcov
    mm.presence[mm.presence>0] = 1

    result$subject.count = rowSums(mm.presence)
    result$subject.ratio = round(result$subject.count / dim(mm.xcov)[2], 3)
    result$mean.median.xcov = ifelse(result$subject.count > 0, rowSums(mm.xcov) / result$subject.count, 0)
    result$mean.median.xcov = round(result$mean.median.xcov, 3)

    save.table(result, ofn)
}
