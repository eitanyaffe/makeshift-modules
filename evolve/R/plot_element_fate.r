plot.element.fate=function(ifn.cores, ifn.elements, ifn.element2core, fdir)
{
    elements = load.table(ifn.elements)

    levels.elements = c("element.not.detected", "element.low.detected", "element.turnover", "element.persist")
    names = c("Not detected", "Detected (low)", "Turnover", "Persist")

    levels.cores = c("core.not.detected", "core.low.detected", "core.turnover", "core.persist")
    colors = c("blue", "gray", "orange", "darkgreen")
    wlegend(fdir=fdir, names=names, cols=colors, title="host.fate")

    tt = t(as.matrix(table(factor(elements$host.fate, levels=levels.cores), factor(elements$fate,levels=levels.elements))))
    cs = colSums(tt)
    per = 100 * t(t(tt) * ifelse(cs>0,1/cs,0))
    per.plus = 100 * t(t(tt+sqrt(tt)) * ifelse(cs>0,1/cs,0))
    per.minus = 100 * t(t(tt-sqrt(tt)) * ifelse(cs>0,1/cs,0))

    per.plus[per.plus>100] = 100
    per.minus[per.minus<0] = 0

    pplot=function(df, colors, title, add.text, add.sd) {
        fig.start(fdir=fdir, ofn=paste(fdir, "/", title, ".pdf", sep=""), type="pdf", height=5, width=4)
        par(mai=c(2,1,1,0.5))
        mx = barplot(df, beside=T, col=colors, border=NA, ylim=c(0, max(df)*1.2), las=2, ylab=title, main="groups:hosts, colors:elements")
        if (add.text) {
            text(x=mx, y=df, round(df,1), pos=3, cex=0.75)
        }
        if (add.sd) {
            segments(x0=mx, x1=mx, y0=df, y1=per.plus)
            segments(x0=mx-0.2, x1=mx+0.2, y0=per.plus, y1=per.plus)
        }
        fig.end()
    }
    pplot(df=tt, colors=colors, title="counts", add.text=F, add.sd=F)
    pplot(df=tt, colors=colors, title="counts", add.text=T, add.sd=F)
    pplot(df=per, colors=colors, title="percent", add.text=F, add.sd=T)
}
