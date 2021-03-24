HFILES=Variation.h VariationSet.h nlv.h Params.h util.h

OBJ=Variation.o VariationSet.o Params.o \
nlv.o nlv_construct.o nlv_dump.o nlv_merge.o nlv_compare.o \
nlv_query.o nlv_query_nts.o nlv_divergence.o nlv_coverage.o nlv_segregation.o nlv_view.o \
nlv_restrict.o nlv_sites.o util.o

CFLAGS=-Wall -Wno-write-strings -std=c++0x
LDFLAGS=-Wall -Wno-write-strings -std=c++0x
CC=g++

%.o: %.cpp $(HFILES)
	$(CC) $(CFLAGS) -c -o $@ $<

nlv: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^
