export=function(ifn, gene.table.template, gene.nt.template, gene.aa.template, gene.cov.mat, odir)
{
    df = load.table(ifn)
    for (id in df$ASSEMBLY_ID) {
        odir.ii = paste0(odir, "/", id)
        exec(paste("mkdir -p", odir.ii))
        exec(sprintf("cp %s %s/gene_table.txt", gsub("ASSEMBLY_ID", id, gene.table.template), odir.ii))
        exec(sprintf("cp %s %s/genes.fna", gsub("ASSEMBLY_ID", id, gene.nt.template), odir.ii))
        exec(sprintf("cp %s %s/genes.faa", gsub("ASSEMBLY_ID", id, gene.aa.template), odir.ii))
        exec(sprintf("cp %s %s/genes_cov_matrix.txt", gsub("ASSEMBLY_ID", id, gene.cov.mat), odir.ii))
    }
    exec(sprintf("cd %s && tar cvf genes_data.tar --exclude=*tar . && rm -rf `ls | grep -v 'tar$'`", odir))
}
