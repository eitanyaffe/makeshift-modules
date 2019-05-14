wf.sim=function(N2, u.per.bp, genome.length, M, sample.generations, clonal=T)
{
    u = u.per.bp * genome.length
    mut.count = round(N2 * u)

    # cat(sprintf("2N=%f ,u=%f, theta=%f, mut.per.generations=%d\n", N2, u, N2*u*4, mut.count))

    if (mut.count < 1)
        stop("internal error")

    if (clonal) {
        vv = rep("0",N2)
        mi.base = 0
    } else {
        vv = 1:N2
        mi.base = N2+1
    }

    result = NULL
    for (ii in 1:M) {
        vv = sample(vv, N2, replace=T)
        mi = seq(mi.base+1, mi.base+mut.count)
        vv[1:mut.count] = paste(vv[1:mut.count], mi, sep="_")
        mi.base = mi.base + mut.count

        if (is.element(ii, sample.generations)) {
            tt = sort(table(strsplit(x=paste(vv, sep="_", collapse="_"), split="_")), decreasing=T) / N2
            fixed.count = sum(tt == 1) - 1
            fixed.density = fixed.count / genome.length
            live.count = sum(0.2 < tt & tt < 0.8)
            live.density = live.count / genome.length
            df = data.frame(N2=N2, u=u, u.per.bp=u.per.bp,
                fixed.count=fixed.count, fixed.density=fixed.density,
                live.count=live.count, live.density=live.density, generations=ii)
            result = rbind(result, df)
        }
    }
    result
}

wf.sample=function(N2, u.per.bp, genome.length, M, sample.generations, sample.size=10)
{
    u = u.per.bp * genome.length
    mut.count = round(N2 * u)
    cat(sprintf("2N=%f ,u=%f, mut.count=%d, generations=%d, sample.size=%d\n", N2, u, mut.count, M, sample.size))
    result = NULL
    for (i in 1:sample.size) {
        cat(sprintf("%d...", i))
        flush.console()
        result = rbind(result, wf.sim(N2=N2, u.per.bp=u.per.bp, genome.length=genome.length, sample.generations=sample.generations, M=M))
    }
    cat("\n")
    result
}

wf.temporal=function(N2, sample.size, genome.length, u.per.bp, end.factor, step.factor, ofn)
{
    step.size = step.factor * N2
    end.step = (end.factor * N2) / step.size
    sample.generations = step.size * (1:end.step)
    M = max(sample.generations)
    df = wf.sample(N2=N2, u.per.bp=u.per.bp, genome.length=genome.length, sample.size=sample.size, sample.generations=sample.generations, M=M)
    save.table(df, ofn)
}

wf.temporal=function(N2, sample.size, genome.length, u.per.bp, end.factor, step.factor, ofn)
{
    step.size = step.factor * N2
    end.step = (end.factor * N2) / step.size
    sample.generations = step.size * (1:end.step)
    M = max(sample.generations)
    df = wf.sample(N2=N2, u.per.bp=u.per.bp, genome.length=genome.length, sample.size=sample.size, sample.generations=sample.generations, M=M)
    save.table(df, ofn)
}

wf.pop=function(N2.begin, N2.end, N2.logstep, sample.size, genome.length, u.per.bp, factor, ofn)
{
    N2s = round(10^(seq(log10(N2.begin), log10(N2.end), by=N2.logstep)))
    u = u.per.bp * genome.length
    result = NULL
    cat(sprintf("N2: %s\n", paste(N2s, sep="", collapse=",")))
    for (N2 in N2s) {
        M = factor * N2
        mut.count = round(N2 * u)
        df = wf.sample(N2=N2, u.per.bp=u.per.bp, genome.length=genome.length, sample.size=sample.size, sample.generations=M, M=M)
        result = rbind(result, df)
    }

    save.table(result, ofn)
}


################################################################################################################
# plots
################################################################################################################

wf.plot=function(ifn, fdir)
{
    df = load.table(ifn)

    plot.f=function(field, xlim=c(-7,-2), zero.value=10^-7) {
        s = split(df[,field], df$generations)

        main = sprintf("%s 2N=%d, u=%f", field, df$N2[1], df$u[1])
        fig.start(fdir=fdir, ofn=paste(fdir, "/", field, "_temporal.pdf", sep=""), type="pdf", height=4, width=8)
        boxplot(s, las=2, xlab="generation", outline=F)
        title(main=main)
        fig.end()

        max.gen = max(df$generations)
        values = df[df$generations == max.gen,field]
        values[values == 0] = zero.value
        fig.start(fdir=fdir, ofn=paste(fdir, "/", field, "_last_ecdf.pdf", sep=""), type="pdf", height=6, width=6)
        plot(ecdf(log10(values)), xlim=xlim, xlab="SNPs/bp (log10)", main=field)
        grid()
        plot(ecdf(log10(values)), xlim=xlim, xlab="SNPs/bp (log10)", main="", add=T)
        fig.end()

        fig.start(fdir=fdir, ofn=paste(fdir, "/", field, "_density.pdf", sep=""), type="pdf", height=6, width=6)
        plot(density(values), xlab="", main=field)
        fig.end()
    }
    plot.f("live.density")
    plot.f("fixed.density")
    plot.f("fixed.count", xlim=c(0, 3), zero.value=1)
}

wf.plot.pop=function(ifn, fdir)
{
    df = load.table(ifn)
    plot.f=function(field, xlim=c(-7,-2), zero.value=10^-7) {
        s = split(df[,field], df$N2)

        main = sprintf("%s u=%f", field, df$u[1])
        fig.start(fdir=fdir, ofn=paste(fdir, "/", field, "_pop.pdf", sep=""), type="pdf", height=4, width=8)
        par(mai=c(1,1.5,1,0.5))
        boxplot(s, las=2, xlab="N2", outline=F)
        title(main=main)
        fig.end()
    }
    plot.f("live.density")
    plot.f("fixed.density")

    plot.s=function(field, xlim=c(-7,-2), zero.value=10^-7) {
        s = sapply(split(df[,field], df$N2), median)
        ss = data.frame(N2=as.numeric(names(s)), value=s)
        main = sprintf("%s u=%f", field, df$u[1])
        fig.start(fdir=fdir, ofn=paste(fdir, "/", field, "_scatter.pdf", sep=""), type="pdf", height=4, width=4)
        plot(log10(ss$N2), log10(ss$value), pch=19, cex=0.5, las=2)
        grid()
        title(main=main)
        fig.end()
    }
    plot.s("live.density")
    plot.s("fixed.density")
}
