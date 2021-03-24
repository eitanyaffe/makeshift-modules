#include <iostream>
#include <vector>
#include <string>
#include <set>
#include <map>
#include <fstream>
#include <assert.h>
#include <sstream>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

#include "util.h"
#include "VariationSet.h"
#include "Params.h"

struct Segment {
  string contig;
  int start, end;
  Segment(string _contig, int _start, int _end) : contig(_contig), start(_start), end(_end) {};
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// main functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void restrict_init_params(const char* name, int argc, char **argv, Parameters& params)
{
  params.add_parser("ifn_nlv", new ParserFilename("NLV filename"), true);
  params.add_parser("ifn_contigs", new ParserFilename("Contig table"), true);
  params.add_parser("ofn", new ParserFilename("Output file"), true);

  if (argc == 1) {
    params.usage(name);
    exit(0);
  }

  // read command line params
  params.read(argc, argv);
  params.parse();
  params.verify_mandatory();
  params.print(cout);
}

void read_contig_table(string fn, vector<string>& result)
{
  cout << "reading table: " << fn << endl;
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());
  vector<string> fields;
  char delim = '\t';

  // parse header
  split_line(in, fields, delim);
  int contig_ind = get_field_index("contig", fields);

  while(in) {
    split_line(in, fields, delim);
    if(fields.size() == 0)
      break;

    string contig = fields[contig_ind];
    result.push_back(contig);
  }
}

int restrict_main(const char* name, int argc, char **argv)
{
  Parameters params;
  restrict_init_params(name, argc, argv, params);

  string ifn_nlv = params.get_string("ifn_nlv");
  string ifn_contigs = params.get_string("ifn_contigs");
  string ofn = params.get_string("ofn");

  vector<string> contigs;
  read_contig_table(ifn_contigs, contigs);
  cout << "number of output contigs: " << contigs.size() << endl;

  VariationSet varset(ifn_nlv);
  varset.restrict(contigs);
  varset.save(ofn);

  return 0;
}
