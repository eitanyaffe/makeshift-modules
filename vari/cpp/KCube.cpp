void KCube::read_fastq(string fn)
{
  cout << "reading table: " << fn << endl;
  ifstream in(fn.c_str());
  massert(in.is_open(), "could not open file %s", fn.c_str());
}

void KCube::read(string fn)
{
}

void KCube::write(string fn)
{
}

void KCube::add_count(Kmer kmer)
{
  m_counts[*kmer.m_data]++;
}

int KCube::get_count(Kmer kmer)
{
  return (m_counts[*kmer.m_data]);
}

