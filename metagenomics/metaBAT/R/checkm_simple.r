plot.analysis=function(ifn, fdir)
{
    qa = load.table(ifn)

    fig.start(fdir=fdir, ofn=paste(fdir, "/checkm_diagram.pdf", sep=""), type="pdf", width=width, height=5)
    ix = order(qa$Completeness, decreasing=T)
    plot.init(xlim=c(1,dim(qa)[1]), ylim=c(0,100), xlab="genome", ylab="%", axis.las=1)
    # plot(1:dim(qa)[1], qa$Completeness[ix], type="p", pch=19, col=1, ylim=c(0,100), las=2, xlab="genome", ylab="%")
    points(1:dim(qa)[1], qa$Contamination[ix], pch=19, col=2)
    points(1:dim(qa)[1], qa$Completeness[ix], pch=19, col=1)
    grid()
    fig.end()
}
