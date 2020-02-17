plot.GO.compare.internal=function(idir, select.ver, ids, colors, fdir, type, add.text)
{
    go.ids = NULL
    for (id in ids) {
        df = load.table(paste(idir, "/geneset/", id, "/significant_", select.ver, "/table", sep=""))
        df = df[df$type == type,]
        go.ids = unique(c(go.ids, df$id))
    }

    table.en = data.frame(GO=go.ids, desc="")
    table.minus = data.frame(GO=go.ids)
    table.plus = data.frame(GO=go.ids)
    table.count = data.frame(GO=go.ids)
    table.mlp = data.frame(GO=go.ids)
    table.selected = data.frame(GO=go.ids)
    for (id in ids) {
        df = load.table(paste(idir, "/geneset/", id, "/merge", sep=""))
        df = df[df$type == type,]

        df.selected = load.table(paste(idir, "/geneset/", id, "/significant_", select.ver, "/table", sep=""))
        df.selected = df.selected[df.selected$type == type,]

        table.selected[,id] = is.element(table.selected$GO, df.selected$id)

        ix = match(table.en$GO, df$id)
        table.en$desc = ifelse(!is.na(ix), df$desc[ix], table.en$desc)
        table.en[,id] = ifelse(!is.na(ix), df$enrichment[ix], 0)
        table.count[,id] = ifelse(!is.na(ix), df$count[ix], 0)
        table.mlp[,id] = ifelse(!is.na(ix), df$minus.log.p[ix], 0)
        table.plus[,id] = ifelse(!is.na(ix), df$enrichment.plus[ix], 0)
        table.minus[,id] = ifelse(!is.na(ix), df$enrichment.minus[ix], 0)
    }

    table.en = table.en[order(table.en$acc, decreasing=F),]
    max.enrichment = apply(table.en[,-(1:2)], 1, max)
    mm = t(as.matrix(table.en[,-(1:2)]))

    table.count = table.count[match(table.en$GO, table.count$GO),]
    mm.count = t(as.matrix(table.count[,-1]))

    table.mlp = table.mlp[match(table.en$GO, table.mlp$GO),]
    mm.mlp = t(as.matrix(table.mlp[,-1]))

    table.selected = table.selected[match(table.en$GO, table.selected$GO),]
    mm.selected = t(as.matrix(table.selected[,-1]))

    table.minus = table.minus[match(table.en$GO, table.minus$GO),]
    mm.minus = t(as.matrix(table.minus[,-1]))
    table.plus = table.plus[match(table.en$GO, table.plus$GO),]
    mm.plus = t(as.matrix(table.plus[,-1]))

    wlegend(fdir=fdir, names=ids, cols=colors, title="sets")
    gap = 1
    ww = 1
    Nminor = dim(mm)[1]
    Nmajor = dim(mm)[2]
    N = Nminor * Nmajor
    axis.at = (1:Nmajor - 0.5) * (Nminor+gap)
    table.en$title = table.en$desc
    fig.start(fdir=fdir, ofn=paste(fdir, "/", type, if (add.text) "_labels", ".pdf", sep=""), type="pdf", height=0.1*dim(mm)[1]*dim(mm)[2]+2, width=12)
    par(mai=c(1, 7, 1, 0.5))
    xlim = c(0, 1.1*max(mm.plus))
    ylim = c(0, Nmajor*(Nminor+gap))

    if (add.text)
        xlim[2] = xlim[2]*1.2

    sig = function(mlp, selected) {
        pval = 10^(-mlp)
        # paste(round(mlp,1), ifelse(selected, "T", "F"))
        ifelse(!selected, "",
               ifelse(pval<0.001, "***",
                             ifelse(pval<0.01, "**",
                                    ifelse(pval<0.05, "*", ""))))
    }
    plot.init(xlim=xlim, ylim=ylim, xlab="enrichment", ylab="", main="", axis.las=1, grid.ny=NA, y.axis=F, xaxs="i")
    abline(v=1, lty=2)
    box()
    axis(2, at=axis.at, labels=table.en$title, las=1, tick=F)
    for (i in 1:Nmajor) {
        coords = 1:Nminor + (i-1) * (Nminor+gap)
        rect(xleft=mm.minus[,i], xright=mm.plus[,i], ybottom=coords-ww/2, ytop=coords+ww/2, col=colors, border=NA)
        segments(x0=mm[,i], x1=mm[,i], y0=coords-ww/2, y1=coords+ww/2, col=1, lwd=2)
        # if (add.text) text(x=mm.plus[,i], y=coords, sig(mm.mlp[,i], mm.selected[,i]), pos=4)
        if (add.text) text(x=mm.plus[,i], y=coords, sig(mm.mlp[,i], mm.selected[,i]), adj=-0.1)
    }
    par(xpd=NA)
    for (i in 1:Nmajor) {
        segments(x0=-0.4, x1=-0.4, y0=axis.at-Nminor/2-0.2, y1=axis.at+Nminor/2+0.2)
        segments(x0=-0.4, x1=0, y0=axis.at-Nminor/2-0.2, y1=axis.at-Nminor/2-0.2)
        segments(x0=-0.4, x1=0, y0=axis.at+Nminor/2+0.2, y1=axis.at+Nminor/2+0.2)
    }
    fig.end()
}

plot.GO.compare=function(idir, select.ver, ids, colors, fdir)
{
    types = c("component", "func", "process")
    for (type in types) {
        plot.GO.compare.internal(idir, select.ver, ids, colors, fdir, type, add.text=F)
        plot.GO.compare.internal(idir, select.ver, ids, colors, fdir, type, add.text=T)
    }
}
