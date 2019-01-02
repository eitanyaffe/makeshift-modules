compute.score.threshold=function(ifn.mat, ifn.contigs, mb.threshold, ofn.table, ofn.threshold)
{
    tab = load.table(ifn.contigs)
    mat = load.table(ifn.mat)
    mat$score = log10(mat$contacts / mat$factor) - mean(log10(mat$contacts / mat$factor))
    mat$length2 = tab$length[match(mat$contig2, tab$contig)]

    N = 100
    values = quantile(mat$score, 0:N/N)

    result = NULL
    for (value in values[-(N+1)]) {
        mat.v = mat[mat$score > value,]
        s = sapply(split(mat.v$length2, mat.v$contig1), sum)

        result = rbind(result, data.frame(score=value, mb=quantile(s, 0.99)/10^6))
    }
    save.table(result, ofn.table)

    result = result[order(result$mb),]

    if (mb.threshold < min(result$mb))
        stop(sprintf("trying to filter-out entire matrix, consider increasing the size threshold, currently set to %.0fMb", mb.threshold))

    if (mb.threshold > max(result$mb)) {
        cat(sprintf("no filtering of noise\n"))
        tt = min(mat$score)
    } else {
        ii = findInterval(mb.threshold, result$mb)
        tt = result$score[ii]
    }
    save.table(data.frame(threshold=tt), ofn.threshold)
}

filter.matrix=function(ifn.contigs, ifn.mat, ifn.threshold, ofn.mat, ofn.contigs, ofn.stats)
{
    mat = load.table(ifn.mat)
    tt = load.table(ifn.threshold)[,1]
    mat$score = log10(mat$contacts / mat$factor) - mean(log10(mat$contacts / mat$factor))
    selected = mat$score >= tt
    pp = 100 * sum(!selected) / length(selected)

    cat(sprintf("score threshold: %.2f\n", tt))
    cat(sprintf("number of filtered out inter-contig pairs: %d (%.1f%%)\n", sum(!selected), pp))

    stats = data.frame(total.pairs=dim(mat)[1], ok.pairs=sum(selected), noise.pairs=sum(!selected))
    save.table(stats, ofn.stats)

    mat = mat[selected,]
    save.table(mat, ofn.mat)

    contigs = unique(c(mat$contig1, mat$contig2))
    df = load.table(ifn.contigs)
    selected = is.element(df$contig, contigs)
    pp = 100 * sum(!selected) / length(selected)
    cat(sprintf("number of filtered out contigs: %d (%.1f%%)\n", sum(!selected), pp))
    df = df[selected,]
    save.table(df, ofn.contigs)
}

plot.score.threshold=function(ifn.table, ifn.threshold, fdir)
{
    df = load.table(ifn.table)
    tt = load.table(ifn.threshold)[,1]
    main = paste("score threshold=", round(tt,4), sep="")
    fig.start(fdir=fdir, ofn=paste(fdir, "/score_threshold.pdf", sep=""), type="pdf", width=6, height=6)
    plot(df$score, df$mb, type="l", xlab="score", ylab="top99 of neighbour size (mb)", main=main)
    grid()
    abline(v=tt, lty=2)
    fig.end()
}

plot.filter.scatter=function(ifn.mat, ifn.threshold, fdir)
{
    mat = load.table(ifn.mat)
    tt = load.table(ifn.threshold)[,1]
    mat$score = log10(mat$contacts / mat$factor) - mean(log10(mat$contacts / mat$factor))

    fig.start(fdir=fdir, ofn=paste(fdir, "/filter_scatter.pdf", sep=""), type="pdf", width=6, height=6)
    plot(log10(1+mat$contacts), mat$score, xlab="contacts", ylab="score", pch=".")
    grid()
    abline(h=tt, lty=2)
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/filter_density.pdf", sep=""), type="pdf", width=6, height=6)
    plot(density(mat$score), xlab="score", ylab="density")
    grid()
    abline(v=tt, lty=2)
    fig.end()
}
