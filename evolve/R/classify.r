classify.live=function(
    ifn.cores, ifn.elements, ifn.taxa,
    min.cov, min.detect, snp.density.threshold,
    ofn.cores, ofn.elements)
{
    cores = load.table(ifn.cores)
    taxa = load.table(ifn.taxa)
    elements = load.table(ifn.elements)

    cores$anchor.id = taxa$anchor.id[match(cores$anchor, taxa$anchor)]

    # if effective element length is shorter than the length required to generate the minimal number of mutations (given the snp estimation)
    # we classify it as umbigious ('unknown')
    min.muts = 2

    classify=function(df) {
        ifelse(df$median.cov < min.cov | df$detected.fraction < min.detect, "unknown",
               ifelse(df$live.density < snp.density.threshold, "simple", "complex"))
    }

    cores$class = classify(cores)
    elements$class = classify(elements)

    save.table(cores, ofn.cores)
    save.table(elements, ofn.elements)
}

classify.fate=function(
    ifn.cores, ifn.elements, ifn.taxa,
    min.cov, min.detect, snp.density.threshold,
    ofn.cores, ofn.elements)
{
    cores = load.table(ifn.cores)
    taxa = load.table(ifn.taxa)
    elements = load.table(ifn.elements)

    cores$anchor.id = taxa$anchor.id[match(cores$anchor, taxa$anchor)]

    # if effective element length is shorter than the length required to generate the minimal number of mutations (given the snp estimation)
    # we classify it as umbigious ('low.detected')
    # min.muts = 1

    ## classify=function(df) {
    ##     df$fate =
    ##         ifelse(df$detected.fraction < min.detect, "not.detected",
    ##                ifelse(df$median.cov < min.cov | (df$fixed.count == 0 & df$effective.length < min.muts/snp.density.threshold), "low.detected",
    ##                       ifelse(df$fixed.density < snp.density.threshold, "persist", "turnover")))
    ##     df
    ## }


    classify=function(df) {
        df$fixed.density = ifelse(df$fixed.count == 0, 0, df$fixed.density)
        ifelse(df$detected.fraction < min.detect, "not.detected",
               ifelse(df$median.cov < min.cov, "low.detected",
                      ifelse(df$fixed.density < snp.density.threshold, "persist", "turnover")))
    }

    cores$fate = classify(cores)
    elements$fate = classify(elements)

    save.table(cores, ofn.cores)
    save.table(elements, ofn.elements)
}

# select elements with low zscore values
select.elements=function(ifn, max.score, ofn)
{
    df = load.table(ifn)
    df = df[df$sd.zscore < max.score,]
    save.table(data.frame(element.id=df$element.id), ofn)
}

# filter according to selected set
filter.elements=function(ifn, ifn.select, ofn)
{
    df = load.table(ifn)
    ids = load.table(ifn.select)$element.id
    df = df[is.element(df$element.id, ids),]
    save.table(df, ofn)
}

###############################################################################################################
# plots
###############################################################################################################

plot.classify.live.breakdown=function(ifn.cores, ifn.elements, fdir)
{
    cores = load.table(ifn.cores)
    elements = load.table(ifn.elements)
    elements.single = elements[elements$type == "single",]
    elements.shared = elements[elements$type == "shared",]

    t.cores = table(cores$class)
    t.shared = table(elements.shared$class)
    t.single = table(elements.single$class)

    fig.start(fdir=fdir, ofn=paste(fdir, "/hosts.pdf", sep=""), type="pdf", height=4, width=2+length(t.cores)*0.4)
    mx = barplot(t.cores, col="darkblue", border=NA, ylim=c(0, max(t.cores)*1.1), las=2, ylab="#", main="host breakdown")
    text(x=mx, y=t.cores, t.cores, pos=3, cex=0.75)
    fig.end()

    counts = rbind(t.single, t.shared)
    per = 100 * counts / rowSums(counts)
    fig.start(fdir=fdir, ofn=paste(fdir, "/elements.pdf", sep=""), type="pdf", height=4, width=2+length(t.shared)*0.5)
    mx = barplot(per, beside=T, col=c("red", "orange"), border=NA, ylim=c(0, max(per)*1.1), las=2, ylab="%", main="element breakdown")
    text(x=mx, y=per, counts, pos=3, cex=0.75)
    fig.end()

    wlegend(fdir=fdir, names=c("single", "shared"), cols=c("red", "orange"), title="elements")
}

plot.classify.fate.breakdown=function(ifn.cores, ifn.elements, fdir)
{
    cores = load.table(ifn.cores)
    elements = load.table(ifn.elements)
    elements.single = elements[elements$type == "single",]
    elements.shared = elements[elements$type == "shared",]

    # levels.elements = c("chimeric", "not.detected", "low.detected", "turnover", "persist")
    levels.elements = c("not.detected", "low.detected", "turnover", "persist")
    levels.cores = c("not.detected", "low.detected", "turnover", "persist")

    t.cores = table(factor(cores$fate, levels=levels.cores))
    t.shared = table(factor(elements.shared$fate, levels=levels.elements))
    t.single = table(factor(elements.single$fate, levels=levels.elements))

    fig.start(fdir=fdir, ofn=paste(fdir, "/hosts.pdf", sep=""), type="pdf", height=5, width=2+length(t.cores)*0.4)
    par(mai=c(1.5,1,1,0.5))
    mx = barplot(t.cores, col="darkblue", border=NA, ylim=c(0, max(t.cores)*1.1), las=2, ylab="#", main="host breakdown")
    text(x=mx, y=t.cores, t.cores, pos=3, cex=0.75)
    fig.end()

    cols = c("darkblue", "blue")
    counts = rbind(t.single, t.shared)
    per = 100 * counts / rowSums(counts)
    pfunc=function(add.text) {
        fig.start(fdir=fdir, ofn=paste(fdir, "/elements", if (add.text) "_labels", ".pdf", sep=""), type="pdf", height=5, width=2+length(t.shared)*0.4)
        par(mai=c(1.5,1,1,0.5))
        mx = barplot(per, beside=T, col=cols, border=NA, ylim=c(0, max(per)*1.1), las=2, ylab="%", main="element breakdown")
        if (add.text) text(x=mx, y=per, counts, pos=3, cex=0.75)
        fig.end()
    }
    pfunc(add.text=F)
    pfunc(add.text=T)
    wlegend(fdir=fdir, names=c("single", "shared"), cols=cols, title="elements")

    ##################################################################################################################################
    # persistence probability
    ##################################################################################################################################

    get.prob=function(v) {
        ix = match("persist", names(v))
        100 * v[ix] / sum(v)
    }
    df = as.matrix(data.frame(cores=get.prob(t.cores), single=get.prob(t.single), shared=get.prob(t.shared)))
    fig.start(fdir=fdir, ofn=paste(fdir, "/persist_prob.pdf", sep=""), type="pdf", height=5, width=3)
    par(mai=c(1.5,1,1,0.5))
    mx = barplot(df, col="darkblue", border=NA, ylim=c(0, max(df)*1.1), las=2, ylab="%", main="persist probability")
    text(x=mx, y=df, round(df,1), pos=3, cex=0.75)
    fig.end()
}

element.host.combined.fate=function(ifn.cores, ifn.elements, ifn.element2core, ofn)
{
   cores = load.table(ifn.cores)
   elements = load.table(ifn.elements)
   e2c = load.table(ifn.element2core)

   elements = elements[!is.na(elements$fate),]

   cores$fate = paste("core", cores$fate, sep=".")
   elements$fate = paste("element", elements$fate, sep=".")

   e2c$host.fate = cores$fate[match(e2c$anchor, cores$anchor)]
   ss = sapply(split(e2c$host.fate, e2c$element.id), function(x) {
        if (any(x == "core.persist")) { return ("core.persist") }
        if (any(x == "core.turnover")) { return ("core.turnover") }
        if (any(x == "core.low.detected")) { return ("core.low.detected") }
        return ("core.not.detected")
    })
   ix = match(elements$element.id, names(ss))
   elements$host.fate = ss[ix]

   save.table(elements, ofn)
}
