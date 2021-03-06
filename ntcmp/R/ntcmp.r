get.bin.data=function(bin.size, length)
{
    nbins = ceiling(length/bin.size)
    df = data.frame(coords=1:length)
    df$bin = floor((df$coord-1) / bin.size) + 1
    list(map=df, nbins=nbins, bins=1:nbins, bin.size=bin.size)
}

bin.align=function(df, bin.data)
{
    bsize = bin.data$bin.size
    map = bin.data$map
    bins = bin.data$bins
    df$bin = map$bin[match(df$coord, map$coords)]
    result = data.frame(bin=bins, start=(bins-1)*bsize+1, end=bins * bsize)

    sp = split(df, df$bin)

    # max contig
    ss = sapply(sp, function(x) {
        tt = table(x$contig)
        names(tt)[which.max(tt)]
    } )
    ix = match(bins, names(ss))
    result$max.contig = ifelse(!is.na(ix), ss[ix], NA)

    # max contig coverage
    df$max.contig = result$max.contig[match(df$bin,result$bin)]
    sp = split(df, df$bin)
    ss = sapply(sp, function(x) {
        sum(x$contig == x$max.contig) / dim(x)[1]
    } )
    ix = match(bins, names(ss))
    result$coverage = ifelse(!is.na(ix), ss[ix], NA)

    # fragmentation
    ss = sapply(sp, function(x) {
        sum(diff(x$contig.index) != 0) / bsize
    } )
    ix = match(bins, names(ss))
    result$break.density = ifelse(!is.na(ix), ss[ix], NA)

    # N50
    ss = sapply(sp, function(x) {
        rle = rle(x$contig)
        if (!any(rle$values != "none"))
            return (0)
        lengths = sort(rle$lengths[rle$values != "none"])
        total = sum(lengths)
        cs = cumsum(lengths)
        ix = findInterval(total/2, cs) + 1
        lengths[ix]
    } )
    ix = match(bins, names(ss))
    result$N50 = ifelse(!is.na(ix), ss[ix], NA)

    ss = sapply(sp, function(x) {
        median(x$clength)
    } )
    ix = match(bins, names(ss))
    result$median.contig.length = ifelse(!is.na(ix), ss[ix], NA)

    result
}

ntcmp.bin=function(ifn.table, idir, bin.sizes, odir, min.contig.length=1000)
{
    table = load.table(ifn.table)
    table = table[order(table$length, decreasing=F),]
    table = table[table$length >= min.contig.length,]

    cat(sprintf("saving binned results to directory: %s\n", odir))
    cat(sprintf("number of contigs: %d\n", dim(table)[1]))
    for (i in 1:dim(table)[1]) {
        contig = table$contig[i]
        length = table$length[i]

        df = load.table(paste(idir, "/", contig, ".dense", sep=""), verbose=F)
        cat(".")
        flush(stdout())

        # fix coords
        df$coord = 1:length
        df$contig[is.na(df$contig)] = "none"

        # add contig index
        df$contig.index = match(df$contig, unique(df$contig))

        for (bin.size in bin.sizes) {
            odir.bin = paste(odir, "/binsize_", bin.size, sep="")
            ofn = paste(odir.bin, "/", contig, ".table", sep="")
            if (file.exists(ofn))
                next
            if (system(paste("mkdir -p", odir.bin)) != 0)
                stop(sprintf("cannot create directory: %s\n", odir.bin))
            bin.data = get.bin.data(bin.size=bin.size, length=length)
            df.binned = bin.align(df=df, bin.data=bin.data)
            save.table(df.binned, ofn, verbose=F)
        }
    }
    cat(". done\n")

}

ntcmp.summary=function(ifn.table, idir, ofn)
{
    table = load.table(ifn.table)
    table$max.contig = NA
    table$max.contig.coverage = 0
    for (i in 1:dim(table)[1]) {
        contig = table$contig[i]
        length = table$length[i]

        df = load.table(paste(idir, "/", contig, ".table", sep=""), verbose=F)
        if (dim(df)[1] == 0)
            next
        ss = sapply(split(df$length, df$mcontig), sum)
        ss = ss[order(ss, decreasing=T)]
        table$max.contig[i] = names(ss)[1]
        table$max.contig.coverage[i] = ss[1]/length
    }
    save.table(table, ofn)
}
