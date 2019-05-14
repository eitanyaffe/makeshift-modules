plot.coverage=function(
    ifn.hosts.current, ifn.hosts.10y,
    ifn.elements.current, ifn.elements.10y, fdir)
{
    hosts.cur = load.table(ifn.hosts.current)
    hosts.10y = load.table(ifn.hosts.10y)
    elements.cur = load.table(ifn.elements.current)
    elements.10y = load.table(ifn.elements.10y)

    mm.hosts = merge(hosts.cur, hosts.10y, by="anchor")
    hosts = data.frame(anchor=mm.hosts$anchor, cov.cur=mm.hosts$median.cov.x, cov.10y=mm.hosts$median.cov.y)

    mm.elements = merge(elements.cur, elements.10y, by="element.id")
    elements = data.frame(anchor=mm.elements$element.id, cov.cur=mm.elements$median.cov.x, cov.10y=mm.elements$median.cov.y)

    xlim = range(elements$cov.cur+1)
    ylim = range(elements$cov.10y+1)
    fig.start(fdir=fdir, ofn=paste(fdir, "/elements.pdf", sep=""), type="pdf", height=4, width=4)
    plot.init(xlim=xlim, ylim=ylim, xlab="current", ylab="10y", main="elements x-cov", axis.las=2, log="xy")
    points(elements$cov.cur+1, elements$cov.10y+1, pch=".", cex=2)
    fig.end()

    xlim = range(hosts$cov.cur+1)
    ylim = range(hosts$cov.10y+1)
    fig.start(fdir=fdir, ofn=paste(fdir, "/hosts.pdf", sep=""), type="pdf", height=4, width=4)
    plot.init(xlim=xlim, ylim=ylim, xlab="current", ylab="10y", main="hosts x-cov", axis.las=2, log="xy")
    points(hosts$cov.cur+1, hosts$cov.10y+1, pch=".", cex=2)
    fig.end()
}
