#include <stdlib.h>
#include <iostream>

#include "kmer_utils.h"
using namespace std;

index_t char2base(const char ch) {
  switch (ch) {
  case 'A': return(0);
  case 'C': return(1);
  case 'G': return(2);
  case 'T': return(3);
  default: return(-1);
  }
}

char base2char(int base) {
  base &= 3;
  switch (base) {
  case 0: return('A');
  case 1: return('C');
  case 2: return('G');
  case 3: return('T');
  default: return('N');
  }
}

index_t kmer2index(string kmer)
{
  index_t result = 0;
  for (unsigned int i=0; i<kmer.size(); ++i) {
    index_t base = char2base(kmer[kmer.size()-1-i]);
    result |= base << i*2;
  }
  return (result);
}

string index2kmer(index_t index, int ksize)
{
  string kmer;
  kmer.resize(ksize);
  for (unsigned int i=0; i<kmer.size(); ++i) {
    int base = index & 3;
    kmer[kmer.size()-1-i] = base2char(base);
    index = index >> 2;
  }
  return (kmer);
}
