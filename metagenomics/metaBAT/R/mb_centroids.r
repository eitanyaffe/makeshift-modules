compute.vectors=function(ifn.cb, ifn.depth, ids, ofn)
{
    cb = load.table(ifn.cb)
    depth = load.table(ifn.depth)
    length = depth$contigLen
    N = (dim(depth)[2] - 3) / 2
    vals = depth[,1:N*2+2]
    colnames(vals) = ids
    result = data.frame(contig=depth$contigName, vals)
    save.table(result, ofn)
}

compute.centroids=function(ifn.cb, ifn.vec, ofn)
{
    cb = load.table(ifn.cb)
    contig.vecs = load.table(ifn.vec)
    contig.vecs = contig.vecs[is.element(contig.vecs$contig, cb$contig),]
    bins = cb$bin[match(contig.vecs$contig, cb$contig)]
    ss = split(contig.vecs[,-1], bins)
    result = NULL
    for (i in 1:length(ss)) {
        vals = as.data.frame(t(colMeans(ss[[i]])))
        result = rbind(result, data.frame(bin=as.numeric(names(ss)[i]), vals))
    }
    save.table(result, ofn)
}

compute.contig.scores=function(ifn.cb, ifn.vec, ifn.centroid, ofn)
{
    cb = load.table(ifn.cb)
    contig.vecs = load.table(ifn.vec)
    centroid.vecs = load.table(ifn.centroid)

    bins = sort(unique(cb$bin))
    result = NULL
    for (bin in bins) {
        contigs = cb$contig[cb$bin == bin]
        v.centroid = as.matrix(centroid.vecs[centroid.vecs$bin == bin,-1])
        v.contigs = as.matrix(contig.vecs[match(contigs,contig.vecs$contig),-1])
        cc = as.vector(cor(t(v.centroid), t(v.contigs)))

        df = data.frame(contig=contigs, bin=bin, pearson=cc)

        # add z-score
        if (length(contigs) >= 10) {
            qq = quantile(cc,c(0.1,0.9))
            cc.middle = cc[cc>=qq[1] & cc<=qq[2]]
            bin.mean = mean(cc.middle)
            bin.sd = sd(cc.middle)
        } else if (length(contigs) > 1) {
            bin.mean = mean(cc)
            bin.sd = sd(cc)
        } else {
            bin.mean = df$pearson
            bin.sd = 1
        }
        df$zscore = if(bin.sd>0) (df$pearson-bin.mean) / bin.sd else 0

        result = rbind(result, df)
    }
    save.table(result, ofn)
}
