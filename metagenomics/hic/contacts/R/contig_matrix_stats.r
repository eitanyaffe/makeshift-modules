stats=function(ifn, ofn)
{
    cat(sprintf("reading file: %s\n", ifn))
    table = read.delim(ifn)
    table$type = ifelse(table$contig1 != table$contig2, "inter", "intra")
    stats = data.frame(
        intra.reads = sum(table$contacts[table$type == "intra"]),
        inter.masked.reads = sum(table$masked_contacts[table$type == "inter"]),
        inter.ok.reads = sum(table$contacts[table$type == "inter"]),
        inter.contig.pairs = sum(table$type == "inter"),
        inter.ok.contig.pairs = sum(table$contacts > 0 & table$type == "inter"))
    write.table(stats, ofn, quote=F, col.names=T, row.names=F, sep="\t")
}
