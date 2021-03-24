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

#include <boost/math/distributions/chi_squared.hpp>
using namespace boost::math;

#include "util.h"
#include "Params.h"
#include "VariationSet.h"
#include "Dissolve.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// sites chi-square p-value functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

double sites_get_chi_square(vector<int> v1, vector<int> v2)
{
  massert(v1.size() == v2.size(), "vectors must be same length");
  int N = v1.size();
  double sum1 = 0;
  double sum2 = 0;
  vector<double> sum_sets(N);
  for (int i=0; i<N; ++i) {
    sum1 += v1[i];
    sum2 += v2[i];
    sum_sets[i] = v1[i] + v2[i];
  }
  double total = sum1 + sum2;
  double f1 = sum1 / total;
  double f2 = sum2 / total;
  
  double result = 0;
  for (int i=0; i<N; ++i) {
    double o1 = v1[i];
    double e1 = sum_sets[i] * f1;
    double o2 = v2[i];
    double e2 = sum_sets[i] * f2;
    result += (o1-e1)*(o1-e1)/e1 + (o2-e2)*(o2-e2)/e2;
  }
  return result;
}

double sites_get_pvalue(vector<int> v1, vector<int> v2)
{
  massert(v1.size() == v2.size(), "vectors must be same length");
  int N = v1.size();
  chi_squared chi_squared(N-1);
  return 1 - cdf(chi_squared, sites_get_chi_square(v1, v2));
}

double sites_get_pvalue(vector<VariationSet>& vsets, string contig, int coord, Variation var)
{
  int N = vsets.size();
  vector<int> var_counts(N); 
  vector<int> other_counts(N); 
  for (int i=0; i<N; ++i) {
    int coverage = vsets[i].get_coverage(contig, coord);
    int var_count = vsets[i].get_var_count(contig, coord, var);
    massert(coverage >= var_count, "Expecting var<=cov. i=%d, contig: %s, coord: %d, var: %s, cov: %d, var_count: %d", i, contig.c_str(), coord, var.to_string().c_str(), coverage, var_count);
    var_counts[i] = var_count + 1;
    other_counts[i] = coverage - var_count + 1;
  }
  return sites_get_pvalue(var_counts, other_counts);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// sites functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void sites_read_library_table(string fn, vector< string >& ifns)
{
  cout << "reading table: " << fn << endl;
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());
  vector<string> fields;
  char delim = '\t';

  // parse header
  split_line(in, fields, delim);
  int fn_ind = get_field_index("fn", fields);

  while(in) {
    split_line(in, fields, delim);
    if(fields.size() == 0)
      break;
    string ifn = fields[fn_ind];
    ifns.push_back(ifn);
  }
}

bool sort_var_pairs(const pair<Variation,int> &a, const pair<Variation,int> &b)
{
    return (a.second > b.second);
}

void extract_sites(string ofn, vector<VariationSet>& vsets, VariationSet& vset_sum,
		   int min_var_count, int min_total_count, int min_sample_count, double pvalue_t)
{
  ofstream out(ofn.c_str(), ios::out);
  massert(out.is_open(), "could not open file %s", ofn.c_str());
  out << "contig\tcoord\tvar_count\tmajor\tmajor_count\tmajor_pvalue\tminor\tminor_count\tminor_pvalue" << endl;

  map< string, map< int, map <Variation, int> > >& vars = vset_sum.get_vars();
  for (map< string, map< int, map <Variation, int> > >::const_iterator it=vars.begin(); it!=vars.end(); ++it) {
    string contig = (*it).first;
    const map< int, map <Variation, int> >& vars_contig = (*it).second;
    for (map< int, map <Variation, int> >::const_iterator jt=vars_contig.begin(); jt != vars_contig.end(); ++jt) {
      int coord = (*jt).first;

      // check total coverage
      if (vset_sum.get_coverage(contig, coord) < min_total_count)
	continue;

      // extract variations that pass coverage threshold
      vector < pair <Variation, int> > vars;

      // add the reference if needed
      int ref_count = vset_sum.get_ref_count(contig, coord);
      Variation ref_var;
      if (ref_count >= min_var_count)
	vars.push_back(make_pair(ref_var, ref_count));

      const map <Variation, int>& vars_coord = (*jt).second;
      for (map <Variation, int>::const_iterator xt=vars_coord.begin(); xt!=vars_coord.end(); ++xt) {
	Variation var = (*xt).first;
	int count = (*xt).second;
	if (count < min_var_count)
	  continue;

	// count number of unique samples
	int n_samples = 0;
	for (unsigned int i=0; i<vsets.size(); ++i)
	  if (vsets[i].get_var_count(contig, coord, var) > 0)
	    n_samples++;

	double pvalue = sites_get_pvalue(vsets, contig, coord, var);
	if (pvalue > pvalue_t)
	  continue;
	
	if (n_samples >= min_sample_count)
	  vars.push_back(make_pair(var, count));
      }
      if (vars.size() < 2)
	continue;

      // sort by variation coverage
      sort(vars.begin(), vars.end(), sort_var_pairs);

      double p1 = sites_get_pvalue(vsets, contig, coord, vars[0].first);
      double p2 = sites_get_pvalue(vsets, contig, coord, vars[1].first);

      // output
      out << contig << "\t" << coord+1 << "\t" << vars.size() << "\t";
      out << vars[0].first.to_string() << "\t" << vars[0].second << "\t" << p1 << "\t";
      out << vars[1].first.to_string() << "\t" << vars[1].second << "\t" << p2 << endl;
    }
  }

  out.close();
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// main functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void sites_init_params(const char* name, int argc, char **argv, Parameters& params)
{
  params.add_parser("ifn", new ParserFilename("Table with multiple NLV files"), true);
  params.add_parser("min_var_count", new ParserInteger("Minimal read support of variation", 4), false);
  params.add_parser("min_total_count", new ParserInteger("Minimal total support of site", 10), false);
  params.add_parser("min_sample_count", new ParserInteger("Minimal number of samples variation appeared in", 2), false);
  params.add_parser("pvalue_threshold", new ParserDouble("Maximal chi-square p-value", 0.05), false);
  params.add_parser("ofn", new ParserFilename("output file"), true);

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

int sites_main(const char* name, int argc, char **argv)
{
  Parameters params;
  sites_init_params(name, argc, argv, params);

  string ifn = params.get_string("ifn");
  int min_var_count = params.get_int("min_var_count");
  int min_total_count = params.get_int("min_total_count");
  int min_sample_count = params.get_int("min_sample_count");
  double pvalue_t = params.get_double("pvalue_threshold");
  string ofn = params.get_string("ofn");

  vector< string > ifns;
  sites_read_library_table(ifn, ifns);

  vector<VariationSet> vsets(ifns.size());
  VariationSet sum_vset;
  for (unsigned int i=0; i<ifns.size(); ++i) {
    VariationSet& varset_i = vsets[i];
    varset_i.load(ifns[i]);
    if (i == 0)
      sum_vset = varset_i;
    else
      sum_vset = sum_vset + varset_i;

  }

  extract_sites(ofn, vsets, sum_vset, min_var_count, min_total_count, min_sample_count, pvalue_t);

  return 0;
}
