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

#include <boost/math/distributions/chi_squared.hpp>
using namespace boost::math;

inline double diverge_get_item_value(double obs, double exp, bool correct)
{
  double aa = abs(obs - exp) - (correct ? 0.5 : 0);
  if (aa < 0)
    aa = 0;
  return (aa * aa) / exp;
}

double diverge_compute_four_chi_square(int major1, int major2, int minor1, int minor2, bool correct)
{
  double N = major1 + major2 + minor1 + minor2;
  double major_sum = (major1 + major2);
  double minor_sum = (minor1 + minor2);
  double sample1_sum = (major1 + minor1);
  double sample2_sum = (major2 + minor2);
  double aa = abs(major1 * minor2 - major2 * minor1) - (correct ? N/2 : 0);
  if (aa < 0)
    aa = 0;
  return (N * aa * aa) / (major_sum * minor_sum * sample1_sum * sample2_sum);
}

double diverge_compute_four_pvalue(int major1, int major2, int minor1, int minor2, bool correct)
{
  double stat = diverge_compute_four_chi_square(major1, major2, minor1, minor2, correct);
  chi_squared chi_squared(1);
  return (1 - cdf(chi_squared, stat));
}

void diverge_save_sites(VariationSet& varset1, VariationSet& varset2,
			map< string, map < int, pair< Variation, Variation > > >& sites,
			bool correct,
			ofstream& out)
{
  out << "contig" << "\t" << "coord" << "\t" << "major_var" << "\t" << "minor_var";
  out << "\t" << "P_value" << "\t" << "coverage1" << "\t" << "coverage2";
  out << "\t" << "major1" << "\t" << "major2" << "\t" << "minor1" << "\t" << "minor2" << endl;

  // go over all sites
  for (map< string, map < int, pair< Variation, Variation > > >::iterator it=sites.begin(); it!=sites.end(); ++it) {
    string contig = (*it).first;
    map < int, pair< Variation, Variation > >& sites_contig = (*it).second;
    for (map < int, pair< Variation, Variation > >::iterator jt=sites_contig.begin(); jt != sites_contig.end(); ++jt) {
      int coord = (*jt).first;

      Variation var_major = (*jt).second.first;
      Variation var_minor = (*jt).second.second;

      int major1 = varset1.get_var_count(contig, coord, var_major);
      int major2 = varset2.get_var_count(contig, coord, var_major);
      int minor1 = varset1.get_var_count(contig, coord, var_minor);
      int minor2 = varset2.get_var_count(contig, coord, var_minor);

      int cover1 = varset1.get_coverage(contig, coord);
      int cover2 = varset2.get_coverage(contig, coord);

      double p_value = diverge_compute_four_pvalue(major1+1, major2+1, minor1+1, minor2+1, correct);
	out << contig << "\t" << coord+1 << "\t" << var_major.to_string() << "\t" << var_minor.to_string();
	out << "\t" << p_value << "\t" << cover1 << "\t" << cover2;
	out << "\t" << major1 << "\t" << major2 << "\t" << minor1 << "\t" << minor2 << endl;
    }
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// main functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void divergence_init_params(const char* name, int argc, char **argv, Parameters& params)
{
  params.add_parser("ifn", new ParserFilename("Site table"), true);
  params.add_parser("nlv1", new ParserFilename("First NLV"), true);
  params.add_parser("nlv2", new ParserFilename("Second NLV"), true);
  //params.add_parser("p", new ParserDouble("P-value threshold", 0.05), false);
  params.add_parser("yates_correct", new ParserBoolean("Perform Yate's correction", false), false);
  params.add_parser("ofn", new ParserFilename("Output table with P-values"), true);

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

int divergence_main(const char* name, int argc, char **argv)
{
  Parameters params;
  divergence_init_params(name, argc, argv, params);

  string ifn_sites = params.get_string("ifn");
  string ifn1 = params.get_string("nlv1");
  string ifn2 = params.get_string("nlv2");
  //  double pthreshold = params.get_double("p");
  bool correct = params.get_bool("yates_correct");
  string ofn = params.get_string("ofn");

  // sites: contig->coord->pair(major/minor)
  map< string, map < int, pair< Variation, Variation > > > sites;
  int count = read_sites(ifn_sites, sites);
  cout << "number of sites: " << count << endl;

  VariationSet varset1(ifn1), varset2(ifn2);

  cout << "saving result to table: " << ofn << endl;
  ofstream out(ofn.c_str(), ios::out | ios::binary);
  massert(out.is_open(), "could not open file %s", ofn.c_str());
  diverge_save_sites(varset1, varset2, sites, correct, out);
  out.close();

  return 0;
}
