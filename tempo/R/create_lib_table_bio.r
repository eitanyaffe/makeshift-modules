create.lib.table.bio=function(sample.ifn, dna.seq.ifn, rna.seq.ifn, subject.id,
    ofn.dna.lib.table, ofn.dna.lib.ids, ofn.rna.lib.table, ofn.rna.lib.ids, ofn.defs)
{
    library(stringr)

    samples = load.table(sample.ifn)

    dna.seq = load.table(dna.seq.ifn)[,1]
    rna.seq = load.table(rna.seq.ifn)

    ########################################################################
    # DNA
    ########################################################################

    dna.seq = dna.seq[dna.seq != "LibCtr"]
    reprep = grepl("reprep", dna.seq)
    dna.seq1 = gsub("-reprep", "", dna.seq)
    df.dna = data.frame(Meas_Type = "MetaG", lib=dna.seq1, is.reprep=reprep)
    df.dna$subject.id = gsub("_", "", str_extract(df.dna$lib, ".*_"))
    df.dna$sample.index = gsub("_", "", str_extract(df.dna$lib, "_.*"))
    df.dna = df.dna[df.dna$subject.id == subject.id,]

    ########################################################################
    # RNA
    ########################################################################

    rna.seq = rna.seq[rna.seq[,1] != "" & rna.seq[,2] != "",]
    rna.ids = gsub("r", "", rna.seq$Sample.id)
    df.rna = data.frame(Meas_Type = "MetaT", lib=rna.ids, is.reprep=F, subject.id=gsub("_", "", str_extract(rna.ids, ".*_")), sample.index=gsub("_", "", str_extract(rna.ids, "_.*")))
    df.rna = df.rna[df.rna$subject.id == subject.id,]

    ########################################################################
    # combine
    ########################################################################

    df = rbind(df.dna, df.rna)
    ix = match(df$lib, samples$Event_Code)
    if (any(is.na(ix))) {
        cat(sprintf("some libs not found for subject %s\n", subject.id))
        stop("internal error")
    }

    for (field in c("Samp_Date", "Abx_Interval", "Abx_RelDay", "Full_Code"))
        if(is.element(field, colnames(samples))) df[,field] = samples[ix,field]
    df$Event_Key = df$Abx_Interval
    df$lib = ifelse(df$Meas_Type == "MetaT", paste(df$lib, "r", sep=""), df$lib)
    df = df[order(df$sample.index),]
    df$Meas_ID = df$lib

    ########################################################################
    # save IDs
    ########################################################################

    cat(sprintf("saving DNA ids to file: %s\n", ofn.dna.lib.ids))
    command = paste("echo", paste(df$lib[df$Meas_Type == "MetaG"], sep=" ", collapse=" "), " > ", ofn.dna.lib.ids)
    if (system(command) != 0)
        stop(sprintf("command failed: %s", command))


    cat(sprintf("saving RNA ids to file: %s\n", ofn.rna.lib.ids))
    command = paste("echo", paste(df$lib[df$Meas_Type == "MetaT"], sep=" ", collapse=" "), " > ", ofn.rna.lib.ids)
    if (system(command) != 0)
        stop(sprintf("command failed: %s", command))

    ########################################################################
    # save tables
    ########################################################################

    save.table(df, ofn.defs)
    save.table(df[df$Meas_Type == "MetaG",], ofn.dna.lib.table)
    save.table(df[df$Meas_Type == "MetaT",], ofn.rna.lib.table)

}

