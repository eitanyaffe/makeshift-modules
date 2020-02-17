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
#include "Dissolve.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// dissolve functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void dissolve_read_library_table(string fn, vector< string >& ifns)
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

void get_contig_counts(string contig, vector < VariationSet >& varsets,
		       vector < vector < double > >& result)
{
  for (unsigned int i=0; i<varsets.size(); ++i) {
    map<string, vector<int> >& set_cov = varsets[i].get_covs();
    massert(set_cov.find(contig) != set_cov.end(), "contig not found");
    vector<int>& contig_cov = set_cov[contig];
    unsigned int contig_length = contig_cov.size();

    // !!!
    // contig_length = 600;
    if (i == 0) {
      result.resize(contig_length);
      for (unsigned int j=0; j<contig_length; ++j)
	result[j].resize(varsets.size());
    } else {
      massert(result.size() == contig_length, "contig length does not match up between libraries");
    }
    // !!!
    for (unsigned int j=0; j<contig_length; ++j)
      result[j][i] = contig_cov[j];
      // result[j][i] = contig_cov[j + 43500];
      // result[j][i] = contig_cov[j + 46193 - 800];
  }
}

void dissolve_contig_dump(string ofn, string contig, vector < VariationSet >& varsets, double outlier_fraction, double min_P, double pseudo_count)
{
  Dissolve dissolve(varsets.size(), pseudo_count);
  get_contig_counts(contig, varsets, dissolve.get_counts());
  dissolve.init_once();

  for (unsigned i=0; i<200; ++i) {
    cout << "round: " << (i+1) << endl;

    vector < double > chivalues = dissolve.get_chivalues();
    vector < double > pvalues = dissolve.get_pvalues();
    vector < bool > is_center = dissolve.get_is_center();

    massert(pvalues.size() == chivalues.size(), "size of vectors must match");

    string ofn_round = ofn + "." + to_string(i+1);
    ofstream out(ofn_round.c_str(), ios::out);
    massert(out.is_open(), "could not open file %s", ofn_round.c_str());

    out << "coord\tchivalue\tPvalue\tis_center" << endl;
    for (unsigned int i=0; i<pvalues.size(); ++i)
      out << i+1 << "\t" << chivalues[i] << "\t" << pvalues[i] << "\t" << (is_center[i] ? "T" : "F") << endl;

    out.close();

    if (dissolve.reduce_center_round(outlier_fraction, min_P) == 0)
      break;
  }
}

void dissolve_contig(ofstream& out, string contig, vector < VariationSet >& varsets, double outlier_fraction, double min_P, double pseudo_count)
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// main functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void dissolve_init_params(const char* name, int argc, char **argv, Parameters& params)
{
  params.add_parser("ifn", new ParserFilename("Table with multiple NLV files"), true);
  params.add_parser("contig", new ParserFilename("limit to a single contig", ""), false);
  params.add_parser("outlier_fraction", new ParserDouble("Fraction of outliers tested every round", 0.01), false);
  params.add_parser("p_value", new ParserDouble("Min Chi-Square P-value", 0.001), false);
  params.add_parser("pseudo_count", new ParserDouble("Add pseudo-count", 0.1), false);
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

int dissolve_main(const char* name, int argc, char **argv)
{
  Parameters params;
  dissolve_init_params(name, argc, argv, params);

  string ifn = params.get_string("ifn");
  string contig = params.get_string("contig");
  double outlier_fraction = params.get_double("outlier_fraction");
  double min_P = params.get_double("p_value");
  double pseudo_count = params.get_double("pseudo_count");
  string ofn = params.get_string("ofn");

  vector< string > ifns;
  dissolve_read_library_table(ifn, ifns);

  vector < VariationSet > varsets(ifns.size());
  for (unsigned int i=0; i<ifns.size(); ++i) {
    VariationSet& varset = varsets[i];
    varset.load(ifns[i]);
  }


  if (contig != "") {
    dissolve_contig_dump(ofn, contig, varsets, outlier_fraction, min_P, pseudo_count);
    return 0;
  }

  ofstream out(ofn.c_str(), ios::out);
  massert(out.is_open(), "could not open file %s", ofn.c_str());

  vector<string> contigs = varsets[1].get_contigs();
  for (vector<string>::iterator it=contigs.begin(); it != contigs.end(); ++it)
    dissolve_contig(out, *it, varsets, outlier_fraction, min_P, pseudo_count);

  out.close();

  return 0;
}
