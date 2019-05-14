fix.input=function(ifn1, ifn2, ofn)
{
    make.table=function(ifn, id) {
        df = load.table(ifn)
        df$anchor = paste(id, df$anchor, sep="_")
        df$anchor.id = paste(id, df$anchor.id, sep="_")
        df$gene = paste(id, df$gene, sep="_")
        cbind(data.frame(subject=id), df)
    }
    df1 = make.table(ifn1, "S1")
    df2 = make.table(ifn2, "S2")
    result = rbind(df1, df2)
    save.table(result, ofn)
}

hgt.input=function(ifn1, ifn2, ofn)
{
    make.table=function(ifn, id) {
        df = load.table(ifn)
        df$anchor = paste(id, df$anchor, sep="_")
        df$anchor.id = paste(id, df$anchor.id, sep="_")
        df$gene = paste(id, df$gene, sep="_")
        df$element.id = paste(id, df$element.id, sep="_")
        cbind(data.frame(subject=id), df)
    }
    df1 = make.table(ifn1, "S1")
    df2 = make.table(ifn2, "S2")
    result = rbind(df1, df2)
    save.table(result, ofn)
}
