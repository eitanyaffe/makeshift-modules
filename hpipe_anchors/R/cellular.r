create.mdl.file=function(ifn, anchor.ifn, ofn)
{
    mdl = load.table(ifn)
    df = load.table(anchor.ifn)
    N = length(unique(df$anchor))
    mdl = rbind(mdl, data.frame(raw_field="anchor", field="anchor", size=N, type="const"))
    # mdl = mdl[-match("abundance", mdl$raw_field),]
    save.table(mdl, ofn)
}
