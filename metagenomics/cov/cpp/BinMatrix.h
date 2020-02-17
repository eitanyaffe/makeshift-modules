#ifndef BINMATRIX_H
#define BINMATRIX_H

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

#include <algorithm>
#include <stdio.h>
#include <stdlib.h>

#include <dirent.h>

#include <thread>

#include <boost/math/distributions/chi_squared.hpp>
#include <boost/graph/adjacency_list.hpp>
#include <boost/graph/connected_components.hpp>

#include "util.h"
#include "Coverage.h"

using namespace std;
using namespace boost::math;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// BinSegment
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

struct BinSegment {
  string id, contig;
  int start, end;
  bool is_center;
  int bin;

  // coord -> library -> count
  vector < vector < double > > counts;
  //  vector < vector < double > > freqs;

  BinSegment(string _id, string _contig, int _start, int _end, bool _is_center) : id(_id), contig(_contig), start(_start), end(_end), is_center(_is_center), bin(0) {};
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// BinMatrix
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

struct BinMatrix {
private:
  vector< BinSegment >& m_segs;
  vector<int>& m_ind;
  int m_nlibs;
  int m_nsegs;
  int m_sample_size;

  chi_squared m_chi_squared;

  // distance matrix between all pairs of segments (p-values)
  vector < vector < double > > m_dist;

  double get_chi_value(vector < double >& c1, vector < double >& c2);
  double get_p_value(vector < double >& c1, vector < double >& c2);
  double compute_seg_chi_distance(BinSegment& seg1, BinSegment& seg2);

  int get_random_coord(BinSegment& seg);

public:
  BinMatrix(vector< BinSegment >& segs, vector<int>& ind, int nlibs, int sample_size);

  // init for specific range
  void init_matrix(int index, int from_ind, int to_ind);

  // init all matrix
  void init_matrix(int thread_count);

  // cluster matrix
  int cluster_segments(vector<int>& bins, double p_threshold);
};

#endif
