get.seq=function(script, db.dir, midas.dir, odir)
{
    cat(sprintf("generating results in directory: %s\n", odir))
    taxas = read.delim(paste(midas.dir, "/genes/species.txt", sep=""), header=F)[,1]
    for (taxa in taxas) {
        cat(sprintf("processing taxa: %s\n", taxa))
        idir = paste(db.dir, "/rep_genomes/", taxa, sep="")

        ifasta = paste(idir, "/genome.fna.gz", sep="")
        ofasta = paste(odir, "/", taxa, ".fasta", sep="")
        command = sprintf("gunzip -c %s > %s", ifasta, ofasta)
        if (system(command) != 0)
            stop(paste("command failed:", command))

        ifunc = paste(idir, "/genome.features.gz", sep="")
        ofunc = paste(odir, "/", taxa, ".genes", sep="")
        command = sprintf("gunzip -c %s > %s", ifunc, ofunc)
        if (system(command) != 0)
            stop(paste("command failed:", command))

        otable = paste(odir, "/", taxa, ".table", sep="")
        command = sprintf("cat %s | %s > %s", ofasta, script, otable)
        if (system(command) != 0)
            stop(paste("command failed:", command))
    }
}

gunzip=function(midas.dir, dummy)
{
    idir = sprintf("%s/genes/output", midas.dir)
    cat(sprintf("uncompressing files in %s\n", idir))
    command = sprintf("gunzip %s/*gz", idir)
    if (system(command) != 0)
        stop(paste("command failed:", command))

    idir = sprintf("%s/snps/output", midas.dir)
    cat(sprintf("uncompressing files in %s\n", idir))
    command = sprintf("gunzip %s/*gz", idir)
    if (system(command) != 0)
        stop(paste("command failed:", command))

}
