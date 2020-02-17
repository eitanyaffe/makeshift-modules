export.mags=function(ifn, subject.id, idir, ofn, odir)
{
    df = load.table(ifn)
    cat(sprintf("saving fasta files to directory: %s\n", odir))
    system(paste("mkdir -p", odir))
    for (anchor in df$anchor) {
        id = df$anchor.id[match(anchor,df$anchor)]
        fn = paste(id, ".fasta", sep="")
        ifn = paste(idir, "/", anchor, ".fasta", sep="")
        ofn.fa = paste(odir, "/", fn, sep="")
        system(paste("cp", ifn, ofn.fa))
    }
    result = data.frame(id=df$anchor.id, length_bp=df$anchor.length, accession=df$ref, species.name=df$ref.name, strain.name=df$ref.strain.name, core_fraction=df$anchor.coverage, core_identity=df$anchor.identity)
    save.table(result, ofn)
}
