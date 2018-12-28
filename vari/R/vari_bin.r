var.bin.cov=function(cov, bin.data)
{
    map = bin.data$map
    if (length(cov) != dim(map)[1])
        stop("coverage profile not dense")
    ss = sapply(split(cov, map$bin), sum)
    # result = data.frame(bin=bin.data$bins, start=(bin.data$bins-1)*bin.data$bin.size+1, end=bin.data$bins * bin.data$bin.size)
    result = bin.data$bin.table

    ix = match(result$bin, names(ss))
    result$count = ifelse(!is.na(ix), ss, 0)
    result
}

var.bin.poly=function(poly, bin.data)
{
    map = bin.data$map
    poly = poly[poly$type == "snp",]
    poly$bin = map$bin[match(poly$coord, map$coord)]
    # result = data.frame(bin=bin.data$bins, start=(bin.data$bins-1)*bin.data$bin.size+1, end=bin.data$bins * bin.data$bin.size)
    result = bin.data$bin.table

    ss = sapply(split(poly, poly$bin), function(x) { sum(x$snp.called) })
    ix = match(result$bin, names(ss))
    result$snp.count = ifelse(!is.na(ix), ss[ix], 0)

    ss = sapply(split(poly, poly$bin), function(x) { sum(x$snp.fixed) })
    ix = match(result$bin, names(ss))
    result$snp.fixed.count = ifelse(!is.na(ix), ss[ix], 0)

    result$snp.density = result$snp.count / result$length
    result$snp.fixed.density = result$snp.fixed.count / result$length
    result
}

get.bin.data=function(bin.size, length)
{
    nbins = ceiling(length/bin.size)
    cov.binned = vector("numeric", nbins)

    # map
    map = data.frame(coord=1:length)
    map$bin = floor((map$coord-1) / bin.size) + 1

    # bin table
    ss.min = sapply(split(map$coord, map$bin), min)
    ss.max = sapply(split(map$coord, map$bin), max)
    bin.table = data.frame(bin=as.numeric(names(ss.min)), start=ss.min, end=ss.max)
    bin.table = bin.table[as.numeric(bin.table$bin),]
    bin.table$length = bin.table$end - bin.table$start + 1

    list(map=map, bin.table=bin.table)
}

vari.bin=function(
    ifn.table, field, dir.full, dir.clipped, bin.sizes,
    snp.percent.threshold, snp.count.threshold, snp.fixed.percent.threshold)
{
    dirs = list(full=dir.full, clipped=dir.clipped)
    table = load.table(ifn.table)
    table$item = table[,field]
    items = table$item
    cat(sprintf("number of items: %d\n", length(items)))
    for (item in items) {
        for (i in 1:length(dirs)) {
            type = names(dirs)[i]
            dir = dirs[i]
            length = table$length[match(item,table$item)]
            # cat(sprintf("loading %s tables for item %s\n", type, item))
            poly = read.delim(paste(dir, "/", item, ".poly", sep=""))
            cov = read.delim(paste(dir, "/", item, ".cov", sep=""), header=F)[,1]
            poly$snp.called = poly$percent >= 100*snp.percent.threshold & poly$percent <= 100*(1-snp.percent.threshold) & poly$count >= snp.count.threshold
            poly$snp.fixed = poly$percent >= 100*snp.fixed.percent.threshold & poly$count >= snp.count.threshold

            for (bin.size in bin.sizes) {
                odir = paste(dir, "/binsize_", bin.size, sep="")
                # cat(sprintf("binning profiles, binsize=%d, odir=%s\n", bin.size, odir))
                if (system(paste("mkdir -p", odir)) != 0)
                    stop(sprintf("cannot create directory: %s\n", odir))

                bin.data = get.bin.data(bin.size=bin.size, length=length)

                # coverage
                ofn = paste(odir, "/", item, ".cov", sep="")
                cov.binned = var.bin.cov(cov=cov, bin.data=bin.data)
                write.table(cov.binned, ofn, quote=F, sep="\t", row.names=F)

                # poly
                ofn = paste(odir, "/", item, ".poly", sep="")
                poly.binned = var.bin.poly(poly=poly, bin.data=bin.data)
                write.table(poly.binned, ofn, quote=F, sep="\t", row.names=F)
            }
        }
    }
}
