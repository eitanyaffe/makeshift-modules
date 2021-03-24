#include <cstring>
#include "VariationSet.h"
#include "util.h"
using namespace std;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Variation Set
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

VariationSet::VariationSet() {}

VariationSet::VariationSet(const map<string, int>& contig_map)
{
  for (map<string, int>::const_iterator it=contig_map.begin(); it!=contig_map.end(); ++it) {
    string contig = (*it).first;
    int length = (*it).second;

    vector<int>& coverage_contig = m_covs[contig];
    coverage_contig.resize(length);
  }
}

VariationSet::VariationSet(string fn)
{
  load(fn);
}

map< string, map< int, map <Variation, int> > >& VariationSet::get_vars()
{
  return m_vars;
}

map<string, vector<int> >& VariationSet::get_covs()
{
  return m_covs;
}

vector<string> VariationSet::get_contigs()
{
  vector<string> result;
  for (auto const& element : m_covs)
    result.push_back(element.first);
  return result;
}

void VariationSet::collect_var_keys(map< string, map< int, set< Variation > > >& keys)
{
  map< string, map< int, map <Variation, int> > >& vars = get_vars();
  for (map< string, map< int, map <Variation, int> > >::const_iterator it=vars.begin(); it!=vars.end(); ++it) {
    string contig = (*it).first;
    const map< int, map <Variation, int> >& vars_contig = (*it).second;
    map< int, set <Variation> >& result_vars_contig = keys[contig];

    for (map< int, map <Variation, int> >::const_iterator jt=vars_contig.begin(); jt != vars_contig.end(); ++jt) {
      int coord = (*jt).first;
      const map <Variation, int>& vars_coord = (*jt).second;
      set <Variation >& result_vars_coord = result_vars_contig[coord];
      for (map <Variation, int>::const_iterator xt=vars_coord.begin(); xt!=vars_coord.end(); ++xt) {
	Variation var = (*xt).first;
	result_vars_coord.insert(var);
      }
    }
  }
}

void VariationSet::collect_coord_keys(map< string, set< int > >& keys)
{
  map< string, map< int, map <Variation, int> > >& vars = get_vars();
  for (map< string, map< int, map <Variation, int> > >::const_iterator it=vars.begin(); it!=vars.end(); ++it) {
    string contig = (*it).first;
    const map< int, map <Variation, int> >& vars_contig = (*it).second;
    set <int>& keys_contig = keys[contig];

    for (map< int, map <Variation, int> >::const_iterator jt=vars_contig.begin(); jt != vars_contig.end(); ++jt) {
      int coord = (*jt).first;
      keys_contig.insert(coord);
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Save Variation Set
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void VariationSet::save_nlv(ofstream& out)
{
  // write number of contigs
  size_t size = m_vars.size();
  out.write(reinterpret_cast<const char*>(&size), sizeof(size));

  for (map< string, map< int, map <Variation, int> > >::iterator it=m_vars.begin(); it!=m_vars.end(); ++it) {
    string contig = (*it).first;
    map< int, map <Variation, int> >& vars_contig = (*it).second;

    // write contig id length
    size_t size_contig = contig.size();
    out.write(reinterpret_cast<const char*>(&size_contig), sizeof(size_contig));

    // write contig id
    out.write(contig.c_str(), sizeof(char)*contig.size());

    // write number of coords per contig
    size_t size_vars_contig = vars_contig.size();
    out.write(reinterpret_cast<const char*>(&size_vars_contig), sizeof(size_vars_contig));

    for (map< int, map <Variation, int> >::iterator jt=vars_contig.begin(); jt != vars_contig.end(); ++jt) {
      int coord = (*jt).first;
      map <Variation, int>& vars_coord = (*jt).second;

      // write coord
      out.write(reinterpret_cast<const char*>(&coord), sizeof(int));

      // write number of vars per coord
      size_t size_vars_coord = vars_coord.size();
      out.write(reinterpret_cast<const char*>(&size_vars_coord), sizeof(size_vars_coord));

      for (map <Variation, int>::iterator xt=vars_coord.begin(); xt!=vars_coord.end(); ++xt) {
	Variation var = (*xt).first;
	int count = (*xt).second;

	var.save(out);
	out.write(reinterpret_cast<const char*>(&count), sizeof(int));
      }
    }
  }
}


void VariationSet::load_nlv(ifstream& in)
{
  // cout << "loading NLV maps" << endl;

  // load number of contigs
  size_t n_contigs;
  in.read(reinterpret_cast<char*>(&n_contigs), sizeof(n_contigs));

  for (unsigned i=0; i<n_contigs; ++i) {
    string contig;

    // read contig id size
    size_t size_contig;
    in.read(reinterpret_cast<char*>(&size_contig), sizeof(size_contig));

    // read contig id
    contig.resize(size_contig);
    in.read(&contig[0], sizeof(char)*contig.size());

    map< int, map <Variation, int> >& vars_contig = m_vars[contig];

    // read number of coords per contig
    size_t n_coords;
    in.read(reinterpret_cast<char*>(&n_coords), sizeof(n_coords));

    for (unsigned j=0; j<n_coords; ++j) {

      // read coord
      int coord;
      in.read(reinterpret_cast<char*>(&coord), sizeof(int));

      map <Variation, int>& vars_coord = vars_contig[coord];

      // read number of vars per coord
      size_t n_vars;
      in.read(reinterpret_cast<char*>(&n_vars), sizeof(n_vars));

      for (unsigned k=0; k<n_vars; ++k) {
	Variation var;
	int count;

	var.load(in);
	in.read(reinterpret_cast<char*>(&count), sizeof(int));

	vars_coord[var] = count;
      }
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// coverage load/save (VariationSet)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void VariationSet::save_cov(ofstream& out)
{
  // write number of contigs
  size_t size = m_covs.size();
  out.write(reinterpret_cast<const char*>(&size), sizeof(size));

  for (map<string, vector<int> >::iterator it=m_covs.begin(); it!=m_covs.end(); ++it) {
    string contig = (*it).first;
    vector<int>& coverage_contig = (*it).second;

    // write contig id length
    size_t size_contig = contig.size();
    out.write(reinterpret_cast<const char*>(&size_contig), sizeof(size_contig));

    // write contig id
    out.write(contig.c_str(), sizeof(char)*contig.size());

    // write coverage vector length
    size_t length = coverage_contig.size();
    out.write(reinterpret_cast<const char*>(&length), sizeof(length));

    // write coverage vector values
    out.write(reinterpret_cast<const char*>(&coverage_contig[0]), coverage_contig.size()*sizeof(int));
  }
}

void VariationSet::load_cov(ifstream& in)
{
  // cout << "loading coverage vectors" << endl;
  // read number of contigs
  size_t n_contigs;
  in.read(reinterpret_cast<char*>(&n_contigs), sizeof(n_contigs));

  for (unsigned i=0; i<n_contigs; ++i) {
    // read contig
    string contig;

    size_t size_contig;
    in.read(reinterpret_cast<char*>(&size_contig), sizeof(size_contig));

    contig.resize(size_contig);
    in.read(&contig[0], sizeof(char)*contig.size());

    vector<int>& coverage_contig = m_covs[contig];

    // read coverage vector length
    size_t length;
    in.read(reinterpret_cast<char*>(&length), sizeof(length));

    // read coverage vector values
    coverage_contig.resize(length);
    in.read(reinterpret_cast<char*>(&coverage_contig[0]), coverage_contig.size()*sizeof(int));
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Load/Save Variation Set
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

static const char VariationSet_magicref[] = {0x01,0x03,0x02,0x04};
const char* VariationSet::m_magicref = VariationSet_magicref;

void VariationSet::save(string fn)
{
  cout << "saving NLV file: " << fn << endl;
  ofstream out(fn.c_str(), ios::out | ios::binary);
  massert(out.is_open(), "could not open file %s", fn.c_str());

  // save magic number
  out.write(m_magicref, 4);

  save_cov(out);
  save_nlv(out);
  out.close();
}

void VariationSet::load(string fn)
{
  cout << "reading NLV file: " << fn << endl;
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());

  char magic[4];
  in.read(magic, 4);
  massert((memcmp(magic, m_magicref, sizeof(magic)) == 0), "magic number not found, check file format");

  load_cov(in);
  load_nlv(in);

  in.close();
}

void VariationSet::add_var_map(const map< string, map< int, map <Variation, int> > >& vars)
{
  for (map< string, map< int, map <Variation, int> > >::const_iterator it=vars.begin(); it!=vars.end(); ++it) {
    string contig = (*it).first;
    const map< int, map <Variation, int> >& vars_contig = (*it).second;
    map< int, map <Variation, int> >& this_vars_contig = m_vars[contig];

    for (map< int, map <Variation, int> >::const_iterator jt=vars_contig.begin(); jt != vars_contig.end(); ++jt) {
      int coord = (*jt).first;
      const map <Variation, int>& vars_coord = (*jt).second;
      map <Variation, int>& this_vars_coord = this_vars_contig[coord];
      for (map <Variation, int>::const_iterator xt=vars_coord.begin(); xt!=vars_coord.end(); ++xt) {
	Variation var = (*xt).first;
	int count = (*xt).second;
	this_vars_coord[var] += count;
      }
    }
  }
}

VariationSet operator+(VariationSet const &v1, VariationSet const &v2)
{
  VariationSet result;

  // add nlv maps
  result.add_var_map(v1.m_vars);
  result.add_var_map(v2.m_vars);

  // sum coverage vectors
  massert(v1.m_covs.size() == v2.m_covs.size(), "number of contigs must be the same");
  for (map<string, vector<int> >::const_iterator it=v1.m_covs.begin(); it!=v1.m_covs.end(); ++it) {
    string contig = (*it).first;
    const vector<int>& coverage_contig1 = (*it).second;

    massert(v2.m_covs.find(contig) != v2.m_covs.end(), "contig %s not found", contig.c_str());
    const vector<int>& coverage_contig2 = v2.m_covs.at(contig);

    massert(coverage_contig1.size() == coverage_contig2.size(), "coverage vectors must be equal size for contig %s", contig.c_str());
    vector<int>& coverage_contig = result.m_covs[contig];
    coverage_contig.resize(coverage_contig1.size());
    for (unsigned i=0; i<coverage_contig1.size(); ++i) {
      coverage_contig[i] = coverage_contig1[i] + coverage_contig2[i];
    }
  }

  return result;
}

int VariationSet::get_var_count(string& contig, int& coord, Variation& var)
{
  massert(m_covs.find(contig) != m_covs.end(), "contig not found");
  if (var.is_ref())
    return get_ref_count(contig, coord);

  // contig not found
  if (m_vars.find(contig) == m_vars.end())
    return 0;
  map< int, map <Variation, int> >& contig_vars = m_vars[contig];

  // coord not found
  if (contig_vars.find(coord) == contig_vars.end())
    return 0;
  map <Variation, int>& coord_vars = contig_vars[coord];

  // var not found
  if (coord_vars.find(var) == coord_vars.end())
    return 0;

  return coord_vars[var];
}

int VariationSet::get_coverage(const string contig, const int coord)
{
  massert(m_covs.find(contig) != m_covs.end(), "contig not found");
  vector<int>& cov = m_covs[contig];
  massert(coord >= 0 && coord < (int)cov.size(), "coordinate out of range");
  return cov[coord];
}

void VariationSet::get_vars(const string contig, const int coord, vector<Variation>& vars)
{
  if (m_vars.find(contig) == m_vars.end())
    return;
  map< int, map <Variation, int> >& contig_vars = m_vars[contig];
  if (contig_vars.find(coord) == contig_vars.end())
    return;
  map <Variation, int>& coord_vars = contig_vars[coord];
  for (map <Variation, int>::const_iterator xt=coord_vars.begin(); xt!=coord_vars.end(); ++xt)
    vars.push_back((*xt).first);
}

int VariationSet::get_ref_count(const string contig, const int coord)
{
  massert(m_covs.find(contig) != m_covs.end(), "contig not found");
  vector<int>& cov = m_covs[contig];
  massert(coord >= 0 && coord < (int)cov.size(), "coordinate out of range, contig: %s, coord: %d", contig.c_str(), coord);
  int total_count = cov[coord];

  // contig not found
  if (m_vars.find(contig) == m_vars.end())
    return total_count;
  map< int, map <Variation, int> >& contig_vars = m_vars[contig];

  // coord not found
  if (contig_vars.find(coord) == contig_vars.end())
    return total_count;
  map <Variation, int>& coord_vars = contig_vars[coord];

  int total_var = 0;
  for (map <Variation, int>::const_iterator xt=coord_vars.begin(); xt!=coord_vars.end(); ++xt) {
    Variation var = (*xt).first;
    int count = (*xt).second;
    total_var += count;
  }

  return (total_count - total_var);
}

void VariationSet::get_counts(const string contig, const int coord, vector<int>& counts)
{
  counts.clear();
  massert(m_covs.find(contig) != m_covs.end(), "contig not found");
  int ref_count = get_ref_count(contig, coord);
  counts.push_back(ref_count);
  if (m_vars.find(contig) == m_vars.end())
    return;
  map< int, map <Variation, int> >& contig_vars = m_vars[contig];
  map <Variation, int>& coord_vars = contig_vars[coord];
  for (map <Variation, int>::const_iterator xt=coord_vars.begin(); xt!=coord_vars.end(); ++xt)
    counts.push_back((*xt).second);
  sort(counts.begin(), counts.end(), greater<int>());
}

Variation VariationSet::get_major(const string contig, const int coord)
{
  Variation result;
  massert(m_covs.find(contig) != m_covs.end(), "contig not found");
  vector<int>& cov = m_covs[contig];
  massert(coord >= 0 && coord < (int)cov.size(), "coordinate out of range");

  // contig not found
  if (m_vars.find(contig) == m_vars.end())
    return result;
  map< int, map <Variation, int> >& contig_vars = m_vars[contig];

  // coord not found
  if (contig_vars.find(coord) == contig_vars.end())
    return result;

  // init for reference count
  int ref_count = get_ref_count(contig, coord);
  int max_count = ref_count;

  // find maximal variant
  map <Variation, int>& coord_vars = contig_vars[coord];
  for (map <Variation, int>::const_iterator xt=coord_vars.begin(); xt!=coord_vars.end(); ++xt) {
    Variation var = (*xt).first;
    int count = (*xt).second;
    if (count > max_count) {
      max_count = count;
      result = var;
    }
  }

  return result;
}

void VariationSet::get_contig_data(string contig, int from, int to,
				   vector<string>& contig_r,
				   vector<int>& coord_r,
				   vector<string>& var_r,
				   vector<int>& count_r,
				   vector<int>& total_r,
				   vector<int>& cc_start_r,
				   vector<int>& cc_end_r)
{
  if (m_covs.find(contig) == m_covs.end())
    return;

  vector<int>& contig_cov = m_covs[contig];
  map< int, map <Variation, int> >& contig_vars = m_vars[contig];

  for (int coord=from; coord<=to; ++coord) {
    if (coord < 0 || coord >= (int)contig_cov.size()) continue;

    int total_cov = contig_cov[coord];
    int cumsum = 0;

    // start with variations
    if (contig_vars.find(coord) != contig_vars.end()) {
      map <Variation, int>& coord_vars = contig_vars[coord];
      for (map <Variation, int>::const_iterator xt=coord_vars.begin(); xt!=coord_vars.end(); ++xt) {
	Variation var = (*xt).first;
	int count = (*xt).second;
	contig_r.push_back(contig);
	coord_r.push_back(coord);
	var_r.push_back(var.to_string());
	count_r.push_back(count);
	total_r.push_back(total_cov);
	cc_start_r.push_back(cumsum);
	cc_end_r.push_back(cumsum+count);
	cumsum += count;
      }
    }

    // add ref
    int ref_cov = total_cov - cumsum;
    if (ref_cov != 0) {
      contig_r.push_back(contig);
      coord_r.push_back(coord);
      var_r.push_back("none");
      count_r.push_back(ref_cov);
      total_r.push_back(total_cov);
      cc_start_r.push_back(cumsum);
      cc_end_r.push_back(cumsum+ref_cov);
    }
  }
}

void VariationSet::restrict(vector<string>& contigs)
{
  map< string, map< int, map <Variation, int> > > vars;
  map<string, vector<int> > covs;
  for (unsigned int i=0; i<contigs.size(); ++i) {
    string contig = contigs[i];
    vars[contig] = m_vars[contig];
    covs[contig] = m_covs[contig];
  }
  m_vars = vars;
  m_covs = covs;
}

int median(vector<int> &v)
{
  size_t n = v.size() * 0.5;
  if (n >= v.size()) n = v.size()-1;
  nth_element(v.begin(), v.begin()+n, v.end());
  return v[n];
}

void VariationSet::get_summary(string contig, int& from, int& to, int min_cov, double max_seg_freq,
			       int& seg_count_r, int& median_cov_r)
{
  seg_count_r = 0;
  median_cov_r = 0;
  if (m_covs.find(contig) == m_covs.end()) {
    from = -1;
    to = -1;
    return;
  }

  vector<int>& contig_cov = m_covs[contig];
  map< int, map <Variation, int> >& vars_contig = m_vars[contig];

  if (from < 0)
    from = 0;
  if (to >= (int)contig_cov.size())
    to = contig_cov.size()-1;

  vector<int> acounts;

  // count sites
  for (int coord=from; coord<=to; ++coord) {
    map< int, map <Variation, int> >::const_iterator it = vars_contig.find(coord);
    if (it == vars_contig.end())
      continue;

    Variation var = get_major(contig, coord);
    get_counts(contig, coord, acounts);
    if (acounts.size() < 2)
      continue;
    int total = get_coverage(contig, coord);
    double freq2 = (double)acounts[1] / (double)total;
    if (total >= min_cov && (freq2 >= (1-max_seg_freq) || !var.is_ref()))
      seg_count_r++;

    // int count = get_var_count(contig, coord, var);
    // int total = get_coverage(contig, coord);
    // double freq = (double)count / (double)total;

    // if (total >= min_cov && freq <= max_seg_freq)
    //  seg_count_r++;
    // if (total >= min_cov && (freq <= max_seg_freq || !var.is_ref()))
    //  seg_count_r++;
  }

  // median coverage
  vector<int> counts(contig_cov.begin() + from, contig_cov.begin() + to + 1);
  median_cov_r = median(counts);
}
