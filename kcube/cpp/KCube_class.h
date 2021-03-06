#ifndef KCUBE_H
#define KCUBE_H

#include <vector>
#include <string>
#include <climits>
#include <bitset>
#include <map>
#include <cmath>

#include "util.h"
#include "kmer_utils.h"

using namespace std;

class KCube
{
 private:
  int m_ksize;
  index_t m_kmer_count;
  index_t m_read_count;
  index_t m_read_min_length;
  index_t m_read_max_length;

  count_t* m_data;
  index_t m_data_length;

  void allocate_memory(int ksize);

// access kmer vector
  inline void set_kmer(index_t index) {
    /* if(index < 0 || index > m_data_length) { */
    /*   cout << "index out of range, index=" << index << ", n=" << m_data_length << endl; */
    /*   exit(-1); */
    /* } */
    m_kmer_count++;
    if (m_data[index] < UCHAR_MAX)
      m_data[index]++;
    // cout << "set_kmer: index=" << index << ", value=" << (int)m_data[index] << endl;
  };
  inline int get_kmer(index_t index) {
    if(index > m_data_length) {
      cout << "out of bounds, index: " << index << endl;
      exit(1);
    }
    // cout << "get_kmer: index=" << index << ", value=" << (int)m_data[index] << endl;
    return (m_data[index]);
  };

  void add_read(string seq);
  void process_segment(vector<index_t>& seq_v, int start, int end,
		       int min_segment, int min_count, bool allow_single_sub,
		       int& result_count, double& result_median_xcov);

  // load assembly
  void load_fasta(string fn, map<string,string>& contigs);
  void get_kmers_map(string seq, vector<index_t>& result);

  // binning
  void assembly_bin(map<string,string>& contigs, int binsize, int min_segment, int min_count, bool allow_single_sub, string odir);

  // snp vector
  void add_snp_vector(string seq, int min_segment, int min_count, vector<int>& result);

public:
 KCube() : m_ksize(0), m_kmer_count(0), m_read_count(0), m_read_min_length(0), m_read_max_length(0), m_data(NULL), m_data_length(0) {};
  KCube(int kSize);
  ~KCube();

  // init from reads
  void init_from_fastq(string fn, int max_reads);
  void init_from_fastq_command(string command, int max_reads);

  // project cube onto assembly
  void assembly_complete(string ifn_fasta, string odir);
  void assembly_bins(string ifn_fasta, vector<int>& binsizes,
		     int min_segment, int min_count, bool allow_single_sub, string odir);
  void assembly_summary(string ifn_fasta,
			int min_segment, int min_count, bool allow_single_sub, string ofn);

  // compute snp vector summary over multiple data files
  void snp_summary(string fasta_fn, vector<string>& data_fns, int min_segment, int min_count, string odir);

  // stream object
  void load(string fn, bool quiet=false);
  void save(string fn);

  void dump();
  void stats();
};

#endif
