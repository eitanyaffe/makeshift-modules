plot.checkm=function(ifn, fdir)
{
    df = load.table(ifn)
    df$col = ifelse(df$default, "blue", "lightgray")
    params = sort(unique(df$param))

    hwidth = 0.3
    ll.max = list()
    for (param in params) {
        dfp = df[df$param == param,]
        get.max=function(field) {
            ll = split(dfp[,field], dfp$value)
            values = names(ll)
            col = dfp$col[match(values, dfp$value)]
            N = length(ll)
            index = 1:N
            xlim = c(0.4, N+0.6)
            max(sapply(ll, function(x) quantile(x, 0.95)))
        }
        ll.max[["complete"]] = get.max("complete")
        ll.max[["contam"]] = get.max("contam")
    }

    for (param in params) {
        dfp = df[df$param == param,]

        plot.f=function(field, ylim) {
            ll = split(dfp[,field], dfp$value)
            values = names(ll)
            col = dfp$col[match(values, dfp$value)]
            N = length(ll)
            index = 1:N
            xlim = c(0.4, N+0.6)
            qq = sapply(ll, function(x) quantile(x, c(0.05, 0.25, 0.5, 0.75, 0.95)))
            fig.start(ofn=paste(fdir, "/", param, "_", field, ".pdf", sep=""), type="pdf", fdir=fdir, width=1+0.2*N, height=3)
            plot.init(xlim=xlim, ylim=ylim, x.axis=F, y.axis=F)

            segments(x0=index, x1=index, y0=qq[1,], y1=qq[5,])
            segments(x0=index-hwidth/2, x1=index+hwidth/2, y0=qq[1,], y1=qq[1,])
            segments(x0=index-hwidth/2, x1=index+hwidth/2, y0=qq[5,], y1=qq[5,])
            rect(xleft=index-hwidth, ybottom=qq[2,], xright=index+hwidth, ytop=qq[4,], col=col, border=col)
            segments(x0=index-hwidth, x1=index+hwidth, y0=qq[3,], y1=qq[3,], lwd=2)

            axis(side=2, cex.axis=0.7, las=1)
            axis(side=1, at=1:N, labels=values, cex.axis=0.7, las=2)
            fig.end()
        }
        plot.f("complete", ylim=c(0,100))
        plot.f("contam", ylim=c(0, ll.max[["contam"]]))
    }
}

plot.genome=function(ifn, fdir)
{
    df = load.table(ifn)
    df$median.mbp = df$median.bp/10^6

    df$col = ifelse(df$default, "blue", "black")
    ylim.bp = c(0, max(df$contig.bp))
    ylim.count = c(0, max(df$contig.count))
    ylim.median.mbp = c(0, 1.1*max(df$median.mbp))

    params = sort(unique(df$param))
    for (param in params) {
        dfp = df[df$param == param,]
        dfp = dfp[order(dfp$value),]
        N = dim(dfp)[1]
        dfp$index = 1:N
        xlim = c(0.4, N+0.6)

        plot.f=function(field, ylim) {
            fig.start(ofn=paste(fdir, "/", param, "_", field, ".pdf", sep=""), type="pdf", fdir=fdir, width=1+0.2*N, height=3)
            plot.init(xlim=xlim, ylim=ylim, x.axis=F, y.axis=F)
            lines(dfp$index, dfp[,field])
            points(dfp$index, dfp[,field], col=dfp$col, pch=19, cex=0.75)
            axis(side=2, cex.axis=0.7, las=1)
            axis(side=1, at=1:N, labels=dfp$value, cex.axis=0.7, las=2)
            fig.end()
        }
        plot.f(field="contig.bp", ylim.bp)
        plot.f(field="contig.count", ylim.count)
        plot.f(field="median.mbp", ylim.median.mbp)
    }
}
