bin.summary=function(ifn.cb, ifn.contigs, ofn)
{
    cb = load.table(ifn.cb)
    contigs = load.table(ifn.contigs)
    bins = sort(unique(cb$bin))
    fc = field.count(cb, "contig")
    if (!all(fc$count == 1)) {
        cc = fc$contig[fc$count > 1]
        stop(sprintf("contig %s appears more than once in table: %s", cc[1], ifn.cb))
    }
    cb$length = contigs$length[match(cb$contig,contigs$contig)]
    ss.length = sapply(split(cb$length,cb$bin), sum)
    ss.count = sapply(split(cb$length,cb$bin), length)
    result = data.frame(bin=bins, count=ss.count[match(bins,names(ss.count))], length=ss.length[match(bins,names(ss.length))])

    save.table(result, ofn)
}

bin.select=function(ifn, min.length, idir, odir)
{
    df = load.table(ifn)
    bins = df$bin[df$length>=min.length]
    system(paste("rm -rf", odir))
    system(paste("mkdir -p", odir))
    cat(sprintf("copying files to %s\n", odir))
    for (bin in bins) {
        ifn.fa = sprintf("%s/bin.%d.fa", idir, bin)
        ofn.fa = sprintf("%s/bin.%d.fa", odir, bin)
        command = sprintf("cp %s %s", ifn.fa, ofn.fa)
        if (system(command) != 0)
            stop(sprintf("error in command: %s\n", command))
    }
}
