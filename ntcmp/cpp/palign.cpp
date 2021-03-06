#include <iostream>
#include <vector>
#include <string>
#include <map>
#include <set>
#include <fstream>
#include <assert.h>
#include <sstream>

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <dirent.h>

#include "util.h"

using namespace std;

//////////////////////////////////////////////////////////////////////////////////////////////////
// Parsing and handling user arguments
//////////////////////////////////////////////////////////////////////////////////////////////////

struct Align {
  int index, coord, length;
  bool unique;

  Align() : index(-1), coord(-1), length(-1), unique(true) {};
  Align(int _index, int _coord, int _length) : index(_index), coord(_coord), length(_length), unique(true) {};
  void set_non_unique() { unique = false; };
  bool is_valid() { return (index != -1); };
  bool is_neighbour(Align& oalign) { return (index == oalign.index && (abs(coord-oalign.coord) == 1) && (unique == oalign.unique)); };

  bool is_compatible(Align& oalign, int length) {
    int mlength = abs(coord - oalign.coord);
    return ( (is_valid() && oalign.is_valid()) &&
	     (index == oalign.index) &&
	     (length == mlength) );
  };

  string dump() {
    char buffer[200];
    sprintf(buffer, "(index=%d coord=%d length=%d unique=%d)", index, coord+1, length, unique);
    return (buffer);
  };
};

class UserParams {
public:
  string idir, odir1, odir2;
  string ifn_table1, ifn_table2;
  bool debug;
};

void usage(const char* name, UserParams& params)
{
  fprintf(stderr, "usage: %s [options]\n", name);
  cout << " -itable1 <fn>: contig table1" << endl;
  cout << " -itable2 <fn>: contig table2" << endl;
  cout << " -idir <fn>: dir with alignment tables" << endl;
  cout << " -odir1 <dir>: output directory1" << endl;
  cout << " -odir2 <dir>: output directory2" << endl;
  cout << " -debug <T|F>: output complete match vector to stderr" << endl;
  exit(1);
}

void parse_user_arguments(int argc, char **argv, UserParams& params)
{
  if (argc == 1)
    usage(argv[0], params);

  int i = 1;
  while (i < argc)
    {
      string option = argv[i];
      char* arg = argv[i+1];

      if (option == "-itable1")
	params.ifn_table1 = arg;
      else if (option == "-itable2")
	params.ifn_table2 = arg;
      else if (option == "-idir")
	params.idir = arg;
      else if (option == "-odir1")
	params.odir1 = arg;
      else if (option == "-odir2")
	params.odir2 = arg;
      else if (option == "-debug")
	params.debug = string(arg) == string("T");
      else {
	cout << "Error: unknown option: " << option << endl;
	exit(1);
      }
      i += 2;
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// read contig tables
//////////////////////////////////////////////////////////////////////////////////////////////////

void read_contig_table(string fn, string contig_field,
		       map<string, int >& contig_map,
		       map<int, string >& contig_revmap,
		       map<string, vector<Align> >& align_map,
		       map<int, int>& contig_length)
{
  cout << "reading contig table: " << fn << endl;
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());
  vector<string> fields;
  char delim = '\t';

  int index = 1;
  int tlength = 0;

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
    contig_map[contig] = index;
    contig_revmap[index] = contig;
    contig_length[index] = length;

    vector<Align>& align_contig = align_map[contig];
    align_contig.resize(length);
    for (int i=0; i<length; ++i)
      align_contig[i] = Align();

    tlength += length;
    index++;
  }
  cout << "number of contigs: " << contig_map.size() << endl;
  cout << "total bp: " << tlength << endl;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// traverse alignment tables
//////////////////////////////////////////////////////////////////////////////////////////////////

void update_alignment(vector<Align>& align_contig,
		      int start, int end,
		      int oindex, int ostart, int oend, int length, bool debug)
{
  int alength = end - start;
  int olength = oend - ostart;
  massert(alength == olength && alength == length, "length mismatch, source=%d target=%d expected=%d", alength, olength, length);

  if (debug)
    cerr << "start=" << start << " end=" << end << " oindex=" <<
      oindex << " ostart=" << ostart << " oend=" << oend << " length=" << length << endl;


  for (int i=0; i<length; ++i) {
    int coord = start + i - 1;
    int ocoord = ostart + i - 1;
    massert((unsigned int)coord < align_contig.size(), "coord %d not in vector of size %d",  coord, align_contig.size());
    Align& align = align_contig[coord];
    if ((align.index != -1) && (align.length >= length)) {
      if (align.length == length)
	align.set_non_unique();
      continue;
    }
    align_contig[coord] = Align(oindex, ocoord, length);
  }
}

void read_alignment_table(string fn,
			  map<string, int >& contig_map1,
			  map<string, int >& contig_map2,
			  map<string, vector<Align> >& align_map1,
			  map<string, vector<Align> >& align_map2, bool debug)
{
  cout << "reading alignment table: " << fn << endl;
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());
  vector<string> fields;
  char delim = '\t';

  // parse header
  split_line(in, fields, delim);
  int contig_ind1 = get_field_index("tcontig", fields);
  int start_ind1 = get_field_index("tstart", fields);
  int end_ind1 = get_field_index("tend", fields);

  int contig_ind2 = get_field_index("qcontig", fields);
  int start_ind2 = get_field_index("qstart", fields);
  int end_ind2 = get_field_index("qend", fields);

  int length_ind = get_field_index("length", fields);

  while (in) {
    split_line(in, fields, delim);
    if(fields.size() == 0)
      break;

    string contig1 = fields[contig_ind1];
    string contig2 = fields[contig_ind2];
    if (contig_map1.find(contig1) == contig_map1.end() || contig_map2.find(contig2) == contig_map2.end())
      continue;

    vector<Align>& align_contig1 = align_map1[contig1];
    vector<Align>& align_contig2 = align_map2[contig2];

    int index1 = contig_map1[contig1];
    int index2 = contig_map2[contig2];

    int start1 = atoi(fields[start_ind1].c_str());
    int start2 = atoi(fields[start_ind2].c_str());

    int end1 = atoi(fields[end_ind1].c_str());
    int end2 = atoi(fields[end_ind2].c_str());

    int length = atoi(fields[length_ind].c_str());

    update_alignment(align_contig1, start1, end1,
		     index2, start2, end2, length, debug);
    update_alignment(align_contig2, start2, end2,
		     index1, start1, end1, length, debug);
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// unite and output alignment segments
//////////////////////////////////////////////////////////////////////////////////////////////////

void report_segment(ofstream& out, string& contig,
		    int coord_start, int coord_end,
		    Align& start_align, Align& end_align,
		    map<int, string>& contig_revmap,
		    map<int, int>& contig_length,
		    bool debug)
{
  if (!start_align.is_valid() || !end_align.is_valid() || !start_align.is_compatible(end_align, coord_end-coord_start) || (coord_end-coord_start)<=1)
    return;

  if (debug)
    cerr << " end of segment found" << endl;
  massert(start_align.index != -1, "index cannot be -1");
  massert(start_align.index == end_align.index, "indices do not match");
  massert((end_align.coord - start_align.coord) == (coord_end - coord_start),
	  "length mismatch, start=%d end=%d align_start=%d align_end=%d", coord_start, coord_end, start_align.coord, end_align.coord);

  massert(start_align.unique == end_align.unique, "unique flag does not match");
  bool unique = end_align.unique;

  massert(start_align.index == end_align.index, "indices do not match");
  int oindex = start_align.index;

  massert(contig_revmap.find(oindex) != contig_revmap.end(), "index not found");
  string ocontig = contig_revmap[oindex];

  int olength = contig_length[oindex];

  out << contig << "\t" << coord_start+1 << "\t" << coord_end+1 << "\t";
  out << ocontig << "\t" << start_align.coord+1 << "\t" << end_align.coord+1 << "\t";
  out << end_align.coord - start_align.coord + 1 << "\t";
  out << (unique ? string("T") : string("F")) << "\t" << olength << endl;
}

void output_tables(string odir,
		   map<string, vector<Align> >& align_map,
		   map<int, string>& contig_revmap,
		   map<int, int>& contig_length,
		   bool debug)
{
  if (debug)
    cerr << "==========================" << endl;

  cout << "writing results in directory: " << odir << endl;
  for (map<string, vector<Align > >::iterator it = align_map.begin(); it != align_map.end(); ++it) {
    string contig = (*it).first;

    // sparse
    string ofn = odir + "/" + contig + ".table";
    ofstream out(ofn.c_str());
    massert(out.is_open(), "could not open file %s", ofn.c_str());
    out << "contig\tstart\tend\tmcontig\tmstart\tmend\tlength\tunique\tclength" << endl;

    // dense
    string ofn_dense = odir + "/" + contig + ".dense";
    ofstream out_dense(ofn_dense.c_str());
    massert(out_dense.is_open(), "could not open file %s", ofn_dense.c_str());
    out_dense << "contig\tcoord\tclength" << endl;

    vector<Align>& align_contig = align_map[contig];

    if (debug)
      cerr << "contig: " << contig << endl;

    Align start_align;
    Align prev_align;
    int coord_start = -1;
    for (unsigned int coord=0; coord<align_contig.size(); ++coord) {
      Align& align = align_contig[coord];
      if (debug)
	cerr << " coord=" << coord << " current=" << align.dump() << " start=" << start_align.dump() << endl;

      // output dense
      string ocontig = (align.index != -1) ? contig_revmap[align.index] : "NA";
      int olength = (align.index != -1) ? contig_length[align.index] : 0;
      out_dense << ocontig << "\t" << align.coord+1 << "\t" << olength << endl;

      // end of segment
      if (!align.is_neighbour(prev_align)) {
	report_segment(out, contig, coord_start, coord-1, start_align, prev_align, contig_revmap, contig_length, debug);
	start_align = Align();
	coord_start = -1;
      }

      // outside a segment
      if (!start_align.is_valid() && align.is_valid()) {
	start_align = align;
	coord_start = coord;
      }

      prev_align = align;
    }
    int last_coord = align_contig.size()-1;
    Align& last_align = align_contig[last_coord];
    report_segment(out, contig, coord_start, last_coord, start_align, last_align, contig_revmap, contig_length, debug);

    out.close();
    out_dense.close();
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// debug
//////////////////////////////////////////////////////////////////////////////////////////////////

void dump_alignment(map<string, vector<Align> >& align_map,
		    map<int, string>& contig_revmap, string title)
{
  cerr << title << endl;
  for (map<string, vector<Align > >::iterator it = align_map.begin(); it != align_map.end(); ++it) {
    string contig = (*it).first;
    cerr << "contig=" << contig << endl;
    vector<Align>& align_contig = align_map[contig];

    for (unsigned int coord=0; coord<align_contig.size(); ++coord) {
      Align& align = align_contig[coord];
      cerr << " " << coord + 1 << " : " << align.dump() << endl;
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// files
//////////////////////////////////////////////////////////////////////////////////////////////////

void get_files(string dir, vector<string> &files)
{
    DIR *dp;
    struct dirent *dirp;
    if((dp  = opendir(dir.c_str())) == NULL) {
        cout << "Error(" << errno << ") opening " << dir << endl;
        exit(-1);
    }

    while ((dirp = readdir(dp)) != NULL) {
      if (string(dirp->d_name) == "." || string(dirp->d_name) == "..")
	continue;
      string fn = dir + "/" + string(dirp->d_name);
      files.push_back(fn);
    }
    closedir(dp);
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// Main
//////////////////////////////////////////////////////////////////////////////////////////////////

int main(int argc, char **argv)
{
  UserParams params;
  parse_user_arguments(argc, argv, params);

  vector<string> ifiles;
  get_files(params.idir, ifiles);
  cout << "found " << ifiles.size() << " alignment files in dir: " << params.idir << endl;
  if (ifiles.size() == 0)
    exit(-1);

  // map from contig to index and back
  map<string, int> contig_map1, contig_map2;
  map<int, string> contig_revmap1, contig_revmap2;

  // map from contig to length
  map<int, int> contig_length1, contig_length2;

  // per contig/position, keep a index of longest aligned contig and length of alignment
  map<string, vector<Align> > align_map1;
  map<string, vector<Align> > align_map2;

  read_contig_table(params.ifn_table1, "contig", contig_map1, contig_revmap1, align_map1, contig_length1);
  read_contig_table(params.ifn_table2, "contig", contig_map2, contig_revmap2, align_map2, contig_length2);

  for (unsigned int i=0; i<ifiles.size(); ++i) {
    string fn = ifiles[i];
    read_alignment_table(fn, contig_map1, contig_map2, align_map1, align_map2, params.debug);
  }

  if (params.debug) {
    dump_alignment(align_map1, contig_revmap2, "align1");
    dump_alignment(align_map2, contig_revmap1, "align2");
  }

  output_tables(params.odir1, align_map1, contig_revmap2, contig_length2, params.debug);
  output_tables(params.odir2, align_map2, contig_revmap1, contig_length1, params.debug);

  return (0);
}
