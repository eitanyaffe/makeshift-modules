anchor.table=function(ifn, ofn)
{
    df = load.table(ifn)
    df = df[df$class == "host",]
    result = data.frame(set=df$bin, id=paste("b", df$bin, sep=""))
    save.table(result, ofn)
}
