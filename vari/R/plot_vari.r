plot.single=function(icags, igenes, idir, lib.id, fdir)
{
    cags = load.table(icags)
    genes = load.table(igenes)

    compute.xcoord=function(df, lookup) {
        df$base = lookup$base.coord[match(df$contig,lookup$gene)]
        df$coord + df$base
    }

    my.load.table=function(ifn) {
        if (file.exists(ifn))
            return (load.table(ifn))
        else
            return (NULL)
    }

    for (i in 1:dim(cags)[1]) {
        cag = cags$id[i]
        idir.cag = paste(idir, "/", cag, sep="")
        nt = my.load.table(paste(idir.cag, "/nt", sep=""))
        nt.cov = my.load.table(paste(idir.cag, "/nt_cov", sep=""))

        genes.cag = genes[genes$set == cag,]
        genes.cag = genes.cag[order(genes.cag$length, decreasing=T),]
        N = dim(genes.cag)[1]
        max.xcoord = cumsum(genes.cag$length)[N]
        genes.cag$base.coord = c(0,cumsum(genes.cag$length)[-N])

        # append x coords
        nt.cov$xcoord = compute.xcoord(df=nt.cov, lookup=genes.cag)

        ylim = c(0, 1.1*max(c(nt.cov$count)))
        xlim = c(0, max.xcoord)
        fig.start(fdir=fdir, ofn=paste(fdir, "/", cag, ".pdf", sep=""), type="pdf", width=10, height=6)
        plot.init(xlim=xlim, ylim=ylim, xlab="coord", ylab="count", axis.las=1, x.axis=F, xaxs="i", yaxs="i")
        rect(xleft=nt.cov$xcoord-1, xright=nt.cov$xcoord, ybottom=0, ytop=nt.cov$count, border=NA, col="gray")
        abline(v=genes.cag$base.coord)

        if (!is.null(nt)) {
            nt$xcoord = compute.xcoord(df=nt, lookup=genes.cag)
            nt = nt[nt$type != "REF",]
            nt$col = ifelse(nt$type == "snp", "blue", "red")
            rect(xleft=nt$xcoord-1, xright=nt$xcoord, ybottom=0, ytop=nt$count, border=NA, col=nt$col)
        }

        fig.end()

    }
}

plot.all=function(ilibs, icags, igenes, base.dir, fdir)
{
    libs = load.table(ilibs)
    cags = load.table(icags)
    genes = load.table(igenes)

    compute.xcoord=function(df, lookup) {
        df$base = lookup$base.coord[match(df$contig,lookup$gene)]
        df$coord + df$base
    }

    my.load.table=function(ifn) {
        if (file.exists(ifn))
            return (load.table(ifn))
        else
            return (NULL)
    }


    plot.summary=function(ll, fdir, var.y.axis) {
        fig.start(fdir=fdir, ofn=paste(fdir, "/", cag, ".pdf", sep=""), type="pdf", width=10, height=10)
        layout(matrix(1:M, M, 1))
        par(mai=c(0.05,0,00.05,0))
        for (j in 1:dim(libs)[1]) {
            lib.id = libs$run.id[j]
            xlim = c(0, max.xcoord)

            nt = ll[[lib.id]]$nt
            nt.cov = ll[[lib.id]]$nt.cov
            if (var.y.axis) {
                ylim = c(0, 1.1*max(nt.cov$count))
            } else {
                ylim = c(0, 1.1*max.count)
            }

            plot.init(xlim=xlim, ylim=ylim, xlab="coord", ylab="count", axis.las=1, x.axis=F, xaxs="i", yaxs="i")
            rect(xleft=nt.cov$xcoord-1, xright=nt.cov$xcoord, ybottom=0, ytop=nt.cov$count, border=NA, col="gray")
            abline(v=genes.cag$base.coord)

            if (!is.null(nt)) {
                nt$xcoord = compute.xcoord(df=nt, lookup=genes.cag)
                nt = nt[nt$type != "REF",]
                nt$col = ifelse(nt$type == "snp", "blue", "red")
                rect(xleft=nt$xcoord-1, xright=nt$xcoord, ybottom=0, ytop=nt$count, border=NA, col=nt$col)
            }
        }
        fig.end()
    }

    M = dim(libs)[1]

    for (i in 1:dim(cags)[1]) {
        cag = cags$id[i]

        genes.cag = genes[genes$set == cag,]
        genes.cag = genes.cag[order(genes.cag$length, decreasing=T),]
        N = dim(genes.cag)[1]
        max.xcoord = cumsum(genes.cag$length)[N]
        genes.cag$base.coord = c(0,cumsum(genes.cag$length)[-N])

        ll = list()
        max.count = 0
        for (j in 1:dim(libs)[1]) {
            lib.id = libs$run.id[j]
            idir.cag = paste(base.dir, "/", lib.id, "/cags/", cag, sep="")
            nt = my.load.table(paste(idir.cag, "/nt", sep=""))
            nt.cov = my.load.table(paste(idir.cag, "/nt_cov", sep=""))

            # append x coords
            nt.cov$xcoord = compute.xcoord(df=nt.cov, lookup=genes.cag)
            ll[[lib.id]] = list(nt=nt, nt.cov=nt.cov)
            max.count = max(max.count, max(nt.cov$count))
        }
        plot.summary(ll=ll, fdir=paste(fdir,"/single_yaxis",sep=""), var.y.axis=F)
        # plot.summary(ll=ll, fdir=paste(fdir,"/var_yaxis",sep=""), var.y.axis=T)
}
}
