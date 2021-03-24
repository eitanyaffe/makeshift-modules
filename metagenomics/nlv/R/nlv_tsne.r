compute.strain.tsne=function(ifn.bins, bin.template, idir.template, ofn.sites, ofn.bins)
{
    library(Rtsne)
    df = load.table(ifn.bins)
    nts = c("A", "C", "G", "T")

    result.sites = NULL
    result.bins = NULL
    cat(sprintf("computing t-SNE of SNPs for %d bins...\n", dim(df)[1]))
    for (i in 1:dim(df)[1]) {
        bin = df$bin[i]
        idir = gsub(bin.template, bin, idir.template)

        ll = list()
        df.tot = NULL
        for (nt in nts) {
            df.nt = read.delim(paste0(idir, "/", nt))
            ll[[nt]] = df.nt
            if (nt == "A")
                df.tot = data.frame(apply(as.matrix(df.nt[,-(1:3)]), 1, sum))
            else
                df.tot = cbind(df.tot, data.frame(apply(as.matrix(df.nt[,-(1:3)]), 1, sum)))
        }
        names(df.tot) = nts
        nsites = dim(df.tot)[1]

        df.bin = NULL
        for (j in 1:nsites) {
            nt = names(which.max(df.tot[j,]))
            df.bin = rbind(df.bin, ll[[nt]][j,])
        }
        mm.bin = as.matrix(df.bin[,-(1:3)])

        perplexity = 30
        while (1) {
            failed = F
            rr = tryCatch(Rtsne(mm.bin, perplexity=perplexity, check_duplicates=F, num_threads=10),
                          error = function(e) {
                              failed <<- T })
            if (!failed) break
            perplexity = ceiling(perplexity/2)
            if (perplexity < 2) {
                failed = T
                break
            }
            # cat(sprintf("reducing perplexity to %d\n", perplexity))
        }
        if (failed) next
        result.sites = rbind(result.sites, data.frame(bin=bin, df.bin[,1:3], x=rr$Y[,1], y=rr$Y[,2]))
        result.bins = rbind(result.bins, data.frame(bin=bin, nsites=nsites, perplexity=perplexity))
    }

    save.table(result.sites, ofn.sites)
    save.table(result.bins, ofn.bins)
}
