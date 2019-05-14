host.matrix=function(cores.ifn, elements.ifn, ea.ifn, ofn)
{
    cores = load.table(cores.ifn)
    elements = load.table(elements.ifn)
    ea = load.table(ea.ifn)

    # limit to selected elements
    ea = ea[is.element(ea$element.id,elements$element.id),]

    fc = field.count(ea, "element.id")
    ids = fc$element.id[fc$count>1]
    ea = ea[is.element(ea$element.id, ids),]

    anchors = cores$anchor
    N = length(anchors)

    mm.elements = matrix(rep(0,N^2), N, N)
    mm.genes = matrix(rep(0,N^2), N, N)
    mat2vec = function(x,y,dim) { return (x+(y-1)*dim) }

    ss = split(ea$anchor, ea$element.id)
    for (i in 1:length(ss)) {
        id = names(ss)[i]
        gene.count = elements$gene.count[match(id, elements$element.id)]
        e.anchors = match(ss[[i]], anchors)
        eg = expand.grid(e.anchors, e.anchors, stringsAsFactors=F)
        eg = eg[eg[,1] != eg[,2],]

        indices = mat2vec(eg[,1], eg[,2], N)
        mm.elements[indices] = mm.elements[indices] + 1
        mm.genes[indices] = mm.genes[indices] + gene.count
    }

    get.result=function(mm) {
        smat = matrix2smatrix(mm)
        smat = smat[smat$value>0,]
        smat$anchor.x = anchors[smat$i]
        smat$anchor.y = anchors[smat$j]
        data.frame(anchor.x=smat$anchor.x, anchor.y=smat$anchor.y, count=smat$value)
    }

    result.elements = get.result(mm.elements)
    result.genes = get.result(mm.genes)

    if (!all(result.elements$anchor.x == result.genes$anchor.x)|| !all(result.elements$anchor.y == result.genes$anchor.y))
        stop("internal error")

    result = data.frame(
        anchor.x=result.elements$anchor.x,
        anchor.y=result.elements$anchor.y,
        element.count=result.elements$count,
        gene.count=result.genes$count)

    save.table(result, ofn)
}
