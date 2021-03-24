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

void query_init_params(const char* name, int argc, char **argv, Parameters& params)
{
  params.add_parser("nlv", new ParserFilename("NLV file"), true);
  params.add_parser("table", new ParserFilename("Table with (contig,coord,variation) triplets"), true);
  params.add_parser("field", new ParserString("Variation field in table"), true);
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

void query_save(VariationSet& varset,
		map< string, map< int, set< Variation > > >& keys,
		ofstream& out)
{
  out << "contig" << "\t" << "coord" << "\t";
  out << "var" << "\t" << "count" << "\t" << "total" << "\n";

  // go over all keys
  for (map< string, map< int, set< Variation > > >::iterator it=keys.begin(); it!=keys.end(); ++it) {
    string contig = (*it).first;
    map< int, set< Variation > >& keys_contig = (*it).second;
    for (map< int, set< Variation > >::iterator jt=keys_contig.begin(); jt != keys_contig.end(); ++jt) {
      int coord = (*jt).first;
      set< Variation >& keys_coord = (*jt).second;
      for (set< Variation >::iterator kt=keys_coord.begin(); kt != keys_coord.end(); ++kt) {
	Variation var = (*kt);

	int count = varset.get_var_count(contig, coord, var);
	int total = varset.get_coverage(contig, coord);

	out << contig << "\t" << coord+1 << "\t";
	out << var.to_string() << "\t" << count << "\t" << total << "\n";
      }
    }
  }
}

void query_load(string fn,string var_field, map< string, map< int, set< Variation > > >& keys)
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
  int var_ind = get_field_index(var_field, fields);

  while(in) {
    split_line(in, fields, delim);
    if(fields.size() == 0)
      break;

    string contig = fields[contig_ind];
    int coord = safe_string_to_int(fields[coord_ind], "coordinate") - 1;
    Variation var = Variation(fields[var_ind]);
    keys[contig][coord].insert(var);
  }
}

int query_main(const char* name, int argc, char **argv)
{
  Parameters params;
  query_init_params(name, argc, argv, params);

  string ifn_nlv = params.get_string("nlv");
  string ifn_tab = params.get_string("table");
  string field = params.get_string("field");
  string ofn = params.get_string("ofn");

  VariationSet varset(ifn_nlv);

  map< string, map< int, set< Variation > > > keys;
  query_load(ifn_tab, field, keys);

  cout << "saving result to table: " << ofn << endl;
  ofstream out(ofn.c_str());
  massert(out.is_open(), "could not open file %s", ofn.c_str());

  query_save(varset, keys, out);

  out.close();

  return 0;
}
