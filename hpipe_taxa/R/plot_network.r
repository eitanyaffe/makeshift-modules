plot.network=function(
    order.ifn, elements.ifn, ea.ifn, fdir)
{
    anchor.table = load.table(order.ifn)
    hids = anchor.table$id

    df = load.table(elements.ifn)
    df = df[df$gene.count > 4 & df$class=="simple",]

    ea = load.table(ea.ifn)
    ea$eid = ea$element.id
    ea$hid = anchor.table$id[match(ea$anchor,anchor.table$set)]
    fc = field.count(ea, "element.id")
    eids = fc$element.id[fc$count>1]
    eids = eids[is.element(eids,df$element.id)]

    ea = ea[is.element(ea$eid,eids),]

    hids = unique(ea$hid)
    vs = c(hids, eids)
    type = c(rep("host", length(hids)) , rep("element", length(eids)))
    gg = graph_from_data_frame(ea[,c("eid", "hid")], directed=F, vertices=vs)
    init = layout_in_circle(gg, order=hids)

    cc = layout_with_fr(gg, coords=init)
#    cc = layout_with_graphopt(
#        gg, start=init, niter=500, charge=0.001, mass=ifelse(type=="host",10,1), spring.length=0, spring.constant=1, max.sa.movement=5)

    plot(gg, layout=cc, vertex.size=30,
         vertex.label=vs, rescale=F, vertex.color=ifelse(type=="host",1,2),
         xlim=range(cc[,1]), ylim=range(cc[,2]), vertex.label.dist=2,
         vertex.label.color="black")
    axis(1)
    axis(2)
}
