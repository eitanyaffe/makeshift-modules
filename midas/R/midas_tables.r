midas.tables=function(ifn, ids, ifn.order, ifn.species2genome, ifn.genome.taxa, odir)
{
    df = load.table(ifn)
    ot = load.table(ifn.order)
    df = df[,c("species_id", ids)]
    species2genome = load.table(ifn.species2genome)
    genome.taxa = load.table(ifn.genome.taxa)

    sample.ids = names(df)[-1]
    sample.order = order(ot$order[match(sample.ids,ot$id)])
    sorted.sample.ids = sample.ids[sample.order]
    df = df[,c("species_id", sorted.sample.ids)]

    system(paste("mkdir -p", odir))
    result = df[rowSums(df[,-1]) > 0,]
    save.table(result, paste(odir, "/base.txt", sep=""))

    genomes = species2genome$rep_genome[match(df$species_id,species2genome$species_id)]
    ranks = c("species", "genus", "family", "order", "class", "phylum")
    ix = match(genomes, genome.taxa$genome_id)
    if (any(is.na(ix)))
        stop("internal error")

    for (rank in ranks) {
        ofn.rank = paste(odir, "/", rank, ".txt", sep="")
        rank.i = genome.taxa[ix,rank]
        ss = split(df[,-1], rank.i)
        result = data.frame(taxa=names(ss), as.data.frame(t(sapply(ss, function(x) { round(100*colSums(x),4)} ))))
        result$taxa[result$taxa == ""] = "unknown"
        result = result[rowSums(result[,-1]) > 0,]
        save.table(result, ofn.rank)
    }
}

midas.coverage=function(idir, ifn.stats, ids, odir)
{
    stats = load.table(ifn.stats)
    result = NULL
    for (id in ids) {
        total.read = stats$deconseq[match(id,stats$id)]
        df = load.table(paste(idir, "/", id, "/genes/summary.txt", sep=""))
        result = rbind(result, data.frame(id=id, total.reads=total.read, aligned.reads=sum(df$aligned_reads)))
    }
    result$percent = round(100 * (result$aligned.reads / result$total.reads),1)
    ofn = paste(odir, "/coverage.txt", sep="")
    system(paste("mkdir -p", odir))
    save.table(result, ofn)
}
