#####################################################################################################
# register module
#####################################################################################################

units=genes_prodigal.mk genes_uniref.mk genes_blast_aa.mk genes_blast_nt.mk genes_GO.mk genes_bins.mk
$(call _register_module,genes,$(units),,)

#####################################################################################################
# input and databases locations
#####################################################################################################

# input fasta
GENES_FASTA_INPUT?=$(CONTIG_FASTA)

# uniref/diamond database can be shared across projects
UNIREF_DIAMOND_DB_DIR?=$(BASE_OUTPUT_DIR)/diamond_db

# GO database can be shared across projects
GO_BASE_DIR?=$(BASE_OUTPUT_DIR)/GO

#####################################################################################################
# prodigal.mk
#####################################################################################################

PRODIGAL_BIN?=/home/dethlefs/Prodigal_2.6.3/prodigal

# output directory
PRODIGAL_DIR?=$(ASSEMBLY_DIR)/prodigal

# parameters: https://github.com/hyattpd/prodigal/wiki/cheat-sheet
PRODIGAL_SELECT_PROCEDURE?=meta

# translation table
PRODIGAL_TRANSLATION_TABLE?=11

# input
PRODIGAL_INPUT?=$(GENES_FASTA_INPUT)

# output
PRODIGAL_AA_BASE?=$(PRODIGAL_DIR)/genes.faa
PRODIGAL_NT_BASE?=$(PRODIGAL_DIR)/genes.fna
PRODIGAL_OUTPUT_RAW?=$(PRODIGAL_DIR)/prodigal.out

# clean fasta headers
PRODIGAL_AA?=$(PRODIGAL_DIR)/genes_final.faa
PRODIGAL_NT?=$(PRODIGAL_DIR)/genes_final.fna

# gene table
PRODIGAL_GENE_TABLE?=$(PRODIGAL_DIR)/gene.tab

# by default use prodigal genes
GENE_FASTA_AA?=$(PRODIGAL_AA)
GENE_FASTA_NT?=$(PRODIGAL_NT)
GENE_TABLE?=$(PRODIGAL_GENE_TABLE)

#####################################################################################################
# blastn
#####################################################################################################

# blastn binary
BLAST_BIN?=blastn

BLAST_THREADS=40
BLAST_EVALUE=0.001

#####################################################################################################
# diamond
#####################################################################################################

# diamond binary
DIAMOND_BIN?=diamond

DIAMOND_BLOCK_SIZE?=20
DIAMOND_INDEX_CHUNKS?=1
DIAMOND_THREADS?=40
DIAMOND_EVALUE?=0.001
DIAMOND_BLASTP_PARAMS?=--sensitive

#####################################################################################################
# uniref
#####################################################################################################

# UniRef from ftp://ftp.uniprot.org/pub/databases/uniprot/uniref
GENE_REF_ID?=2019_03
UNIREF_INPUT_DIR?=/relman01/shared/databases/UniRef100/$(GENE_REF_ID)
GENE_REF_IFN?=$(UNIREF_INPUT_DIR)/uniref100.fasta
GENE_REF_XML_IFN=$(UNIREF_INPUT_DIR)/uniref100.xml

# UniProt from ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.xml.gz
UNIPROT_ID?=2019_03
UNIPROT_XML_IFN?=/relman01/shared/databases/UniProt/versions/$(UNIPROT_ID)/uniprot_sprot.xml

# uniref diamond database
UNIREF_DIAMOND_DB?=$(UNIREF_DIAMOND_DB_DIR)/$(GENE_REF_ID)

# uniref table
UNIREF_TABLE_DIR?=$(UNIREF_INPUT_DIR)/files
UNIREF_TABLE?=$(UNIREF_TABLE_DIR)/table
UNIREF_GENE_TABLE?=$(UNIREF_TABLE_DIR)/genes

# uniprot and taxa id lookup
UNIREF_TAX_LOOKUP?=$(UNIREF_TABLE_DIR)/tax_lookup

# uniref search result
UNIREF_ODIR_BASE?=$(ASSEMBLY_DIR)/uniref
UNIREF_DIR?=$(UNIREF_ODIR_BASE)/$(GENE_REF_ID)
UNIREF_RAW_OFN?=$(UNIREF_DIR)/raw_table
UNIREF_OFN_UNIQUE?=$(UNIREF_DIR)/table_uniq
UNIREF_GENE_TAX_TABLE?=$(UNIREF_DIR)/table_uniq_taxa

# final annotated table, with GO
UNIREF_GENE_GO?=$(UNIREF_DIR)/table_GO

TOP_IDENTITY_RATIO=2
TOP_IDENTITY_DIFF=5
UNIREF_TOP?=$(UNIREF_DIR)/top_uniref_top

# gene general stats
UNIREF_POOR_ANNOTATION?="uncharacterized_protein hypothetical_protein MULTISPECIES:_hypothetical_protein Putative_uncharacterized_protein"
UNIREF_STATS?=$(UNIREF_DIR)/gene_stats

#####################################################################################################
# Gene Ontology
#####################################################################################################

# GO table from http://purl.obolibrary.org/obo/go/go-basic.obo
GO_OBO_ID?=2019-03-14
GO_BASIC_OBO?=/relman01/shared/databases/GO/go-basic.obo-$(GO_OBO_ID)

# UniProt to GO: ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/UNIPROT/goa_uniprot_all.gaf.gz
GOA_UNIPROT_ID?=2019-03-14
GOA_UNIPROT_TABLE?=/relman01/shared/databases/GO/goa_uniprot/$(GOA_UNIPROT_ID)/goa_uniprot_all.gaf
UNIPROT2GO_LOOKUP?=/relman01/shared/databases/GO/goa_uniprot/$(GOA_UNIPROT_ID)/goa_uniprot_all.gaf.parsed

# UniParc table: ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/uniparc/uniparc_all.xml.gz
UNIPARC_ID?=March_2019
UNIPARC_XML_IFN?=/relman03/work/users/eitany/uniparc/$(UNIPARC_ID)/uniparc_all.xml

GO_ID?=2019_03
GO_DIR?=$(GO_BASE_DIR)/$(GO_ID)
GO_TREE?=$(GO_DIR)/go_tree

# uniparc to uniprot lookup
UNIPARC2UNIPROT_LOOKUP?=$(GO_DIR)/uniparc2uniprot_lookup

#####################################################################################################
# gene to bin
#####################################################################################################

GENE2BIN_TABLE?=$(PRODIGAL_DIR)/gene2bin
