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
#include "KCube_class.h"

using namespace std;

void init_params(int argc, char **argv, Parameters& params, string& command)
{
  params.add_parser("ksize", new ParserInteger("kmer size"), false);
  params.add_parser("input_command", new ParserString("fastq input command"), false);
  params.add_parser("read_dir", new ParserFilename("fastq read directory"), false);
  params.add_parser("read_pattern", new ParserFilename("filename pattern"), false);
  params.add_parser("assembly", new ParserFilename("assembly filename (fasta)"), false);
  params.add_parser("odir", new ParserFilename("output directory"), false);
  params.add_parser("ofn", new ParserFilename("coverage summary table"), false);
  params.add_parser("data", new ParserFilename("kcube filename"), false);
  params.add_parser("data_table", new ParserFilename("kcube filename table"), false);
  params.add_parser("binsize", new ParserInteger("binsize"), false);
  params.add_parser("binsizes", new ParserVector("binsizes"), false);
  params.add_parser("min_segment", new ParserInteger("minimal binning segment length", 1));
  params.add_parser("min_count", new ParserInteger("minimal kmer count", 1));
  params.add_parser("allow_sub", new ParserBoolean("allow single substitution", false));
  params.add_parser("max_reads", new ParserInteger("max reads during create", 0));

  if (argc == 1) {
    fprintf(stderr, "usage: %s command [options]\n", argv[0]);
    cout << "commands:" << endl;
    cout << " create: create kcube data file from reads (in fastq format)" << endl;
    cout << " details: project kcube data file onto assembly (in fasta format), generating one detailed file per contig " << endl;
    cout << " summary: project kcube data file onto assembly, computing contig mean coverage values" << endl;
    cout << " bin: project kcube data file onto assembly, binning contigs using specified binsizes" << endl;
    cout << " snps: generate snp vector summary over multiple data files" << endl;
    cout << " stats: print some stats of the kcube" << endl;
    cout << " dump: dump kcube data to screen" << endl;
    cout << "options:" << endl;
    params.usage(argv[0], false);
    exit(1);
  }

  // read command line params
  command = argv[1];
  cout << "===============================================" << endl;
  cout << "command: " << command << endl;
  params.read(argc-1, argv+1);
  params.parse();
  params.verify_mandatory();
  params.print(cout);
  cout << "===============================================" << endl;
}

void get_files(string idir, string pattern, vector<string>& fns)
{
  DIR *dir;
  struct dirent *ent;
  massert((dir = opendir (idir.c_str())) != NULL, "could not open input directory");
  while ((ent = readdir (dir)) != NULL) {
    string fn = ent->d_name;
    if (fn.find(pattern) == string::npos || fn.find("~") != string::npos)
      continue;
    fns.push_back(idir + "/" + fn);
  }
  closedir (dir);
}

void read_table(string fn, vector<string>& result)
{
  cout << "loading data table: " << fn << endl;
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());
  while(1) {
    string line;
    getline(in, line);
    if (line != "") result.push_back(line);
    bool eof = in.eof();
    if (eof)
      break;
  }
  in.close();
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// main functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

int main(int argc, char **argv)
{
  Parameters params;
  string command;
  init_params(argc, argv, params, command);

  if (command == "create") {
    string data_fn = params.get_string("data");
    int ksize = params.get_int("ksize");
    int max_reads = params.get_int("max_reads");
    KCube kcube(ksize);

    vector<string> fns;
    if (params.is_used("read_dir")) {
      string fastq_dir = params.get_string("read_dir");
      string fastq_pattern = params.get_string("read_pattern");
      get_files(fastq_dir, fastq_pattern, fns);
      cout << "number of fastq files: " << fns.size() << endl;
      massert(fns.size() > 0, "no files found in directory: %s");
      for (unsigned int i=0; i<fns.size(); ++i)
	kcube.init_from_fastq(fns[i], max_reads);
    } else {
      string input_command = params.get_string("input_command");
      kcube.init_from_fastq_command(input_command, max_reads);
    }

    kcube.save(data_fn);
  } else if (command == "details") {
    string data_fn = params.get_string("data");
    string fasta_fn = params.get_string("assembly");
    string odir = params.get_string("odir");
    KCube kcube;
    kcube.load(data_fn);
    kcube.assembly_complete(fasta_fn, odir);
  } else if (command == "snps") {
    string table_fn = params.get_string("data_table");
    string fasta_fn = params.get_string("assembly");
    int min_segment = params.get_int("min_segment");
    int min_count = params.get_int("min_count");
    string odir = params.get_string("odir");
    vector<string> fns;
    read_table(table_fn, fns);
    KCube kcube;
    kcube.snp_summary(fasta_fn, fns, min_segment, min_count, odir);
  } else if (command == "summary") {
    string data_fn = params.get_string("data");
    string fasta_fn = params.get_string("assembly");
    int min_segment = params.get_int("min_segment");
    int min_count = params.get_int("min_count");
    bool allow_sub = params.get_bool("allow_sub");
    string ofn = params.get_string("ofn");
    KCube kcube;
    kcube.load(data_fn);
    kcube.assembly_summary(fasta_fn, min_segment, min_count, allow_sub, ofn);
  } else if (command == "bin") {
    string data_fn = params.get_string("data");
    string fasta_fn = params.get_string("assembly");
    int min_segment = params.get_int("min_segment");
    int min_count = params.get_int("min_count");
    bool allow_sub = params.get_bool("allow_sub");
    string odir = params.get_string("odir");
    vector<string> binsizes_str = params.get_vector("binsizes");
    vector<int> binsizes(binsizes_str.size());
    for (unsigned int i=0; i<binsizes_str.size(); ++i)
      binsizes[i] = atoi(binsizes_str[i].c_str());

    KCube kcube;
    kcube.load(data_fn);
    kcube.assembly_bins(fasta_fn, binsizes, min_segment, min_count, allow_sub, odir);
  } else if (command == "dump") {
    string data_fn = params.get_string("data");
    KCube kcube;
    kcube.load(data_fn);
    kcube.dump();
  } else if (command == "stats") {
    string data_fn = params.get_string("data");
    KCube kcube;
    kcube.load(data_fn);
    kcube.stats();
  } else {
    cout << "unknown command: " << command << endl;
    exit(2);
  }
  return (0);
}
