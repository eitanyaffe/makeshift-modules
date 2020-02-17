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
#include "Variation.h"
#include "Params.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// main functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void segregation_output(VariationSet& varset, int min_cov, double max_freq, ofstream& out)
{
  out << "contig" << "\t" << "coord" << "\t" << "major_allele" << "\t" << "major_count" << "\t" << "total_count" << endl;

  map< string, map< int, map <Variation, int> > >& vars = varset.get_vars();
  for (map< string, map< int, map <Variation, int> > >::const_iterator it=vars.begin(); it!=vars.end(); ++it) {
    string contig = (*it).first;
    const map< int, map <Variation, int> >& vars_contig = (*it).second;
    for (map< int, map <Variation, int> >::const_iterator jt=vars_contig.begin(); jt != vars_contig.end(); ++jt) {
      int coord = (*jt).first;

      Variation var = varset.get_major(contig, coord);
      int count = varset.get_var_count(contig, coord, var);
      int total = varset.get_coverage(contig, coord);

      if (total < min_cov)
	continue;

      double freq = (double)count / (double)total;
      if (freq > max_freq)
	continue;

      out << contig << "\t" << coord+1 << "\t" << var.str() << "\t" << count << "\t" << total << endl;
    }
  }
}

void segregation_init_params(const char* name, int argc, char **argv, Parameters& params)
{
  params.add_parser("nlv", new ParserFilename("NLV filename"), true);
  params.add_parser("min_cov", new ParserInteger("Minimal total coverage to report site", 10), false);
  params.add_parser("max_freq", new ParserDouble("Maximal major allele frequency to report site", 0.8), false);
  params.add_parser("ofn", new ParserFilename("Output table, with segregating positions"), true);

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

int segregation_main(const char* name, int argc, char **argv)
{
  Parameters params;
  segregation_init_params(name, argc, argv, params);

  string ifn = params.get_string("nlv");
  int min_cov = params.get_int("min_cov");
  double max_freq = params.get_double("max_freq");
  string ofn = params.get_string("ofn");

  VariationSet varset(ifn);

  cout << "saving result to table: " << ofn << endl;
  ofstream out(ofn.c_str(), ios::out | ios::binary);
  massert(out.is_open(), "could not open file %s", ofn.c_str());
  segregation_output(varset, min_cov, max_freq, out);
  out.close();

  return 0;
}
