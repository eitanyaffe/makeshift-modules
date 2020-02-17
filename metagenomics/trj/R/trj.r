
compute.anchor.trj.global=function(ifn.contigs, ifn.ca, ifn.norm, ofn)
{
    contig.table = load.table(ifn.contigs)
    ca = load.table(ifn.ca)
    norm = load.table(ifn.norm)
    anchors = sort(unique(ca$anchor))

    result = NULL
    for (anchor in anchors) {
        contigs = ca$contig[ca$contig_anchor == anchor]
        anchor.norm = as.matrix(norm[match(contigs, norm$contig),-1])
        anchor.length = contig.table$length[match(contigs, contig.table$contig)]
        anchor.length = anchor.length / sum(anchor.length)
        df = data.frame(anchor=anchor, as.data.frame(round(t(colSums(anchor.norm * anchor.length)),5)))
#        df = data.frame(anchor=anchor, as.data.frame(round(t(colSums(anchor.norm)),5)))
        result = rbind(result, df)
    }
    save.table(result, ofn)
}


mean.cluster=function(ifn, ifn.ca, thresholds, ofn.order, ofn.prefix)
{
    library("fastcluster")

    ca = load.table(ifn.ca)
    table = load.table(ifn)
    table = table[is.element(table$contig, ca$contig),]

    contigs = table$contig

    cat(sprintf("computing pearson over contigs: %d\n", length(contigs)))
    cc = cor(t(table[,-1]))
    cc[is.na(cc) | !is.finite(cc)] = -1

    cat(sprintf("computing hclust...\n"))
    hh = fastcluster::hclust(as.dist(1 - cc), method="average")

    ordered.contigs = contigs[hh$order]
    save.table(data.frame(contig=ordered.contigs), ofn.order)

    for (threshold in thresholds) {
        ofn = paste(ofn.prefix, "_", threshold, sep="")
        cat(sprintf("cutting tree, threshold: %f\n", threshold))
        result = data.frame(contig=contigs, cluster=cutree(hh, h=1-threshold))
        result = add.field.count(result, "cluster")
        result$cluster[result$cluster_count == 1] = -1
        save.table(result[,1:2], ofn)
    }
}

element.genes=function(ifn.clusters, ifn.genes, ifn.uniref, ofn)
{
    table = load.table(ifn.clusters)
    uniref = load.table(ifn.uniref)
    gene = load.table(ifn.genes)
    gene$index = 1:dim(gene)[1]

    gene = lookup.append(table=gene, lookup.table=uniref, lookup.field="gene", value.field="uniref", omit.na=F)
    gene = lookup.append(table=gene, lookup.table=uniref, lookup.field="gene", value.field="identity", omit.na=F)
    gene = lookup.append(table=gene, lookup.table=uniref, lookup.field="gene", value.field="prot_desc", omit.na=F)
    gene = lookup.append(table=gene, lookup.table=uniref, lookup.field="gene", value.field="tax", omit.na=F)

    df = lookup.append(table=gene, lookup.table=table, lookup.field="contig", value.field="cluster")
    df = df[order(df$cluster, df$index),]
    df = df[,c("cluster", "contig", "gene", "uniref", "identity", "prot_desc", "tax")]
    save.table(df, ofn)
}


anchor.major=function(ifn.contigs, ifn.clusters, ifn.cluster.map, ifn.ca, ofn.major, ofn.clusters.final)
{
    contigs = load.table(ifn.contigs)
    cluster.table = load.table(ifn.clusters)

    ca =  load.table(ifn.ca)
    anchors = sort(unique(ca$anchor))

    cluster.table$cluster = cluster.table$cluster.consistent
    cluster.table$length = contigs$length[match(cluster.table$contig, contigs$contig)]
    ca$length = contigs$length[match(ca$contig, contigs$contig)]

    major.df = NULL
    major.result = NULL
    for (anchor in anchors) {
        ca.anchor = ca[ca$anchor == anchor,]
        anchor.size = sum(ca.anchor$length)

        # add cluster
        ca.anchor$cluster = cluster.table$cluster[match(ca.anchor$contig, cluster.table$contig)]

        # limit to valid clusters
        ca.anchor = ca.anchor[ca.anchor$cluster > 0,]

        # limit to anchor contigs
        ca.anchor = ca.anchor[ca.anchor$contig_anchor != 0,]

        ss = sapply(split(ca.anchor$length, ca.anchor$cluster), sum)
        cluster = as.numeric(names(which.max(ss)))
        match.size = max(ss)

        full.size = sum(ca.anchor$length[ca.anchor$contig_anchor == anchor])
        df = data.frame(anchor=anchor, cluster=cluster, anchor.f=match.size/anchor.size, anchor.full.f=full.size/anchor.size)
        major.df = rbind(major.df, df)

        anchor.contigs = ca.anchor$contig[ca.anchor$cluster == cluster]
        major.result = rbind(major.result, data.frame(contig=anchor.contigs, cluster=cluster))
    }
    save.table(major.df, ofn.major)

    result = cluster.table[!is.element(cluster.table$cluster, major.df$cluster),c("contig", "cluster")]
    result = rbind(result, major.result)
    save.table(result, ofn.clusters.final)
}

anchor.elements=function(ifn.matrix, ifn.means, ofn)
{
    ea = load.table(ifn.matrix)
    means = load.table(ifn.means)
    anchors = sort(unique(ea$anchor))

    result = NULL
    for (anchor in anchors) {
        e.major = means[means$cluster == anchor,-(1:2)]
        if (!any(ea$anchor == anchor)) {
            next
        }
        clusters = ea$cluster[ea$anchor == anchor]
        e.minors = means[is.element(means$cluster, clusters),-(1:2)]
        cc = cor(t(e.major), t(e.minors))
        cc[is.na(cc) | !is.finite(cc)] = -1
        df = data.frame(anchor=anchor, cluster=clusters, round(t(cc),4))
        names(df)[3] = "pearson"
        df$major = df$cluster == anchor
        df = df[order(df$pearson),]
        result = rbind(result, df)
    }
    save.table(result, ofn)
}
