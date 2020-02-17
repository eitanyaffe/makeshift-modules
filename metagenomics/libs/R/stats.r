merge.stats=function(ldir, ids, ofn.count, ofn.yield)
{
    N = length(ids)
    get.reads=function(x) { sum(x[,2]) }

    result = NULL
    for (id in ids) {
        ll = list(
            input=paste(ldir, "/", id, "/.count_input", sep=""),
            trimmomatic=paste(ldir, "/", id, "/.count_trimmomatic", sep=""),
            duplicate=paste(ldir, "/", id, "/.count_dups", sep=""),
            deconseq=paste(ldir, "/", id, "/.count_deconseq", sep=""))

        # others stat files are summed over both sides
        result.lib = NULL
        for (i in 1:length(ll)) {
            name = names(ll)[i]
            fn = ll[[i]]
            x = load.table(fn, header=F)
            result.lib = c(result.lib, sum(as.numeric(x[,3])))
        }
        df = data.frame(id=id, t(result.lib))
        names(df) = c("id", names(ll))
        result = rbind(result, df)
    }
    save.table(result, ofn.count)

    yield = data.frame(id=result$id)
    for (i in 3:(dim(result)[2])) {
        name = names(result[i])
        yield[[name]] = round(100*result[,i]/result[,i-1],2)
    }
    save.table(yield, ofn.yield)
}
