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

#define massert_range(v, coord) massert(coord >= 0 && coord < (int)v.size(), "coord not in vector range");
#define INCREMENT(v, coord, var, length) \
massert(coord >=0 && coord < length, "coord out of range, coord=%d, contig_size=%d", coord, length); \
v[coord][var]++;

// cout << "coord=" << coord  << " var=" << var.str() << endl;

using namespace std;

enum VariType { vtNone, vtSubstitute, vtDelete, vtInsert, vtDangleLeft, vtDangleRight };
struct Variation {
  VariType type;

  // vtSubstitute (N=1), vtInsert (N>=1)
  string seq;

  // ctor
  Variation(VariType _type=vtNone, string _seq="NA") : type(_type), seq(_seq) {};
  bool get_type() { return type; };
  string type_str() {
    switch(type) {
    case vtNone: return "none";
    case vtSubstitute: return "snp";
    case vtDelete: return "delete";
    case vtInsert: return "insert";
    case vtDangleLeft: return "dangle_left";
    case vtDangleRight: return "dangle_right";
    }
    return "";
  }
  string str() {
    return type_str() + "_" + seq;
  }
};

bool operator<(const Variation& lhs, const Variation& rhs) {
  if (lhs.type != rhs.type)
    return (int)lhs.type < (int)rhs.type;
  return lhs.seq < rhs.seq;

}

void init_params(int argc, char **argv, Parameters& params)
{
  params.add_parser("idir", new ParserFilename("input directory"), true);
  params.add_parser("contigs", new ParserFilename("contig table"), true);
  params.add_parser("contig_field", new ParserString("contig field"), true);
  params.add_parser("odir_full", new ParserFilename("output directory of fully matched reads"), true);
  params.add_parser("odir_clipped", new ParserFilename("output directory of reads clipped on either side"), true);

  params.add_parser("margin", new ParserInteger("ignore variation that are close to read edge", 10), false);
  params.add_parser("min_length", new ParserInteger("minimal match length (nts)", 50), false);
  params.add_parser("min_score", new ParserInteger("minimal score", 30), false);

  if (argc == 1) {
    params.usage(argv[0]);
    exit(0);
  }

  // read command line params
  params.read(argc, argv);
  params.parse();
  params.verify_mandatory();
  params.print(cout);
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// I/O
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void split_string(string in, vector<string> &fields, char delim)
{
  fields.resize(0);
  string field;
  for (unsigned int i=0; i<in.size(); ++i) {
    char c = in[i];
    if (c == -1)
      break;
    if(c == '\r') {
      continue;
    }
    if(c == '\n') {
      fields.push_back(field);
      field.resize(0);
      break;
    }
    if(c == delim) {
      fields.push_back(field);
      field.resize(0);
    } else {
      field.push_back(c);
    }
  }

  if (field.length() > 0)
    fields.push_back(field);
}

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

string reverse_complement(string seq) {
  string result = seq;
  int N = seq.length();
  for (int i=0; i<N; i++) {
    char c = seq[N-i-1], r;
    switch( c )
      {
      case 'A': r = 'T'; break;
      case 'G': r = 'C'; break;
      case 'C': r = 'G'; break;
      case 'T': r = 'A'; break;
      default: r = c;
      }
    result[i] = r;
  }
  return(result);
}

void process_fasta(string fn,
		   map<string, int>& contig_map,
		   int margin, int min_score, int min_length,
		   map< string, map< int, map <Variation, int> > >& full_poly,
		   map< string, map< int, map <Variation, int> > >& clipped_poly,
		   map<string, vector<int> >& full_coverage,
		   map<string, vector<int> >& clipped_coverage)
{
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
    int left_coord = strand ? back_coord : front_coord;
    int right_coord = !strand ? back_coord : front_coord;
    int read_length = right_coord - left_coord + 1;
    int match_length = atoi(fields[match_ind].c_str());
    int score = atoi(fields[score_ind].c_str());
    int contig_length = contig_map[contig];
    string sub = fields[sub_ind];
    string insert = fields[insert_ind];
    string del = fields[delete_ind];
    string cigar_str = fields[cigar_ind];

    // skip if this is a secondary match with a lower score
    if (id_score.find(id) != id_score.end()) {
      massert(score <= id_score[id], "first line per id should be the best score");
      continue;
    }
    id_score[id] = score;

    // skip if quality or match length fall under thresholds
    if (match_length < min_length || score < min_score)
      continue;

    // skip contigs which are not in contig table
    if(contig_map.find(contig) == contig_map.end())
      continue;

    // parse cigar format to identify dangles
    vector<pair < char, int> > cigar;
    parse_cigar(cigar_str, cigar);
    bool clip_start = (cigar.front().first == 'S' || cigar.front().first == 'H');
    bool clip_end = (cigar.back().first == 'S' || cigar.back().first == 'H');
    bool clipped = clip_start || clip_end;

    vector<int>& coverage_contig = !clipped ? full_coverage[contig] : clipped_coverage[contig];
    map< int, map <Variation, int> >& poly_contig = !clipped ? full_poly[contig] : clipped_poly[contig];

    // cout << "id=" << id << ", contig=" << contig << ", left_coord=" << left_coord << ", right_coord=" << right_coord
    // 	 << ", strand=" << (strand ? "+" : "-")
    // 	 << ", cigar=" << cigar_str << ", sub=" << sub << ", insert=" << insert << ", delete=" << del
    // 	 << ", clipped=" << clipped << ", read_length=" << read_length << ", match_length=" << match_length << endl;

    // dangle left
    if (strand ? clip_start : clip_end) {
      int coord = strand ? left_coord : right_coord;
      Variation var(strand ? vtDangleLeft : vtDangleRight);
      INCREMENT(poly_contig, coord, var, contig_length);
    }

    // dangle right
    if (!strand ? clip_start : clip_end) {
      int coord = strand ? right_coord : left_coord;
      Variation var(strand ? vtDangleRight : vtDangleLeft);
      INCREMENT(poly_contig, coord, var, contig_length);
    }

    // substitutes
    split_string(sub, sub_fields, sub_delim);
    for (unsigned int i=0; i<sub_fields.size(); ++i) {
      split_string(sub_fields[i], ssub_fields, ssub_delim);
      if (ssub_fields.size() < 4)
	continue;
      int coord = atoi(ssub_fields[0].c_str()) - 1;
      if (coord < left_coord+margin || coord > right_coord-margin)
	continue;
      // string nt = (strand ? ssub_fields[3] : reverse_complement(ssub_fields[3]));
      string nt = ssub_fields[3];
      if (nt == "N")
	continue;
      Variation var(vtSubstitute, nt);
      INCREMENT(poly_contig, coord, var, contig_length);
    }

    // deletions
    split_string(del, sub_fields, sub_delim);
    for (unsigned int i=0; i<sub_fields.size(); ++i) {
      split_string(sub_fields[i], ssub_fields, ssub_delim);
      if (ssub_fields.size() < 2)
	continue;
      int start_coord = atoi(ssub_fields[0].c_str()) - 1;
      if (start_coord < left_coord+margin || start_coord > right_coord-margin)
	continue;
      int del_length = atoi(ssub_fields[1].c_str());
      for (int k=0; k<del_length; k++) {
	int coord = start_coord + k;
	Variation var(vtDelete);
	INCREMENT(poly_contig, coord, var, contig_length);
      }
    }

    // insertions
    split_string(insert, sub_fields, sub_delim);
    for (unsigned int i=0; i<sub_fields.size(); ++i) {
      split_string(sub_fields[i], ssub_fields, ssub_delim);
      if (ssub_fields.size() < 3)
	continue;
      int coord = atoi(ssub_fields[0].c_str()) - 2;
      if (coord < left_coord+margin || coord > right_coord-margin)
	continue;
      // string seq = (strand ? ssub_fields[2] : reverse_complement(ssub_fields[2]));
      string seq = ssub_fields[2];
      Variation var(vtInsert, seq);
      INCREMENT(poly_contig, coord, var, contig_length);
    }

    // coverage
    for (int i=0; i<read_length; ++i) {
      int coord = left_coord + i;
      massert_range(coverage_contig, coord);
      coverage_contig[coord]++;
    }
  }
}

void read_contig_table(string fn, string contig_field, map<string, int>& contig_map)
{
  cout << "reading table: " << fn << endl;
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());
  vector<string> fields;
  char delim = '\t';

  // parse header
  split_line(in, fields, delim);
  int contig_ind = get_field_index(contig_field, fields);
  int length_ind = get_field_index("length", fields);

  while(in) {
    split_line(in, fields, delim);
    if(fields.size() == 0)
      break;

    string contig = fields[contig_ind];
    int length = atoi(fields[length_ind].c_str());
    contig_map[contig] = length;
  }
}

inline double mround(double v, int digits) {
  double f = pow(10,digits);
  return (round(v * f) / f);
}

void save_tables(map<string, int>& contig_map,
		 map< string, map< int, map <Variation, int> > >& table,
		 map<string, vector<int> >& coverage, string odir)
{
  cout << "writing output in director: " << odir << endl;
  for (map<string, int>::iterator it=contig_map.begin(); it!=contig_map.end(); ++it) {
    string contig = (*it).first;
    int length = (*it).second;
    map< int, map <Variation, int> >& table_contig = table[contig];
    vector<int>& coverage_contig = coverage[contig];
    massert((unsigned int)length == coverage_contig.size(), "internal error");

    string ofn_cov = odir + "/" + contig + ".cov";
    ofstream out_cov(ofn_cov.c_str());
    massert(out_cov.is_open(), "could not open file %s", ofn_cov.c_str());
    for (unsigned int coord = 0; coord < coverage_contig.size(); ++coord)
      out_cov << coverage_contig[coord] << endl;
    out_cov.close();

    string ofn_poly = odir + "/" + contig + ".poly";
    ofstream out_poly(ofn_poly.c_str());
    massert(out_poly.is_open(), "could not open file %s", ofn_poly.c_str());
    out_poly << "contig\tcoord\ttype\tcount\ttotal\tpercent\tsequence" << endl;
    for (map< int, map <Variation, int> >::iterator it = table_contig.begin(); it != table_contig.end(); ++it) {
      int coord = (*it).first;
      map <Variation, int>& xmap = (*it).second;
      int vcount = 0;
      for (map <Variation, int>::iterator jt=xmap.begin(); jt!=xmap.end(); ++jt) {
	Variation var = (*jt).first;
	int count =  (*jt).second;
	vcount += count;
	out_poly << contig << "\t" << coord+1 << "\t" << var.type_str() << "\t" << count << "\t" << coverage_contig[coord] << "\t" << mround(100*count/(double)coverage_contig[coord],1) << "\t" << var.seq << endl;
      }
    }
  }
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

int main(int argc, char **argv)
{
  Parameters params;
  init_params(argc, argv, params);

  string contig_table_ifn = params.get_string("contigs");
  string contig_field = params.get_string("contig_field");
  int margin = params.get_int("margin");
  int min_score = params.get_int("min_score");
  int min_length = params.get_int("min_length");

  string idir = params.get_string("idir");

  string odir_full = params.get_string("odir_full");
  string odir_clipped = params.get_string("odir_clipped");

  map<string, int> contig_map;
  read_contig_table(contig_table_ifn, contig_field, contig_map);
  cout << "number of contigs: " << contig_map.size() << endl;

  // for deletions and substitutes
  map< string, map< int, map <Variation, int> > > full_poly;
  map<string, vector<int> > full_coverage;

  // for inserts and dangles
  map< string, map< int, map <Variation, int> > > clipped_poly;
  map<string, vector<int> > clipped_coverage;

  for (map<string, int>::iterator it=contig_map.begin(); it!=contig_map.end(); ++it) {
    string contig = (*it).first;
    int length = (*it).second;

    vector<int>& full_coverage_contig = full_coverage[contig];
    vector<int>& clipped_coverage_contig = clipped_coverage[contig];
    full_coverage_contig.resize(length);
    clipped_coverage_contig.resize(length);
  }

  cout << "number of fastq files found: " << get_of_files(idir) << endl;
  DIR *dir;
  struct dirent *ent;
  massert((dir = opendir (idir.c_str())) != NULL, "could not open input directory");
  // int file_count = 0;
  while ((ent = readdir (dir)) != NULL) {
    string ifn = ent->d_name;
    if (ifn.find("fastq") == string::npos || ifn.find("~") != string::npos)
      continue;
    process_fasta(idir + "/" + ifn, contig_map, margin, min_score, min_length, full_poly, clipped_poly, full_coverage, clipped_coverage);
    //    if (file_count++ > 3)
    //      break;
  }
  closedir (dir);

  save_tables(contig_map, full_poly, full_coverage, odir_full);
  save_tables(contig_map, clipped_poly, clipped_coverage, odir_clipped);
}
