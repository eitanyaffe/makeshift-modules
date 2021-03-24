#include <iostream>
#include <vector>
#include <string>
#include <set>
#include <map>
#include <fstream>
#include <assert.h>
#include <sstream>
#include <stdarg.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "nlv.h"

using namespace std;

void usage(const char* name)
{
  fprintf(stderr, "NLV: Nucleotide-level variation tool\n");
  fprintf(stderr, "usage: %s <command> [options]\n", name);
  fprintf(stderr, "commands:\n");
  fprintf(stderr, "  construct: Construct NLV from mapped reads\n");
  fprintf(stderr, "  merge: Merge multiple NLVs\n");
  fprintf(stderr, "  compare: Out table comparing multiple NLVs\n");
  fprintf(stderr, "  diverge: Identify diverging major alleles between two NLVs\n");
  fprintf(stderr, "  segregation: Identify segtrgating positions in a single NLV\n");
  fprintf(stderr, "  query: Extract counts for a set of contig/coord/variation\n");
  fprintf(stderr, "  coverage: Extract total median coverage for segment sets\n");
  fprintf(stderr, "  restrict: Restrict NLV to a set of contigs\n");
  fprintf(stderr, "  sites: Extract segregating sites across multiple NLVs\n");
  fprintf(stderr, "  view: Print to screen data for single contig\n");
  fprintf(stderr, "  dump: Dump single NLV into tab-delimited tables (for debugging)\n");
}

int main(int argc, char **argv)
{
  if (argc == 1) {
    usage(argv[0]);
    exit(0);
  }
  string command(argv[1]);
  string name =  string(argv[0]) + " " + command;

  int rc = 0;
  if (command == "construct") {
    rc = construct_main(name.c_str(), argc-1, argv+1);
  } else if (command == "dump") {
    rc = dump_main(name.c_str(), argc-1, argv+1);
  } else if (command == "merge") {
    rc = merge_main(name.c_str(), argc-1, argv+1);
  } else if (command == "diverge") {
    rc = divergence_main(name.c_str(), argc-1, argv+1);
  } else if (command == "compare") {
    rc = compare_main(name.c_str(), argc-1, argv+1);
  } else if (command == "query") {
    rc = query_main(name.c_str(), argc-1, argv+1);
  } else if (command == "coverage") {
    rc = coverage_main(name.c_str(), argc-1, argv+1);
  } else if (command == "restrict") {
    rc = restrict_main(name.c_str(), argc-1, argv+1);
  } else if (command == "segregation") {
    rc = segregation_main(name.c_str(), argc-1, argv+1);
  } else if (command == "sites") {
    rc = sites_main(name.c_str(), argc-1, argv+1);
  } else if (command == "view") {
    rc = view_main(name.c_str(), argc-1, argv+1);
  } else {
    printf("unknown command: %s\n", command.c_str());
    usage(argv[0]);
    exit(1);
  }

  return rc;
}
