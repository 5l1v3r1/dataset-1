
# Julia Module for Dataset

This directory includes code to build a Go C-Shared library to use from
Julia.  The makefile is used to compile the Go code to a C shared library
format needed to take advantage of Julia's `ccall` function.

## Compiling

You need to have Go v1.10 or better installed and Julia v0.4.x. 
If those are installed running _make_ in this directory should 
build the modules.  You can test the compiled version with _make test_ and 
build a release zip file with _make release_.

## Installation

The shared library (i.e. `libdataset.so`, `libdataset.dll` or `libdataset.dylib`) needs to be in the same directory as `dataset.jl` which in turn
needs to be in your Julia environment's search path.

## Usage

The file `dataset_test.jl` shows you how to use the basic functions
in Julia via importing the module `dataset`.

