plot.checkm=function(ifn, min.complete, max.contam, fdir)
{
    qa = load.table(ifn)
    qa = qa[qa$Completeness >= 10,]

    N = dim(qa)[1]
    width = 1+N*0.15

    fig.start(fdir=fdir, ofn=paste(fdir, "/checkm_diagram.pdf", sep=""), type="pdf", width=width, height=5)
    ix = order(qa$Completeness, decreasing=T)
    plot.init(xlim=c(1,dim(qa)[1]), ylim=c(0,100), xlab="genome", ylab="%", axis.las=1)
    # plot(1:dim(qa)[1], qa$Completeness[ix], type="p", pch=19, col=1, ylim=c(0,100), las=2, xlab="genome", ylab="%")
    points(1:dim(qa)[1], qa$Contamination[ix], pch=19, col=2)
    points(1:dim(qa)[1], qa$Completeness[ix], pch=19, col=1)
    grid()
    abline(h=min.complete, col=1, lty=2)
    abline(h=max.contam, col=2, lty=2)
    fig.end()
}
