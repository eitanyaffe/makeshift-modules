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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// main functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void query_nts_init_params(const char* name, int argc, char **argv, Parameters& params)
{
  params.add_parser("nlv", new ParserFilename("NLV file"), true);
  params.add_parser("table", new ParserFilename("Table with (contig,coord) pairs"), true);
  params.add_parser("ofn", new ParserFilename("Output table"), true);

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

void query_nts_save(VariationSet& varset,
		map< string, set< int > >& keys,
		ofstream& out)
{
  out << "contig" << "\t" << "coord" << "\t";
  out << "sub_A" << "\t" << "sub_C" << "\t" << "sub_G" << "\t" << "sub_T" << "\t" << "ref" << endl;

  vector<Variation> vars { Variation("sub_A"), Variation("sub_C"), Variation("sub_G"), Variation("sub_T"), Variation("none") };

  // go over all keys
  for (map< string, set< int > >::iterator it=keys.begin(); it!=keys.end(); ++it) {
    string contig = (*it).first;
    set< int >& keys_contig = (*it).second;
    for (set< int >::iterator jt=keys_contig.begin(); jt != keys_contig.end(); ++jt) {
      int coord = *jt;
      out << contig << "\t" << coord+1;
      for (unsigned int i=0; i < vars.size(); ++i) {
	int count = varset.get_var_count(contig, coord, vars[i]);
	out << "\t" << count;
      }
      out << "\n";
    }
  }
}

void query_nts_load(string fn, map< string, set< int > >& keys)
{
  cout << "reading query table: " << fn << endl;
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());
  vector<string> fields;
  char delim = '\t';

  // parse header
  split_line(in, fields, delim);
  int contig_ind = get_field_index("contig", fields);
  int coord_ind = get_field_index("coord", fields);

  while(in) {
    split_line(in, fields, delim);
    if(fields.size() == 0)
      break;

    string contig = fields[contig_ind];
    int coord = safe_string_to_int(fields[coord_ind], "coordinate") - 1;
    keys[contig].insert(coord);
  }
}

int query_nts_main(const char* name, int argc, char **argv)
{
  Parameters params;
  query_nts_init_params(name, argc, argv, params);

  string ifn_nlv = params.get_string("nlv");
  string ifn_tab = params.get_string("table");
  string ofn = params.get_string("ofn");

  VariationSet varset(ifn_nlv);

  map< string, set< int > > keys;
  query_nts_load(ifn_tab, keys);

  cout << "saving result to table: " << ofn << endl;
  ofstream out(ofn.c_str());
  massert(out.is_open(), "could not open file %s", ofn.c_str());

  query_nts_save(varset, keys, out);

  out.close();

  return 0;
}
