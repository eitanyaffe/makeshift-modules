create.lib.table.dna=function(sample.ifn, measure.ifn, base.dir, subject.id, ofn.lib.table, ofn.lib.ids)
{
    samples = load.table(sample.ifn)
    measures = load.table(measure.ifn)

    samples = samples[samples$Samp_Type == "Stool" | samples$Samp_Type == "Swab",]
    samples = samples[!is.na(samples$Subject),]
    samples = samples[,c("Samp_ID", "Subject", "Event_Code", "Abx_Interval", "Abx_RelDay")]

    measures = measures[measures$Meas_Type == "MetaG",]
    ix = match(samples$Samp_ID, measures$SampID)

    samples$Meas_ID = ifelse (!is.na(ix), measures$Meas_ID[ix], "NONE")
    samples$plate = ifelse (!is.na(ix), measures$Extr_Plate[ix], "NONE")
    samples = samples[samples$Subject == subject.id,]

    # massage and fix filenames
    samples$plate = gsub("R_Plate18", "D_Plate18", samples$plate)
    samples$plate = as.numeric(gsub("D_Plate", "", samples$plate))

    fns = list.files(base.dir, include.dirs=T)
    fns = fns[grepl("^DNA_Plate_", fns)]

    cat(sprintf("plate base dir: %s\n", base.dir))
    if (length(fns) == 0)
        stop("no files found")

    plates = unique(samples$plate)
    plate.dir = character(length(plates))
    for (i in 1:length(plates)) {
        plate = plates[i]
        ix = grepl(plate, fns)
        if (sum(ix) == 0)
            stop(sprintf("plate directory not found: %d\n", plate))
        if (sum(ix) > 1)
            stop(sprintf("plate directory not single: %d\n", plate))
        plate.dir[i] = fns[ix]
        cat(sprintf("plate %d directory: %s\n", plate, plate.dir[i]))
    }
    samples$dir = paste(base.dir, "/", plate.dir[match(samples$plate,plates)], sep="")

    samples$fn1 = NA
    samples$fn2 = NA
    for (i in 1:dim(samples)[1]) {
        pattern = paste(samples$Meas_ID[i], "_*", sep="")
        path = samples$dir[i]
        fns = list.files(path=path, pattern=pattern)
        if (length(fns) != 2)
            stop(sprintf("expecting two files for measure %s in directory: %s", samples$Meas_ID[i], path))
        samples$fn1[i] = fns[grepl("1P", fns)]
        samples$fn2[i] = fns[grepl("2P", fns)]
    }
    save.table(samples, ofn.lib.table)
    if (any(is.na(samples$fn1) | is.na(samples$fn2)))
        stop("some files not found")

    cat(sprintf("saving ids to file: %s\n", ofn.lib.ids))
    command = paste("echo", paste(samples$Meas_ID, sep=" ", collapse=" "), " > ", ofn.lib.ids)
    if (system(command) != 0)
        stop(sprintf("command failed: %s", command))
}

create.lib.table.rna=function(sample.ifn, measure.ifn, base.dir, subject.id, ofn.lib.table, ofn.lib.ids)
{
    samples = load.table(sample.ifn)
    measures = load.table(measure.ifn)

    samples = samples[samples$Samp_Type == "Stool" | samples$Samp_Type == "Swab",]
    samples = samples[!is.na(samples$Subject),]
    samples = samples[,c("Samp_ID", "Subject", "Event_Code", "Abx_Interval", "Abx_RelDay")]

    measures = measures[measures$Meas_Type == "MetaT",]
    ix = match(samples$Samp_ID, measures$SampID)

    samples$Meas_ID = ifelse (!is.na(ix), measures$Meas_ID[ix], "NONE")
    samples$plate = ifelse (!is.na(ix), measures$Extr_Plate[ix], "NONE")
    samples = samples[samples$Subject == subject.id,]

    sdir = paste(base.dir, "/", subject.id, "r_Sub", sep="")
    cat(sprintf("subject dir: %s\n", sdir))
    fns = list.files(sdir)
    if (length(fns) == 0)
        stop("no files found")
    samples$dir = sdir

    samples$fn1 = NA
    samples$fn2 = NA
    for (i in 1:dim(samples)[1]) {
        pattern = paste(samples$Meas_ID[i], "_*", sep="")
        path = samples$dir[i]
        fns = list.files(path=path, pattern=pattern)
        if (length(fns) != 2)
            stop(sprintf("expecting two files for measure %s in directory: %s", samples$Meas_ID[i], path))
        samples$fn1[i] = fns[grepl("1P", fns)]
        samples$fn2[i] = fns[grepl("2P", fns)]
    }
    save.table(samples, ofn.lib.table)
    if (any(is.na(samples$fn1) | is.na(samples$fn2)))
        stop("some files not found")

    cat(sprintf("saving ids to file: %s\n", ofn.lib.ids))
    command = paste("echo", paste(samples$Meas_ID, sep=" ", collapse=" "), " > ", ofn.lib.ids)
    if (system(command) != 0)
        stop(sprintf("command failed: %s", command))
}

create.lib.table=function(sample.ifn, measure.ifn, base.dna.dir, base.rna.dir, subject.id, types,
    ofn.dna.lib.table, ofn.dna.lib.ids, ofn.rna.lib.table, ofn.rna.lib.ids, ofn.defs)
{
    # generate table with sample defs
    samples = load.table(sample.ifn)
    measures = load.table(measure.ifn)
    measures$lib = measures$Meas_ID
    measures$Subject = samples$Subject[match(measures$SampID, samples$Samp_ID)]
    measures = measures[measures$Subject == subject.id & is.element(measures$Meas_Type, c("MetaG", "MetaT")),c("lib", "Meas_Type", "SampID")]
    ix = match(measures$SampID, samples$Samp_ID)
    for (field in c("Abx_Interval", "CC_Interval", "Diet_Interval", "Samp_Date", "Samp_Type", "Full_Code"))
        if(is.element(field, colnames(samples))) measures[,field] = samples[ix,field]

    # add event key
    ff = function(v, label) { ifelse(!is.na(v), v, paste("No", label, sep="")) }
    measures$Event_Key = paste(ff(measures$Abx_Interval,"Abx"), ff(measures$CC_Interval,"CC"), ff(measures$Diet_Interval,"Diet"), sep="_")
    save.table(measures, ofn.defs)

    if (is.element("DNA", types))
        create.lib.table.dna(sample.ifn=sample.ifn, measure.ifn=measure.ifn, subject.id=subject.id,
                             base.dir=base.dna.dir, ofn.lib.table=ofn.dna.lib.table, ofn.lib.ids=ofn.dna.lib.ids)

    if (is.element("RNA", types))
        create.lib.table.rna(sample.ifn=sample.ifn, measure.ifn=measure.ifn, subject.id=subject.id,
                             base.dir=base.rna.dir, ofn.lib.table=ofn.rna.lib.table, ofn.lib.ids=ofn.rna.lib.ids)
}
