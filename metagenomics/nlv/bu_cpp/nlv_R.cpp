#include <Rcpp.h>
#include "Variation.h"

using namespace Rcpp;
using namespace std;

// echo PKG_CPPFLAGS=-Wall -Wno-write-strings -std=c++0x > ~/.R/Makevars

/*
library("Rcpp")
Sys.setenv(PKG_CPPFLAGS="-Wall -Wno-write-strings -std=c++0x")
sourceCpp("nlv_R.cpp", verbose=T)
nlv = nlv_load("/relman03/work/users/eitany/tempo/subjects/AAB/assembly/megahit/nlv_v4/sets_N1/sets/s1/set.nlv")
df = data.frame(contig="s1", from=1, to=10)
nlv_query(nlv, df)
cc = nlv_contigs(nlv)
*/

// [[Rcpp::export]]
Rcpp::XPtr<VariationSet> nlv_load(string fn)
{
  VariationSet* varset = new VariationSet;
  varset->load(fn);
  Rcpp::XPtr<VariationSet> result(varset, true);
  return result;
}

// [[Rcpp::export]]
vector<string> nlv_contigs(Rcpp::XPtr<VariationSet> xptr)
{
  Rcpp::XPtr<VariationSet> varset(xptr);
  return varset->get_contigs();
}

// [[Rcpp::export]]
DataFrame nlv_query(Rcpp::XPtr<VariationSet> xptr, DataFrame df)
{
  Rcpp::XPtr<VariationSet> varset(xptr);
  StringVector contig_v = df["contig"];
  IntegerVector from_v = df["from"];
  IntegerVector to_v = df["to"];

  vector<string> contig_r;
  vector<int> coord_r;
  vector<string> var_r;
  vector<string> info_r;
  vector<int> count_r;
  vector<int> total_r;
  vector<int> cc_start_r;
  vector<int> cc_end_r;

  for (unsigned int i=0; i<contig_v.size(); ++i) {
    string contig = as<string>(contig_v[i]);
    int from = from_v[i] - 1;
    int to = to_v[i] - 1;
    varset->get_contig_data(contig, from, to, contig_r, coord_r, var_r, info_r, count_r, total_r, cc_start_r, cc_end_r);
  }

  // switch back to 1-based
  for (unsigned int i=0; i<coord_r.size(); ++i)
    coord_r[i]++;

  DataFrame result = DataFrame::create(
				       Named("contig") = contig_r,
				       Named("coord") = coord_r,
				       Named("var") = var_r,
				       Named("info") = info_r,
				       Named("count") = count_r,
				       Named("total") = total_r,
				       Named("cc_start") = cc_start_r,
				       Named("cc_end") = cc_end_r);

  return result;
}

/*
library("Rcpp")
Sys.setenv(PKG_CPPFLAGS="-Wall -Wno-write-strings -std=c++0x")
sourceCpp("nlv_R.cpp", verbose=T)
nlv = nlv_load("/relman03/work/users/eitany/tempo/subjects/AAB/assembly/megahit/nlv_v4/sets_N1/sets/s1/hosts.nlv")
df = data.frame(contig="s1", from=1, to=1000)
nlv_summary(nlv, df, 2, 0.8)
 */

// [[Rcpp::export]]
DataFrame nlv_summary(Rcpp::XPtr<VariationSet> xptr, DataFrame df, int min_cov, double max_seg_freq)
{
  Rcpp::XPtr<VariationSet> varset(xptr);
  StringVector contig_v = df["contig"];
  IntegerVector from_v = df["from"];
  IntegerVector to_v = df["to"];

  vector<string> contig_r;
  vector<int> from_r;
  vector<int> to_r;
  vector<int> seg_r;
  vector<int> cov_r;

  for (unsigned int i=0; i<contig_v.size(); ++i) {
    string contig = as<string>(contig_v[i]);
    int from = from_v[i] - 1;
    int to = to_v[i] - 1;
    int seg, cov;
    varset->get_summary(contig, from, to, min_cov, max_seg_freq, seg, cov);
    if (from == to)
      continue;
    contig_r.push_back(contig);
    from_r.push_back(from+1);
    to_r.push_back(to+1);
    seg_r.push_back(seg);
    cov_r.push_back(cov);
  }

  DataFrame result = DataFrame::create(
				       Named("contig") = contig_r,
				       Named("from") = from_r,
				       Named("to") = to_r,
				       Named("seg.count") = seg_r,
				       Named("xcov") = cov_r);
  return result;
}
