#include "BinMatrix.h"

BinMatrix::BinMatrix(vector< BinSegment >& segs, vector<int>& ind, int nlibs, int sample_size)
  : m_segs(segs), m_ind(ind), m_nlibs(nlibs), m_sample_size(sample_size), m_chi_squared(nlibs-1)
{
  m_nsegs = m_ind.size();
  m_dist.resize(m_nsegs);
  for (int i=0; i<m_nsegs; ++i)
    m_dist[i].resize(m_nsegs);
};

double BinMatrix::get_chi_value(vector < double >& c1, vector < double >& c2)
{
  massert(c1.size() == c2.size(), "vector length not equal");
  int n = c1.size();

  // get totals
  double tot1 = 0;
  double tot2 = 0;
  for (int i=0; i<n; ++i) {
    tot1 += c1[i];
    tot2 += c2[i];
  }
  double tot = tot1 + tot2;
  double f1 = tot1/tot;
  double f2 = tot2/tot;

  // get lib freq
  vector <double> freq_lib(n);
  for (int i=0; i<n; ++i)
    freq_lib[i] = (c1[i] + c2[i]) / tot;

  double result = 0;
  for (int i=0; i<n; ++i) {
    double exp1 = tot * f1 * freq_lib[i];
    double exp2 = tot * f2 * freq_lib[i];
    result += ((c1[i] - exp1) * (c1[i] - exp1)) / exp1;
    result += ((c2[i] - exp2) * (c2[i] - exp2)) / exp2;
  }
  return result;
}

double BinMatrix::get_p_value(vector < double >& c1, vector < double >& c2)
{
  double stat = get_chi_value(c1, c2);
  // cout << "chi=" << stat << endl;
  return (1 - cdf(m_chi_squared, stat));
}

double BinMatrix::compute_seg_chi_distance(BinSegment& seg1, BinSegment& seg2)
{
  double sum = 0;
  for (int i=0; i<m_sample_size; ++i) {
    int coord1 = get_random_coord(seg1);
    int coord2 = get_random_coord(seg2);
    massert(coord1 < (int)seg1.counts.size() && coord2 < (int)seg2.counts.size(), "coord out of range");
    double p_value = get_p_value(seg1.counts[coord1], seg2.counts[coord2]);
    sum += log(p_value);

    // cout << "c1=c(";
    // for (int j=0; j<m_nlibs; ++j)
    //   cout << seg1.counts[coord1][j] << (j == m_nlibs-1 ? ")" : ", ");
    // cout << endl;

    // cout << "c2=c(";
    // for (int j=0; j<m_nlibs; ++j)
    //   cout << seg2.counts[coord2][j] << (j == m_nlibs-1 ? ")" : ", ");
    // cout << endl;

    // cout << "p=" << p_value << endl;
  }
  return (-2 * sum);
}

int BinMatrix::get_random_coord(BinSegment& seg)
{
  return (rand() % (seg.end-seg.start));
}

void BinMatrix::init_matrix(int index, int from_ind, int to_ind)
{
  for (int i1=from_ind; i1<to_ind; ++i1) {
    for (int i2=0; i2<m_nsegs; ++i2) {
      massert(i1 >= 0 && i1 < (int)m_ind.size() && i2 >= 0 && i2 < (int)m_ind.size(), "index out of range");
      massert(m_ind[i1] >= 0 && m_ind[i1] < (int)m_segs.size() && m_ind[i2] >= 0 && m_ind[i2] < (int)m_segs.size(), "segment index out of range");
      massert(i1 < (int)m_dist.size() && i2 < (int)m_dist[i1].size(), "matrix out of range");
      double chi_value = compute_seg_chi_distance(m_segs[m_ind[i1]], m_segs[m_ind[i2]]);
      m_dist[i1][i2] = chi_value;
      // double p_value = 1 - cdf(fisher_chi_squared, chi_value);
      // double ml_p_value = -log10(p_value);
      // cout << "1 chi[" << i1 << "][" << i2 << "]=" << chi_value << endl;
      // cout << "D[" << i1 << "][" << i2 << "]=" << ml_p_value << endl;
      // m_dist[i1][i2] = ml_p_value;
    }
  }
}

void global_init_matrix(BinMatrix* bin_matrix, int index, int from_ind, int to_ind)
{
  bin_matrix->init_matrix(index, from_ind, to_ind);
}

void BinMatrix::init_matrix(int thread_count)
{
  if (thread_count > m_nsegs)
    thread_count = m_nsegs;

  int step = floor(m_nsegs / thread_count);
  cout << "number of segments: " << m_nsegs << endl;
  cout << "number of threads: " << thread_count << endl;

  vector<thread> threads;
  for (int i=0; i<thread_count; ++i) {
    int from_ind = i * step;
    int to_ind = (i < (thread_count-1)) ? (i+1) * step : m_nsegs;
    // cout << "init matrix, index=" << i << ", from_index=" << from_ind << ", to_index=" << to_ind << endl;
    threads.push_back(thread(global_init_matrix, this, i, from_ind, to_ind));
  }

  cout << "waiting for all threads to finish\n";
  for (auto& th : threads) th.join();
}

int BinMatrix::cluster_segments(vector<int>& bins, double p_threshold)
{
  chi_squared chi_squared(2*m_sample_size);
  double chi_threshold = quantile(chi_squared, 1-p_threshold);
  cout << "chi_threshold=" << chi_threshold << endl;
  bins.resize(m_nsegs);
  using namespace boost;
  {
    typedef adjacency_list <vecS, vecS, undirectedS> Graph;
    Graph G;

    for (int i=0; i<m_nsegs; ++i)
      add_vertex(G);

    int edge_count = 0;
    for (int i1=0; i1<m_nsegs; ++i1) {
      for (int i2=i1; i2<m_nsegs; ++i2) {
	double chi = m_dist[i1][i2];
	// double P = (1 - cdf(chi_squared, chi));
	// cout << "X[" << i1 << "][" << i2 << "]=" << chi << " : " << P << " : " << (chi <= chi_threshold ? "T" : "F") << endl;
	if (chi <= chi_threshold) {
	  edge_count++;
	  add_edge(i1, i2, G);
	}
      }
    }
    cout << "number of segments: " << num_vertices(G) << endl;
    cout << "number of segment-segment edges: " << num_edges(G) << endl;
    massert(edge_count > 0, "no pairs of segments were associated, consider reducing p threshold");
    int num = connected_components(G, &bins[0]);

    // for (int i=0; i<m_nsegs; ++i)
    //   cout << i << " : " << bins[i] << endl;
    return num;
  }
}
