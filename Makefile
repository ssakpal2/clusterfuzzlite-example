# Copyright 2017 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");

# Simple example of a build file that nicely integrates a fuzz target
# with the rest of the project.
#
# We use 'make' as the build system, but these ideas are applicable
# to any other build system

# By default, use our own standalone_fuzz_target_runner.
# This runner does no fuzzing, but simply executes the inputs
# provided via parameters.
# Run e.g. "make all LIB_FUZZING_ENGINE=/path/to/libFuzzer.a"
# to link the fuzzer(s) against a real fuzzing engine.
#
# OSS-Fuzz will define its own value for LIB_FUZZING_ENGINE.
LIB_FUZZING_ENGINE ?= standalone_fuzz_target_runner.o
$(info $$LIB_FUZZING_ENGINE is [${LIB_FUZZING_ENGINE}])

# Values for CC, CFLAGS, CXX, CXXFLAGS are provided by OSS-Fuzz.
# Outside of OSS-Fuzz use the ones you prefer or rely on the default values.
# Do not use the -fsanitize=* flags by default.
# OSS-Fuzz will use different -fsanitize=* flags for different builds (asan, ubsan, msan, ...)

# You may add extra compiler flags like this:
CXXFLAGS += -std=c++11

all: do_stuff_unittest do_stuff_fuzzer 

clean:
	rm -fv *.a *.o *unittest *_fuzzer *_seed_corpus.zip crash-* *.zip

# Continuos integration system should run "make clean && make check"
check: all
	./do_stuff_unittest
	./do_stuff_fuzzer do_stuff_test_data/*

# Unit tests
do_stuff_unittest: do_stuff_unittest.cpp my_api.a
	${CXX} ${CXXFLAGS} $< my_api.a -o $@

	
do_stuff_fuzzer: do_stuff_fuzzer.cpp my_api.a standalone_fuzz_target_runner.o
	${CXX} ${CXXFLAGS} $< my_api.a ${LIB_FUZZING_ENGINE} -o $@
	zip -q -r do_stuff_fuzzer_seed_corpus.zip do_stuff_test_data


# The library itself.
my_api.a: my_api.cpp my_api.h
	${CXX} ${CXXFLAGS} $^ -c
	ar ruv my_api.a my_api.o 

# The standalone fuzz target runner.
standalone_fuzz_target_runner.o: standalone_fuzz_target_runner.cpp
