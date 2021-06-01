merge.stats=function(ifn, ldir,
                     ofn.reads.count, ofn.reads.yield,
                     ofn.bps.count, ofn.bps.yield)
{
    df = load.table(ifn)
    ids = df$LIB_ID

    get.matrix=function(type) {
        result = NULL
        field.index = switch(type, reads=3, bps=4)
        cat(sprintf("collecting %s data, number of libraries: %d\n", type, length(ids)))
        for (id in ids) {
            ll = list(
                input=paste(ldir, "/", id, "/info/read_stats/.count_input", sep=""),
                trimmomatic=paste(ldir, "/", id, "/info/read_stats/.count_trimmomatic", sep=""),
                duplicate=paste(ldir, "/", id, "/info/read_stats/.count_dups", sep=""),
                deconseq=paste(ldir, "/", id, "/info/read_stats/.count_deconseq", sep=""),
                final=paste(ldir, "/", id, "/info/read_stats/.count_final", sep=""))
            
            if (file.exists(ll[[1]])) {
                result.lib = NULL
                for (i in 1:length(ll)) {
                    name = names(ll)[i]
                    fn = ll[[i]]
                    x = load.table(fn, header=F, verbose=F)
                    result.lib = c(result.lib, sum(as.numeric(x[,field.index])))
                }
            } else {
                cat(sprintf("no data for library: %s\n", id))
                result.lib = rep(0, length(ll))
            }
            
            df = data.frame(id=id, t(result.lib))
            names(df) = c("id", names(ll))
            result = rbind(result, df)
        }
        
        yield = data.frame(id=result$id)
        for (i in 3:(dim(result)[2])) {
            name = names(result[i])
            yield[[name]] = round(100*result[,i]/result[,i-1],2)
        }

        list(result=result, yield=yield)
    }

    mm.reads = get.matrix(type="reads")
    save.table(mm.reads$result, ofn.reads.count)
    save.table(mm.reads$yield, ofn.reads.yield)
    
    mm.bps = get.matrix(type="bps")
    save.table(mm.bps$result, ofn.bps.count)
    save.table(mm.bps$yield, ofn.bps.yield)
}

merge.dup.stats=function(ifn, ldir, ofn)
{
    df = load.table(ifn)
    ids = df$LIB_ID
    cat(sprintf("collecting dup data, number of libraries: %d\n", length(ids)))

    max.multi = 100
    rr = data.frame(multi=1:max.multi)
    for (id in ids) {
        dx = read.delim(paste0(ldir, "/", id, "/info/dup_complexity.table"))
        ix = dx$multi>=max.multi
        mcount = sum(dx$count[ix])
        dx = dx[!ix,]
        
        ix = match(rr$multi, dx$multi)
        rr[,id] = ifelse(!is.na(ix), dx$count[ix], 0)
        rr[max.multi,id] = mcount
    }
    save.table(rr, ofn)
}
