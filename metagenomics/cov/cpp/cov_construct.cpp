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
#include "Params.h"
#include "Coverage.h"

#define massert_range(v, coord, id) massert(coord >= 0 && coord < (int)v.size(), "coord %d outside vector of length %d, id: %s", coord, (int)v.size(), id.c_str());
#define INCREMENT(v, coord, var, length) \
massert(coord >=0 && coord < length, "coord out of range, coord=%d, contig_size=%d", coord, length); \
v[coord][var]++;

using namespace std;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// I/O
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void parse_cigar(string in, vector<pair < char, int> > & result)
{
  result.resize(0);
  string field;
  for (unsigned int i=0; i<in.size(); ++i) {
    char c = in[i];
    int length = 0;
    if (isdigit(c))
      length = length*10 + (c - '0');
    else
      result.push_back(make_pair(c, length));
  }
}

void process_mapping_file(string fn,
			  map<string, int>& contig_map,
			  bool discard_clipped, int min_score, int min_length, int max_edit,
			  Coverage& cov)
{
  map<string, vector<int> >& covs = cov.get_covs();
  
  cout << "reading table: " << fn << endl;
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());
  vector<string> fields;
  char delim = '\t';

  // parse header
  split_line(in, fields, delim);
  int id_ind = get_field_index("id", fields);
  int score_ind = get_field_index("score", fields);
  int contig_ind = get_field_index("contig", fields);
  int coord_ind = get_field_index("coord", fields);
  int back_coord_ind = get_field_index("back_coord", fields);
  int strand_ind = get_field_index("strand", fields);
  int edit_ind = get_field_index("edit_dist", fields);
  int cigar_ind = get_field_index("cigar", fields);
  int match_ind = get_field_index("match_length", fields);

  map<string, int> id_score;

  int read_count = 1;
  while(in) {
    split_line(in, fields, delim);
    if(fields.size() == 0)
      break;

    if (read_count++ % 1000000 == 0) {
      cout << "read: " << read_count-1 << " ..." << endl;
    }

    // use only longest match for each read
    string id = fields[id_ind];
    string contig = fields[contig_ind];
    int front_coord = atoi(fields[coord_ind].c_str()) - 1;
    int back_coord = atoi(fields[back_coord_ind].c_str()) - 1;
    bool strand = fields[strand_ind] == "1";
    int edit_dist = atoi(fields[edit_ind].c_str());
    int left_coord = strand ? back_coord : front_coord;
    int right_coord = !strand ? back_coord : front_coord;
    int read_length = right_coord - left_coord + 1;
    int match_length = atoi(fields[match_ind].c_str());
    int score = atoi(fields[score_ind].c_str());
    string cigar_str = fields[cigar_ind];

    // skip if quality or match length fall under thresholds
    if (match_length < min_length || score < min_score || edit_dist > max_edit)
      continue;

    // skip if this is a secondary match with a lower score
    if (id_score.find(id) != id_score.end()) {
      if (score <= id_score[id])
	continue;
      else
	id_score[id] = score;
    } else {
      id_score[id] = score;
    }

    // skip contigs which are not in contig table
    if(contig_map.find(contig) == contig_map.end())
      continue;

    // parse cigar format to identify dangles
    vector<pair < char, int> > cigar;
    parse_cigar(cigar_str, cigar);
    bool clip_start = (cigar.front().first == 'S' || cigar.front().first == 'H');
    bool clip_end = (cigar.back().first == 'S' || cigar.back().first == 'H');
    bool clipped = clip_start || clip_end;

    if (clipped && discard_clipped)
      continue;
    
    // coverage
    vector<int>& coverage_contig = covs[contig];
    for (int i=0; i<read_length; ++i) {
      int coord = left_coord + i;
      massert_range(coverage_contig, coord, id);
      coverage_contig[coord]++;
    }
  }
}

void read_contig_table(string fn, map<string, int>& contig_map)
{
  cout << "reading table: " << fn << endl;
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());
  vector<string> fields;
  char delim = '\t';

  // parse header
  split_line(in, fields, delim);
  int contig_ind = get_field_index("contig", fields);
  int length_ind = get_field_index("length", fields);

  while(in) {
    split_line(in, fields, delim);
    if(fields.size() == 0)
      break;

    string contig = fields[contig_ind];
    int length = (int)atof(fields[length_ind].c_str());
    contig_map[contig] = length;
  }
}

inline double mround(double v, int digits) {
  double f = pow(10,digits);
  return (round(v * f) / f);
}

int get_of_files(string idir)
{
  DIR *dir;
  struct dirent *ent;
  massert((dir = opendir (idir.c_str())) != NULL, "could not open input directory");
  int file_count = 0;
  while ((ent = readdir (dir)) != NULL) {
    string ifn = ent->d_name;
    if (ifn.find("fastq") == string::npos || ifn.find("~") != string::npos)
      continue;
    file_count++;
  }
  closedir (dir);
  return file_count;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// main functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void construct_init_params(const char* name, int argc, char **argv, Parameters& params)
{
  params.add_parser("contig_table", new ParserFilename("contig table"), true);
  params.add_parser("idir", new ParserFilename("input directory with parsed mapped reads"), true);
  params.add_parser("discard_clipped", new ParserBoolean("discard clipped reads", true), false);
  params.add_parser("min_length", new ParserInteger("minimal match length (nts)", 50), false);
  params.add_parser("min_score", new ParserInteger("minimal score", 30), false);
  params.add_parser("max_edit", new ParserInteger("maximal edit distance", 2), false);
  params.add_parser("ofn", new ParserFilename("output variation table"), true);

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

int construct_main(const char* name, int argc, char **argv)
{
  Parameters params;
  construct_init_params(name, argc, argv, params);

  string idir = params.get_string("idir");
  string contig_table_ifn = params.get_string("contig_table");
  int discard_clipped = params.get_bool("discard_clipped");
  int min_score = params.get_int("min_score");
  int min_length = params.get_int("min_length");
  int max_edit = params.get_int("max_edit");
  string ofn = params.get_string("ofn");

  // contig lengths
  map<string, int> contig_map;
  read_contig_table(contig_table_ifn, contig_map);
  cout << "number of contigs: " << contig_map.size() << endl;

  Coverage cov(contig_map);

  cout << "number of fastq files found: " << get_of_files(idir) << endl;
  DIR *dir;
  struct dirent *ent;
  massert((dir = opendir (idir.c_str())) != NULL, "could not open input directory");
  // int file_count = 0;
  while ((ent = readdir (dir)) != NULL) {
    string ifn = ent->d_name;
    if (ifn.find("fastq") == string::npos || ifn.find("~") != string::npos)
      continue;
    process_mapping_file(idir + "/" + ifn, contig_map,
			 discard_clipped, min_score, min_length, max_edit, cov);
  }
  closedir (dir);

  cov.save(ofn);

  return 0;
}
