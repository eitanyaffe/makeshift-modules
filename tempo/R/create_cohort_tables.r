create.cohort.table=function(sample.ifn,
                             dna.seq.ifn, rna.seq.ifn,
                             dna.stats.ifn, rna.stats.ifn,
                             max.dna.reads, max.rna.reads,
                             ofn)
{
    library(stringr)

    samples = load.table(sample.ifn)

    dna.seq = load.table(dna.seq.ifn)[,1]
    rna.seq = load.table(rna.seq.ifn)
    dna.stats = load.table(dna.stats.ifn)
    rna.stats = load.table(rna.stats.ifn)

    ########################################################################
    # DNA
    ########################################################################

    dna.seq = dna.seq[dna.seq != "LibCtr"]
    dna.seq = unique(gsub("-reprep", "", dna.seq))
    df.dna = data.frame(Meas_Type = "MetaG", lib=dna.seq)
    df.dna$subject.id = gsub("_", "", str_extract(df.dna$lib, ".*_"))
    df.dna$sample.index = gsub("_", "", str_extract(df.dna$lib, "_.*"))
    df.dna = df.dna[!grepl("^P", df.dna$subject.id),]
    ix = match(df.dna$lib, dna.stats$id)
    if (any(is.na(ix))) {
        stop("internal error")
    }
    df.dna$read.count.original = dna.stats$deconseq[ix]/2
    df.dna$read.count = pmin(max.dna.reads, df.dna$read.count.original)

    ########################################################################
    # RNA
    ########################################################################

    rna.seq = rna.seq[rna.seq[,1] != "" & rna.seq[,2] != "",]
    rna.ids = unique(gsub("r", "", rna.seq$Sample.id))

    # RNA labeling issues
    # 1. Sample EBF_54 was labeled by Alvaro as EBF_59 by mistake
    # 1. Sample EAX_55 was labeled by Arati as EAZ_55 by mistake
    rna.stats$id[rna.stats$id == "EBF_54"] = "EBF_59"
    rna.stats$id[rna.stats$id == "EAZ_55"] = "EAX_55"

    df.rna = data.frame(Meas_Type = "MetaT", lib=rna.ids, subject.id=gsub("_", "", str_extract(rna.ids, ".*_")), sample.index=gsub("_", "", str_extract(rna.ids, "_.*")))
    df.rna = df.rna[!grepl("^P", df.rna$subject.id),]
    ix = match(df.rna$lib, rna.stats$id)
    if (any(is.na(ix))) {
        stop("internal error")
    }
    df.rna$read.count.original = rna.stats$deconseq[ix]/2
    df.rna$read.count = pmin(max.rna.reads, df.rna$read.count.original)

    ########################################################################
    # combine
    ########################################################################

    df = rbind(df.dna, df.rna)
    ix = match(df$lib, samples$Event_Code)
    if (any(is.na(ix))) {
        cat(sprintf("some libs not found\n"))
        stop("internal error")
    }

    for (field in c("Samp_Date", "Abx_Interval", "Abx_RelDay", "Full_Code"))
        if(is.element(field, colnames(samples))) df[,field] = samples[ix,field]
    df$Event_Key = df$Abx_Interval
    df$lib = ifelse(df$Meas_Type == "MetaT", paste(df$lib, "r", sep=""), df$lib)
    df = df[order(df$subject.id, df$Abx_RelDay),]
    df$Meas_ID = df$lib

    save.table(df, ofn)
}

select.cohort.table=function(ifn,
                             min.dna.reads, min.rna.reads,
                             ofn.subjects, ofn.samples)
{
    df = load.table(ifn)
    df = df[(df$Meas_Type == "MetaG" & df$read.count >= min.dna.reads) | (df$Meas_Type == "MetaT" & df$read.count >= min.rna.reads),]
    save.table(df, ofn.samples)

    ids = sort(unique(df$subject.id))
    rr = data.frame(subject.id=ids)

    df.dna = df[df$Meas_Type == "MetaG",]
    df.rna = df[df$Meas_Type == "MetaT",]

    ff.count = function(df) {
        ss = split(df$read.count, df$subject.id)
        xx = sapply(ss, length)
        ix = match(ids, names(xx))
        ifelse(!is.na(ix), xx, 0)
    }
    ff.sum = function(df) {
        ss = split(df$read.count, df$subject.id)
        xx = sapply(ss, sum)
        ix = match(ids, names(xx))
        ifelse(!is.na(ix), xx, 0)
    }
    rr$dna.sample.count = ff.count(df.dna)
    rr$rna.sample.count = ff.count(df.rna)

    rr$dna.read.count = ff.sum(df.dna)
    rr$rna.read.count = ff.sum(df.rna)

    save.table(rr, ofn.subjects)
}

subject.init=function(ifn, subject.id,
                      ofn.dna.lib.table, ofn.dna.lib.ids,
                      ofn.rna.lib.table, ofn.rna.lib.ids, ofn.defs)
{

    df = load.table(ifn)
    df = df[df$subject.id == subject.id,]

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

import.lib=function(ifn, type, lib.id, idir.dna, idir.rna, odir)
{
    df = load.table(ifn)
    if (sum(df$lib == lib.id) != 1)
        stop(cat(sprintf("id not found in table: %s\n", lib.id)))

    # !!! fix EBF_59
    if (grepl("EBF_59", lib.id))
        idir.rna = gsub("EBF_59", "EBF_54", idir.rna)
    if (grepl("EAX_55", lib.id))
        idir.rna = gsub("EAX_55", "EAZ_55", idir.rna)

    command = paste("mkdir -p", odir)
    if (system(command) != 0)
        stop(sprintf("command failed: %s", command))

    # remove from RNA the r suffix
    idir.rna = gsub("r/final", "/final", idir.rna)

    df = df[df$lib == lib.id,]
    trim = df$read.count < df$read.count.original
    trim.lines = df$read.count * 4
    idir = ifelse(type == "DNA", idir.dna, idir.rna)
    for (side in c("R1", "R2")) {
        ifn.side = paste0(idir, "/", side, ".fastq")
        ofn.side = paste0(odir, "/", side, ".fastq")
        if (!file.exists(ifn.side))
            stop(paste0("file not found: ", ifn.side))
        if (trim) {
            command = sprintf("head -n %d %s > %s", trim.lines, ifn.side, ofn.side)
        } else {
            command = sprintf("ln -sf %s %s", ifn.side, ofn.side)
        }
        cat(sprintf("command: %s\n", command))
        if (system(command) != 0)
            stop(sprintf("command failed: %s", command))
    }
}
