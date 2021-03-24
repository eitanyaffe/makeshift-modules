#include <iostream>
#include <vector>
#include <string>
#include <map>
#include <set>
#include <fstream>
#include <assert.h>
#include <sstream>
#include <stdarg.h>
#include <cmath>

#include <algorithm>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <ctime>
#include <unordered_map>

using namespace std;

typedef uint64_t htype;

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

inline const htype hash_f(const string s)
{
  htype hash = 7;
  for (unsigned int i = 0; i < s.length(); i++)
    hash = hash*31 + s[i];
  return hash;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// Parsing and handling user arguments
//////////////////////////////////////////////////////////////////////////////////////////////////

class UserParams {
public:
  vector<string> ifns;
  string ofn;
  string mfn;
  string sfn;
};

void usage(const char* name, UserParams& params)
{
  fprintf(stderr, "usage: %s [options]\n", name);
  cout << " -ifn <fn>: input fastq, can have more than one" << endl;
  cout << " -ofn <fn>: output fastq" << endl;
  cout << " -mfn <fn>: multiplexcity output table" << endl;
  cout << " -sfn <fn>: stats output table" << endl;
  fprintf(stderr, "example: %s -ifn A1 -ifn A2 -ofn O -mfn m -sfn s\n", name);
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
	params.ifns.push_back(arg);
      else if (option == "-ofn")
	params.ofn = arg;
      else if (option == "-mfn")
	params.mfn = arg;
      else if (option == "-sfn")
	params.sfn = arg;
      else {
	cout << "Error: unknown option: " << option << endl;
	exit(1);
      }

      i += 2;
    }
}

ifstream::pos_type filesize(string filename)
{
    ifstream in(filename.c_str(), std::ifstream::ate | std::ifstream::binary);
    return in.tellg();
}

void traverse_fasta(ifstream& in, ofstream& out, unordered_map<htype, int>& multi,
		    double size, int& counter_total, int& counter_dups)
{
  const int MAXLINE = 1024;
  long counter = 0;
  char line[4*MAXLINE];

  clock_t begin = clock();
  clock_t time = begin;

  double total_seqs = 0;
  while(1) {
    int index = counter % 4;
    in.getline(line + index*MAXLINE, MAXLINE-1);
    bool eof = in.eof();

    if (!eof && !in.good()) {
      cerr << "Error reading line: " << counter+1
	   << ", rdstate=" << in.rdstate() << endl;
      if ( (in.rdstate() & std::ifstream::failbit ) != 0)
	cerr << "Probably line in file exceeds allocated maximal length: " << MAXLINE << endl;
      exit(-1);
    }

    // check if sequence already encountered
    if (index == 3 && counter) {
      string seq(line + MAXLINE);
      htype key = hash_f(seq);
      if (multi.find(key) == multi.end()) {
	multi[key] = 0;
	for (int i=0; i<4; i++)
	  out << line + i*MAXLINE << endl;
      } else {
	counter_dups++;
      }
      multi[key]++;
      counter_total++;
    }

    if (eof)
      break;

    counter++;
    if (counter % 10000000 == 0) {
      clock_t ntime = clock();
      double secs = double(ntime - time) / CLOCKS_PER_SEC;
      time = ntime;
      cout << "progress: " << 100*((double)counter/4)/total_seqs << "%, delta sec=" << secs << endl;
    }

    // report once the estimated number of lines (given all sequences are same length)
    if (counter == 4) {
      ifstream::pos_type pos = in.tellg();
      total_seqs = round(size/pos);
      cout << "estimated number of sequences (given length of first sequence): " << round(total_seqs/100000)/10 << "M" << endl;
    }
  }

  clock_t end = clock();
  double secs = double(end - begin) / CLOCKS_PER_SEC;
  cout << "total time traversing fasta file: " << secs/60 << " minutes" << endl;
}

void save_multi_table(unordered_map<htype, int>& multi, string ofn)
{
  // counter per each multiplicity
  map<int, int> table;

  cout << "computing multiplexity table..." << endl;
  for (unordered_map<htype, int>::iterator it = multi.begin(); it !=  multi.end(); ++it) {
    int count = (*it).second;
    if (table.find(count) == table.end())
      table[count] = 0;
    table[count]++;
  }

  cout << "saving multiplexity table to file: " << ofn << endl;
  ofstream out(ofn.c_str());
  massert(out.is_open(), "could not open file %s", ofn.c_str());
  out << "multi" << "\t" << "count" << endl;

  for (map<int, int>::iterator it = table.begin(); it !=  table.end(); ++it) {
    int multi_value = (*it).first;
    int multi_count = (*it).second;
    out << multi_value << "\t" << multi_count << endl;
  }

  out.close();
}


//////////////////////////////////////////////////////////////////////////////////////////////////
// Main
//////////////////////////////////////////////////////////////////////////////////////////////////

int main(int argc, char **argv)
{
  UserParams params;
  parse_user_arguments(argc, argv, params);
  unordered_map<htype, int> multi;

  cout << "output file: " << params.ofn << endl;

  ofstream out(params.ofn.c_str());
  massert(out.is_open(), "could not open file %s", params.ofn.c_str());
  int counter_total=0, counter_dups=0;

  for (unsigned int i=0; i<params.ifns.size(); i++) {
    string ifn = params.ifns[i];
    cout << "input file: " << ifn << endl;
    double size = filesize(ifn);
    ifstream in(ifn.c_str());
    massert(in.is_open(), "could not open file %s", ifn.c_str());
    traverse_fasta(in, out, multi, size, counter_total, counter_dups);
    in.close();
  }
  cout << "total sequences: " << counter_total << endl;
  cout << "dup sequences: " << counter_dups << endl;
  cout << "yield (percentage of kept reads): " << (double) 100 * (counter_total-counter_dups) / counter_total << "%" << endl;

  out.close();

  save_multi_table(multi, params.mfn);

  // stats
  cout << "saving stats table to file: " << params.sfn << endl;
  ofstream out_stats(params.sfn.c_str());
  massert(out_stats.is_open(), "could not open file %s", params.sfn.c_str());
  out_stats << "input" << "\t" << "output" << endl;
  out_stats << counter_total << "\t" << counter_total-counter_dups << endl;
  out_stats.close();

  return (0);
}
