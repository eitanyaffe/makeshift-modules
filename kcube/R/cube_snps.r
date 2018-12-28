make.snp.table=function(ifn, input.type, lib.id, base.dir, ksize, ofn)
{
    if (input.type == "table") {
        ids = load.table(ifn)[,1]
    } else {
        ids = lib.id
    }
    result = paste(base.dir, "/", ids, "/cube.k", ksize, sep="")
    cat(sprintf("writing table: %s\n", ofn))

    # result = result[1:20]
    write.table(result, ofn, row.names=F, col.names=F, quote=F)
}
