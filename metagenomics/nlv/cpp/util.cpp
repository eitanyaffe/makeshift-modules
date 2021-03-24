#include "util.h"

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

void split_line(istream &in, vector<string> &fields, char delim)
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
}

void mexit(char *fmt, ...)
{
  fprintf(stderr, "Error: ");

  va_list argp;
  va_start(argp, fmt);
  vfprintf(stderr, fmt, argp);
  va_end(argp);

  fprintf(stderr, "\n");
  exit(-1);
}

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

int safe_string_to_int(const string str, const string title)
{
    try {
      return stoi(str);
    }
    catch (std::invalid_argument const &e) {
      mexit("%s %s could not be converted to integer", title.c_str(), str.c_str());
    }
    return 0;
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

char index2char(int i) {
  switch (i)
    {
    case 0: return('A');
    case 1: return('C');
    case 2: return('G');
    case 3: return('T');
    }
  massert(0, "unknown character index");
  return 0;
}

int char2index(char c) {
  switch (c)
    {
    case 'A': return(0);
    case 'C': return(1);
    case 'G': return(2);
    case 'T': return(3);
    }
  massert(0, "unknown character: %c", c);
  return 0;
}

int read_sites(string ifn, map< string, map < int, pair< Variation, Variation > > >& sites)
{
  cout << "reading site table: " << ifn << endl;
  ifstream in(ifn.c_str());
  massert(in.is_open(), "could not open file %s", ifn.c_str());
  vector<string> fields;
  char delim = '\t';

  // parse header
  split_line(in, fields, delim);
  int contig_ind = get_field_index("contig", fields);
  int coord_ind = get_field_index("coord", fields);
  int major_ind = get_field_index("major", fields);
  int minor_ind = get_field_index("minor", fields);

  int count = 0;
  while(in) {
    split_line(in, fields, delim);
    if(fields.size() == 0)
      break;
    string contig = fields[contig_ind];
    int coord = safe_string_to_int(fields[coord_ind], "coordinate") - 1;
    Variation major = Variation(fields[major_ind]);
    Variation minor = Variation(fields[minor_ind]);
    sites[contig][coord] = make_pair(major, minor);
    count++;
  }

  in.close();
  return count;
}
