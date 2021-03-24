plot.strains=function(ifn.libs, ifn.bins, ifn.taxa, ifn.bin.coverage, ifn.bin.order, ifn.strains.template, bin.template, type, maxSNPs, maxN, fdir)
{
    if (file.info(ifn.bins)$size == 1)
        return (NULL)

    library(gplots)
    df.libs = load.table(ifn.libs)
    df.bins = load.table(ifn.bins)
    df.bins.cov = load.table(ifn.bin.coverage)

    df.bins = df.bins[df.bins$nsites < maxSNPs,]
    df.bins = df.bins[order(df.bins$nsites),]

    # add taxa name if available
    if (file.exists(ifn.taxa)) {
        df.taxa = load.table(ifn.taxa)
        df.taxa$name = gsub('\\]', '', gsub('\\[', '', df.taxa$name))
        ix = match(df.bins$bin, df.taxa$anchor)

        # df.bins$label = paste0(df.taxa$name[ix], " ", df.bins$bin, " ", df.bins$nsites)
        df.bins$taxa = df.taxa$name[ix]
    } else {
        df.bins$label = paste0(df.bins$bin, " ", df.bins$nsites)
    }

    # order bins if possible
    if (file.exists(ifn.bin.order)) {
        df.bin.order = load.table(ifn.bin.order)
        df.bins = df.bins[order(match(df.bins$bin, df.bin.order$bin), decreasing=T),]
    }

    # !!! order by bin
    # df.bins = df.bins[order(df.bins$bin),]


    ll = list()
    for (i in 1:dim(df.bins)[1]) {
        bin = df.bins$bin[i]
        ifn = gsub(bin.template, bin, ifn.strains.template)
        df = read.delim(ifn)
        ll[[as.character(bin)]] = df
    }
    N = dim(df.bins)[1]
    M = dim(df.libs)[1]

    plot.f=function(i, details) {
        bin = df.bins$bin[i]
        df = ll[[as.character(bin)]]
        nsites = df.bins$nsites[i]
        taxa = df.bins$taxa[i]
        nstrains = dim(df)[2]

        strain.labs = paste0("s", 1:nstrains)

        # order strains
        ix = order(colSums(df))
        strain.labs = strain.labs[ix]
        df = df[,ix]

        # handle low coverage
        xx = df.bins.cov[df.bins.cov$bin == bin,]
        xcov = xx$cov_p50[match(df.libs$set, xx$set)]
        ix = xcov < 1
        df[ix,] = 0

        label = paste0(" ", taxa, " (n=", nsites, ", m=", nstrains, ")")

        cols = colorpanel(dim(df)[2], colors()[509], colors()[563])
        cols = colorpanel(dim(df)[2], "darkblue", colors()[400])
        m = barplot(t(as.matrix(df)), col=cols, main=NULL, border=NA, las=2, cex.axis=0.75, space=0, axes=F)
        if (any(ix))
            rect(xleft=m[ix]-0.5, xright=m[ix]+0.5, ybottom=0, ytop=1, border=NA, col="lightgray")

        if (details) {
            title(main=label)
            legend(x=M+2, y=1, legend=strain.labs, fill=cols, xpd=T, box.lwd=0)
            axis.value = seq(0,100,by=20)
            axis.at = axis.value/100
            axis(2, at=axis.at, labels=axis.value, las=2, cex.axis=0.75)

        } else {
            text(x=M, y=0.5, labels=label, xpd=T, pos=4)
            text(x=0, y=0.5, labels=paste(i, bin), xpd=T, pos=2)
        }

        if (type == "HMD") {
            ix = range(which(df.libs$Event_Key == "MidAbx"))
            abline(v=c(ix[1]-1, ix[2]), lwd=1, lty=2, col="darkgreen")
        }
    }
    # first one per bin

    ffdir = paste0(fdir, "/bins")
    system(paste("mkdir -p", ffdir))
    for (i in 1:N) {
        bin = df.bins$bin[i]
        fig.start(fdir=ffdir, ofn=paste(ffdir, "/", bin, ".pdf", sep=""), type="pdf", height=2, width=8)
        par(mai=c(0.1, 0.55, 0.5, 4))
        plot.f(i, details=T)
        fig.end()
    }

    cat(sprintf("number of bins: %d\n", N))
    fig.start(fdir=ffdir, ofn=paste(fdir, "/column_view.pdf", sep=""), type="pdf", height=2+N*0.12, width=3.7)
    layout(matrix(1:N, N, 1))
    par(mai=c(0.02, 0.55, 0.02, 2.5))
    for (i in 1:N)
        plot.f(i, details=F)

    fig.end()
}
