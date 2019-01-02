assembly.stats=function(ifn, ofn)
{
    df = load.table(ifn)
    lens = sort(df$length)
    ii = findInterval(sum(lens)/2, cumsum(lens))
    n50 = lens[ii]
    fragmented = sum(lens[lens<1000])

    lines = NULL
    lines = c(lines, sprintf("number of contigs: %.0fk", length(lens)/1000))
    lines = c(lines, sprintf("number of contigs <1k: %.0fk", fragmented/1000))
    lines = c(lines, sprintf("total assembly: %.0fMb", sum(lens)/10^6))
    lines = c(lines, sprintf("total assembly (>1k): %.0fMb", sum(lens[lens>=1000])/10^6))
    lines = c(lines, sprintf("N50 length: %.1fkb", n50/10^3))

    cat(sprintf("generating file: %s\n", ofn))
    fc = file(ofn)
    writeLines(lines, fc)
    close(fc)
}
