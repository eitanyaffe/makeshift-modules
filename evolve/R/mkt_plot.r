plot.mkt=function(ifn1, ifn2, max.poly.density, years, fdir)
{
    df1 = load.table(ifn1)
    df2 = load.table(ifn2)
    df1$subject = "A"
    df2$subject = "B"
    df = rbind(df1, df2)

    N = dim(df)[1]
    df = df[order(df$gene.count, decreasing=T),]
    df$index = 1:N
    df$genome.count = 1

    # add poly density
    df$poly.density = df$poly.count / df$length
    df.all = df[df$poly.density<max.poly.density,]

    # fields
    fields.no.sum = c("index", "anchor.id", "family.name", "genus.name", "subject")
    fields.sum = c("genome.count", "pN.o", "pN.e", "pS.o", "pS.e", "dN.o", "dN.e", "dS.o", "dS.e", "gene.count", "poly.count", "length")

    df = df[,c(fields.no.sum, fields.sum)]

    all = data.frame(index="all", anchor.id=NA, family.name=NA, genus.name=NA, subject=NA, as.data.frame(t(colSums(df.all[,fields.sum]))))
    # df = rbind(df, all)
    N = dim(df)[1]

    # add poly density
    df$poly.density = df$poly.count / df$length

    # add gene/year
    df$genes.per.year = (df$gene.count/years) / df$genome.count

    # add mkt ratio
    get.ratio=function(S.o, S.e, N.o, N.e) {
        ((N.o+1)/(N.e+1)) / ((S.o+1)/(S.e+1))
#        ifelse(S.o == 0 & N.o == 0, NA,
#               ifelse(S.o == 0, +Inf, (N.o/N.e) / (S.o/S.e)))
    }
    df$p.ratio = get.ratio(S.o=df$pS.o, S.e=df$pS.e, N.o=df$pN.o, N.e=df$pN.e)
    df$d.ratio = get.ratio(S.o=df$dS.o, S.e=df$dS.e, N.o=df$dN.o, N.e=df$dN.e)

    # mkt chi-square p-values
    df$p.value = 1
    for (i in 1:N) {
        # mm = matrix(c(df$pN.o[i], df$pS.o[i], df$dN.o[i], df$dS.o[i]), 2, 2)
        mm = matrix(c(df$pN.o[i]+1, df$pS.o[i]+1, df$dN.o[i]+1, df$dS.o[i]+1), 2, 2)
        cs = suppressWarnings(chisq.test(mm, correct=F))
        df$p.value[i] = cs$p.value
    }

    # variance on both axis
 #   get.var=function(A, B) {
 #       mean.A.sq = mean(A)^2
 #       mean.B.sq = mean(B)^2
 #       var.A = var(A)
 #       var.B = var(B)
 #       (mean.A.sq/mean.B.sq) * (var.A/mean.A.sq + var.B/mean.B.sq)
 #   }
 #   df$p.sd = (df$pS.e/df$pN.e) * sqrt(get.var(A=df$pN.o, B=df$pS.o))
 #   df$d.sd = (df$dS.e/df$dN.e) * sqrt(get.var(A=df$dN.o, B=df$dS.o))

    rnd.count = 100000
    get.sd=function(S.o, S.e, N.o, N.e) {
        Ps = (S.o+1)/(S.e+1)
        Pn = (N.o+1)/(N.e+1)
        rdf = data.frame(S.o=rbinom(n=rnd.count, prob=Ps, size=S.e), N.o=rbinom(n=rnd.count, prob=Pn, size=N.e))
        rdf$ratio = get.ratio(S.o=rdf$S.o, S.e=S.e, N.o=rdf$N.o, N.e=N.e)
        rdf = rdf[!is.na(rdf$ratio) & is.finite(rdf$ratio),]
        sd(rdf$ratio)
    }

    # add standard deviation
    for (i in 1:N) {
        df$p.sd[i] = get.sd(S.o=df$pS.o[i], S.e=df$pS.e[i], N.o=df$pN.o[i], N.e=df$pN.e[i])
        df$d.sd[i] = get.sd(S.o=df$dS.o[i], S.e=df$dS.e[i], N.o=df$dN.o[i], N.e=df$dN.e[i])
    }

    # fit values into plot
#    df$p.ratio[df$p.ratio>1] = 1
#    df$d.ratio[df$d.ratio>1] = 1

    df$p.ratio.high = df$p.ratio + df$p.sd
    df$p.ratio.low = df$p.ratio - df$p.sd
    df$d.ratio.high = df$d.ratio + df$d.sd
    df$d.ratio.low = df$d.ratio - df$d.sd

    df$NI = df$p.ratio / df$d.ratio

    otable = df[,c("index", "genome.count", "subject", "anchor.id", "family.name", "genus.name", "gene.count", "genes.per.year", "poly.density")]
    otable$pN.count = df$pN.o
    otable$pS.count = df$pS.o
    otable$dN.count = df$dN.o
    otable$dS.count = df$dS.o
    otable$pN.pS = round(df$p.ratio,3)
    otable$dN.dS = round(df$d.ratio,3)
    otable$p.value = df$p.value

    system(paste("mkdir -p", fdir))
    save.table(otable, paste(fdir, "/table.txt", sep=""))

    xlim = range(c(0,1, df$p.ratio), na.rm=T, finite=T)
    ylim = range(c(0,1, df$d.ratio), na.rm=T, finite=T)
    ylim[2] = ylim[2]*1.05

    df$col = ifelse(df$index == "all", "red", "darkblue")
    df$col.cross = ifelse(df$index == "all", "red", "gray")
    df$cex = ifelse(df$index == "all", 1.2, 0.75)

    ################################################################################################
    # poly vs diverge
    ################################################################################################

    plot.f=function(title, post.f) {
        fig.start(fdir=fdir, ofn=paste(fdir, "/", title, ".pdf", sep=""), type="pdf", height=8.5, width=4)
        plot.init(xlim=xlim, ylim=ylim, xlab="pN/pS", ylab="dN/dS", main=N, axis.las=1, add.grid=F, xaxs="i", yaxs="i")
        # grid()
        abline(b=1, a=0, lty=2)
        post.f()

        points(df$p.ratio, df$d.ratio, col=df$col, pch=19, cex=df$cex)
        fig.end()
    }

    ww = 0.008
    plot.f(title="mkt_base",
           post.f=function(){
           })
    plot.f(title="mkt_cross",
           post.f=function(){
               segments(x0=df$p.ratio.low, x1=df$p.ratio.high, y0=df$d.ratio, y1=df$d.ratio, col=df$col.cross)
               segments(x0=df$p.ratio, x1=df$p.ratio, y0=df$d.ratio.low, y1=df$d.ratio.high, col=df$col.cross)

               segments(x0=df$p.ratio.low, x1=df$p.ratio.low, y0=df$d.ratio-ww, y1=df$d.ratio+ww, col=df$col.cross)
               segments(x0=df$p.ratio.high, x1=df$p.ratio.high, y0=df$d.ratio-ww, y1=df$d.ratio+ww, col=df$col.cross)

               segments(x0=df$p.ratio-ww, x1=df$p.ratio+ww, y0=df$d.ratio.low, y1=df$d.ratio.low, col=df$col.cross)
               segments(x0=df$p.ratio-ww, x1=df$p.ratio+ww, y0=df$d.ratio.high, y1=df$d.ratio.high, col=df$col.cross)
           })

    plot.f(title="mkt_text",
           post.f=function(){
               text(df$p.ratio, df$d.ratio, df$index, pos=1, cex=0.5)
           })

    ################################################################################################
    # NI vs gene
    ################################################################################################

    col = "darkblue"

    xlim = range(df$NI, na.rm=T)
    ylim = c(0, max(df$gene.count))
    fig.start(fdir=fdir, ofn=paste(fdir, "/coreNI_vs_geneHGT.pdf", sep=""), type="pdf", height=5.5, width=5)
    plot.init(xlim=xlim, ylim=ylim, xlab="NI", ylab="#genes", main=paste("N=", dim(df)[1], sep=""))
    grid()
    abline(v=1, lty=2)
    points(df$NI, df$gene.count, col=col, pch=19, cex=0.75)
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/coreNI_vs_geneHGT_text.pdf", sep=""), type="pdf", height=5.5, width=5)
    plot.init(xlim=xlim, ylim=ylim, xlab="NI", ylab="#genes", main=paste("N=", dim(df)[1], sep=""))
    grid()
    abline(v=1, lty=2)
    points(df$NI, df$gene.count, col=col, pch=19, cex=0.75)
    text(df$NI, df$gene.count, df$anchor.id, pos=4)
    fig.end()
}

plot.mkt.poly=function(ifn1, ifn2, max.poly.density, fdir)
{
    df1 = load.table(ifn1)
    df2 = load.table(ifn2)
    df1$subject = "A"
    df2$subject = "B"
    df = rbind(df1, df2)

    N = dim(df)[1]
    df = df[order(df$gene.count, decreasing=T),]
    df$index = 1:N
    df$genome.count = 1

    # add poly density
    df$poly.density = (df$poly.count) / df$length
    df$poly.density.10y = (df$poly.10y.count) / df$length

    df = df[df$poly.count>0 & df$poly.10y.count>0,]

    df$x = log10(df$poly.density)
    df$y = log10(df$poly.density.10y)

    lim = range(c(df$x, df$y))

    fig.start(fdir=fdir, ofn=paste(fdir, "/poly_scatter.pdf", sep=""), type="pdf", height=5.5, width=5)
    plot.init(xlim=lim, ylim=lim, xlab="current", ylab="10y", main="log10(snps/bp)")
    grid()
    abline(a=0, b=1, lty=3)
    points(df$x, df$y, pch=19, cex=0.5)
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/poly_scatter_text.pdf", sep=""), type="pdf", height=5.5, width=5)
    plot.init(xlim=lim, ylim=lim, xlab="current", ylab="10y", main="log10(snps/bp)")
    grid()
    abline(a=0, b=1, lty=3)
    points(df$x, df$y, pch=19, cex=0.5)
    text(df$x, df$y, df$index, pos=1, cex=0.5)
    fig.end()
}
