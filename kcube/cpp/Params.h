#ifndef PARAMS_H
#define PARAMS_H

#include <vector>
#include <string>
#include <string.h>
#include <map>
#include <sstream>

#include "util.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Abstract Parser
////////////////////////////////////////////////////////////////////////////////////////////////////////////

enum ParserType { ptString, ptFilename, ptInteger, ptVector, ptDouble, ptBoolean };

struct Parser {
  // string identifier on command line
  string id;

  // desciption on usage
  string desc;

  // if true use only for usage
  bool dummy;

  // if actually used
  bool used;

Parser(string _desc, bool _dummy) : desc(_desc), dummy(_dummy), used(false) {};
  // parse from string
  virtual void parse(string arg) = 0;
  virtual ParserType type() = 0;

  // conversions
  virtual int to_int();
  virtual double to_double();
  virtual bool to_boolean();
  virtual string to_string();
  virtual vector<string> to_vector();

  // class functions
  static string ParserType2String(ParserType ptype);
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Parsers
////////////////////////////////////////////////////////////////////////////////////////////////////////////

struct ParserInteger : public Parser {
  int value;
 ParserInteger(string _desc, int default_value=0, bool _dummy=false) : Parser(_desc, _dummy), value(default_value) {};
  ParserType type() { return ptInteger; };
  void parse(string arg) { value = atoi(arg.c_str()); };

  // conversions
  string to_string() { return std::to_string((long long int)value); };
  int to_int() { return value; };
};

struct ParserDouble : public Parser {
  double value;
 ParserDouble(string _desc, double default_value=0.0, bool _dummy=false) : Parser(_desc, _dummy), value(default_value) {};
  ParserType type() { return ptDouble; };
  void parse(string arg) { value = atof(arg.c_str()); };

  // conversions
  string to_string() {

#if GCC_VERSION < 11000
    ostringstream x_convert;
    x_convert << value;
    return (x_convert.str());
#else
    return std::to_string(value);
#endif
  };

  double to_double() { return value; };
};

struct ParserBoolean : public Parser {
  bool value;
 ParserBoolean(string _desc, bool default_value=false, bool _dummy=false) : Parser(_desc, _dummy), value(default_value) {};
  ParserType type() { return ptBoolean; };
  void parse(string arg) {
    massert(arg.length() == 1 && (arg[0] == 'T' || arg[0] == 'F'), "boolean must be T|F: %s", arg.c_str());
    value = (arg[0] == 'T');
  };

  // conversions
  string to_string() { return (value ? "T" : "F"); };
  bool to_boolean() { return value; };
};

struct ParserString : public Parser {
  string value;
 ParserString(string _desc, string default_value="", bool _dummy=false) : Parser(_desc, _dummy), value(default_value) {};
  ParserType type() { return ptString; };
  void parse(string arg) { value = arg; };

  // conversions
  string to_string() { return value; };
};

struct ParserFilename : public ParserString {
 ParserFilename(string _desc, string default_value="", bool _dummy=false) : ParserString(_desc, default_value, _dummy) {};
  ParserType type() { return ptFilename; };
};

struct ParserVector : public Parser {
  vector<string> value;
 ParserVector(string _desc, bool _dummy=false) : Parser(_desc, _dummy) {};
  ParserType type() { return ptVector; };
  void parse(string arg) {
    istringstream iss(arg);
    do {
      string subs;
      iss >> subs;
      if (subs != "")
	value.push_back(subs);
    } while (iss);
  };

  // conversions
  vector<string> to_vector() { return value; };
  string to_string() {
    if (value.size() == 0)
      return "none";
    string result;
    result = value[0];
    for (unsigned int i=1; i<value.size(); ++i)
      result += ", " + value[i];
    return result;
  };
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////

class Parameters {
 private:
  // raw values
  map<string, vector<char*> > m_values;

  // parsers
  map<string, Parser*> m_parsers;
  vector<Parser*> m_add_order;

  map<string, bool> m_mandatory;
  map<string, bool> m_set;

  // parse all into parameters
  Parser* get_parser(string id);
  string get_value(string id);

 public:
  void usage(const char* name, bool print_header);

  // read from command line
  void read(int argc, char **argv);

  // parse values
  void add_parser(string id, Parser* param, bool mandatory=false);
  void parse(bool ignore_missing=false);

  // print all parsed values
  void print(ostream &os);

  // verify all mandatory params
  void verify_mandatory();

  bool is_used(string id);

  const int get_int(string id) { return get_parser(id)->to_int(); };
  const double get_double(string id) { return get_parser(id)->to_double(); };
  const string get_string(string id) { return get_parser(id)->to_string(); };
  const bool get_bool(string id) { return get_parser(id)->to_boolean(); };
  const vector<string> get_vector(string id) { return get_parser(id)->to_vector(); };
};

#endif
