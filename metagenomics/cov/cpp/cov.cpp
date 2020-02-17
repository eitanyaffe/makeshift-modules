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
#include "cov.h"

using namespace std;

void usage(const char* name)
{
  fprintf(stderr, "cov: Nucleotide-level coverage tool\n");
  fprintf(stderr, "usage: %s <command> [options]\n", name);
  fprintf(stderr, "commands:\n");
  fprintf(stderr, "  construct: Construct cov file from mapped reads\n");
  fprintf(stderr, "  refine: Breakdown contigs into segments\n");
  fprintf(stderr, "  refine_single: Breakdown single contig into segments\n");
  fprintf(stderr, "  bin: Bin segments\n");
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
  } else if (command == "refine_single") {
    rc = break_single_main(name.c_str(), argc-1, argv+1);
  } else if (command == "refine") {
    rc = break_multi_main(name.c_str(), argc-1, argv+1);
  } else if (command == "bin") {
    rc = bin_main(name.c_str(), argc-1, argv+1);
  } else {
    printf("unknown command: %s\n", command.c_str());
    usage(argv[0]);
    exit(1);
  }

  return rc;
}
