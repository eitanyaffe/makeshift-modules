cube.matrix=function(ifn.table, lib.id.field, max.libs, cube.dir, min.portion, min.xcov, ofn.identity, ofn.xcov)
{
    table = load.table(ifn.table)
    table$id = table[,lib.id.field]
    N = dim(table)[1]
    if (max.libs > 0)
        N = min(N, max.libs)
    ids = table[1:N,"id"]

    result.xcov = NULL
    result.identity = NULL
    skipped = 0
    cat(sprintf("number of potential libs: %d\n", length(ids)))
    for (id in ids) {
        if (!file.exists(paste(cube.dir, "/", id, "/.done_cube_summary", sep=""))) {
            skipped = skipped + 1
            next
        }
        ifn = paste(cube.dir, "/", id, "/summary", sep="")
        if (!file.exists(ifn))
            next
        x = load.table(ifn, verbose=F)
        if (is.null(result.xcov)) {
            result.xcov = data.frame(item=x$contig)
            result.identity = data.frame(item=x$contig)
        }
        result.xcov[,id] = ifelse(x$covered_portion >= min.portion & x$median_xcoverage >= min.xcov, x$median_xcoverage, 0)
        result.identity[,id] = ifelse(x$covered_portion >= min.portion & x$median_xcoverage >= min.xcov, round(x$covered_portion,3), 0)
    }
    if (skipped == length(ids))
        stop("no libs found")
    cat(sprintf("number of skipped libs (summary file not ready): %d\n", skipped))
    cat(sprintf("number of final libs: %d\n", dim(result.xcov)[2]-1))
    save.table(result.xcov, ofn.xcov)
    save.table(result.identity, ofn.identity)
}

matrix.select=function(ifn.lib, ifn.xcov, ifn.identity, ofn.xcov, ofn.identity)
{
    lib = load.table(ifn.lib)
    lib = lib[!duplicated(lib$subject.id),]
    fields = c("item", lib$id)

    mat.xcov = load.table(ifn.xcov)
    mat.identity = load.table(ifn.identity)

    mat.xcov = mat.xcov[,is.element(colnames(mat.xcov), fields)]
    mat.identity = mat.identity[,is.element(colnames(mat.identity), fields)]

    save.table(mat.xcov, ofn.xcov)
    save.table(mat.identity, ofn.identity)
}

item.table=function(ifn.xcov, ifn.identity, ofn)
{
    mat.xcov = load.table(ifn.xcov)
    mat.identity = load.table(ifn.identity)
    result = data.frame(item=mat.xcov$item)

    mm.xcov = as.matrix(mat.xcov[,-1])
    mm.presence = mm.xcov
    mm.presence[mm.presence>0] = 1

    result$subject.count = rowSums(mm.presence)
    result$subject.ratio = round(result$subject.count / dim(mm.xcov)[2], 3)
    result$mean.median.xcov = ifelse(result$subject.count > 0, rowSums(mm.xcov) / result$subject.count, 0)
    result$mean.median.xcov = round(result$mean.median.xcov, 3)

    # add identity
    mm.identity = as.matrix(mat.identity[,-1])
    mm.identity[mm.presence==0] = 0
    result$identity = ifelse(result$subject.count>0, round(rowSums(mm.identity)/result$subject.count,5), 0)

    save.table(result, ofn)
}
