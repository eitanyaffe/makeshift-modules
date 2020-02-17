bins.classify=function(ifn.checkm, ifn.bins, min.genome.complete, max.genome.contam, max.element.complete, ofn)
{
    df = load.table(ifn.bins)
    cm = load.table(ifn.checkm)

    ix = match(df$bin, cm$bin)
    df$has.checkm = !is.na(ix)
    df$completeness = ifelse(df$has.checkm, cm$Completenes[ix], 0)
    df$contamination = ifelse(df$has.checkm, cm$Contamination[ix], 0)

    # genomes
    df$class =
        ifelse(df$has.checkm & df$completeness >= min.genome.complete & df$contamination <= max.genome.contam, "host",
               ifelse(df$has.checkm & df$completeness >= min.genome.complete & df$contamination > max.genome.contam, "host.contaminated",
                      ifelse(!df$has.checkm | df$completeness <= max.element.complete, "element", "unknown")))
    save.table(df, ofn)
}
