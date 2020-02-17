#include <cstring>
#include "Coverage.h"
using namespace std;

Coverage::Coverage() {}

Coverage::Coverage(const map<string, int>& contig_map)
{
  for (map<string, int>::const_iterator it=contig_map.begin(); it!=contig_map.end(); ++it) {
    string contig = (*it).first;
    int length = (*it).second;

    vector<int>& coverage_contig = m_covs[contig];
    coverage_contig.resize(length);
  }
}

Coverage::Coverage(string fn)
{
  load(fn);
}

map<string, vector<int> >& Coverage::get_covs()
{
  return m_covs;
}

vector<string> Coverage::get_contigs()
{
  vector<string> result;
  for (auto const& element : m_covs)
    result.push_back(element.first);
  return result;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// I/O
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void Coverage::save_cov(ofstream& out)
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

void Coverage::load_cov(ifstream& in)
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

static const char cov_magic[] = {0x01,0x05,0x07,0x04};

// format is compatible to nlv
static const char nlv_magic[] = {0x01,0x03,0x02,0x04};

void Coverage::save(string fn)
{
  cout << "saving COV file: " << fn << endl;
  ofstream out(fn.c_str(), ios::out | ios::binary);
  massert(out.is_open(), "could not open file %s", fn.c_str());

  // save magic number
  out.write(cov_magic, 4);

  save_cov(out);
  out.close();
}

void Coverage::load(string fn)
{
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());

  char magic[4];
  in.read(magic, 4);
  bool cov_magic_found = memcmp(magic, cov_magic, sizeof(magic)) == 0;
  bool nlv_magic_found = memcmp(magic, nlv_magic, sizeof(magic)) == 0;
  massert(cov_magic_found || nlv_magic_found, "magic number not found, check file format", cov_magic_found, nlv_magic_found);
  if (cov_magic_found)
    cout << "reading COV file: " << fn << endl;
  else if (nlv_magic_found)
    cout << "reading NLV file: " << fn << endl;

  load_cov(in);

  in.close();
}
