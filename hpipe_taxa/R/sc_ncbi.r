prepare.for.ncbi=function(ifn.info, ifn.anchors, ifn.anchor2id, ifn.taxa, subject.id, idir, ofn, odir)
{
    df = load.table(ifn.anchors)
    anchor2id = load.table(ifn.anchor2id)
    info = load.table(ifn.info)
    taxa = load.table(ifn.taxa)

    df$id = anchor2id$anchor.id[match(df$anchor, anchor2id$anchor)]
    df$name = taxa$name[match(df$anchor,taxa$anchor)]

    df = df[,c("anchor", "id", "name")]
    df$genome_coverage = round(info$reads.per.bp[match(df$anchor, info$anchor)],2)
    df$filename = paste(subject.id, "_", df$id, ".fasta", sep="")
    df$assembly_name = paste(subject.id, "_", df$id, sep="")

    cat(sprintf("saving fasta files to directory: %s\n", odir))
    system(paste("mkdir -p", odir))
    for (anchor in df$anchor) {
        id = df$id[match(anchor,df$anchor)]
        fn = df$filename[match(anchor,df$anchor)]
        ifn = paste(idir, "/", anchor, ".fasta", sep="")
        ofn.fa = paste(odir, "/", fn, sep="")
        system(paste("cp", ifn, ofn.fa))
    }

    result = df[,c("assembly_name", "name", "genome_coverage", "filename")]
    save.table(result, ofn)
}
