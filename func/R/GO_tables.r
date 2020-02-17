prep.df=function(df) {
    start = match("minus.log.p", names(df))+1
    end = dim(df)[2]
    count.fields = names(df)[start:end]
    fields = c("type", "id","desc", "enrichment", "minus.log.p", count.fields)

    df = df[order(df$type, -df$enrichment), fields]

    df$minus.log.p = round(df$minus.log.p,1)
    df$enrichment = round(df$enrichment,1)
    df
}

GO.tables=function(idir, select.ver, ids, odir)
{
    system(paste("mkdir -p", odir))

    for (id in ids) {
        if (id == "bg")
            next
        ofn = paste(odir, "/", id, ".txt", sep="")
        df = load.table(paste(idir, "/geneset/", id, "/significant_", select.ver, "/table", sep=""))
        df = prep.df(df)
        save.table(df, ofn)
    }
}

merge.subjects=function(idir1.id, idir2.id, select.ver, min.log.pvalue, min.gene.count, min.enrichment)
{
    df1 = read.delim(paste(idir1.id, "/significant_", select.ver, "/table", sep=""))
    df2 = read.delim(paste(idir2.id, "/significant_", select.ver, "/table", sep=""))

    gos = intersect(df1$id, df2$id)

    df1 = read.delim(paste(idir1.id, "/final", sep=""))
    df2 = read.delim(paste(idir2.id, "/final", sep=""))

#    gos = intersect(df1$id, df2$id)

    # df1 = prep.df(df1)
    # df2 = prep.df(df2)
    rdf = rbind(df1, df2)

    # shared
    df = data.frame(id=gos)
    df$type = rdf$type[match(df$id, rdf$id)]
    df$desc = rdf$desc[match(df$id, rdf$id)]
    fields = names(df1)[-(1:3)]
    ix1 = match(df$id, df1$id)
    ix2 = match(df$id, df2$id)
    get.field=function(field, df.subject, ix, default.value) {
        ifelse(!is.na(ix), df.subject[ix,field], default.value)
    }
    for (field in fields) {
        field.sub = paste(field, "_1", sep="")
        default.value = ""
        df[,field.sub] = get.field(field=field, df.subject=df1, ix=ix1, default.value=default.value)
    }
    for (field in fields) {
        field.sub = paste(field, "_2", sep="")
        df[,field.sub] = get.field(field=field, df.subject=df2, ix=ix2, default.value=default.value)
    }
    df$count = df1$count[ix1] + df2$count[ix2]
    df$count.total = df1$count.total[ix1] + df2$count.total[ix2]
    df$count.ctrl = df1$count.ctrl[ix1] + df2$count.ctrl[ix2]
    df$count.ctrl.total = df1$count.ctrl.total[ix1] + df2$count.ctrl.total[ix2]
    df$enrichment = (df$count / df$count.total) / (df$count.ctrl / df$count.ctrl.total)
    df$minus.log.p = df$minus.log.p_1 + df$minus.log.p_2

#    df = df[df$minus.log.p >= min.log.pvalue & df$count >= min.gene.count & df$enrichment >=  min.enrichment &
#        df$minus.log.p_1 >= min.log.pvalue & df$minus.log.p_2 >= min.log.pvalue,]

    df
}

GO.table.subjects=function(
    idir1, idir2, select.ver, ids,
    min.log.pvalue, min.gene.count, min.enrichment,
    reduce.tree.script, ifn.go.tree, rnd.count, odir)
{
    system(paste("mkdir -p", odir))

    for (id in ids) {
        if (id == "bg")
            next
        df = merge.subjects(
            idir1.id=paste(idir1, "/geneset/", id, sep=""),
            idir2.id=paste(idir2, "/geneset/", id, sep=""),
            min.log.pvalue=min.log.pvalue, min.gene.count=min.gene.count, min.enrichment=min.enrichment,
            select.ver=select.ver)
        df = df[order(df$minus.log.p, decreasing=T),]
        rnd.p.values = NULL
        for (i in 1:rnd.count) {
            df.rnd = merge.subjects(
                idir1.id=paste(idir1, "/geneset/", id, "/FDR_dir/", i, sep=""),
                idir2.id=paste(idir2, "/geneset/", id, "/FDR_dir/", i, sep=""),
                min.log.pvalue=min.log.pvalue, min.gene.count=min.gene.count, min.enrichment=min.enrichment,
                select.ver=select.ver)
            rnd.p.values = c(rnd.p.values, df.rnd$minus.log.p)
        }
        ff = ecdf(rnd.p.values)
        hindex = 1:dim(df)[1]
        false.count = ((1-ff(df$minus.log.p)) * length(rnd.p.values)) / rnd.count
        df$q.value = false.count / hindex

        # sort by type and enrichment
        df = df[order(df$type, -df$enrichment),]

        df$p.value = 10^(-df$minus.log.p)
        df$p.value_1= 10^(-df$minus.log.p_1)
        df$p.value_2= 10^(-df$minus.log.p_2)
        df$count = df$count_1 + df$count_2

        fields = c("id", "type", "desc", "enrichment", "count", "p.value", "q.value",
            "count_1", "count.contig_1", "anchor_1", "enrichment_1", "p.value_1",
            "count_2", "count.contig_2", "anchor_2", "enrichment_2", "p.value_2")
        df = df[,fields]

#        fields.round.1 = c("enrichment_1", "minus.log.p_1", "enrichment_2", "minus.log.p_2", "enrichment", "minus.log.p")
#        fields.round = c("enrichment_1", "minus.log.p_1", "enrichment_2", "minus.log.p_2", "enrichment", "minus.log.p")
#        for (field in fields.round)
#           df[,field] = round(df[,field], 1)
#        df$q.value = round(df$q.value, 6)

        ofn = paste(odir, "/all_", id, ".txt", sep="")
        save.table(df, ofn)

        ofn.leaves = paste(odir, "/leaves_", id, ".txt", sep="")
        cat(sprintf("reducing to GO leaves: %s\n", ofn.leaves))
        system(paste(reduce.tree.script, ofn, ifn.go.tree, ofn.leaves))
    }
}

GO.table.subjects.plots=function(ids, table.dir, fdir)
{
    for (id in ids) {
        if (id == "bg")
            next
        ifn  = paste(table.dir, "/leaves_", id, ".txt", sep="")
        df = load.table(ifn)

        df$enrich.log2 = log2(df$enrichment)
        df$minus.log.p = -log10(df$p.value)
        df$col = 1
        df$pos = 2

        xlim = range(c(0,df$enrich.log2))
        ylim = range(c(0,df$minus.log.p))

        plot.type=function(type) {
            if (!any(df$type==type))
                return (NULL)
            dft = df[df$type==type,]

            fig.start(fdir=fdir, ofn=paste(fdir, "/", id, "_", type, ".pdf", sep=""), type="pdf", height=6, width=6)
            plot.init(xlim=xlim, ylim=ylim, xlab="log2(enrichment)", ylab="-log10(P)", main="")
            grid()
            points(dft$enrich.log2, dft$minus.log.p, pch=19, col=dft$col, cex=0.5)
            fig.end()

            fig.start(fdir=fdir, ofn=paste(fdir, "/", id, "_", type, "_text.pdf", sep=""), type="pdf", height=6, width=6)
            plot.init(xlim=xlim, ylim=ylim, xlab="log2(enrichment)", ylab="-log10(P)", main="")
            grid()
            points(dft$enrich.log2, dft$minus.log.p, pch=19, col=dft$col, cex=0.5)
            text(dft$enrich.log2, dft$minus.log.p, dft$desc, pos=dft$pos, cex=0.5)
            fig.end()
        }
        plot.type("func")
        plot.type("component")
        plot.type("process")
    }
}
