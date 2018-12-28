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

class UserParams {
public:
  string idir, odir1, odir2;
  string ifn_table1, ifn_table2;
};

void usage(const char* name, UserParams& params)
{
  fprintf(stderr, "usage: %s [options]\n", name);
  cout << " -itable1 <fn>: contig table1" << endl;
  cout << " -itable2 <fn>: contig table2" << endl;
  cout << " -idir <fn>: dir with alignment tables" << endl;
  cout << " -odir1 <dir>: output directory1" << endl;
  cout << " -odir2 <dir>: output directory2" << endl;
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
      else {
	cout << "Error: unknown option: " << option << endl;
	exit(1);
      }

      i += 2;
    }
}

void read_contig_table(string fn, string contig_field,
		       map<string, int >& contig_map,
		       map<int, string >& contig_rmap,
		       map<string, vector<int> >& align)
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
    contig_rmap[index] = contig;
    align[contig].resize(length);
    tlength += length;
    index++;
  }
  cout << "number of contigs: " << contig_map.size() << endl;
  cout << "total bp: " << tlength << endl;
}

void read_alignment_table(string fn,
			  map<string, int >& contig_map1, map<string, int >& contig_map2,
			  map<int, string >& contig_rmap1, map<int, string >& contig_rmap2,
			  map<string, vector<int> >& align1, map<string, vector<int> >& align2)
{
}

void get_files(string dir, vector<string> &files)
{
    DIR *dp;
    struct dirent *dirp;
    if((dp  = opendir(dir.c_str())) == NULL) {
        cout << "Error(" << errno << ") opening " << dir << endl;
        exit(-1);
    }

    while ((dirp = readdir(dp)) != NULL) {
        files.push_back(string(dirp->d_name));
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
  cout << "found " << ifiles.size() << " alignment files in dir: " << params.idir;
  if (ifiles.size() == 0)
    exit(-1);

  // map from contig to index and back
  map<string, int> contig_map1, contig_map2;
  map<int, string> contig_rmap1, contig_rmap2;

  // per contig/position, keep index of longest aligned contig
  map<string, vector<int> > align1;
  map<string, vector<int> > align2;

  read_contig_table(params.ifn_table1, "contig", contig_map1, contig_rmap1, align1);
  read_contig_table(params.ifn_table2, "contig", contig_map2, contig_rmap2, align2);

  return (0);
}
