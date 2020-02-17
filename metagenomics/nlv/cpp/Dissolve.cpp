#include <iostream>
#include <random>

#include <boost/math/distributions/chi_squared.hpp>
using namespace boost::math;

#include "Dissolve.h"

///////////////////////////////////////////////////////////////////////////////////////////////
// ctor and init
///////////////////////////////////////////////////////////////////////////////////////////////

Dissolve::Dissolve(int lib_count, double pseudo_count) : m_init(false), m_lib_count(lib_count), m_pseudo_count(pseudo_count) {}

vector < vector < double > >& Dissolve::get_counts() { return m_counts; }
vector < vector < double > >& Dissolve::get_freqs() { return m_freqs; }

void Dissolve::add_pseudo_count()
{
  for (int i=0; i<m_contig_length; ++i)
    for (int j=0; j<m_lib_count; ++j)
      m_counts[i][j] += m_pseudo_count;
}

void Dissolve::init_marg()
{
  m_marg.resize(m_contig_length);
  for (int i=0; i<m_contig_length; ++i)
    for (int j=0; j<m_lib_count; ++j)
      m_marg[i] += m_counts[i][j];
}

void Dissolve::init_freq()
{
  m_freqs.resize(m_contig_length);
  for (int i=0; i<m_contig_length; ++i) {
    m_freqs[i].resize(m_lib_count);

    // compute total for coord
    double total = 0;
    for (int j=0; j<m_lib_count; ++j)
      total += m_counts[i][j];

    // compute freq for coord
    for (int j=0; j<m_lib_count; ++j)
      m_freqs[i][j] = m_counts[i][j] / total;
  }
}

void Dissolve::init_center_coords()
{
  for (int i=0; i<m_contig_length; ++i)
    m_center_coords.insert(i);
}

void Dissolve::init_once()
{
  // init once
  if (m_init)
    return;
  m_init = true;

  massert(m_counts.size() > 0, "contig vector is empty");
  m_contig_length = m_counts.size();

  add_pseudo_count();

  init_freq();
  init_marg();
  init_center_coords();
  update_center_freq();
}

///////////////////////////////////////////////////////////////////////////////////////////////
// center functions
///////////////////////////////////////////////////////////////////////////////////////////////

void Dissolve::update_center_freq()
{
  int center_size = m_center_coords.size();
  vector < double > result(m_lib_count);
  for (set <int >::iterator it=m_center_coords.begin(); it != m_center_coords.end(); ++it) {
    int coord = *it;
    massert(coord >= 0 && coord < m_contig_length, "coord out of range");
    for (int j=0; j<m_lib_count; ++j)
      result[j] += m_freqs[coord][j];
  }
  double total = 0;
  for (int j=0; j<m_lib_count; ++j) {
    result[j] = result[j] / center_size;
    total += result[j];
  }

  // extra normalize step due to possible precision issue
  for (int j=0; j<m_lib_count; ++j) {
    result[j] = result[j] / total;
  }

  m_center_freq = result;
}

void Dissolve::remove_from_center(int coord)
{
  int center_size = m_center_coords.size();
  for (int j=0; j<m_lib_count; ++j)
    m_center_freq[j] = (m_center_freq[j] * center_size - m_freqs[coord][j]) / (center_size-1);
  m_center_coords.erase(coord);
}

///////////////////////////////////////////////////////////////////////////////////////////////
// outlier functions
///////////////////////////////////////////////////////////////////////////////////////////////

void Dissolve::sort_by_chi_values(vector< ChiValue >& chi_values)
{
  sort(chi_values.begin(), chi_values.end(), []( const ChiValue& lhs, const ChiValue& rhs )
       {
	 return lhs.value > rhs.value;
       });
}

void Dissolve::sort_by_coords(vector< ChiValue >& chi_values)
{
  sort(chi_values.begin(), chi_values.end(), []( const ChiValue& lhs, const ChiValue& rhs )
       {
	 return lhs.coord < rhs.coord;
       });
}

double Dissolve::get_chi_value(int coord)
{
  double stat = 0;
  for (int j=0; j<m_lib_count; ++j) {
    double obs = m_counts[coord][j];
    double exp = m_center_freq[j] * m_marg[coord];
    stat += (obs - exp) * (obs - exp) / exp;
  }
  return stat;
}


void Dissolve::get_center_chi_values(vector < ChiValue >& chi_values)
{
  chi_values.clear();
  for (set <int >::iterator it=m_center_coords.begin(); it != m_center_coords.end(); ++it) {
    int coord = *it;
    ChiValue cv(coord, get_chi_value(coord));
    chi_values.push_back(cv);
  }
}

void Dissolve::update_chi_values(vector < ChiValue >& chi_values)
{
  for (unsigned int i=0; i<chi_values.size(); ++i)
    chi_values[i].value = get_chi_value(chi_values[i].coord);
}

///////////////////////////////////////////////////////////////////////////////////////////////
// outlier functions
///////////////////////////////////////////////////////////////////////////////////////////////

void Dissolve::potential_outliers(double outlier_fraction, vector<ChiValue>& result)
{
  massert(m_init, "init must be called");

  result.clear();
  vector < ChiValue > chi_values;
  get_center_chi_values(chi_values);
  sort_by_chi_values(chi_values);
  int size = floor((double)chi_values.size() * outlier_fraction);
  if (size < 10)
    size = min(10, (int)chi_values.size());
  copy_n(chi_values.begin(), size, std::back_inserter(result));
}

int Dissolve::reduce_center_round(double outlier_fraction, double p_threshold)
{
  massert(m_init, "init must be called");

  // !!!
  // m_center_coords.clear();
  // m_center_coords.insert(200);
  // update_center_freq();
  // return 0;

  chi_squared chi_squared(m_lib_count-1);
  double chi_threshold = quantile(chi_squared, 1-p_threshold);
  cout << "P=" << p_threshold << ", chi=" << chi_threshold << endl;
  update_center_freq();

  vector<ChiValue> chi_values;
  potential_outliers(outlier_fraction, chi_values);
  // cout << "number of potential outliers: "<< chi_values.size() << endl;
  if (chi_values.size() == 0)
    return 0;

  int removed_count = 0;
  for (unsigned int i=0; i<chi_values.size(); ++i) {
    if (chi_values[i].value > chi_threshold) {
      remove_from_center(chi_values[i].coord);
      update_chi_values(chi_values);
      removed_count++;
    }
  }
  update_center_freq();

  cout  << "number of removed coords: " << removed_count << endl;
  return removed_count;
}

void Dissolve::reduce_center(double outlier_fraction, double p_threshold)
{
  massert(m_init, "init must be called");

  int max_rounds = 1000;
  int round_count = 0;
  int removed_count = 1;
  while (round_count < max_rounds && removed_count > 0) {
    round_count++;
    removed_count = reduce_center_round(outlier_fraction, p_threshold);
  }
}

vector < double >& Dissolve::get_center_freq()
{
  massert(m_init, "init must be called");

  return m_center_freq;
}

vector < double > Dissolve::get_chivalues()
{
  massert(m_init, "init must be called");

  vector < double > result(m_contig_length);
  for (int i=0; i<m_contig_length; ++i)
    result[i] = get_chi_value(i);
  return result;
}

vector < double > Dissolve::get_pvalues()
{
  massert(m_init, "init must be called");

  vector < double > result(m_contig_length);
  vector < double > chivalues = get_chivalues();
  chi_squared chi_squared(m_lib_count-1);
  result.resize(m_contig_length);
  for (int i=0; i<m_contig_length; ++i)
    result[i] = 1 - cdf(chi_squared, chivalues[i]);
  return result;
}

vector < bool > Dissolve::get_is_center()
{
  massert(m_init, "init must be called");
  vector < bool > result(m_contig_length);
  for (int i=0; i<m_contig_length; ++i)
    result[i]  = m_center_coords.find(i) != m_center_coords.end();
  return result;
}

// void Dissolve::get_segments(vector<DissolveSegment>& segments)
// {
//   vector<DissolveSegment> result;
// }

