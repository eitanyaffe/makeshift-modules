explode.fate=function(ifn.elements, ifn.gene2element, ofn.prefix)
{
    elements = load.table(ifn.elements)
    genes = load.table(ifn.gene2element)

    genes$fate = elements$fate[match(genes$element.id, elements$element.id)]
    ii = match("fate", names(genes))
    fates = unique(elements$fate)

    for (fate in fates) {
        ofn = paste(ofn.prefix, "_", fate, sep="")
        save.table(genes[genes$fate == fate,-ii], ofn)
    }
}

explode.live=function(ifn.elements, ifn.gene2element, ofn.prefix)
{
    elements = load.table(ifn.elements)
    genes = load.table(ifn.gene2element)

    ix = match(genes$element.id, elements$element.id)
    genes$class = elements$class[ix]
    genes$type = elements$type[ix]
    genes$id = paste(genes$type, genes$class, sep="_")

    ids = unique(genes$id)

    for (id in ids) {
        ofn = paste(ofn.prefix, "_", id, sep="")
        save.table(genes[genes$id == id,c("gene", "element.id")], ofn)
    }
}
