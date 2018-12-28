#include <cmath>
#include <cstdio>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <string>
#include <array>
#include <algorithm>

#include <stdio.h>
#include <string.h>

#include <sys/wait.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "KCube_class.h"
#include "util.h"
#include "kmer_utils.h"

using namespace std;

void KCube::allocate_memory(int ksize)
{
  massert(ksize < 18, "limited to k<18");
  if (m_data && ksize != m_ksize) {
    free(m_data);
    m_data = NULL;
  }
  m_ksize = ksize;
  m_data_length = pow(4, m_ksize);

  if (!m_data) {
    cout << "calling calloc for " << m_data_length << " bytes (" << m_data_length/(1024*1024) << " Mb)" << endl;
    m_data = (count_t*)calloc(m_data_length, sizeof(count_t));
    massert(m_data != NULL, "error allocating memory");
  }
}

KCube::KCube(int kSize)
  : m_ksize(kSize), m_kmer_count(0), m_read_count(0), m_read_min_length(0), m_read_max_length(0), m_data(NULL)
{
  allocate_memory(kSize);
}

KCube::~KCube()
{
  if (m_data) {
    free(m_data);
    m_data = 0;
    m_data_length = 0;
  }
}

void KCube::add_read(string seq)
{
  int read_length = seq.length();

  // keep read length
  if (m_read_min_length == 0 || m_read_min_length > read_length)
    m_read_min_length = read_length;
  if (m_read_max_length < read_length)
    m_read_max_length = read_length;

  massert(read_length > m_ksize,"read too short: read_length=%d, ksize=%d", read_length, m_ksize);

  index_t index = 0;
  index_t last_nt_mask = ~(3 << (m_ksize-1)*2);
  // cout << "last_nt_mask=" << ~last_nt_mask << endl;
  int invalid_until = 0;
  for (int i=0; i<read_length; ++i) {
    index_t nt_index = char2base(seq[i]);
    index = (index & last_nt_mask) << 2;
    if (nt_index != -1)
      index |= nt_index;
    else
      invalid_until = i+m_ksize;
    // cout << "i=" << i << ", next_index=" << invalid_until<< ", base=" << seq[i] << ", nt_index=" << nt_index << ", index=" << index << endl;
    if (i>=(m_ksize-1) && (i>=invalid_until))
      set_kmer(index);
  }
}

void KCube::get_kmers_map(string seq, vector<index_t>& result)
{
  massert(m_data, "KCube not initialized");
  result.resize(seq.size());

  int seq_length = seq.length();
  massert(seq_length > m_ksize,"contig too short: contig_length=%d, ksize=%d", seq_length, m_ksize);

  index_t index = 0;
  index_t last_nt_mask = ~(3 << (m_ksize-1)*2);
  int invalid_until = 0;
  for (int i=0; i<seq_length; ++i) {
    index_t nt_index = char2base(seq[i]);
    index = (index & last_nt_mask) << 2;
    if (nt_index != -1)
      index |= nt_index;
    else
      invalid_until = i+m_ksize;
    // cout << "i=" << i << ", next_index=" << invalid_until<< ", base=" << seq[i] << ", nt_index=" << nt_index << ", index=" << index << endl;
    if (i>=(m_ksize-1) && (i>=invalid_until))
      result[i-m_ksize+1] = index;
  }
}

void KCube::init_from_fastq(string fn, int max_reads)
{
  cout << "traversing read file (fastq): " << fn << endl;
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());

  index_t counter = 0;
  while(1) {
    int index = counter++ % 4;
    string line;
    getline(in, line);
    if (line[line.length()-1] == '\n')
      line = line.substr(0,line.length()-1);
    bool eof = in.eof();
    if (eof)
      break;
    if (!eof && !in.good()) {
      cerr << "Error reading line: " << counter << ", rdstate=" << in.rdstate() << endl;
      exit(-1);
    }

    massert(index != 0 || (line.size() > 0 && line[0] == '@'), "command should output reads in fastq format, found: %s", line.c_str());
    if (index == 1 && counter) {
      m_read_count++;
      add_read(line);
      add_read(reverse_complement(line));
    }
    if (counter % 40000000 == 0)
      cout << "read: " << counter/4 << endl;

    if (max_reads && max_reads <= m_read_count)
      break;
  }
  in.close();
}

void KCube::init_from_fastq_command(string command, int max_reads)
{
  cout << "running command: " << command << endl;
  string result;
  FILE* pipe = popen(command.c_str(), "r");
  massert(pipe != NULL, "popen() failed");

  index_t counter = 0;
  char *line_p = NULL;
  size_t len = 0;
  ssize_t read;
  while ((read = getline(&line_p, &len, pipe)) != -1) {
    string line(line_p);
    if (line[line.length()-1] == '\n')
      line = line.substr(0,line.length()-1);
    int index = counter++ % 4;
    massert(index != 0 || (line.size() > 0 && line[0] == '@'), "command should output reads in fastq format, found: %s", line.c_str());
    if (index == 1 && counter) {
      m_read_count++;
      add_read(line);
      add_read(reverse_complement(line));
    }

    if (counter % 40000000 == 0)
      cout << "read: " << counter/4 << endl;

    if (max_reads && max_reads <= m_read_count)
      break;
  }
  int rc = pclose(pipe);
  massert(WEXITSTATUS(rc) == 0, "command failed, return code: %d", WEXITSTATUS(rc));
}

void KCube::save(string fn)
{
  massert(fn != "", "data file (-data) not defined");
  cout << "saving file: " << fn << endl;

  ofstream out(fn.c_str(), ios::out|ios::binary);
  massert(out.is_open(), "could not open file %s", fn.c_str());

  out.write((char*)&m_ksize, sizeof(int)/sizeof(char));
  out.write((char*)&m_kmer_count, sizeof(index_t)/sizeof(char));
  out.write((char*)&m_read_count, sizeof(index_t)/sizeof(char));
  out.write((char*)&m_read_min_length, sizeof(index_t)/sizeof(char));
  out.write((char*)&m_read_max_length, sizeof(index_t)/sizeof(char));

  out.write((char*)m_data, (m_data_length*sizeof(count_t))/sizeof(char));

  out.close();
}

void KCube::load(string fn, bool quiet)
{
  if (!quiet) cout << "loading cube file: " << fn << endl;
  ifstream in(fn.c_str(), ios::in|ios::binary);
  massert(in.is_open(), "could not open file %s", fn.c_str());

  int ksize;
  in.read((char*)&ksize, sizeof(int));
  allocate_memory(ksize);

  in.read((char*)&m_kmer_count, sizeof(index_t));
  in.read((char*)&m_read_count, sizeof(index_t));
  in.read((char*)&m_read_min_length, sizeof(index_t));
  in.read((char*)&m_read_max_length, sizeof(index_t));

  if (!quiet) cout << "reading vector into memory" << endl;
  in.read((char*)m_data, m_data_length*sizeof(count_t));

  in.close();
}

void KCube::dump()
{
  cout << "dumping cube:" << endl;
  cout << "k=" << m_ksize << ", nk=" << m_data_length << endl;

  for (index_t index=0; index<m_data_length; ++index) {
    int count = get_kmer(index);
    if (count > 0) {
      string kmer = index2kmer(index, m_ksize);
      cout << kmer << " : " << count << endl;
    }
  }
}

void KCube::stats()
{
  cout << "===============================================" << endl;
  cout << "ksize: " << m_ksize << endl;
  cout << "kmer count: " << m_kmer_count << endl;
  cout << "read count: " << m_read_count << endl;
  if (m_read_min_length == m_read_max_length)
    cout << "read length: " << m_read_max_length << endl;
  else
    cout << "read length range: " << m_read_min_length << " - " << m_read_max_length << endl;

  int count = 0;
  for (index_t index=0; index<m_data_length; ++index) {
    count += (get_kmer(index)>0) ? 1 : 0;
  }
  cout << "present kmer count: " << count << endl;
  cout << "present kmer percentage: " << 100 * ((double)count/m_data_length) << endl;
  cout << "===============================================" << endl;
}

void KCube::load_fasta(string fn, map<string,string>& contigs)
{
  massert(fn != "", "assembly file not defined");
  cout << "loading assembly file (fasta): " << fn << endl;
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());

  string contig = "";
  string seq = "";
  while(1) {
    string line;
    getline(in, line);
    bool eof = in.eof();
    if (eof)
      break;
    if (!eof && !in.good()) {
      cerr << "Error reading line, rdstate=" << in.rdstate() << endl;
      exit(-1);
    }
    massert(line.length() > 0, "empty line in fasta file");
    if (line[0] == '>') {
      if (contig != "")
	contigs[contig] = seq;
      contig = line.substr(1);
      if (contig.find(' ') != string::npos)
	contig = contig.substr(0, contig.find(' '));
      seq = "";
    } else {
      seq += line;
    }
  }
  if (contig != "")
    contigs[contig] = seq;
  in.close();
}

void KCube::assembly_complete(string ifn_fasta, string odir)
{
  map<string,string> contigs;
  load_fasta(ifn_fasta, contigs);

  cout << "number of contigs: " << contigs.size() << endl;

  for (map<string,string>::iterator it = contigs.begin(); it != contigs.end(); ++it) {
    string contig = (*it).first;
    string seq = (*it).second;
    vector<index_t> seq_v;
    get_kmers_map(seq, seq_v);

    string ofn = odir + "/" + contig;
    ofstream out(ofn.c_str());
    massert(out.is_open(), "could not open file %s", ofn.c_str());
    for (unsigned int i=0; i<seq.length(); ++i)
      out << get_kmer(seq_v[i]) << endl;
    out.close();
  }
}

double get_median(vector<int>& values)
{
  size_t size = values.size();

  if (size == 0) {
    return 0;
  } else if (size == 1) {
    return values[0];
  } else {
    sort(values.begin(), values.end());
    if (size % 2 == 0)
      return (values[size / 2 - 1] + values[size / 2]) / 2;
    else
      return values[size / 2];
  }
}

void KCube::process_segment(vector<index_t>& seq_v, int start, int end,
			    int min_segment, int min_count, bool allow_single_sub,
			    int& result_count, double& result_median_xcov)
{
  result_count = 0;
  int segment_length = 0;
  vector<int> tmp_counts;
  vector<int> counts;

  vector<index_t> neighbor_bits;
  index_t one = 1;
  for (int i=0; i<2*m_ksize; i++) {
    index_t value = one << i;
    massert(value >= 0 && value < m_data_length, "index out of range");
    neighbor_bits.push_back(value);
  }

  int length = end-start;
  vector<bool> found_vec(length);
  for (int i=0; i<length; ++i)
    found_vec[i] = false;

  for (int coord=start; coord<end-m_ksize+1; ++coord) {
    index_t index = seq_v[coord];
    int count = get_kmer(index);
    if (allow_single_sub) {
      for (int i=0; i<2*m_ksize; i++)
    	count+= get_kmer(index ^ neighbor_bits[i]);
    }
    bool present = count >= min_count;
    if (present) {
      segment_length++;
      tmp_counts.push_back(count);
    } else {
      if (segment_length >= min_segment) {
	// result_count += segment_length + m_ksize - 1;
	for (int scoord=(coord-segment_length); scoord<(coord+m_ksize-1); ++scoord) {
	  // massert(scoord-start >= 0 && scoord-start < length, "out of range: scoord=%d, segment_length=%d", scoord, start);
	  found_vec[scoord-start] = true;
	}

	counts.insert(counts.end(), tmp_counts.begin(), tmp_counts.end());
      }
      segment_length = 0;
      tmp_counts.resize(0);
    }
  }
  if (segment_length >= min_segment) {
    for (int scoord=(end-m_ksize-segment_length+1); scoord<end; ++scoord) {
      // massert(scoord-start >= 0 && scoord-start < length, "out of range: %d", scoord);
      found_vec[scoord-start] = true;
    }
    counts.insert(counts.end(), tmp_counts.begin(), tmp_counts.end());
    // result_count += segment_length + m_ksize - 1;
  }

  for (int i=0; i<length; ++i)
    result_count += (int)found_vec[i];

  result_median_xcov = get_median(counts);
}

void KCube::assembly_summary(string ifn_fasta,
			     int min_segment, int min_count, bool allow_single_sub,
			     string ofn)
{
  massert(ofn != "", "binning output file (ofn) file not defined");

  map<string,string> contigs;
  load_fasta(ifn_fasta, contigs);

  cout << "number of contigs: " << contigs.size() << endl;
  cout << "min segment length: " << min_segment << endl;
  cout << "min count: " << min_count << endl;

  cout << "writing summary table: " << ofn << endl;
  ofstream out(ofn.c_str());
  massert(out.is_open(), "could not open file %s", ofn.c_str());
  out << "contig\tlength\tcovered_nt\tcovered_portion\tmedian_xcoverage" << endl;
  for (map<string,string>::iterator it = contigs.begin(); it != contigs.end(); ++it) {
    string contig = (*it).first;
    string seq = (*it).second;
    vector<index_t> seq_v;
    get_kmers_map(seq, seq_v);
    int start = 0;
    int end = (int)seq.size();

    int count;
    double median_xcov;
    process_segment(seq_v, start, end, min_segment, min_count, allow_single_sub, count, median_xcov);
    double coverage = (double)count / (end-start);
    out << contig << "\t" << seq.size() << "\t" << count << "\t" << coverage << "\t" << median_xcov << endl;
  }

  out.close();
}

void KCube::assembly_bin(map<string,string>& contigs, int binsize,
			 int min_segment, int min_count, bool allow_single_sub, string odir)
{
  int status = mkdir(odir.c_str(), S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
  massert(status == 0 || status == EEXIST || status == -1, "mkdir failed with code %d for directory: %s", status, odir.c_str());

  for (map<string,string>::iterator it = contigs.begin(); it != contigs.end(); ++it) {
    string contig = (*it).first;
    string seq = (*it).second;
    vector<index_t> seq_v;
    get_kmers_map(seq, seq_v);

    string ofn = odir + '/' + contig;
    // cout << "writing bin table: " << ofn << endl;
    ofstream out(ofn.c_str());
    massert(out.is_open(), "could not open file %s", ofn.c_str());
    out << "start\tend\tcovered_nt\tcovered_portion\tmedian_xcoverage" << endl;

    unsigned int n_bins = ceil((double)seq.length() / binsize);
    for (unsigned int i=0; i<n_bins; ++i) {
      unsigned int start = i * binsize;
      unsigned int end = (i+1) * binsize;
      if (end > (seq.length()))
	end = seq.length();
      if (end <= start)
	continue;
      int count;
      double median_xcov;
      process_segment(seq_v, start, end, min_segment, min_count, allow_single_sub, count, median_xcov);
      double coverage = (double)count / (end-start);
      out << start+1 << "\t" << end << "\t" << count << "\t" << coverage << "\t" << median_xcov << endl;
    }

    out.close();
  }

}

void KCube::assembly_bins(string ifn_fasta, vector<int>& binsizes,
			  int min_segment, int min_count, bool allow_single_sub, string odir)
{
  massert(binsizes.size() > 0, "binsize parameter not defined");
  massert(odir != "", "output directory (odir) not defined");

  cout << "binsizes: ";
  for (unsigned int i=0; i<binsizes.size(); ++i)
    cout << binsizes[i] << " ";
  cout << endl;

  map<string,string> contigs;
  load_fasta(ifn_fasta, contigs);
  cout << "number of contigs: " << contigs.size() << endl;
  cout << "min segment length: " << min_segment << endl;
  cout << "min count: " << min_count << endl;

  cout << "binning into directory: " << odir << endl;
  for (unsigned int i=0; i<binsizes.size(); ++i) {
    string odir_binsize = odir + "/bin_" + to_string((long long int)binsizes[i]);
    assembly_bin(contigs, binsizes[i], min_segment, min_count, allow_single_sub, odir_binsize);
  }
}

void KCube::add_snp_vector(string seq, int min_segment, int min_count, vector<int>& result)
{
  int length = seq.size();
  vector<index_t> seq_v;
  get_kmers_map(seq, seq_v);

  vector<bool> flags(length);
  for (int coord=0; coord<length; ++coord)
    flags[coord] = false;

  vector<index_t> neighbor_bits;
  index_t one = 1;
  index_t one = 1;
  index_t three = 3;
  for (int i=0; i<2*m_ksize; i++) {
    index_t value = one << i;
    massert(value >= 0 && value < m_data_length, "index out of range");
    neighbor_bits.push_back(value);
  }
  for (int i=0; i<m_ksize; i++) {
    index_t value = three << i;
    massert(value >= 0 && value < m_data_length, "index out of range");
    neighbor_bits.push_back(value);
  }

  int segment_length = 0;
  for (int coord=0; coord<length-m_ksize+1; ++coord) {
    index_t index = seq_v[coord];
    int count = get_kmer(index);
    int max_neighbour = 0;
    for (int i=0; i<2*m_ksize; i++) {
      int n_count = get_kmer(index ^ neighbor_bits[i]);
      if (max_neighbour < n_count)
	max_neighbour = n_count;
      if (coord == 428)
	cout << "n_i: " << n_count << endl;
    }
    bool present = count >= min_count && count >= max_neighbour;
    if (coord == 428) {
      cout << "main: " << count << endl;
      cout << "max_n: " << max_neighbour << endl;
      cout << "present: " << present << endl;
    }
    if (present) {
      segment_length++;
    } else {
      if (segment_length >= min_segment)
	for (int scoord=(coord-segment_length); scoord<(coord+m_ksize-1); ++scoord)
	  flags[scoord] = true;
      segment_length = 0;
    }
  }
  if (segment_length >= min_segment)
    for (int scoord=(length-m_ksize-segment_length+1); scoord<length; ++scoord)
      flags[scoord] = true;

  for (int coord=0; coord<length; ++coord)
    result[coord] += flags[coord] ? 1 : 0;
}

void KCube::snp_summary(string fasta_fn, vector<string>& data_fns, int min_segment, int min_count, string odir)
{
  map<string, string> contigs;
  load_fasta(fasta_fn, contigs);

  cout << "number of contigs: " << contigs.size() << endl;
  map<string, vector<int>> result;

  // initialize result
  for (map<string,string>::iterator it = contigs.begin(); it != contigs.end(); ++it) {
    string contig = (*it).first;
    string seq = (*it).second;
    int length = seq.length();
    result[contig].resize(length);
  }

  // collect counts over all files
  cout << "number of libraries: " << data_fns.size() << endl;
  for (unsigned int i=0; i<data_fns.size(); ++i) {
    load(data_fns[i], true);
    for (map<string,string>::iterator it = contigs.begin(); it != contigs.end(); ++it) {
      string contig = (*it).first;
      string seq = (*it).second;
      cout << "contig: " << contig << endl;
      add_snp_vector(seq, min_segment, min_count, result[contig]);
    }
    if (i % 20 == 0)
      cout << "progress: " << (i+1) << endl;
  }
  cout << endl;

  // dump result per contig
  cout << "saving results to directory: " << odir << endl;
  for (map<string,string>::iterator it = contigs.begin(); it != contigs.end(); ++it) {
    string contig = (*it).first;
    string seq = (*it).second;
    vector<int>& contig_counts = result[contig];

    string ofn = odir + "/" + contig;
    ofstream out(ofn.c_str());
    massert(out.is_open(), "could not open file %s", ofn.c_str());
    for (unsigned int i=0; i<seq.length(); ++i)
      out << contig_counts[i] << endl;
    out.close();
  }
}
