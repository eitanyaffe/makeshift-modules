HFILES=Variation.h VariationSet.h nlv.h Params.h util.h

OBJS=Variation.o VariationSet.o Params.o \
nlv.o nlv_construct.o nlv_dump.o nlv_merge.o nlv_compare.o \
nlv_query.o nlv_divergence.o nlv_coverage.o nlv_segregation.o nlv_view.o \
nlv_restrict.o nlv_sites.o

TARGET=bin/nlv

%.o : %.cpp $(HFILES)
  xg++ -Wall -Wno-write-strings -std=c++0x -o $@ -c $<

$(TARGET): $(OBJS)
  xg++ -Wall -Wno-write-strings -std=c++0x -o $@ $^

all: $(TARGET)
