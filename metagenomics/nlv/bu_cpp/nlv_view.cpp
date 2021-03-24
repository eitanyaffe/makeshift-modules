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
#include "Params.h"
#include "Variation.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// main functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void view_init_params(const char* name, int argc, char **argv, Parameters& params)
{
  params.add_parser("ifn", new ParserFilename("NLV filename"), true);
  params.add_parser("contig", new ParserString("contig"), true);

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

int view_main(const char* name, int argc, char **argv)
{
  Parameters params;
  view_init_params(name, argc, argv, params);

  string ifn = params.get_string("ifn");
  string contig = params.get_string("contig");

  VariationSet varset;
  varset.load(ifn);

  map< string, map< int, map <Variation, int> > >& vars = varset.get_vars();
  if (vars.find(contig) == vars.end()) {
    cout << "contig not found" << endl;
    return 0;
  }

  map< int, map <Variation, int> > & contig_vars = vars[contig];
  for (map< int, map <Variation, int> >::iterator it=contig_vars.begin(); it != contig_vars.end(); ++it) {
    int coord = (*it).first;
    map <Variation, int>& xmap = (*it).second;
    int total = varset.get_coverage(contig, coord);
    int ref = varset.get_ref_count(contig, coord);
    for (map <Variation, int>::iterator xt=xmap.begin(); xt!=xmap.end(); ++xt) {
      Variation var = (*xt).first;
      int count = (*xt).second;
      cout << coord+1 << ":\t" << var.str() << "=" << count  << " | " << "total=" << total << " | " << "ref=" << ref << endl;
    }
  }
  return 0;
}
