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

#include "util.h"
#include "VariationSet.h"
#include "Params.h"

struct Segment {
  string contig;
  int start, end;
  Segment(string _contig, int _start, int _end) : contig(_contig), start(_start), end(_end) {};
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// main functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void coverage_init_params(const char* name, int argc, char **argv, Parameters& params)
{
  params.add_parser("ifn_nlv", new ParserFilename("NLV filename"), true);
  params.add_parser("ifn_segments", new ParserFilename("Segment table (contig/start/end) and an optional extra summary field"), true);
  params.add_parser("summary_field", new ParserString("Output median coverage per element according to this field", "contig"), false);
  params.add_parser("ofn", new ParserFilename("Output file"), true);

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

void read_segment_table(string fn, string summary_field, map<string, vector< Segment > >& result)
{
  cout << "reading table: " << fn << endl;
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());
  vector<string> fields;
  char delim = '\t';

  // parse header
  split_line(in, fields, delim);
  int contig_ind = get_field_index("contig", fields);
  int start_ind = get_field_index("start", fields);
  int end_ind = get_field_index("end", fields);
  int summary_ind = get_field_index(summary_field, fields);

  while(in) {
    split_line(in, fields, delim);
    if(fields.size() == 0)
      break;

    string contig = fields[contig_ind];
    int start = safe_string_to_int(fields[start_ind], "start_coordinate")-1;
    int end = safe_string_to_int(fields[end_ind], "end_coordinate")-1;
    string item = fields[summary_ind];

    Segment segment(contig, start, end);
    result[item].push_back(segment);
  }
}

int percentile(vector<int> &v, int percentile)
{
  size_t n = (v.size() * percentile) / 100;
  if (n < 0) n = 0;
  if (n >= v.size()) n = v.size()-1;
  nth_element(v.begin(), v.begin()+n, v.end());
  return v[n];
}

int sorted_percentile(vector<int> &v, int percentile)
{
  size_t n = (v.size() * percentile) / 100;
  if (n < 0) n = 0;
  if (n >= v.size()) n = v.size()-1;
  return v[n];
}

void coverage_output(VariationSet& varset,
		     map<string, vector< Segment > >& segment_map,
		     string summary_field,
		     ofstream& out)
{
  int percentiles[7] = {0,5,25,50,75,95,100};
  out << summary_field;
  for (unsigned int i=0; i<7; ++i)
    out << "\tp" << percentiles[i];
  out << endl;

  for (map<string, vector< Segment > >::iterator it=segment_map.begin(); it != segment_map.end(); ++it) {
    string key = (*it).first;
    vector< Segment >& segments = (*it).second;

    // keep all values per key
    vector<int> covs;
    for (vector< Segment >::iterator jt=segments.begin(); jt != segments.end(); ++jt) {
      Segment& segment = *jt;
      for (int coord=segment.start; coord < segment.end; ++coord) {
	covs.push_back(varset.get_coverage(segment.contig, coord));
      }
    }
    out << key;
    sort (covs.begin(), covs.end()); 
    for (unsigned int i=0; i<7; ++i) {
      int percentile_cov = sorted_percentile(covs, percentiles[i]);
      out << "\t" << percentile_cov;
    }
    out << endl;
  }
}

int coverage_main(const char* name, int argc, char **argv)
{
  Parameters params;
  coverage_init_params(name, argc, argv, params);

  string ifn_nlv = params.get_string("ifn_nlv");
  string ifn_segments = params.get_string("ifn_segments");
  string summary_field = params.get_string("summary_field");
  string ofn = params.get_string("ofn");

  map<string, vector< Segment > > segment_map;
  read_segment_table(ifn_segments, summary_field, segment_map);
  cout << "number of output items: " << segment_map.size() << endl;

  VariationSet varset(ifn_nlv);

  cout << "saving result to table: " << ofn << endl;
  ofstream out(ofn.c_str(), ios::out | ios::binary);
  massert(out.is_open(), "could not open file %s", ofn.c_str());
  coverage_output(varset, segment_map, summary_field, out);
  out.close();

  return 0;
}
