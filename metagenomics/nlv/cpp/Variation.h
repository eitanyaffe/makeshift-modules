#ifndef __VARIATION__
#define __VARIATION__

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

using namespace std;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Variation
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/*
vtSubstitute: Single nucleotide replaced on coordinate
vtDelete: Nucleotides deleted starting from coordinate
vtInsert: Nucleotides inserted to left of coordinate
vtDangleLeft: Read dangles to the left of coordinate
vtDangleRight: Read dangles the right of coordinate
*/

enum VariType { vtNone, vtSubstitute, vtDelete, vtInsert, vtDangleLeft, vtDangleRight, vtCount };
class Variation {
 private:
  int m_type_bitmap;

  // vtSubstitute data
  char m_sub_nt;

  // vtInsert data
  string m_insert_seq;

  // vtDelete data
  int m_delete_length;

  void set_type(VariType type);
  void get_types(vector<VariType>& types);

  void from_string(const string str);

 public:

  // ctor
  Variation();
  Variation(string str);

  void save(ofstream& out);
  void load(ifstream& in);

  void add_sub(string nt);
  void add_delete(int length);
  void add_insert(string seq);
  void add_dangle_left();
  void add_dangle_right();

  // a variation
  bool is_ref() { return m_type_bitmap == 0; };

  string to_string();

  friend bool operator<(const Variation& lhs, const Variation& rhs);
  friend bool operator==(const Variation& lhs, const Variation& rhs);

  ////////////////////////////////////////////////////////////////////
  // static
  ////////////////////////////////////////////////////////////////////

  // type to/from string
  static string type_to_string(const VariType type);
  static VariType string_to_type(const string str);
};

#endif
