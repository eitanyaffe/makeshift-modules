make.cov.table=function(base.dir, ids, ofn)
{
    result = data.frame(id=ids, fn=paste(base.dir, "/libs/", ids, "/lib.cov", sep=""))
    save.table(result, ofn)
}

