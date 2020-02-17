dummy.genome.table=function(ifn, ofn)
{
    df = load.table(ifn)
    bins = df$bin
    result = data.frame(set=bins, id=paste("b", bins, sep=""))
    save.table(result, ofn)
}

dummy.ca.table=function(ifn, ofn)
{
    df = load.table(ifn)
    df$anchor = df$bin
    df$contig_anchor = df$anchor
    result = df[,c("contig", "anchor", "contig_anchor")]
    save.table(result, ofn)
}
