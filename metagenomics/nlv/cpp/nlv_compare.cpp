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

struct Library {
  string id;
  string path;
  Library(string _id, string _path) : id(_id), path(_path) {};
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// main functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void compare_init_params(const char* name, int argc, char **argv, Parameters& params)
{
  params.add_parser("nlv_table", new ParserFilename("Table with NLV files (filename column) and NLV identifier (id column)"), true);
  params.add_parser("ofn", new ParserFilename("Comparison output file"), true);

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

void read_library_table(string fn, vector< Library >& libs)
{
  cout << "reading table: " << fn << endl;
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());
  vector<string> fields;
  char delim = '\t';

  // parse header
  split_line(in, fields, delim);
  int id_ind = get_field_index("id", fields);
  int fn_ind = get_field_index("filename", fields);

  while(in) {
    split_line(in, fields, delim);
    if(fields.size() == 0)
      break;

    string id = fields[id_ind];
    string fn = fields[fn_ind];
    Library lib(id, fn);
    libs.push_back(lib);
  }
}

void cmp_save_keys(vector< VariationSet >& sets,
		   vector< string >& set_ids,
		   map< string, map< int, set< Variation > > >& keys,
		   ofstream& out)
{
  out << "contig" << "\t" << "coord" << "\t" << "var";
  for (unsigned int i=0; i<sets.size(); ++i) {
    out << "\t" << set_ids[i];
  }
  out << endl;

  // go over all keys
  for (map< string, map< int, set <Variation> > >::iterator it=keys.begin(); it!=keys.end(); ++it) {
    string contig = (*it).first;
    map< int, set <Variation > >& keys_contig = (*it).second;
    for (map< int, set <Variation > >::iterator jt=keys_contig.begin(); jt != keys_contig.end(); ++jt) {
      int coord = (*jt).first;
      set <Variation >& keys_coord = (*jt).second;

      ////////////////////////////////////////////////////////////////////////////////
      // print ref support
      ////////////////////////////////////////////////////////////////////////////////

      out << contig << "\t" << coord+1 << "\t" << "REF";
      for (unsigned int i=0; i<sets.size(); ++i) {
	int count = sets[i].get_ref_count(contig, coord);
	out << "\t" << count;
      }
      out << endl;

      ////////////////////////////////////////////////////////////////////////////////
      // print variant support
      ////////////////////////////////////////////////////////////////////////////////

      for (set <Variation>::iterator xt=keys_coord.begin(); xt!=keys_coord.end(); ++xt) {
	Variation var = (*xt);
	out << contig << "\t" << coord+1 << "\t" << var.to_string();
	for (unsigned int i=0; i<sets.size(); ++i) {
	  int count = sets[i].get_var_count(contig, coord, var);
	  out << "\t" << count;
	}
	out << endl;
      }
    }
  }
}

int compare_main(const char* name, int argc, char **argv)
{
  Parameters params;
  compare_init_params(name, argc, argv, params);

  string ifn = params.get_string("nlv_table");
  string ofn = params.get_string("ofn");

  vector< Library > libs;
  read_library_table(ifn, libs);
  cout << "number of libraries: " << libs.size() << endl;

  //////////////////////////////////////////////////////////////////
  // first round: collect keys
  //////////////////////////////////////////////////////////////////

  vector< VariationSet > sets(libs.size());
  vector< string > set_ids(libs.size());

  map< string, map< int, set< Variation > > > keys;
  for (unsigned int i=0; i<libs.size(); ++i) {
    string id = libs[i].id;
    string path = libs[i].path;

    set_ids[i] = id;
    VariationSet& varset_i = sets[i];

    varset_i.load(path);
    varset_i.collect_var_keys(keys);
  }

  //////////////////////////////////////////////////////////////////
  // second round: save results to table
  //////////////////////////////////////////////////////////////////

  cout << "saving result to table: " << ofn << endl;
  ofstream out(ofn.c_str(), ios::out | ios::binary);
  massert(out.is_open(), "could not open file %s", ofn.c_str());

  cmp_save_keys(sets, set_ids, keys, out);

  out.close();
  return 0;
}
