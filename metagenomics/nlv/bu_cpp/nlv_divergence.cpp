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

#include <boost/math/distributions/chi_squared.hpp>
using namespace boost::math;

inline double diverge_get_item_value(double obs, double exp, bool correct)
{
  //  cout << "obs: " << obs << ", exp=" << exp << endl;
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
  return (N * aa * aa) / (major_sum * minor_sum * sample1_sum * sample2_sum);
}

double diverge_compute_four_pvalue(int major1, int major2, int minor1, int minor2, bool correct)
{
  double stat = diverge_compute_four_chi_square(major1, major2, minor1, minor2, correct);
  if (stat < 0) {
    cout << major1 << " " <<  major2 << " " <<  minor1 << " " <<  minor2 << endl;
  }
  chi_squared chi_squared(1);
  return (1 - cdf(chi_squared, stat));
}

void diverge_save_sites(VariationSet& varset1, VariationSet& varset2,
			map< string, map < int, pair< Variation, Variation > > >& sites,
			double pthreshold, bool correct,
			ofstream& out)
{
  out << "contig" << "\t" << "coord" << "\t" << "P_value" << "\t" << "coverage1" << "\t" << "coverage2" << endl;

  // go over all sites
  for (map< string, map < int, pair< Variation, Variation > > >::iterator it=sites.begin(); it!=sites.end(); ++it) {
    string contig = (*it).first;
    map < int, pair< Variation, Variation > >& sites_contig = (*it).second;
    for (map < int, pair< Variation, Variation > >::iterator jt=sites_contig.begin(); jt != sites_contig.end(); ++jt) {
      int coord = (*jt).first;

      Variation var_major = (*jt).second.first;
      Variation var_minor = (*jt).second.second;

      int major1 = varset1.get_var_count(contig, coord, var_major) + 1;
      int major2 = varset2.get_var_count(contig, coord, var_major) + 1;
      int minor1 = varset1.get_var_count(contig, coord, var_minor) + 1;
      int minor2 = varset2.get_var_count(contig, coord, var_minor) + 1;

      int cover1 = varset1.get_coverage(contig, coord);
      int cover2 = varset2.get_coverage(contig, coord);

      // !!!
      major1 = max(major1, 1);
      major2 = max(major2, 1);
      minor1 = max(minor1, 1);
      minor2 = max(minor2, 1);
      // nlv view -contig s117388 -ifn /relman03/work/users/eitany/tempo/subjects/AAB/assembly/megahit/nlv_v4/libs/full_S2/lib.nlv.old | head -n 10 > s117388.view

      double p_value = diverge_compute_four_pvalue(major1, major2, minor1, minor2, correct);
      if (p_value <= pthreshold)
	out << contig << "\t" << coord+1 << "\t" << p_value << "\t" << cover1 << "\t" << cover2 << endl;
    }
  }
}

void read_sites(string ifn, map< string, map < int, pair< Variation, Variation > > >& sites)
{
  cout << "reading site table: " << ifn << endl;
  ifstream in(ifn.c_str());
  massert(in.is_open(), "could not open file %s", ifn.c_str());
  vector<string> fields;
  char delim = '\t';

  // parse header
  split_line(in, fields, delim);
  int contig_ind = get_field_index("contig", fields);
  int coord_ind = get_field_index("coord", fields);
  int major_ind = get_field_index("major", fields);
  int minor_ind = get_field_index("minor", fields);

  while(in) {
    split_line(in, fields, delim);
    if(fields.size() == 0)
      break;

    string contig = fields[contig_ind];
    int coord = safe_string_to_int(fields[coord_ind], "coordinate") - 1;
    Variation major = Variation(fields[major_ind]);
    Variation minor = Variation(fields[minor_ind]);

    sites[contig][coord] = make_pair(major, minor);
  }

  in.close();
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// main functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void divergence_init_params(const char* name, int argc, char **argv, Parameters& params)
{
  params.add_parser("ifn", new ParserFilename("Site table"), true);
  params.add_parser("nlv1", new ParserFilename("First NLV"), true);
  params.add_parser("nlv2", new ParserFilename("Second NLV"), true);
  params.add_parser("p", new ParserDouble("P-value threshold", 0.05), false);
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
  double pthreshold = params.get_double("p");
  bool correct = params.get_bool("yates_correct");
  string ofn = params.get_string("ofn");

  // sites: contig->coord->pair(major/minor)
  map< string, map < int, pair< Variation, Variation > > > sites;
  read_sites(ifn_sites, sites);

  // VariationSet varset(ifn2);
  // string contig("s117388");
  // int coord = 396;

  // vector<Variation> vars;
  // varset.get_vars(contig, coord, vars);
  // for (unsigned int i=0; i<vars.size(); ++i) {
  //   int var_count = varset.get_var_count(contig, coord, vars[i]);
  //   cout << " var: " << vars[i].str() << " count: " << var_count << endl;
  // }

  // int ref_count = varset.get_ref_count(contig, coord);
  // int cov_count = varset.get_coverage(contig, coord);
  // cout << "ref: "<< ref_count << " cov: " << cov_count << endl;
  // exit(0);

  VariationSet varset1(ifn1), varset2(ifn2);

  cout << "saving result to table: " << ofn << endl;
  ofstream out(ofn.c_str(), ios::out | ios::binary);
  massert(out.is_open(), "could not open file %s", ofn.c_str());
  diverge_save_sites(varset1, varset2, sites, pthreshold, correct, out);
  out.close();

  return 0;
}
