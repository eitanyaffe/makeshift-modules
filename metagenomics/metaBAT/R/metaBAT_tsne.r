compute.tsne=function(ifn, perplexity, nthreads, max.iter, min.length, norm, ofn)
{
    library(Rtsne)
    df = load.table(ifn)
    df = df[df$contigLen >= min.length,]

    N = (dim(df)[2] - 3) / 2
    data = df[,2*(1:N) + 2]

    if (norm)
        data = data / rowSums(data)

    set.seed(1)
    rr = Rtsne(data, perplexity=perplexity, max_iter=max.iter, check_duplicates=F, num_threads=nthreads)

    df$num.detected = apply(data, 1, function(x) sum(x>0))

    result = data.frame(contig=df$contigName, length=df$contigLen,
                        total.depth=df$totalAvgDepth, num.samples.detected=df$num.detected,
                        x=rr$Y[,1], y=rr$Y[,2])
    save.table(result, ofn)
}
