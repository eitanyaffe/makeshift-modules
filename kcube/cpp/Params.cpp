#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <assert.h>
#include <string.h>
#include <set>
#include <algorithm>

#include "Params.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Parser
////////////////////////////////////////////////////////////////////////////////////////////////////////////

string Parser::ParserType2String(ParserType ptype)
{
  switch (ptype) {
  case ptString: return "string";
  case ptFilename: return "fn";
  case ptInteger: return "int";
  case ptDouble: return "double";
  case ptBoolean: return "T|F";
  default:
    printf("unknown type: %d\n", ptype);
    exit(-1);
  }
}

int Parser::to_int()
{
  mexit("cannot convert %s to int", id.c_str());
  return 0;
};

double Parser::to_double()
{
  mexit("cannot convert %s to double", id.c_str());
  return 0;
};

bool Parser::to_boolean()
{
  mexit("cannot convert %s to boolean", id.c_str());
  return 0;
};


string Parser::to_string()
{
  mexit("cannot convert %s to string", id.c_str());
  return 0;
};

vector<string> Parser::to_vector()
{
  mexit("cannot convert %s to vector", id.c_str());
  vector<string> null;
  return null;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////////////

void Parameters::usage(const char* name, bool print_header)
{
  if (print_header)
    fprintf(stderr, "usage: %s [options]\n", name);
  for (unsigned int i=0; i < m_add_order.size(); i++) {
    Parser* parser = m_add_order[i];
    string id = parser->id;
    string ptype_str = Parser::ParserType2String(parser->type());
    cerr << " -" << parser->id << " <" << ptype_str << ">: " << parser->desc << (m_mandatory[id] ? " (mandatory)" : "") << endl;
  }
}

void Parameters::verify_mandatory()
{
  for (unsigned int i=0; i < m_add_order.size(); i++) {
    Parser* parser = m_add_order[i];
    string id = parser->id;
    massert(!m_mandatory[id] || m_set[id], "mandatory option %s not set", id.c_str());
  }
}

void Parameters::read(int argc, char **argv)
{
  int i = 1;
  while (i < argc) {
    string option = argv[i++];
    vector<char *> values;
    if (option.at(0) != '-') {
      cerr << "must start with a '-' sign" << endl;
      exit(-1);
    }
    while (i < argc && strlen(argv[i]) > 0 && (argv[i][0] != '-' || values.size() == 0)) {
      values.push_back(argv[i++]);
    }
    m_values[option.substr(1)] = values;
  }
}

void Parameters::parse(bool ignore_missing)
{
  for (map<string, vector<char*> >::iterator it = m_values.begin(); it != m_values.end(); ++it) {
    string id = (*it).first;
    if (m_parsers.find(id) == m_parsers.end() && ignore_missing)
      continue;
    Parser* parser = get_parser(id);
    string value = get_value(id);
    parser->parse(value);
    m_set[id] = true;
  }
}

void Parameters::print(ostream &os)
{
  os << "parameters:" << endl;
  for (unsigned int i=0; i < m_add_order.size(); i++) {
    Parser* parser = m_add_order[i];
    string id = parser->id;
    string str = parser->to_string();
    if (parser->dummy || !parser->used)
      continue;
    os << " " << parser->desc << ": " << str << (m_mandatory[id] ? " (mandatory)" : "") << endl;
  }
}

void Parameters::add_parser(string id, Parser* parser, bool mandatory)
{
  parser->id = id;
  if (m_parsers.find(id) != m_parsers.end()) {
    cerr << "parser for option " << id << " already set" << endl;
    exit(-1);
  }
  m_parsers[id] = parser;
  m_add_order.push_back(parser);
  m_mandatory[id] = mandatory;
  m_set[id] = false;
}

Parser* Parameters::get_parser(string id)
{
  if (m_parsers.find(id) == m_parsers.end()) {
    cerr << "Parser not defined for option: " << id << endl;
    exit(-1);
  }
  Parser* parser = m_parsers[id];
  if (parser->dummy) {
    cerr << "cannot use dummy parser" << endl;
    exit(-1);
  }
  return parser;
}

string Parameters::get_value(string id)
{
  if (m_values.find(id) == m_values.end()) {
    cerr << "value for option " << id << " not set" << endl;
    exit(-1);
  }
  m_parsers[id]->used = true;

  vector<char*>& values = m_values[id];
  if (values.size() == 0) {
    cerr << "option without a value: " << id << endl;
    exit(-1);
  }

  string result = values[0];
  for (unsigned int i=1; i<values.size(); ++i)
    result += string(" ") + values[i];
  return (result);
}

bool Parameters::is_used(string id)
{
  return (m_values.find(id) != m_values.end());
}
