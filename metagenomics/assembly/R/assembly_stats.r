collect.stats=function(ifn, idir, ofn)
{
    df = load.table(ifn)
    ids = df$ASSEMBLY_ID


    rr = NULL
    for (id in ids) {

        # get input reads
        n.reads = 0
        logf = load.table(paste0(idir, "/", id, "/k77_200M/work/run/log"))[,1]
        logf = logf[grepl("sorting/kmer_counter.cpp      :   76", logf)]
        if (length(logf) == 1) {
            xx = gregexpr(pattern ='76 - [0-9]*',logf)
            ii = xx[[1]][1]
            ll = attr(xx[[1]],"match.length")
            n.reads = as.numeric(gsub("76 - ", "", substr(logf, ii, ii+ll-1)))
        }
        
        aa = load.table(paste0(idir, "/", id, "/k77_200M/work/long_contig_table"))

        get.N50=function(lens) {
            lens = sort(lens, decreasing=T)
            val = sum(lens)/2
            cs = cumsum(lens)
            ii = findInterval(val, cs)
            lens[ii+1]
        }
        rr.id = data.frame(id=id, n.reads=n.reads,
                           total.contigs=dim(aa)[1], total.kmb=sum(aa$length)/10^6,
                           median.bp=median(aa$length), N50.bp=get.N50(aa$length))

        rr = rbind(rr, rr.id)
    }
    save.table(rr, ofn)
}

plot.stats=function(ifn, fdir)
{
    df = load.table(ifn)
    df$input.reads.m = df$n.reads / 10^6 / 2
    fields = c("input.reads.m", "total.contigs", "total.kmb", "median.bp", "N50.bp")

    for (field in fields) {
        fig.start(fdir=fdir, type="pdf", width=4, height=4,
                  ofn=paste(fdir, "/", field, "_ecdf.pdf", sep=""))
        plot(ecdf(df[,field]), main=paste(field, "ECDF"), ylab="fraction", xlab=field)
        fig.end()
    }


    panel.cor = function(x, y, digits = 2, prefix = "", cex.cor, ...) {
        usr = par("usr")
        on.exit(par(usr))
        par(usr = c(0, 1, 0, 1))
        Cor = abs(cor(x, y)) # Remove abs function if desired
        txt = paste0(prefix, format(c(Cor, 0.123456789), digits = digits)[1])
        if(missing(cex.cor)) {
            cex.cor = 0.4 / strwidth(txt)
        }
        text(0.5, 0.5, txt)
    }
    
    
    fig.start(fdir=fdir, type="pdf", width=8, height=8,
              ofn=paste(fdir, "/cor_matrix.pdf", sep=""))
    pairs(as.matrix(df[,fields]), upper.panel = panel.cor)
    fig.end()

    
}
