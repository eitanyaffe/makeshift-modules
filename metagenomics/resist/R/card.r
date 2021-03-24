annotate.card=function(ifn.card, ifn.ga, ifn.taxa, ofn)
{
    card = load.table(ifn.card)
    ga = load.table(ifn.ga)
    taxa = load.table(ifn.taxa)
    card$gene = card$ORF_ID

    ix = match(card$gene, ga$gene)
    df = card[!is.na(ix),]
    ga = ga[is.element(ga$gene, df$gene),]
    ga$anchor.id = taxa$anchor.id[match(ga$anchor,taxa$anchor)]
    ga$name = taxa$name[match(ga$anchor,taxa$anchor)]
    ga$frac = taxa$frac[match(ga$anchor,taxa$anchor)]

    ss = sapply(split(ga$anchor.id, ga$gene), function(x) { paste(x, collapse=";") })
    ix = match(card$gene, names(ss))
    card$anchor.ids = ifelse(!is.na(ix), ss[ix], "")

    ss = sapply(split(ga$name, ga$gene), function(x) { paste(x, collapse=";") })
    ix = match(card$gene, names(ss))
    card$anchor.names = ifelse(!is.na(ix), ss[ix], "")

    ss = sapply(split(ga$frac, ga$gene), function(x) { paste(x, collapse=";") })
    ix = match(card$gene, names(ss))
    card$anchor.frac = ifelse(!is.na(ix), ss[ix], "")

    fields = c("gene","anchor.ids", "anchor.names", "anchor.frac", "Cut_Off", "ARO", "Best_Hit_ARO", "Drug.Class", "Resistance.Mechanism", "AMR.Gene.Family")
    fields.more = c("Pass_Bitscore", "Best_Hit_Bitscore", "Best_Identities", "Model_type", "Percentage.Length.of.Reference.Sequence", "ID", "Model_ID")
    card = card[,c(fields, fields.more)]
    save.table(card, ofn)
}

card.summary=function(ids, fns, ofn)
{
    fields = c("ARO", "Best_Hit_ARO", "AMR.Gene.Family", "Drug.Class", "Resistance.Mechanism")
    result = NULL
    ll = list()
    for (i in 1:length(ids)) {
        id = ids[i]
        fn = fns[i]
        df = load.table(fn)
        df$gene = df$ORF_ID
        result = rbind(result, df[,fields])
        ll[[id]] = table(df$ARO)
    }
    result = result[!duplicated(result),]
    result = result[order(result$Best_Hit_ARO),]
    for (i in 1:length(ids)) {
        id = ids[i]
        tt = ll[[id]]
        ix = match(result$ARO, names(tt))
        result[,id] = ifelse(!is.na(ix), tt[ix], 0)
    }
    save.table(result, ofn)
}

core.breakdown=function(ifn.card, ifn.gene2core, ifn.gene2element, ofn)
{
    cards = load.table(ifn.card)
    gene2core = load.table(ifn.gene2core)
    gene2element = load.table(ifn.gene2element)
    cards$gene = cards$ORF_ID

    core.genes = cards$gene[is.element(cards$gene, gene2core$gene)]
    element.genes = cards$gene[is.element(cards$gene, gene2element$gene)]

    result = data.frame(type="core", count=length(core.genes), total.count=dim(gene2core)[1])
    result = rbind(result, data.frame(type="accessory", count=length(element.genes), total.count=dim(gene2element)[1]))
    result$resist.probability = result$count / result$total.count
    save.table(result, ofn)
#    cards = cards[cards$anchor.id
}

abx.table.old=function(ifn.card, ifn.aro, ifn.cat, ofn)
{
    ids = paste("ARO", load.table(ifn.card)$ARO, sep=":")
    aro = load.table(ifn.aro)
    cat = load.table(ifn.cat)

    prot.acc = aro$Protein.Accession[match(ids, aro$ARO.Accession)]

    drugs = cat$Drug.Class[match(prot.acc, cat$Protein.Accession)]

    x = unlist(sapply(drugs, function(x) { strsplit(x, ";")}))
    names(x) = NULL

    tt = sort(table(x), decreasing=T)

    result = data.frame(drug.class=names(tt), count=tt)
    save.table(result, ofn)
}

abx.table=function(ifn.card, ifn.aro, ofn.drug, ofn.mech, ofn.amr, ofn.model)
{
    ids = paste("ARO", load.table(ifn.card)$ARO, sep=":")
    aro = load.table(ifn.aro)
    aro = aro[match(ids,aro$ARO.Accession), ]

    summary.f=function(field, ofn) {
        values = unlist(sapply(aro[,field], function(x) { strsplit(x, ";")}))
        tt = sort(table(values), decreasing=T)
        rr = data.frame(name=names(tt), count=tt)
        names(rr)[1] = field
        save.table(rr, ofn)
    }

    summary.f(field="Drug.Class", ofn=ofn.drug)
    summary.f(field="AMR.Gene.Family", ofn=ofn.amr)
    summary.f(field="Resistance.Mechanism", ofn=ofn.mech)
    summary.f(field="Model.Name", ofn=ofn.model)
}
