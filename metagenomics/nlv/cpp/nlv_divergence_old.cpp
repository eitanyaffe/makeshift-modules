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

void divergence_init_params(const char* name, int argc, char **argv, Parameters& params)
{
  params.add_parser("nlv1", new ParserFilename("First NLV"), true);
  params.add_parser("nlv2", new ParserFilename("Second NLV"), true);
  params.add_parser("min_cov", new ParserInteger("Minimal total coverage on both sets", 3), false);
  params.add_parser("ofn", new ParserFilename("Output table, with major alleles for the two NLVs"), true);

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

void diverge_save_keys(VariationSet& varset1, VariationSet& varset2,
		       map< string, set< int > >& keys,
		       int min_cov,
		       ofstream& out)
{
  out << "contig" << "\t" << "coord" << "\t";
  out << "var1" << "\t" << "count1" << "\t" << "total1" << "\t";
  out << "var2" << "\t" << "count2" << "\t" << "total2" << "\n";

  // go over all keys
  for (map< string, set< int > >::iterator it=keys.begin(); it!=keys.end(); ++it) {
    string contig = (*it).first;
    set< int >& keys_contig = (*it).second;
    for (set< int >::iterator jt=keys_contig.begin(); jt != keys_contig.end(); ++jt) {
      int coord = (*jt);

      Variation var1 = varset1.get_major(contig, coord);
      Variation var2 = varset2.get_major(contig, coord);

      // report only if major alleles are divergent
      if (var1 == var2)
	continue;

      int count1 = varset1.get_var_count(contig, coord, var1);
      int count2 = varset2.get_var_count(contig, coord, var2);

      int total1 = varset1.get_coverage(contig, coord);
      int total2 = varset2.get_coverage(contig, coord);

      if (total1 < min_cov || total2 < min_cov)
	continue;

      out << contig << "\t" << coord+1 << "\t";
      out << var1.str() << "\t" << count1 << "\t" << total1 << "\t";
      out << var2.str() << "\t" << count2 << "\t" << total2 << "\n";
    }
  }
}

int divergence_main(const char* name, int argc, char **argv)
{
  Parameters params;
  divergence_init_params(name, argc, argv, params);

  string ifn1 = params.get_string("nlv1");
  string ifn2 = params.get_string("nlv2");
  int min_cov = params.get_int("min_cov");
  string ofn = params.get_string("ofn");

  VariationSet varset1(ifn1), varset2(ifn2);
  map< string, set< int > > keys;
  varset1.collect_coord_keys(keys);
  varset2.collect_coord_keys(keys);

  cout << "saving result to table: " << ofn << endl;
  ofstream out(ofn.c_str(), ios::out | ios::binary);
  massert(out.is_open(), "could not open file %s", ofn.c_str());
  diverge_save_keys(varset1, varset2, keys, min_cov, out);
  out.close();

  return 0;
}
