make.nlv.table=function(ifn, base.dir, ofn)
{
    df = load.table(ifn)
    sets = unique(df$set)
    result = data.frame(id=sets, fn=paste(base.dir, "/sets/", sets, "/set.nlv", sep=""))
    save.table(result, ofn)
}

