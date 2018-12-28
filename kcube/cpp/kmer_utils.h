#ifndef KMERUTILS_H
#define KMERUTILS_H

#include <vector>
#include <string>
using namespace std;

typedef long long int index_t;
typedef unsigned char count_t;

index_t char2base(const char ch);
char base2char(int base);

index_t kmer2index(string kmer);
string index2kmer(index_t index, int ksize);

#endif
