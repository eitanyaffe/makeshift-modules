#ifndef __UTIL__
#define __UTIL__

#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

#include "Variation.h"

using namespace std;

void split_string(string in, vector<string> &fields, char delim);
void split_line(istream &in, vector<string> &fields, char delim);
void massert(bool cond, char *fmt, ...);
void mexit(char *fmt, ...);
int get_field_index(string field, const vector<string>& titles);

// error message: "<title> <str> could not be converted an integer"
int safe_string_to_int(const string str, const string title);

char index2char(int i);
int char2index(char c);

string reverse_complement(string seq);

int read_sites(string ifn, map< string, map < int, pair< Variation, Variation > > >& sites);

#endif
