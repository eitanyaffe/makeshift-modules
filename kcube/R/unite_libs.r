unite.libs=function(
    ifn.hmp, field.hmp.sample, field.hmp.subject,
    ifn.ebi, field.ebi.sample, field.ebi.subject,
    ofn)
{
    hmp = load.table(ifn.hmp)
    ebi = load.table(ifn.ebi)

    ids = c(hmp[,field.hmp.sample], ebi[,field.ebi.sample])
    subject.id = c(hmp[,field.hmp.subject], ebi[,field.ebi.subject])

    result = data.frame(id=ids, subject.id=subject.id)
    save.table(result, ofn)
}
