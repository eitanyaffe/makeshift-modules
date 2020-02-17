#include <iostream>
#include <vector>
#include <string>
#include <set>
#include <map>
#include <fstream>
#include <assert.h>
#include <sstream>
#include <stdarg.h>
#include <math.h>

#include <queue>

#include <algorithm>
#include <stdio.h>
#include <stdlib.h>

#include <dirent.h>

#include "util.h"

using namespace std;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Variation
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/*
vtSubstitute: Single nucleotide replaced on coordinate
vtDelete: Nucleotides deleted starting from coordinate
vtInsert: Nucleotides inserted to left of coordinate
vtDangleLeft: Read dangles to the left of coordinate
vtDangleRight: Read dangles the right of coordinate
*/

enum VariType { vtNone, vtSubstitute, vtDelete, vtInsert, vtDangleLeft, vtDangleRight };
struct Variation {
  VariType type;

  // vtSubstitute (N=1), vtInsert (N>=1)
  string seq;

  int delete_length;

  // ctor
  Variation(VariType _type=vtNone, string _seq="", int _delete_length=0);
  Variation(string str);

  // type to/from string
  string type_str();
  VariType str_to_type(const string str);

  // entire variation to/from string
  string str();
  void set_from_string(const string str);

  void save(ofstream& out);
  void load(ifstream& in);
};

bool operator<(const Variation& lhs, const Variation& rhs);
bool operator==(const Variation& lhs, const Variation& rhs);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Variation Set
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class VariationSet {
 private:
  static const char* m_magicref;

  // contig -> coordinate -> variation -> count
  map< string, map< int, map <Variation, int> > > m_vars;

  // contig -> coordinate -> count
  map<string, vector<int> > m_covs;

  void save_cov(ofstream& out);
  void save_nlv(ofstream& out);

  void load_cov(ifstream& in);
  void load_nlv(ifstream& in);

  void add_var_map(const map< string, map< int, map <Variation, int> > >& vars);
 public:
  VariationSet();
  VariationSet(const map<string, int>& contig_map);
  VariationSet(string fn);

  // direct functions for lazy coders
  map< string, map< int, map <Variation, int> > >& get_vars();
  map<string, vector<int> >& get_covs();

  // get contigs
  vector<string> get_contigs();

  // get support for variant
  int get_var_count(string& contig, int& coord, Variation& var);

  // get support for ref sequence
  int get_ref_count(const string contig, const int coord);

  // get total coverage for coord
  int get_coverage(const string contig, const int coord);

  // get major allele
  Variation get_major(const string contig, const int coord);

  // get all contig/coord/var keys
  void collect_var_keys(map< string, map< int, set< Variation > > >& keys);

  // get all contig/coord keys
  void collect_coord_keys(map< string, set< int > >& keys);

  // I/O
  void save(string fn);
  void load(string fn);

  friend VariationSet operator+(VariationSet const &, VariationSet const &);
};

