card.collect=function(template.ifn, template.id, ids, ofn)
{
    if (!grepl(template.id, template.ifn))
        stop("template id not found")

    result = NULL
    for (id in ids) {
        ifn = gsub(template.id, id, template.ifn)
        df = load.table(ifn)
        result = rbind(result, data.frame(id=id, gene=df$ORF_ID, aro.name=df$Best_Hit_ARO, aro.index=df$ARO))
    }
    save.table(result, ofn)
}

card.genes=function(ifn, template.ifn, template.id, ids, odir, ofn)
{

    df = load.table(ifn)

    # load sequences
    library("Biostrings")
    ids = unique(df$id)
    ll = list()
    for (id in ids) {
        ifn = gsub(template.id, id, template.ifn)
        ll[[id]] = readDNAStringSet(ifn)
    }

    fc = field.count(df, "aro.index")
    fc = fc[fc$count>1,]

    result = NULL
    for (i in 1:dim(fc)[1]) {
        aro = fc$aro.index[i]
        ofn.fasta = paste0(odir, "/", aro, ".fasta")
        dff = df[df$aro.index == aro,]
        ids = unique(dff$id)
        rr = NULL
        for (id in ids) {
            genes = dff$gene[dff$id == id]
            for (gene in genes) {
                gid = paste(id, gene, sep="_")
                dna = DNAStringSet(ll[[id]][[gene]])
                names(dna) = gid
                if (is.null(rr))
                    rr = dna
                else
                    rr = append(rr, dna)
            }
        }
        writeXStringSet(rr, ofn.fasta)
        result = rbind(result, data.frame(aro, fn=ofn.fasta))
    }
    save.table(result, ofn)
}

run.cdhit=function(ifn, cdhit.bin, identity, odir)
{
    df = load.table(ifn)
    cat(sprintf("processing %d AROs, and writing output in directory: %s\n", dim(df)[1], odir))
    for (i in 1:dim(df)[1]) {
        ifn.fasta = df$fn[i]
        ofn = paste0(odir, "/", df$aro[i])
        log = paste0(ofn, ".log")
        command = sprintf("%s -i %s -o %s -c %f > %s 2>&1", cdhit.bin, ifn.fasta, ofn, identity, log)
        if (system(command) != 0)
            stop("error in cdhit")
    }
}
