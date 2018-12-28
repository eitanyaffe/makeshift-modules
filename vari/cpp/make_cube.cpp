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

#include <queue>

#include <algorithm>
#include <stdio.h>
#include <stdlib.h>

#include <dirent.h>

#include "util.h"
#include "Params.h"
#include "KCube.h"

using namespace std;

void init_params(int argc, char **argv, Parameters& params)
{
  params.add_parser("ifn", new ParserFilename("input fastq file"), true);
  params.add_parser("ofn", new ParserFilename("output cube file"), true);
  params.add_parser("ksize", new ParserInteger("kmer size", 30), false);

  if (argc == 1) {
    params.usage(argv[0]);
    exit(0);
  }

  // read command line params
  params.read(argc, argv);
  params.parse();
  params.verify_mandatory();
  params.print(cout);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// main functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

int main(int argc, char **argv)
{
  Parameters params;
  init_params(argc, argv, params);

  string ifn = params.get_string("ifn");
  string ofn = params.get_string("ofn");
  int ksize = params.get_integer("ksize");

  KCube kcube(ksize);
  kcube.read_fastq(ifn);
  kcube.write(ofn);
}
