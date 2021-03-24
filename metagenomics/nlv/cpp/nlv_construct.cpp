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
#include "VariationSet.h"

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
			  VariationSet& varset)
{
  map< string, map< int, map <Variation, int> > >& vars = varset.get_vars();
  map<string, vector<int> >& covs = varset.get_covs();

  cout << "reading table: " << fn << endl;
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());
  vector<string> fields;
  char delim = '\t';

  vector<string> sub_fields;
  char sub_delim = ';';

  vector<string> ssub_fields;
  char ssub_delim = ',';

  // parse header
  split_line(in, fields, delim);
  int id_ind = get_field_index("id", fields);
  int score_ind = get_field_index("score", fields);
  int contig_ind = get_field_index("contig", fields);
  int coord_ind = get_field_index("coord", fields);
  int back_coord_ind = get_field_index("back_coord", fields);
  int strand_ind = get_field_index("strand", fields);
  int edit_ind = get_field_index("edit_dist", fields);
  int sub_ind = get_field_index("substitute", fields);
  int insert_ind = get_field_index("insert", fields);
  int delete_ind = get_field_index("delete", fields);
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
    string sub = fields[sub_ind];
    string insert = fields[insert_ind];
    string del = fields[delete_ind];
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
    int contig_length = contig_map[contig];

    // parse cigar format to identify dangles
    vector<pair < char, int> > cigar;
    parse_cigar(cigar_str, cigar);
    bool clip_start = (cigar.front().first == 'S' || cigar.front().first == 'H');
    bool clip_end = (cigar.back().first == 'S' || cigar.back().first == 'H');
    bool clipped = clip_start || clip_end;

    if (clipped && discard_clipped)
      continue;

    // coord->variation
    // establish what are all the variations the read contains
    map< int, Variation> read_vars;

    // dangle left
    if (strand ? clip_start : clip_end) {
      int coord = strand ? left_coord : right_coord;
      if (strand)
	read_vars[coord].add_dangle_left();
      else
	read_vars[coord].add_dangle_right();
      // Variation var(strand ? vtDangleLeft : vtDangleRight);
      // INCREMENT(contig_map, coord, var, contig_length);
    }

    // dangle right
    if (!strand ? clip_start : clip_end) {
      int coord = strand ? right_coord : left_coord;
      if (strand)
	read_vars[coord].add_dangle_right();
      else
	read_vars[coord].add_dangle_left();
      // Variation var(strand ? vtDangleRight : vtDangleLeft);
      // INCREMENT(contig_map, coord, var, contig_length);
    }

    // substitutes
    split_string(sub, sub_fields, sub_delim);
    for (unsigned int i=0; i<sub_fields.size(); ++i) {
      split_string(sub_fields[i], ssub_fields, ssub_delim);
      if (ssub_fields.size() < 4)
	continue;
      int coord = atoi(ssub_fields[0].c_str()) - 1;
      if (coord == -1) {
	cout << "id=" << id << ", contig=" << contig << ", left_coord=" << left_coord << ", right_coord=" << right_coord
	     << ", strand=" << (strand ? "+" : "-")
	     << ", cigar=" << cigar_str << ", sub=" << sub << ", insert=" << insert << ", delete=" << del
	     << ", clipped=" << clipped << ", read_length=" << read_length << ", match_length=" << match_length << endl;
      }

      massert(coord >= left_coord && coord <= right_coord, "coord %d out of range, left=%d, right=%d\n", coord, left_coord, right_coord);
      // string nt = (strand ? ssub_fields[3] : reverse_complement(ssub_fields[3]));
      string nt = ssub_fields[3];
      if (nt == "N")
	continue;
      read_vars[coord].add_sub(nt);
      // Variation var(vtSubstitute, nt);
      // INCREMENT(contig_map, coord, var, contig_length);
    }

    // deletions
    split_string(del, sub_fields, sub_delim);
    for (unsigned int i=0; i<sub_fields.size(); ++i) {
      split_string(sub_fields[i], ssub_fields, ssub_delim);
      if (ssub_fields.size() < 2)
	continue;
      int start_coord = atoi(ssub_fields[0].c_str()) - 1;
      if (start_coord == -1) {
	cout << "id=" << id << ", contig=" << contig << ", left_coord=" << left_coord << ", right_coord=" << right_coord
	     << ", strand=" << (strand ? "+" : "-")
	     << ", cigar=" << cigar_str << ", sub=" << sub << ", insert=" << insert << ", delete=" << del
	     << ", clipped=" << clipped << ", read_length=" << read_length << ", match_length=" << match_length << endl;
      }
      massert(start_coord >= left_coord && start_coord <= right_coord, "coord %d out of range, left=%d, right=%d\n", start_coord, left_coord, right_coord);
      int del_length = atoi(ssub_fields[1].c_str());
      read_vars[start_coord].add_delete(del_length);
      // Variation var(vtDelete, "NA", del_length);
      // INCREMENT(contig_map, start_coord, var, contig_length);
    }

    // insertions
    split_string(insert, sub_fields, sub_delim);
    for (unsigned int i=0; i<sub_fields.size(); ++i) {
      split_string(sub_fields[i], ssub_fields, ssub_delim);
      if (ssub_fields.size() < 3)
	continue;
      int coord = atoi(ssub_fields[0].c_str()) - 1;
      if (coord == -1) {
	cout << "id=" << id << ", contig=" << contig << ", left_coord=" << left_coord << ", right_coord=" << right_coord
	     << ", strand=" << (strand ? "+" : "-")
	     << ", cigar=" << cigar_str << ", sub=" << sub << ", insert=" << insert << ", delete=" << del
	     << ", clipped=" << clipped << ", read_length=" << read_length << ", match_length=" << match_length << endl;
      }
      massert(coord >= left_coord && coord <= right_coord, "coord %d out of range, left=%d, right=%d\n", coord, left_coord, right_coord);
      // string seq = (strand ? ssub_fields[2] : reverse_complement(ssub_fields[2]));
      string seq = ssub_fields[2];
      read_vars[coord].add_insert(seq);
      // Variation var(vtInsert, seq);
      // INCREMENT(contig_map, coord, var, contig_length);
    }

    // increment for all variations identified in read
    map< int, map <Variation, int> >& coord_map = vars[contig];
    for (map< int, Variation>::iterator it=read_vars.begin(); it != read_vars.end(); ++it) {
      int coord = (*it).first;
      Variation var = (*it).second;
      INCREMENT(coord_map, coord, var, contig_length);
    }

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

  VariationSet varset(contig_map);

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
			 discard_clipped, min_score, min_length, max_edit, varset);

    // if (file_count++ == 3)
    //  break;
  }
  closedir (dir);

  varset.save(ofn);

  return 0;
}
