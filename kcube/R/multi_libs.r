multi.libs=function(ifn.table, target, max.libs, lib.id.field, params="NA")
{
    if (params == "NA")
        params = ""
    table = load.table(ifn.table)
    N = dim(table)[1]
    if (max.libs > 0)
        N = min(N, max.libs)
    cat(sprintf("iterating over %d libs, target=%s\n", N, target))
    for (i in 1:N) {
        id = table[i,lib.id.field]
        command = sprintf("make %s LIB_ID=%s %s", target, id, params)
        cat(sprintf("running command: %s\n", command))
        if (system(command) != 0)
            stop("error in command")
    }
}

