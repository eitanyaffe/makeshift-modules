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
#include <cstdlib>

#include "util.h"
#include "Params.h"
#include "Coverage.h"

#include "BinMatrix.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// bin functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void read_segments(string fn, vector< BinSegment >& segs)
{
  cout << "reading table: " << fn << endl;
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());
  vector<string> fields;
  char delim = '\t';

  // parse header
  split_line(in, fields, delim);
  int id_ind = get_field_index("segment", fields);
  int contig_ind = get_field_index("contig", fields);
  int start_ind = get_field_index("start", fields);
  int end_ind = get_field_index("end", fields);
  int outlier_ind = get_field_index("is_outlier", fields);

  while(in) {
    split_line(in, fields, delim);
    if(fields.size() == 0)
      break;
    string id = fields[id_ind];
    string contig = fields[contig_ind];
    int start = stoi(fields[start_ind]);
    int end = stoi(fields[end_ind]);
    bool is_center = fields[outlier_ind] == "F";
    BinSegment seg(id, contig, start-1, end, is_center);

    segs.push_back(seg);
  }
}

void init_segments(vector< BinSegment >& segs, vector < Coverage >& covs, double pseudo_count)
{
  int n_libs = covs.size();
  for (unsigned int i=0; i<segs.size(); ++i) {
    BinSegment& seg = segs[i];
    string contig = seg.contig;
    int seg_length = seg.end - seg.start;
    seg.counts.resize(seg_length);

    for (int j=0; j<seg_length; ++j)
      seg.counts[j].resize(n_libs);

    for (unsigned int k=0; k<covs.size(); ++k) {
      map<string, vector<int> >& set_cov = covs[k].get_covs();
      massert(set_cov.find(contig) != set_cov.end(), "contig not found");
      vector<int>& contig_cov = set_cov[contig];

      for (int j=0; j<seg_length; ++j) {
	int coord = j + seg.start;
	seg.counts[j][k] = contig_cov[coord] + pseudo_count;
      }
    }
  }
}

void output_bins(ofstream& out, vector< BinSegment >& segs, vector<int>& ind, vector<int>& bins)
{
  out << "segment\tcontig\tstart\tend\tis_outlier\tbin" << endl;
  massert(ind.size() == bins.size(), "ind and bins vectors must be of same length");
  for (unsigned int i=0; i<ind.size(); ++i) {
    BinSegment& seg = segs[ind[i]];
    out << seg.id << "\t" << seg.contig << "\t" << seg.start << "\t" << seg.end << "\t" << (seg.is_center ? "F" : "T") << "\t" << bins[i] << endl;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// main functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void bin_init_params(const char* name, int argc, char **argv, Parameters& params)
{
  params.add_parser("ifn_libs", new ParserFilename("Table with multiple COV files"), true);
  params.add_parser("ifn_segments", new ParserFilename("input segment file"), true);
  params.add_parser("ofn", new ParserFilename("output binning table"), true);
  params.add_parser("threads", new ParserInteger("Number of threads used", 40), false);
  params.add_parser("p_value", new ParserDouble("Chi-Square P-value clustering threshold", 0.05), false);
  params.add_parser("sample_size", new ParserInteger("Number of sampled pairs for each seg-seg comparison", 100), false);
  params.add_parser("pseudo_count", new ParserDouble("Add pseudo-count", 0.1), false);
  params.add_parser("random_seed", new ParserDouble("Random seed", 1), false);
  params.add_parser("min_segment_length", new ParserDouble("Apply global clustering to segments with length above threshold", 2000), false);
  params.add_parser("only_center", new ParserBoolean("Cluster only center segments", true), false);
  params.add_parser("add_short", new ParserBoolean("Add short segments after initial global clustering", true), false);
  params.add_parser("add_outliers", new ParserBoolean("Add outlier segments after initial global clustering", true), false);
  params.add_parser("max_lib_count", new ParserInteger("Use only n first libs (0 is all)", 0), false);

  params.add_parser("min_covered_samples", new ParserInteger("Bin segments that have a positive median coverage in at least this number of samples", 3), false);

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

int bin_main(const char* name, int argc, char **argv)
{
  Parameters params;
  bin_init_params(name, argc, argv, params);

  string ifn_libs = params.get_string("ifn_libs");
  string ifn_segments = params.get_string("ifn_segments");
  string ofn = params.get_string("ofn");
  int thread_count = params.get_int("threads");
  int sample_size = params.get_int("sample_size");
  double p_threshold = params.get_double("p_value");
  double pseudo_count = params.get_double("pseudo_count");
  double min_length = params.get_double("min_segment_length");
  int max_lib_count = params.get_int("max_lib_count");

  int random_seed = params.get_double("random_seed");

  // flags
  bool only_center = params.get_bool("only_center");
  bool add_outlier = params.get_bool("add_outliers");
  bool add_short = params.get_bool("add_short");

  cout << "setting random seed: " << random_seed << endl;
  srand(random_seed);

  vector< string > ifns;
  read_library_table(ifn_libs, ifns);

  vector< BinSegment > segs;
  read_segments(ifn_segments, segs);

  int nlibs = ifns.size();
  if (max_lib_count > 0 && max_lib_count < nlibs)
    nlibs = max_lib_count;

  cout << "number of libraries: " << nlibs << endl;
  vector < Coverage > covs(nlibs);
  for (int i=0; i<nlibs; ++i) {
    Coverage& cov = covs[i];
    cov.load(ifns[i]);
  }

  // init counts for all segments
  cout << "initializing segments..." << endl;
  init_segments(segs, covs, pseudo_count);
  cout << "total number segments: " << segs.size() << endl;

  // select segments for global clustering
  vector<int> ind;
  for (unsigned int i=0; i<segs.size(); ++i) {
    if ((segs[i].end - segs[i].start) < min_length)
      continue;
    if (only_center && !segs[i].is_center)
      continue;
    ind.push_back(i);
  }
  massert(ind.size() > 0, "no segments match criteria");
  cout << "number of segments in global clustering: " << ind.size() << endl;

  BinMatrix binner(segs, ind, nlibs, sample_size);

  // init matrix
  cout << "initialing matrix" << endl;
  binner.init_matrix(thread_count);

  // cluster segments
  vector<int> bins;
  cout << "binning contigs" << endl;
  int num = binner.cluster_segments(bins, p_threshold);
  cout << "number of bins: " << num << endl;

  // associate non-clustered segments to nearest cluster, if requested
  massert(!add_outlier, "add outlier not implemented");
  massert(!add_short, "add outlier not implemented");

  // output results
  ofstream out(ofn.c_str(), ios::out);
  output_bins(out, segs, ind, bins);
  out.close();

  return 0;
}
