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
#include "VariationSet.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// main functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void dump_init_params(const char* name, int argc, char **argv, Parameters& params)
{
  params.add_parser("ifn", new ParserFilename("NLV filename"), true);
  params.add_parser("ofn_cov", new ParserFilename("coverage output file"), true);
  params.add_parser("ofn_nlv", new ParserFilename("NLV output file"), true);

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


void dump_cov(VariationSet& varset, string fn)
{
  map<string, vector<int> >& covs = varset.get_covs();

  cout << "saving coverage vector to table: " << fn << endl;
  ofstream out(fn.c_str(), ios::out | ios::binary);
  massert(out.is_open(), "could not open file %s", fn.c_str());

  out << "contig" << "\t" << "coord" << "\t" << "count"  << endl;
  for (map<string, vector<int> >::iterator it=covs.begin(); it!=covs.end(); ++it) {
    string contig = (*it).first;
    vector<int>& coverage_contig = (*it).second;
    for (unsigned int i=0; i<coverage_contig.size(); ++i)
      out << contig << "\t" << i+1 << "\t" << coverage_contig[i] << endl;
  }
  out.close();
}

void dump_nlv(VariationSet& varset, string fn)
{
  map< string, map< int, map <Variation, int> > >& vars = varset.get_vars();

  cout << "saving nlv to table: " << fn << endl;
  ofstream out(fn.c_str(), ios::out | ios::binary);
  massert(out.is_open(), "could not open file %s", fn.c_str());

  // header
  out << "contig" << "\t" << "coord" << "\t" << "var" << "\t" << "count"  << endl;

  for (map< string, map< int, map <Variation, int> > >::iterator it=vars.begin(); it!=vars.end(); ++it) {
    string contig = (*it).first;
    map< int, map <Variation, int> >& table_contig = (*it).second;

    for (map< int, map <Variation, int> >::iterator jt=table_contig.begin(); jt != table_contig.end(); ++jt) {
      int coord = (*jt).first;
      map <Variation, int>& xmap = (*jt).second;
      for (map <Variation, int>::iterator xt=xmap.begin(); xt!=xmap.end(); ++xt) {
	Variation var = (*xt).first;
	int count = (*xt).second;
	out << contig << "\t" << coord+1 << "\t" << var.to_string() << "\t" << count  << endl;
      }
    }
  }
  out.close();
}

int dump_main(const char* name, int argc, char **argv)
{
  Parameters params;
  dump_init_params(name, argc, argv, params);

  string ifn = params.get_string("ifn");
  string ofn_cov = params.get_string("ofn_cov");
  string ofn_nlv = params.get_string("ofn_nlv");

  VariationSet varset;
  varset.load(ifn);

  dump_cov(varset, ofn_cov);
  dump_nlv(varset, ofn_nlv);

  return 0;
}
