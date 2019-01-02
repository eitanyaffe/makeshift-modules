select.anchors=function(ifn.qa, ifn.ga, ifn.ca, min.complete, max.contam, ofn.anchors, ofn.ga, ofn.ca)
{
    qa = load.table(ifn.qa)
    qa$anchor = qa$Bin.Id
    ix = qa$Completeness>=min.complete & qa$Contamination<=max.contam
    result = data.frame(anchor=sort(qa$anchor[ix]))
    save.table(result, ofn.anchors)

    ga = load.table(ifn.ga)
    ga = ga[is.element(ga$anchor, result$anchor),]
    save.table(ga, ofn.ga)

    ca = load.table(ifn.ca)
    ca = ca[is.element(ca$anchor, result$anchor),]
    save.table(ca, ofn.ca)
}
