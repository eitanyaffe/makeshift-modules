plot.contig=function(prefix, contig, fdir)
{
    df = load.table(paste(prefix, ".1", sep=""))
    df.final = load.table(paste(prefix, ".final", sep=""))
    mm = load.table(paste(prefix, ".mat", sep=""))

    ################################################################################################
    # pvalues
    ################################################################################################

    vals = -log10(c(df.final$Pvalue, df$Pvalue))
    ylim = c(0, max(vals[is.finite(vals)]))
    x = df$coord
    fig.start(fdir=fdir, ofn=paste(fdir, "/", contig, "_P.pdf", sep=""), type="pdf", height=3, width=6)
    plot(x, -log10(df$Pvalue), type="l" ,ylim=ylim)
    lines(x, -log10(df.final$Pvalue), type="l", col="blue")
    df.outliers = df[!df.final$is_center,]
    points(df.outliers$coord, rep(0, dim(df.outliers)[1]), col="red")
    fig.end()

    ################################################################################################
    # weights
    ################################################################################################

    fig.start(fdir=fdir, ofn=paste(fdir, "/", contig, "_w.pdf", sep=""), type="pdf", height=3, width=6)
    plot(x, df$weight, type="l")
    fig.end()

    ################################################################################################
    # count/freq matrices
    ################################################################################################

    colors = c("white", "blue", "red", "orange", "green")
    breaks = c(0, 1, 10, 100, 1000)
    panel = make.color.panel(colors=colors)
    wlegend2(fdir=fdir, panel=panel, breaks=breaks, title="counts")

    sm = matrix2smatrix(as.matrix(mm[,-1]))
    sm$col = panel[vals.to.cols(sm$value, breaks)]
    N = max(sm$i)
    M = max(sm$j)

    fig.start(fdir=fdir, type="pdf", ofn=paste(fdir, "/count_mat.pdf", sep=""), height=6, width=6)
    plot.new()
    plot.window(xlim=c(0,N), ylim=c(1,M))
    rect(sm$i-1, sm$j-1, sm$i, sm$j, col=sm$col, border=NA)
    box()
    fig.end()

    ################################################################################################
    # count/freq matrices
    ################################################################################################

    freq.colors = c("white", "blue", "red", "orange", "green")
    freq.breaks = c(0, 0.05, 0.1, 0.2, 1)
    freq.panel = make.color.panel(colors=freq.colors)
    wlegend2(fdir=fdir, panel=freq.panel, breaks=freq.breaks, title="freq")

    mm = as.matrix(mm[,-1]) + 0.01
    mm = mm/rowSums(mm)
    sm = matrix2smatrix(mm)
    sm$col = freq.panel[vals.to.cols(sm$value, freq.breaks)]
    N = max(sm$i)
    M = max(sm$j)

    fig.start(fdir=fdir, type="pdf", ofn=paste(fdir, "/freq_mat.pdf", sep=""), height=6, width=6)
    plot.new()
    plot.window(xlim=c(0,N), ylim=c(1,M))
    rect(sm$i-1, sm$j-1, sm$i, sm$j, col=sm$col, border=NA)
    box()
    fig.end()
}
