compress.poly.files=function(ca.ifn, anchor.field, src.base.dir, tgt.base.dir, title)
{
    ca =  read.delim(ca.ifn)
    ca$anchor = ca[,anchor.field]

    anchors = sort(unique(ca$anchor))
    contigs = sort(unique(ca$contig[is.element(ca$anchor, anchors)]))

    src.dir = paste(src.base.dir, "/output_full", sep="")

    tgt.dir = paste(tgt.base.dir, "/", title, sep="")
    tgt.ofn = paste(tgt.base.dir, "/", title, ".tar.gz", sep="")

    system(paste("mkdir -p ", tgt.dir, "/binsize_100", sep=""))
    system(paste("mkdir -p ", tgt.dir, "/binsize_1000", sep=""))
    system(paste("mkdir -p ", tgt.dir, "/binsize_10000", sep=""))

    N = 100
    ss = split(contigs, cut(seq_along(contigs), N))
    for (i in 1:N) {
        cat(sprintf("copying: poly files of %s contigs (%d/%d)\n", length(ss[[i]]), i, N))
        for (ext in c("poly", "cov")) {
            for (postfix in c("/", "binsize_100/","binsize_1000/","binsize_10000/")) {
                sfiles = paste(src.dir, "/", postfix, ss[[i]], ".", ext, collapse=" ", sep="")
                command = sprintf("cp %s %s", sfiles, paste(tgt.dir, "/", postfix, collapse="", sep=""))
                # cat(sprintf("command: %s", command))
                if (system(command) != 0)
                    stop(sprintf("command: %s", command))
            }
        }
    }

    command = sprintf("tar czf %s %s", tgt.ofn, tgt.dir)
    cat(sprintf("command: %s", command))
    if (system(command) != 0)
        stop(sprintf("error in last command"))
}

