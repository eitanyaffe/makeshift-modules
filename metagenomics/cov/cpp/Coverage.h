#ifndef COVERAGE_H
#define COVERAGE_H

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
// Coverage
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class Coverage {
 private:
  // contig -> coordinate -> count
  map<string, vector<int> > m_covs;

  void load_cov(ifstream& in);
  void save_cov(ofstream& out);

 public:
  Coverage();
  Coverage(const map<string, int>& contig_map);
  Coverage(string fn);

  // direct functions for efficiency
  map<string, vector<int> >& get_covs();

  // get all contigs
  vector<string> get_contigs();

  // I/O
  void save(string fn);
  void load(string fn);
};

#endif
