collect.stats=function(ifn, idir, ofn.bwa, ofn.filter, ofn.paired)
{
    df = load.table(ifn)
    aids = df$ASSEMBLY_ID

    add.f=function(x1, x2) {
        ix = match(names(x1), names(x2))
        x1 + x2[ix]
    }
    
    rr.bwa = NULL
    rr.filter = NULL
    rr.paired = NULL
    for (aid in aids) {
        cat(sprintf("processing assembly: %s\n", aid))
        adf = read.delim(paste0(idir, "/", aid, "/set/libs_table.txt"))
        mids = adf$MAP_LIB_ID
        for (mid in mids) { 
            cdf = read.delim(paste0(idir, "/", aid, "/libs/", mid, "/split/chunk.tab"))
            cids = cdf$chunk
            input.count = sum(cdf$reads)
            rr.ii = data.frame(assembly=aid, sample=mid, input=input.count)
            for (i in 1:length(cids)) {
                cid = cids[i]
                bwa = read.delim(paste0(idir, "/", aid, "/libs/", mid, "/chunks/", cid, "/R1.stats"))
                filter1 = read.delim(paste0(idir, "/", aid, "/libs/", mid, "/chunks/", cid, "/R1.filtered.stats"))
                filter2 = read.delim(paste0(idir, "/", aid, "/libs/", mid, "/chunks/", cid, "/R2.filtered.stats"))
                paired = read.delim(paste0(idir, "/", aid, "/libs/", mid, "/chunks/", cid, "/paired.stats"))
                if (i == 1) {
                    rr.bwa.ii = bwa
                    rr.filter.ii = add.f(filter1, filter2)
                    rr.paired.ii = paired
                } else {
                    rr.bwa.ii = add.f(bwa, rr.bwa.ii)
                    rr.filter.ii = add.f(add.f(filter1, filter2), rr.filter.ii)
                    rr.paired.ii = add.f(paired, rr.paired.ii) 
                }
            }
            rr.bwa = rbind(rr.bwa, data.frame(assembly=aid, sample=mid, input=input.count, rr.bwa.ii))
            rr.filter = rbind(rr.filter, data.frame(assembly=aid, sample=mid, rr.filter.ii))
            rr.paired = rbind(rr.paired, data.frame(assembly=aid, sample=mid, rr.paired.ii))
        }
    }
    save.table(rr.bwa, ofn.bwa)
    save.table(rr.filter, ofn.filter)
    save.table(rr.paired, ofn.paired)
}

plot.stats=function(ifn.bwa, ifn.filter, ifn.paired, fdir)
{
    bwa = load.table(ifn.bwa)
    filter = load.table(ifn.filter)
    paired = load.table(ifn.paired)
    filter$total = rowSums(filter[,-(1:2)])
    paired$total = rowSums(paired[,-(1:2)])
    
    my.plot.ecdf=function(title, type, x) {
        fig.start(fdir=fdir, type="pdf", width=4, height=4,
                  ofn=paste(fdir, "/", title, "_ecdf.pdf", sep=""))
        plot(ecdf(x), main=paste(title), ylab="fraction", xlab=type)
        fig.end()
    }
    my.plot.ecdf(title="1_all_mapped", type="%", x=100 * bwa$ok / bwa$input)
    my.plot.ecdf(title="2_high_quality_mapped", type="%", x=100 * filter$ok / filter$total)
    
    for (field in c("short_match_length", "high_edit_dist", "low_score"))
        my.plot.ecdf(title=paste0("3_filtered_", field), type="%", x=100 * filter[,field] / filter$total)

    my.plot.ecdf(title="4_paired", type="%", x=100 * paired$ok / paired$total)

}
