midas.matrix=function(idir, ids, min.abundance, odir)
{
    fns = c("count_reads.txt", "coverage.txt", "relative_abundance.txt")
    ifns = paste(idir, "/", fns, sep="")
    ofns = paste(odir, "/", fns, sep="")

    # use abundance
    df = load.table(paste(idir, "/relative_abundance.txt", sep=""))

    # limit to selected samples
    ix = c(1, match(ids, names(df)))
    df = df[,ix]

    # identify abundant species
    iy = apply(df[,-1], 1, function(x) {sum(x>min.abundance)})>0

    for (i in 1:length(fns)) {
        df = load.table(ifns[i])
        df = df[iy,ix]
        save.table(df, ofns[i])
    }
}

plot.midas.matrix=function(ifn, ifn.order, fdir)
{
    ot = load.table(ifn.order)
    df = load.table(ifn)

    colors = c("white", "blue", "red", "orange")
    breaks = c(0, 0.01, 0.1, 1)
    panel = make.color.panel(colors=colors)
    wlegend2(fdir=fdir, panel=panel, breaks=breaks, title="abundance")

    plot.mat=function(df, title) {
        sample.ids = names(df)[-1]
        sample.labels = paste(ot$desc[match(sample.ids,ot$id)], sample.ids, sep=" | ")
        N = length(sample.ids)

        species.ids = df$species_id
        M = length(species.ids)

        sm = matrix2smatrix(as.matrix(df[,-1]))
        sm$col = panel[vals.to.cols(sm$value, breaks)]

        xlim = c(0, N)
        ylim = c(0, M)

        fig.start(fdir=fdir, ofn=paste(fdir, "/", title, ".pdf", sep=""), type="pdf", height=3+0.1*M, width=3+0.15*N)
        par(mai=c(2,2,1,0.5))
        plot.init(xlim=xlim, ylim=ylim, xaxs="i", yaxs="i", add.grid=F, x.axis=F, y.axis=F)
        rect(sm$j-1, sm$i-1, sm$j, sm$i, col=sm$col, border=NA)
        axis(side=1, labels=sample.labels, at=1:N - 0.5, las=2, cex.axis=0.75)
        axis(side=2, labels=species.ids, at=1:M - 0.5, las=2, cex.axis=0.5)
        fig.end()
    }

    # cluster
    dd.species = dist(as.matrix(df[,-1]))
    hh.species = hclust(dd.species)
    dd.samples = dist(t(as.matrix(df[,-1])))
    hh.samples = hclust(dd.samples)
    sample.ids = names(df)[-1]

    #####################################################################
    # raw
    #####################################################################

    plot.mat(df, "raw")

    #####################################################################
    # cluster only species
    #####################################################################

    df.species = df[hh.species$order,]
    plot.mat(df.species, "cluster_species")

    #####################################################################
    # cluster both ways
    #####################################################################

    clustered.sample.ids = sample.ids[hh.samples$order]
    df.both = df[hh.species$order, c("species_id", clustered.sample.ids)]
    plot.mat(df.both, "cluster_both")

    #####################################################################
    # sort samples by table
    #####################################################################

    sample.order = order(ot$order[match(sample.ids,ot$id)])
    sorted.sample.ids = sample.ids[sample.order]
    df.sample.order = df[hh.species$order,c("species_id", sorted.sample.ids)]

    plot.mat(df.sample.order, "sample_order")
}

plot.midas.pies=function(ifn, ifn.order, fdir)
{
    ot = load.table(ifn.order)
    df = load.table(ifn)
    df = df[order(df$species_id),]

    threshold = 0.05

    species = df$species_id
    N = length(species)
    species.colors = rainbow(N)

    sample.ids = names(df)[-1]
    for (sample.id in sample.ids) {
        values = df[,sample.id]
        oo = order(values, decreasing=T)
        values = values[oo]
        species.sample = species[oo]

        if (sum(values) == 0)
            next

        ovalues = sum(values[values<threshold])
        ix = values >= threshold
        values = c(values[ix], ovalues)
        species.sample = c(species.sample[ix], "other")
        col = ifelse(species.sample == "other", "gray", species.colors[match(species.sample,species)])
        fig.start(fdir=fdir, ofn=paste(fdir, "/", sample.id, ".pdf", sep=""), type="pdf", height=3, width=3)
        pie(values, species.sample, col=col, border=NA, cex=0.5)
        fig.end()
    }
}

plot.midas.samples=function(ifn, ifn.order, fdir)
{
    ot = load.table(ifn.order)
    df = load.table(ifn)
    sample.ids = names(df)[-1]
    sample.labs = paste(sample.ids, " (", ot$desc[match(sample.ids,ot$id)], ")", sep="")

    values.stool = 100*df[,ot$id[ot$desc == "Stool"]]
    values.saliva = 100*df[,ot$id[ot$desc == "Saliva"]]

    get.enr=function(vals, ctrl) {
        vals[vals<threshold] = threshold
        ctrl[ctrl<threshold] = threshold
        ifelse(vals==threshold & ctrl==threshold, -3, log10(vals/ctrl))
    }

    threshold = 0.1
    lim = log10(c(threshold,100))
    for (i in 1:length(sample.ids)) {
        sample.id = sample.ids[i]
        sample.lab = sample.labs[i]
        values.sample = 100*df[,sample.id]
        values.sample[values.sample<threshold] = threshold

        plot.f=function(fdir, add.text) {
            fig.start(fdir=fdir, ofn=paste(fdir, "/", sample.id, ".pdf", sep=""), type="pdf", height=3, width=9-1.8)
            layout(matrix(1:3, 1, 3))
            par(mai=c(0.8, 0.7, 0.6, 0.1))

            # compare enrichments
            stool.enrich = get.enr(vals=values.sample, ctrl=values.stool)
            saliva.enrich = get.enr(vals=values.sample, ctrl=values.saliva)
            elim = c(-3,3)
            plot.init(xlim=elim, ylim=elim, main=paste(sample.lab, "\nenrichments"), xlab="stool enrichment", ylab="saliva enrichment", axis.las=2)
            points(stool.enrich, saliva.enrich, pch=19, cex=0.3)
            abline(a=0, b=1, lty=2, col="gray")
            if (add.text) {
                text(stool.enrich, saliva.enrich, df$species_id, pos=4, cex=0.3)
            }

            plot.ff=function(values.ctrl, title.ctrl) {
                values.ctrl[values.ctrl <= threshold] = threshold
                plot.init(xlim=lim, ylim=lim, main=title.ctrl, xlab=title.ctrl, ylab=sample.id, axis.las=2)
                points(log10(values.ctrl), log10(values.sample), pch=19, cex=0.3)
                abline(a=0, b=1, lty=2, col="gray")
                if (add.text) {
                    text(log10(values.ctrl), log10(values.sample), df$species_id, pos=4, cex=0.3)
                }
            }

            # compare to controls
            plot.ff(values.ctrl=values.stool, title.ctrl="stool")
            plot.ff(values.ctrl=values.saliva, title.ctrl="saliva")

            fig.end()

        }
        plot.f(fdir=paste(fdir, "/clean", sep=""), add.text=F)
        plot.f(fdir=paste(fdir, "/text", sep=""), add.text=T)
    }
}

plot.midas.species=function(ifn, ifn.order, fdir)
{
    ot = load.table(ifn.order)
    df = load.table(ifn)
    sample.ids = names(df)[-1]
    sample.labs = paste(sample.ids, " (", ot$desc[match(sample.ids,ot$id)], ")", sep="")
    species.ids = df$species_id

    sample.order = order(ot$order[match(sample.ids,ot$id)])
    sorted.sample.ids = sample.ids[sample.order]
    df = df[,c("species_id", sorted.sample.ids)]

    sample.ids = names(df)[-1]
    sample.labs = paste(ot$desc[match(sample.ids,ot$id)], " | ", sample.ids, sep="")
    N = length(sample.ids)
    for (species.id in species.ids) {
        vals = as.matrix(df[df$species_id == species.id,-1])

        plot.f=function(fdir, add.text) {
            fig.start(fdir=fdir, ofn=paste(fdir, "/", species.id, ".pdf", sep=""), type="pdf", height=4, width=2+N*0.12)
            par(mai=c(2,0.8,0.8,0.5))
            mm = barplot(100*vals, names.arg=sample.labs, las=2, ylim=c(0,100), ylab="%", cex.names=0.75, col="darkblue", border=NA)
            if (add.text)
                text(mm, 100*vals, round(100*vals,1), pos=3, cex=0.5)
            title(main=species.id)
            fig.end()
        }
        plot.f(fdir=paste(fdir, "/clean", sep=""), add.text=F)
        plot.f(fdir=paste(fdir, "/text", sep=""), add.text=T)
    }
}

plot.midas.counts=function(ifn, fdir)
{
    df = load.table(ifn)
    tt = colSums(df[,-1])
    sample.ids = names(df)[-1]
    N = length(sample.ids)
    ylim = c(0, 1.2*max(tt))

    fig.start(fdir=fdir, ofn=paste(fdir, "/read_count.pdf", sep=""), type="pdf", height=6, width=2+N*0.12)
    par(mai=c(2,0.8,0.8,0.5))
    barplot(tt, names.arg=names(tt), las=2, ylab="#reads", cex.names=0.75, col="gray", border=NA, ylim=ylim)
    title(main="midas total reads")
    fig.end()


    fig.start(fdir=fdir, ofn=paste(fdir, "/read_count_text.pdf", sep=""), type="pdf", height=6, width=2+N*0.12)
    par(mai=c(2,0.8,0.8,0.5))
    mm = barplot(tt, names.arg=names(tt), las=2, ylab="#reads", cex.names=0.75, col="gray", border=NA, ylim=ylim)
    text(mm, tt, tt, pos=3, cex=0.7)
    title(main="midas total reads")
    fig.end()
}

