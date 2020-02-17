select.ca=function(table, min.contacts=10, min.enrichment, min.contig.coverage=0.5, min.anchor.contigs=2, fdr=0.0001)
{
  table$type = ifelse(table$contig_anchor == 0, "extended", ifelse(table$contig_anchor == table$anchor, "intra", "inter"))

  exp = table$contig_expected
  obs = table$contig_total_count
  N = sum(obs[table$type == "inter"])
  prob = exp / N
  obs = ifelse(obs < exp, exp, obs)
  table$pscore = pbinom(q=obs, size=N, prob=pmin(1,prob), lower.tail=F)
  table$enrichment = log10(table$contig_total_count/table$contig_expected)

  table$selected = (table$pscore < fdr &
                    table$contig_total_count >= min.contacts &
                    table$enrichment >= min.enrichment &
                    table$contig_coverage >= min.contig.coverage &
                    table$anchor_contig_count >= min.anchor.contigs)

  # remove anchor if no anchored are selected
  tt = table(table[table$anchor==table$contig_anchor & table$selected,"anchor"])
  ix = match(table$anchor,names(tt))
  table$anchor.count = ifelse(!is.na(ix), tt[ix], 0)
  table$selected = table$selected & table$anchor.count > 0

  table
}

anchor.contigs=function(table, min.contacts=10, min.enrichment, min.contig.coverage=0.5, min.anchor.contigs=2, fdr=0.0001)
{
    # remove contig/anchor pairs that had no observed contacts
    table = table[table$any_observed,]

    anchors = unique(table$anchor)
    contigs = unique(table$contig)
    T = length(anchors) * length(contigs)
    fdr = fdr / T

    xtable = select.ca(table=table,
        min.enrichment=min.enrichment,
        min.contacts=min.contacts,
        min.contig.coverage=min.contig.coverage,
        min.anchor.contigs=min.anchor.contigs,
        fdr=fdr)

    table$enrichment = xtable$enrichment
    table = table[xtable$selected,]
    table
}

unt.unions=function(ifn.matrix, ifn.params, min.contacts, min.enrichment, min.contig.coverage, min.anchor.contigs, fdr, odir.base)
{
    df = load.table(ifn.params)
    table = load.table(ifn.matrix)

    N = dim(df)[1]
    for (i in 1:N) {
        param = df$param[i]
        value = df$value[i]

        fdr.i = ifelse(param == "CA_ASSIGN_FDR", value, fdr)
        min.contacts.i = ifelse(param == "CA_MIN_CONTACTS", value, min.contacts)
        min.enrichment.i = ifelse(param == "CA_MIN_ENRICHMENT", value, min.enrichment)
        min.anchor.contigs.i = ifelse(param == "CA_MIN_ANCHOR_CONTIGS", value, min.anchor.contigs)
        min.contig.coverage.i = ifelse(param == "CA_CONTIG_COVERAGE", value, min.contig.coverage)

        result = anchor.contigs(table=table,
            min.contacts=min.contacts.i,
            min.enrichment=min.enrichment.i,
            min.contig.coverage=min.contig.coverage.i,
            min.anchor.contigs=min.anchor.contigs.i,
            fdr=fdr.i)

        odir = paste(odir.base, "/", param, "/", value, sep="")
        system(paste("mkdir -p", odir))
        ofn = paste(odir, "/ca.table", sep="")
        save.table(result, ofn)
    }
}

make=function(ifn, target, dry)
{
    df = load.table(ifn)
    N = dim(df)[1]
    cat(sprintf("number of targets: %d\n", N))
    for (i in 1:N) {
        param = df$param[i]
        value = df$value[i]
        command = sprintf("make m=unt %s UNT_PARAMETER=%s UNT_VALUE=%s", target, param, value)
        if (dry) {
            command = paste(command, "-n")
        }
        if (system(command) != 0)
            stop(paste("error in command:", command))
    }
}

checkm.summary=function(ifn, idir.base, ofn)
{
    df = load.table(ifn)
    params = unique(df$param)

    result = NULL
    for (param in params) {
        values = df$value[df$param == param]

        for (value in values) {
            default = df$default[df$param == param & df$value == value]
            x = read.delim(paste(idir.base, "/", param, "/", value, "/checkm/checkm/lineage_U_0/output/qa.table.1", sep=""))
            result = rbind(result, data.frame(param=param, value=value, default=default, complete=x$Completeness, contam=x$Contamination))
        }
    }

    save.table(result, ofn)
}


genome.summary=function(ifn, ifn.contigs, idir.base, ofn)
{
    df = load.table(ifn)
    contigs = load.table(ifn.contigs)

    result = NULL
    params = unique(df$param)
    for (param in params) {
        values = df$value[df$param == param]

        for (value in values) {
            default = df$default[df$param == param & df$value == value]
            x = read.delim(paste(idir.base, "/", param, "/", value, "/ca.table", sep=""))
            ix = is.element(contigs$contig,x$contig)
            count = sum(ix)
            bp = sum(contigs$length[ix])

            # genome length
            x$length = contigs$length[match(x$contig,contigs$contig)]
            median.bp = median(sapply(split(x$length, x$anchor), sum))
            result = rbind(result, data.frame(param=param, value=value, default=default, contig.count=count, contig.bp=bp, median.bp=median.bp))
        }
    }

    save.table(result, ofn)
}
