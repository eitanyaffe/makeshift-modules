#include <cstring>
#include "Variation.h"
#include "util.h"
using namespace std;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Variation
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Variation::Variation() : m_type_bitmap(0), m_sub_nt(0), m_insert_seq(), m_delete_length(0) {};

Variation::Variation(string str) : Variation()
{
  from_string(str);
}

string Variation::type_to_string(const VariType type)
{
  switch(type) {
  case vtNone: return "none";
  case vtSubstitute: return "sub";
  case vtDelete: return "del";
  case vtInsert: return "ins";
  case vtDangleLeft: return "dangleLeft";
  case vtDangleRight: return "dangleRight";
  default: mexit("invalid type: vtCount");
  }
  return "";
}

VariType Variation::string_to_type(const string str) {
  if (str == "none")
    return vtNone;
  if (str == "sub")
    return vtSubstitute;
  if (str == "del")
    return vtDelete;
  if (str == "ins")
    return vtInsert;
  if (str == "dangleLeft")
    return vtDangleLeft;
  if (str == "dangleRight")
    return vtDangleRight;
  mexit("unkown variation type: %s", str.c_str());
  return vtNone;
}

void Variation::add_sub(string nt)
{
  massert(nt.size() == 1, "expecting string of length 1, found: %s", nt.c_str());
  set_type(vtSubstitute);
  m_sub_nt = nt[0];
}

void Variation::add_delete(int length)
{
  set_type(vtDelete);
  m_delete_length = length;
}

void Variation::add_insert(string seq)
{
  set_type(vtInsert);
  m_insert_seq = seq;
}

void Variation::add_dangle_left()
{
  set_type(vtDangleLeft);
}

void Variation::add_dangle_right()
{
  set_type(vtDangleRight);
}

string Variation::to_string()
{
  vector<VariType> types;
  get_types(types);
  if (types.size() == 0)
    return "none";
  
  string result;
  for (unsigned int i=0; i<types.size(); ++i) {
    VariType type = types[i];
    string type_result = type_to_string(type);
    switch(type) {
    case vtSubstitute:
      type_result += string("_") + m_sub_nt;
      break;
    case vtInsert:
      type_result += string("_") + m_insert_seq;
      break;
    case vtDelete:
      type_result += string("_") + std::to_string(m_delete_length);
    break;
    case vtNone:
    case vtDangleLeft:
    case vtDangleRight:
      break;
    default: mexit("invalid type: vtCount");
    }
    if (i == 0)
      result = type_result;
    else
      result += ":" + type_result;
  }
  return result;
}

void Variation::from_string(const string str)
{
  vector<string> fields;
  split_string(str, fields, ':');

  for (unsigned int i=0; i<fields.size(); ++i) {
    string field = fields[i];
    VariType type;
    string data_str;
    std::size_t index = field.find("_");
    if (index == string::npos) {
      type = string_to_type(field);
    } else {
      type = string_to_type(field.substr(0, index));
      data_str = field.substr(index+1);
    }
    set_type(type);
    switch(type) {
    case vtSubstitute:
      massert(data_str.length() == 1, "expecting one character, found %s", data_str.c_str());
      m_sub_nt = data_str[0];
      break;
    case vtInsert:
      m_insert_seq = data_str;
      break;
    case vtDelete:
      m_delete_length = safe_string_to_int(data_str, "delete_length");
      break;
    break;
    case vtNone:
    case vtDangleLeft:
    case vtDangleRight:
      break;
    default: mexit("invalid type: vtCount");
    }
  }
}

void Variation::set_type(VariType type)
{
  if (type != vtNone) {
    int offset = (int)type;
    m_type_bitmap |= 1<<offset;
  }
}

void Variation::get_types(vector<VariType>& types)
{
  for (int i=0; i<vtCount; ++i)
    if (m_type_bitmap & 1<<i)
      types.push_back((VariType)i);
}

void Variation::save(ofstream& out)
{
  // write m_type_bitmap
  out.write(reinterpret_cast<const char*>(&m_type_bitmap), sizeof(int));

  // write m_sub_nt
  out.write(reinterpret_cast<const char*>(&m_sub_nt), sizeof(char));

  // write m_delete_length
  out.write(reinterpret_cast<const char*>(&m_delete_length), sizeof(int));

  // write m_insert_seq length
  size_t size_seq = m_insert_seq.size();
  out.write(reinterpret_cast<const char*>(&size_seq), sizeof(size_seq));

  // write m_insert_seq data
  out.write(m_insert_seq.c_str(), sizeof(char)*m_insert_seq.size());
}

void Variation::load(ifstream& in)
{
  // read m_type_bitmap
  in.read(reinterpret_cast<char*>(&m_type_bitmap), sizeof(int));

  // read m_sub_nt
  in.read(reinterpret_cast<char*>(&m_sub_nt), sizeof(char));

  // read m_delete_length
  in.read(reinterpret_cast<char*>(&m_delete_length), sizeof(int));

  // read m_insert_seq length
  size_t size_seq;
  in.read(reinterpret_cast<char*>(&size_seq), sizeof(size_seq));

  // read m_insert_seq data
  m_insert_seq.resize(size_seq);
  in.read(&m_insert_seq[0], sizeof(char)*m_insert_seq.size());

}

bool operator<(const Variation& lhs, const Variation& rhs)
{
  if (lhs.m_type_bitmap != rhs.m_type_bitmap)
    return lhs.m_type_bitmap < rhs.m_type_bitmap;
  if (lhs.m_sub_nt != rhs.m_sub_nt)
    return lhs.m_sub_nt < rhs.m_sub_nt;
  if (lhs.m_insert_seq != rhs.m_insert_seq)
    return lhs.m_insert_seq < rhs.m_insert_seq;
  return lhs.m_delete_length < rhs.m_delete_length;
}

bool operator==(const Variation& lhs, const Variation& rhs)
{
  return (lhs.m_type_bitmap == rhs.m_type_bitmap)
    && (lhs.m_sub_nt == rhs.m_sub_nt)
    && (lhs.m_delete_length == rhs.m_delete_length)
    && (lhs.m_insert_seq == rhs.m_insert_seq);
}
