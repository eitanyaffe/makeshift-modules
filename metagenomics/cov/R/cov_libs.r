make.libs=function(ids, module, target, is.dry)
{
    for (id in ids) {
        command = sprintf("make m=%s %s LIB_ID=%s", module, target, id)
        if (is.dry) {
            command = paste(command, "-n")
        }
        if (system(command) != 0)
            stop(paste("error in command:", command))
    }
    if (is.dry)
        stop(paste("dry run, stopping", command))
}
