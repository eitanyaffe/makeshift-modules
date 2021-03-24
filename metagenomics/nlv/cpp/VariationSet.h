#ifndef __VARIATIONSET__
#define __VARIATIONSET__

#include "Variation.h"

using namespace std;

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

  // get variations at coord
  void get_vars(const string contig, const int coord, vector<Variation>& vars);

  // get total coverage for coord
  int get_coverage(const string contig, const int coord);

  // get major allele
  Variation get_major(const string contig, const int coord);

  // get allele counts
  void get_counts(const string contig, const int coord, vector<int>& counts);

  // get all contig/coord/var keys
  void collect_var_keys(map< string, map< int, set< Variation > > >& keys);

  // get all contig/coord keys
  void collect_coord_keys(map< string, set< int > >& keys);

  // I/O
  void save(string fn);
  void load(string fn);

  friend VariationSet operator+(VariationSet const &, VariationSet const &);

  // for plotting, detailed
  void get_contig_data(string contig, int from, int to,
		       vector<string>& contig_r,
		       vector<int>& coord_r,
		       vector<string>& var_r,
		       vector<int>& count_r,
		       vector<int>& total_r,
		       vector<int>& cc_start_r,
		       vector<int>& cc_end_r);

  // for plotting, binning
  void get_summary(string contig, int& from, int& to, int min_cov, double max_seg_freq,
		   int& seg_count_r, int& median_cov_r);

  // to reduce space, resrict to specified contigs
  void restrict(vector<string>& contigs);
};

#endif
