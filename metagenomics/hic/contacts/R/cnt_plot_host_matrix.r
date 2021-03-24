plot.matrix.compare=function(ifn.bins, ifn.bins.sites, ifn.map, min.contacts, legend1, legend2, fdir)
{
    bins.df = load.table(ifn.bins)
    sites.df = load.table(ifn.bins.sites)
    map = load.table(ifn.map)

    ix = match(bins.df$bin, sites.df$bin)
    bins.df$nsites = ifelse(!is.na(ix), sites.df$nsites[ix], 0)

    map = map[map$count1 >= min.contacts | map$count2 >= min.contacts,]
    map$col = "black"
    map = map[is.element(map$host, bins.df$bin),]
#    map = map[is.element(map$host, bins.df$bin) & map$type == "element",]

    ss = c(map$score1, map$score2)

    mx = min(ss[ss>0])
    map$score1 = log10(pmax(mx, map$score1)) + 3
    map$score2 = log10(pmax(mx, map$score2)) + 3

    global.lim = range(c(map$score1, map$score2))
    plot.map=function(imap, add.labels=F, main, multi=F) {
        ilim = ifelse(rep(multi,2), global.lim, 1.2*range(c(0, imap$score1, imap$score2)))
        ilim[1] = -2
        # if (ilim[2] < 1) ilim[2] = 1
        plot.init(xlim=ilim, ylim=ilim, xlab=legend1, ylab=legend2, main=main, x.axis=!multi, y.axis=!multi)
        if (multi) {
            axis(1, labels=F)
            axis(2, labels=F)
        }
        abline(a=0, b=1, col=1, lty=3)
        abline(h=0, col=1, lty=3)
        abline(v=0, col=1, lty=3)

        points(x=imap$score1, y=imap$score2, col=imap$col, pch=19, cex=0.5)

        pos = 2
        if (add.labels && dim(imap)[1] > 0)
            text(x=imap$score1, y=imap$score2, pos=pos, labels=imap$label, cex=0.25)
    }

    height = 6
    width = 5

    height.clean = height * 0.75
    width.clean = width * 0.75

    fdir.hosts.clean = paste(fdir, "/bins/clean", sep="")
    fdir.hosts.labels = paste(fdir, "/bins/labels", sep="")
    system(sprintf("mkdir -p %s %s", fdir.hosts.clean, fdir.hosts.labels))

    hosts = sort(unique(map$host))
    N = length(hosts)
    cat(sprintf("plotting hosts: %d\n", N))
    for (i in 1:N) {
        host = hosts[i]
        nsites = bins.df$nsites[match(host,bins.df$bin)]

        main = paste(host, nsites)
        imap = map[map$host == host,]
        imap$label = imap$bin

        fig.start(fdir=fdir.hosts.clean, ofn=paste(fdir.hosts.clean, "/", host, ".pdf", sep=""),
                  type="pdf", height=height.clean, width=width.clean)
        plot.map(imap=imap, add.labels=F, main=main)
        fig.end()

        fig.start(fdir=fdir.hosts.labels, ofn=paste(fdir.hosts.labels, "/", host, ".pdf", sep=""),
                  type="pdf", height=height*2, width=width*2)
        plot.map(imap=imap, add.labels=T, main=main)
        fig.end()
    }

    # one bin large plot
    Ny = ceiling(sqrt(N))
    Nx = ceiling(N/Ny)
    NN = c(1:N,rep(N+1,Nx*Ny-N))
    fig.start(fdir=fdir, ofn=paste(fdir, "/bin_summary.pdf", sep=""), type="pdf", height=Ny*1, width=Nx*1)
    layout(matrix(NN, Nx, Ny, byrow=T))
    par(mai=c(0.1, 0.1, 0.25, 0.05))
    for (i in 1:N) {
        host = hosts[i]
        imap = map[map$host == host,]
        plot.map(imap=imap, add.labels=F, main=host, multi=T)
    }
    fig.end()
}
