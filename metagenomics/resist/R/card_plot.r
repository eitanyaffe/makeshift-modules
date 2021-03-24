abx.summary=function(ids, fns, fdir)
{
    drugs = NULL
    for (i in 1:length(ids)) {
        id = ids[i]
        fn = fns[i]
        df = load.table(fn)
        drugs = unique(c(drugs, df$drug.class))
    }
    drugs = setdiff(drugs, "N/A")
    result = data.frame(drug=drugs, total=0)
    for (i in 1:length(ids)) {
        id = ids[i]
        fn = fns[i]
        df = load.table(fn)
        ix = match(result$drug, df$drug.class)
        result[,id] = ifelse(!is.na(ix), df$count[ix], 0)
        result$total = result$total + result[,id]
    }
    result = result[order(result$total, decreasing=F),]
    mm = as.matrix(result[,-(1:2)])
    colors = c("blue", "darkgreen", "red")

    fig.start(fdir=fdir, ofn=paste(fdir, "/abx_breakdown.pdf", sep=""), type="pdf", height=8, width=8)
    par(mai=c(2,3,0.5,0.5))
    barplot(t(mm), horiz=T, names.arg=drugs, beside=T, col=colors, las=1, border=NA, xlab="#genes", cex.names=0.75)
    legend("bottomright", fill=colors, border=NA, legend=ids, box.lwd=NA)
    fig.end()
}
