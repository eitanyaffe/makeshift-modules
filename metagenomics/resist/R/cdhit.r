run.aro=function(ifn, module, target, is.dry)
{
    df = load.table(ifn)
    aros = unique(df$aro)

    cat(sprintf("number of AROs: %d\n", length(aros)))

    for (i in 1:length(aros)) {
        aro = aros[i]
        command = sprintf("make m=%s %s CDHIT_ARO=%s", module, target, aro)
        if (is.dry) {
            command = paste(command, "-n")
        }
        if (system(command) != 0)
            stop(paste("error in command:", command))
    }
    if (is.dry)
        stop(paste("dry run, stopping", command))
}

merge.aro=function(ifn, template.fn, template.field, ofn)
{
    df = load.table(ifn)
    aros = unique(df$aro)
    cat(sprintf("number of AROs: %d\n", length(aros)))
    result = NULL
    for (i in 1:length(aros)) {
        aro = aros[i]
        fn = gsub(template.field, aro, template.fn)
        result = rbind(result, read.delim(fn))
    }
    save.table(result, ofn)
}
