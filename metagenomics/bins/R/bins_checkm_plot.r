plot.basic=function(ifn, min.complete, max.contam, subject.id, fdir)
{
    df = load.table(ifn)
    N = dim(df)[1]
    width = 1+N*0.15
    ix = order(df$Completeness, decreasing=T)

    n = sum(df$Contamination <= max.contam & df$Completeness >= min.complete)
    main = sprintf("%s, qualified bins: %d\n", subject.id, n)

    fig.start(fdir=fdir, ofn=paste(fdir, "/checkm.pdf", sep=""), type="pdf", width=width, height=5)
    plot.init(xlim=c(1,dim(df)[1]), ylim=c(0,100), xlab="genome", ylab="%", axis.las=1, main=main)
    abline(h=min.complete, col=1, lty=2)
    abline(h=max.contam, col=2, lty=2)
    points(1:dim(df)[1], df$Contamination[ix], pch=19, col=2)
    points(1:dim(df)[1], df$Completeness[ix], pch=19, col=1)
    grid()
    fig.end()
}
