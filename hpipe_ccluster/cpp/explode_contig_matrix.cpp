#include <iostream>
#include <vector>
#include <string>
#include <map>
#include <set>
#include <iostream>
#include <fstream>
#include <assert.h>
#include <sstream>
#include <stdarg.h>
#include <cmath>

#include <dirent.h>
#include <sys/stat.h>

#include <queue>

#include <algorithm>
#include <stdio.h>
#include <stdlib.h>

using namespace std;

//////////////////////////////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////////////////////////////

void massert(bool cond, char *fmt, ...)
{
  if (cond)
    return;

  fprintf(stderr, "Error: ");

  va_list argp;
  va_start(argp, fmt);
  vfprintf(stderr, fmt, argp);
  va_end(argp);

  fprintf(stderr, "\n");
  exit(-1);
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// Parsing and handling user arguments
//////////////////////////////////////////////////////////////////////////////////////////////////

class UserParams {
public:
  string ifn;
  string idir;
  string pattern;
  string odir;
};

void usage(const char* name, UserParams& params)
{
  fprintf(stderr, "usage: %s [options]\n", name);
  cout << " -ifn <path>: contig table" << endl;
  cout << " -idir <path>: input dir" << endl;
  cout << " -pattern <string>: pattern of filename within input dir" << endl;
  cout << " -odir <path>: output dir" << endl;
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

      if (option == "-ifn")
	params.ifn = arg;
      else if (option == "-idir")
	params.idir = arg;
      else if (option == "-pattern")
	params.pattern = arg;
      else if (option == "-odir")
	params.odir = arg;
      else {
	cout << "Error: unknown option: " << option << endl;
	exit(1);
      }

      i += 2;
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// I/O utility functions
//////////////////////////////////////////////////////////////////////////////////////////////////

string join_fields(vector<string> &fields, char delim)
{
  if (fields.size() == 0) return "";
  string result = fields[0];
  for (unsigned int i=1; i<fields.size(); ++i)
    result = result + delim + fields[i];
  return (result);
}

string split_line(istream &in, vector<string> &fields, char delim)
{
  fields.resize(0);
  string field;
  while(in) {
    char c = in.get();
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

  return (join_fields(fields, delim));
}

int get_field_index(string field, const vector<string>& titles)
{
  int result = -1;
  for (unsigned int i = 0; i<titles.size(); i++)
    if (titles[i] == field)
      result = i;
  if (result == -1) {
    cout << "unknown field " << field << endl;
    exit(1);
  }
  return result;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// I/O
//////////////////////////////////////////////////////////////////////////////////////////////////

void read_contigs(string fn, map<int, string>& index2contig, map<string, int>& contig2index)
{
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());
  vector<string> fields;
  char delim = '\t';

  // parse header
  split_line(in, fields, delim);
  int contig_idx = get_field_index("contig", fields);
  int index = 1;
  while(in) {
    split_line(in, fields, delim);
    string contig = fields[contig_idx];

    index2contig[index] = contig;
    contig2index[contig] = index;
    index++;
  }
  in.close();
}

void read_contacts(string fn,
		   map<int, string>& index2contig, map<string, int>& contig2index,
		   map<int, map<int, vector<string> > >& contacts, string& header)
{
  // cout << "reading file: " << fn << endl;
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());
  vector<string> fields;
  char delim = '\t';

  // parse header
  string file_header = split_line(in, fields, delim);
  massert(header == "" || header == file_header, "header mismatch");
  header = file_header;

  int contig1_idx = get_field_index("contig1", fields);
  int contig2_idx = get_field_index("contig2", fields);
  while(in) {
    string line = split_line(in, fields, delim);
    if (fields.size() == 0)
      break;
    string contig1 = fields[contig1_idx];
    string contig2 = fields[contig2_idx];
    massert(contig2index.find(contig1) != contig2index.end() && contig2index.find(contig2) != contig2index.end(), "contigs not found");

    int index1 = contig2index[contig1];
    int index2 = contig2index[contig2];

    contacts[index1][index2].push_back(line);
    if (index1 != index2)
      contacts[index2][index1].push_back(line);
  }
  in.close();
}

void get_filenames(string dir, string pattern, vector<string>& fns)
{
  DIR *dir_f;
  struct dirent *ent;
  massert((dir_f = opendir (dir.c_str())) != NULL, "could not open input directory");
  while ((ent = readdir (dir_f)) != NULL) {
    string fn = string(ent->d_name);
    if (fn.find(pattern) != string::npos && fn[0] != '.')
      fns.push_back(dir + "/" + fn);
  }
  closedir (dir_f);
}

bool fexists(string dir)
{
   struct stat info;
   return( stat( dir.c_str(), &info ) == 0 );
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// Main
//////////////////////////////////////////////////////////////////////////////////////////////////

int main(int argc, char **argv)
{
  UserParams params;
  parse_user_arguments(argc, argv, params);

  map<int, string> index2contig;
  map<string, int> contig2index;

  cout << "contig table: " << params.ifn << endl;
  read_contigs(params.ifn, index2contig, contig2index);
  cout << "number of contigs: "<< index2contig.size() << endl;

  vector<string> fns;
  get_filenames(params.idir, params.pattern, fns);
  cout << "number of input files: " << fns.size() << endl;
  massert(fns.size() > 0, "no input files found");

  map<int, map<int, vector<string> > > contacts;
  string header = "";
  for (unsigned int i=0; i<fns.size(); ++i) {
    read_contacts(fns[i], index2contig, contig2index, contacts, header);
    cout << "." << std::flush;
  }
  cout << endl;

  cout << "writing result into directory: " << params.odir << endl;
  for (map<int, map<int, vector<string> > >::iterator it1 = contacts.begin(); it1 != contacts.end(); ++it1) {
    int index1 = (*it1).first;
    massert(index2contig.find(index1) != index2contig.end(), "contig not found");
    string contig1 = index2contig[index1];
    string contig_odir = params.odir + "/" + contig1;

    // create dir if needed
    if (!fexists(contig_odir))
      massert(mkdir(contig_odir.c_str(), S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH) == 0, "error creating directory");

    map<int, vector<string> >& contacts_contig = (*it1).second;
    for (map<int, vector<string> >::iterator it2 = contacts_contig.begin(); it2 != contacts_contig.end(); ++it2) {
      int index2 = (*it2).first;
      vector<string>& lines = (*it2).second;
      massert(index2contig.find(index2) != index2contig.end(), "contig not found");
      string contig2 = index2contig[index2];

      string ofn = contig_odir + "/" + contig2;
      ofstream out(ofn);
      massert(out.is_open(), "could not open file %s", ofn.c_str());
      out << header << endl;
      for (unsigned int i=0; i<lines.size(); ++i)
	out << lines[i] << endl;
      out.close();
    }
  }

  return (0);
}
