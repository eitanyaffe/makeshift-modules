#ifndef COV_H
#define COV_H

int construct_main(const char* name, int argc, char **argv);
int break_single_main(const char* name, int argc, char **argv);
int break_multi_main(const char* name, int argc, char **argv);
int bin_main(const char* name, int argc, char **argv);

#endif
