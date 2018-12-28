bin.cov=function(cov, bin.data)
{
    map = bin.data$map
    if (length(cov) != dim(map)[1])
        stop("coverage profile not dense")
    ss = sapply(split(cov, map$bin), sum)
    result = bin.data$bin.table

    ix = match(result$bin, names(ss))
    result$count = ifelse(!is.na(ix), ss, 0)
    result$value = result$count / result$length
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

snps.bin=function(ifn, field, idir, bin.sizes, odir)
{
    items = load.table(ifn)[,field]

    cat(sprintf("reading profiles from directory: %s\n", idir))
    ll = list()
    for (item in items)
        ll[[item]] = read.delim(paste(idir, "/", item, sep=""), header=F)[,1]

    for (bin.size in bin.sizes) {
        cat(sprintf("generaring profile, binsize: %s\n", bin.size))
        result = NULL
        for (item in items) {
            cov = ll[[item]]
            length = length(cov)
            bin.data = get.bin.data(bin.size=bin.size, length=length)
            cov.binned = bin.cov(cov=cov, bin.data=bin.data)
            result = rbind(result, data.frame(item=item, cov.binned))
        }
        ofn = paste(odir, "/", bin.size, sep="")
        save.table(result, ofn)
    }
}
