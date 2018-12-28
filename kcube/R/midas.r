get.refs=function(idir, odir)
{
    for (fn in c("centroid_functions.txt" ,"centroids.ffn", "gene_info.txt")) {
        ifn  = paste(idir, "/", fn, ".gz", sep="")
        ofn  = paste(odir, "/", fn, sep="")
        command = sprintf("gunzip -c %s > %s", ifn, ofn)
        cat(sprintf("command: %s\n", command))
       if (system(command) != 0)
           stop("error")
    }
}
