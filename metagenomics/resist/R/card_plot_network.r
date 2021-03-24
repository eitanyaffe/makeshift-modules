plot.network=function(ifn, ifn.aro, highlight.aros, fdir)
{
    library(igraph)
    df = load.table(ifn)
    df.aro = load.table(ifn.aro)
    df$name = df.aro$Model.Name[match(paste0("ARO:",df$aro), df.aro$ARO.Accession)]
    df$id = paste(df$aro, df$cluster, sep="_")

#    df = df[df$subject != "S2_003",]

    subjects = unique(df$subject)

    # highlighted AROs
    hh = data.frame(aro=highlight.aros, name=df.aro$Model.Name[match(paste0("ARO:",highlight.aros), df.aro$ARO.Accession)])
    hh$name[grepl("ampC",hh$name)] = "ampC"
    hh$name[grepl("blaZ",hh$name)] = "blaZ"
    hh$color = rainbow(dim(hh)[1])

    # !!!
    subject.short = as.numeric(gsub("S2_", "", subjects))

    # select degree
    plot.f=function(degree, seed) {
        tt = table(df$id)
        ids.multi = names(tt)[tt>=degree]
        ids = unique(c(ids.multi, df$id[is.element(df$aro,highlight.aros)]))
        dfe = df[is.element(df$id, ids),]

        dfv = data.frame(id=ids)
        dfv$aro = df$aro[match(dfv$id, df$id)]
        dfv$color = ifelse(is.element(dfv$aro, hh$aro), hh$color[match(dfv$aro,hh$aro)], "gray")

        # add degree
        tt = table(dfe$id)
        dfv$degree = tt[match(dfv$id,names(tt))]
        dfv$size = ifelse(dfv$degree == 1, 2, 3)

        tt = table(dfv$aro)
        hh$count = tt[match(hh$aro,names(tt))]
        hh$legend = paste0(hh$name, " (", hh$count, ")")

        hh$count = hh$aro
        vv.subjects = data.frame(name=subjects, type="subject", size=10,
            label=subject.short, label.cex=1, color="lightblue", frame.color=NA, shape="square", label.color="darkblue")

        vv.ids = data.frame(name=ids, type="gene", size=dfv$size,
            label=NA, label.cex=0.75, color=dfv$color, frame.color=colors()[275], shape="circle", label.color="red")

        vv = rbind(vv.subjects, vv.ids)
        ee = data.frame(from=dfe$subject, to=dfe$id, color=colors()[287])
        gg = graph_from_data_frame(ee, directed=F, vertices=vv)

        fig.start(fdir=fdir, ofn=paste(fdir, "/network_", degree, "_", seed, ".pdf", sep=""), type="pdf", height=8, width=8)
        plot(gg)
        legend("bottomleft", legend=hh$legend, cex=0.8, pch=19, col=hh$color, border=NA, box.lwd=0)
        fig.end()
    }
    for (seed in 1:10) {
        for (degree in c(1,2,3,4)) {
            set.seed(seed)
            plot.f(degree, seed)
        }
    }
}
