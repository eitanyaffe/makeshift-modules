library("inline")
myplugin = getPlugin("Rcpp")
myplugin$env$PKG_CXXFLAGS = "-Wall -Wno-write-strings -std=c++0x"
