vari.summary=function(ifn.table, field, dir.full, dir.clipped,
    snp.percent.threshold, snp.count.threshold, snp.fixed.percent.threshold, ofn)
{
    dirs = list(full=dir.full, clipped=dir.clipped)
    table = load.table(ifn.table)
    table$item = table[,field]
    items = table$item
    result = NULL
    cat(sprintf("going over %d items\n", length(items)))
    for (item in items) {
        length = table$length[match(item,table$item)]
        df = data.frame(item=item, length=length)
        for (i in 1:length(dirs)) {
            type = names(dirs)[i]
            dir = dirs[i]
            poly = read.delim(paste(dir, "/", item, ".poly", sep=""))
            cov = read.delim(paste(dir, "/", item, ".cov", sep=""), header=F)[,1]
            poly$snp.called = poly$percent >= 100*snp.percent.threshold & poly$percent <= 100*(1-snp.percent.threshold) & poly$count >= snp.count.threshold
            poly$snp.fixed = poly$percent >= 100*snp.fixed.percent.threshold & poly$count >= snp.count.threshold
            df[,paste("mean_xcoverage", type, sep="_")] = mean(cov)
            df[,paste("snp_count", type, sep="_")] = sum(poly$snp.called)
        }
        result = rbind(result, df)
    }
    save.table(result, ofn)
}
