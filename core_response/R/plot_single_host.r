plot.single.host.element.detailed=function(
    ifn.anchors, ifn.element2anchor, ifn.norm,
    ifn.detection, disturb.ids, base.ids, base.min.correlation, labels, fdir)
{
    get.response.cluster=function(clusters)
    {
        log10(norm[match(clusters, norm$cluster), -1])
    }

    anchor.table = load.table(ifn.anchors)
    norm = load.table(ifn.norm)
    element2anchor = load.table(ifn.element2anchor)

    anchor.ids = anchor.table$id
    anchor.ids = anchor.ids[is.element(anchor.ids, norm$cluster)]

    fc = field.count(element2anchor, "element.id")
    selected = fc$element.id[fc$count > 1]
    element2anchor = element2anchor[is.element(element2anchor$element.id, norm$cluster) & is.element(element2anchor$element.id,selected),]

    norm = norm[,-2]
    min.score = log10(load.table(ifn.detection)[1,1])

    ids = colnames(norm)[-1]
    dindex = which(is.element(ids, disturb.ids))
    drange = c(min(dindex)-1, max(dindex))

    base.index = which(is.element(ids, base.ids))

    M = dim(norm)[2] - 1
    coords = 1:M
    ylim = c(-2, 3)
    ylim.diff = c(-2, 3)

    get.responses=function(anchor.id, filter.base) {
        anchor = anchor.table$set[match(anchor.id, anchor.table$id)]
        clusters = element2anchor$element.id[element2anchor$anchor == anchor]
        cluster.response = get.response.cluster(clusters)
        host.response = get.response.cluster(anchor.id)
        if (filter.base) {
            cc = cor(t(cluster.response[,base.index]), t(host.response[,base.index]))
            if (all(cc<base.min.correlation))
                return (NULL)
            cluster.response = cluster.response[cc>=base.min.correlation,]
        }
        list(host.response=host.response, cluster.response=cluster.response)
    }
    plot.response=function(anchor.id, multi=F, filter.base=T) {
        ll = get.responses(anchor.id=anchor.id, filter.base=filter.base)
        if (is.null(ll)) {
            plot.empty(title="no elements")
            return (NULL)
        }
        K = dim(ll$cluster.response)[1]
        plot.init(xlim=c(1,M), ylim=ylim, main=anchor.id, x.axis=F, y.axis=F)
        abline(h=0)
        at = drange+0.5
        abline(v=at, lwd=2, lty=2)
        if (K > 0)
            for (i in 1:K)
                lines(x=coords, y=ll$cluster.response[i,], lwd=1, col="gray")
        lines(x=coords, y=ll$host.response, lwd=2, col=1)

        if (!multi) {
            axis(side=1, labels=labels, at=1:M, las=2)
            axis(side=2, las=2)
        }
    }

    plot.response.diff=function(anchor.id, multi=F, filter.base=T) {
        ll = get.responses(anchor.id=anchor.id, filter.base=filter.base)
        if (is.null(ll)) {
            plot.empty(title="no elements")
            return (NULL)
        }
        K = dim(ll$cluster.response)[1]
        clusters = rownames(ll$cluster.response)
        delta.cluster.response = as.matrix(ll$cluster.response) - matrix(rep(unlist(ll$host.response), K), nrow=K, ncol=M, byrow=T)
        plot.init(xlim=c(1,M), ylim=ylim.diff, main=anchor.id, x.axis=F, y.axis=F)
        abline(h=0, lty=3)
        at = drange+0.5
        abline(v=at, lwd=2, lty=2)
        # abline(h=0, lty=3)
        colors = colorpanel(K, "orange", "purple")
        if (K > 0)
            for (i in 1:K)
                lines(x=coords, y=delta.cluster.response[i,], lwd=1, col=colors[i])

        if (!multi) {
            axis(side=1, labels=labels, at=1:M, las=2)
            axis(side=2, las=2)
            legend("topright", legend=clusters, fill=colors)
        }
    }

    # united plot
    N = length(anchor.ids)
    Ny = ceiling(sqrt(N))
    Nx = ceiling(N/Ny)
    NN = c(1:N,rep(N+1,Nx*Ny-N))

    ####################################
    # elements and host
    ####################################

    fig.start(fdir=fdir, ofn=paste(fdir, "/all.pdf", sep=""), type="pdf", height=10, width=10)
    layout(matrix(NN, Nx, Ny, byrow=T))
    par(mai=c(0.05, 0.05, 0.15, 0.05))
    for (anchor.id in anchor.ids)
        plot.response(anchor.id=anchor.id, multi=T)
    fig.end()

    # anchor plots
    ffdir = paste(fdir, "/anchors", sep="")
    for (anchor.id in anchor.ids) {
        fig.start(fdir=ffdir, ofn=paste(ffdir, "/", anchor.id, ".pdf", sep=""), type="pdf", height=3, width=6)
        plot.response(anchor.id=anchor.id, multi=F)
        fig.end()
    }

    ####################################
    # elements over host response
    ####################################

    fig.start(fdir=fdir, ofn=paste(fdir, "/all_diff.pdf", sep=""), type="pdf", height=10, width=10)
    layout(matrix(NN, Nx, Ny, byrow=T))
    par(mai=c(0.05, 0.05, 0.15, 0.05))
    for (anchor.id in anchor.ids)
        plot.response.diff(anchor.id=anchor.id, multi=T)
    fig.end()

    # anchor plots
    ffdir = paste(fdir, "/anchors_diff", sep="")
    for (anchor.id in anchor.ids) {
        fig.start(fdir=ffdir, ofn=paste(ffdir, "/", anchor.id, ".pdf", sep=""), type="pdf", height=3, width=6)
        plot.response.diff(anchor.id=anchor.id, multi=F)
        fig.end()
    }
}
