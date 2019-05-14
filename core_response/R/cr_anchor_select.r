select.anchors=function(ifn, field, values, ofn)
{
    df = load.table(ifn)
    df = df[is.element(df[,field], values), c("anchor", "anchor.id")]
    save.table(df, ofn)
}
