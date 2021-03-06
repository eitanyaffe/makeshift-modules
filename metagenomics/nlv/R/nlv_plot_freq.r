plot.freq=function(ifn.libs, ifn.bins, ifn.sites, ifn.sets, ifn.count.mat, ifn.total.mat, fdir)
{
    df.libs = load.table(ifn.libs)
    df.bins = load.table(ifn.bins)
    df.all = load.table(ifn.sets)
    df.sites = load.table(ifn.sites)

    mat.count = load.table(ifn.count.mat)
    mat.total = load.table(ifn.total.mat)

    # limit to selected sites
    make.key=function(df) { paste(df$contig, df$coord) }
    df.sites$key = make.key(df.sites)
    mat.count.key = make.key(mat.count)
    mat.total.key = make.key(mat.total)
    mat.count = mat.count[is.element(mat.count.key, df.sites$key),]
    mat.total = mat.total[is.element(mat.total.key, df.sites$key),]

    set.ind = sort(unique(df.libs$set.index))
    sets = df.libs$set[match(set.ind,df.libs$set.index)]
    bins = df.bins$bin[df.bins$class == "host"]
    N = length(sets)

    box.width = 0.4

    for (bin in bins) {
        # segregation and coverage
        df = df.all[df.all$bin == bin,]
        df$index = match(df$set, sets)

        if (!any(mat.count$bin == bin))
            next
        contigs = unique(mat.count$contig[mat.count$bin == bin])
        if (length(contigs) > 100) next

        for (contig in contigs) {

            # skip if too many variants per contig
            M = sum(mat.count$bin == bin & mat.count$contig == contig)
            if (M == 0 || M > 100) next

            mm.count = mat.count[mat.count$bin == bin & mat.count$contig == contig,]
            mm.total = mat.total[mat.total$bin == bin & mat.count$contig == contig,]
            mm.count$title = paste(mm.count$contig, mm.count$coord, mm.count$var)

            xvals = 1:N
            set.indices = match(sets, colnames(mm.count))

            ylim = c(0, 1.1 * max(mm.total[,set.indices]))

            ffdir = paste(fdir, "/", bin, sep="")
            system(paste("mkdir -p", ffdir))
            fig.start(fdir=ffdir, ofn=paste(ffdir, "/", contig, ".pdf", sep=""), type="pdf", height=2+1*M, width=8)
            layout(matrix(1:(2*M), M, 2, byrow=T), widths=c(2.4,1))

            for (i in 1:M) {
                vcount = unlist(mm.count[i,set.indices])
                vtotal = unlist(mm.total[i,set.indices])
                vfreq = 100 * ifelse(vtotal > 0, vcount / vtotal, NA)
                title = mm.count$title[i]

                # raw counts
                par(mai=c(0.1, 3, 0.1, 0.1))
                plot.init(xlim=c(0,N), ylim=ylim, axis.las=2, x.axis=F)
                segments(x0=df$index-0.5, x1=df$index-0.5, y0=df$cov_p5, y1=df$cov_p95, col="darkgray")
                rect(df$index-0.5-box.width, df$cov_p25, df$index-0.5+box.width, df$cov_p75, col="gray", border=NA)
                lines(xvals-0.5, vtotal)
                lines(xvals-0.5, vcount, col=2)
                mtext(title, side=2, las=2, line=3)

                # freq
                par(mai=c(0.1, 0.4, 0.1, 0.1))
                plot.init(xlim=c(0,N), ylim=c(0,100), ylab="%", axis.las=2, x.axis=F)
                lines(xvals-0.5, vfreq)
            }
            fig.end()
        }
    }
}

