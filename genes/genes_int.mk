#####################################################################################################
# register module
#####################################################################################################

units=genes_uniref.mk genemap.mk diamond.mk
$(call _register_module,genes,$(units),,)

#####################################################################################################
# Gene Ontology
#####################################################################################################

# GO table from http://purl.obolibrary.org/obo/go/go-basic.obo
GO_BASIC_OBO?=/relman01/shared/databases/GO/go-basic.obo-2016-11-08

# UniProt to GO: ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/UNIPROT/goa_uniprot_all.gaf.gz
GOA_UNIPROT_TABLE?=/relman01/shared/databases/GO/goa_uniprot/2016-10-29/goa_uniprot_all.gaf
UNIPROT2GO_LOOKUP?=/relman01/shared/databases/GO/goa_uniprot/2016-10-29/goa_uniprot_all.gaf.parsed

GO_ID?=2016_10
GO_DIR?=$(BASE_OUTDIR)/GO/$(GO_ID)
GO_TREE?=$(GO_DIR)/go_tree

#####################################################################################################
# uniref
#####################################################################################################

# pre-reqs:
# UNIREF_ODIR_BASE: output directory

# UniRef from ftp://ftp.uniprot.org/pub/databases/uniprot/uniref
GENE_REF_ID=uniref100_2018_02
UNIREF_INPUT_DIR?=/relman01/shared/databases/UniRef100/2018_02
GENE_REF_IFN?=$(UNIREF_INPUT_DIR)/uniref100.fasta
GENE_REF_XML_IFN=$(UNIREF_INPUT_DIR)/uniref100.xml

# UniProt from ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.xml.gz
UNIPROT_XML_IFN?=/relman01/shared/databases/UniProt/versions/2016_10/uniprot_sprot.xml

# UniParc table: ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/uniparc/uniparc_all.xml.gz
UNIPARC_XML_IFN?=/relman03/work/users/eitany/uniparc_all.xml

# uniref files
UNIREF_TABLE_BASE_DIR?=$(UNIREF_INPUT_DIR)/files
UNIREF_TABLE_DIR?=$(UNIREF_TABLE_BASE_DIR)/$(GENE_REF_ID)
UNIREF_TABLE?=$(UNIREF_TABLE_DIR)/table
UNIREF_GENE_TABLE?=$(UNIREF_TABLE_DIR)/genes

# uniprot and taxa id lookup
UNIREF_TAX_LOOKUP?=$(UNIREF_TABLE_DIR)/tax_lookup

# uniparc to uniprot lookup
UNIPARC2UNIPROT_LOOKUP?=$(UNIREF_TABLE_DIR)/uniparc2uniprot_lookup

# diamond database
UNIREF_DIAMOND_DB_DIR?=$(UNIREF_INPUT_DIR)/diamond
UNIREF_DIAMOND_DB?=$(UNIREF_DIAMOND_DB_DIR)/index

# uniref result
UNIREF_DIR?=$(UNIREF_ODIR_BASE)/$(GENE_REF_ID)
UNIREF_RAW_OFN?=$(UNIREF_DIR)/raw_table
UNIREF_OFN_UNIQUE?=$(UNIREF_DIR)/table_uniq
UNIREF_GENE_TAX_TABLE?=$(UNIREF_DIR)/table_uniq_taxa

# GO annotated uniref table
UNIREF_GENE_GO?=$(UNIREF_DIR)/table_GO

# genes can be in nt or aa format
UNIREF_QUERY_TYPE?=aa
ifeq (aa,$(UNIREF_QUERY_TYPE))
UNIREF_QUERY_GENE_FASTA?=$(GENE_FASTA_AA)
else
UNIREF_QUERY_GENE_FASTA?=$(GENE_FASTA_NT)
endif

#####################################################################################################
# gene map output
#####################################################################################################

# used to collpase map to a single top gene
COLLAPSE_FUNCTION?=max
COLLAPSE_FIELD?=identity

# output directory
GENEMAP_DIR?=$(OUTDIR)/gene_map_dir/id_$(GENE_MAP_ID)
GENE_MAP?=$(GENEMAP_DIR)/gene_map

#####################################################################################################
# diamond params
#####################################################################################################

DIAMOND_BIN?=diamond

# diamond -b parameter
DIAMOND_BLOCK_SIZE?=20

# diamond -c parameter
DIAMOND_INDEX_CHUNKS?=1

# number of threads
DIAMOND_THREADS?=40

# e value
DIAMOND_EVALUE?=0.001

# other parameters during alignment (blastx or blastp)
DIAMOND_FREE_PARAMS?=--sensitive

DIAMOND_MATRIX?=BLOSUM62
