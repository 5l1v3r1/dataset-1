
# libdataset.go

This is a C-shared library created to allow support of _dataset_ in other 
languages that support integration with the C via C ABI (e.g.  Python 3).

## Adding support for your favorate language of choice

Adding support for _dataset_ in your favorite language is usually a matter
of following the documentation for integrating an existing C shared library.
In Python 3 we have done this via the ctypes package. Adding support for
a language like Julia would be done via _ccall_ function and wrapping Julia
code. In Common Lisp you could do this via its packages for supporting C calls
and in languages like Octave, Matlab or R you'd probably need to write some small ammount
of wrapping C++ to get what you need.

Go is expected to support writing to Web Assembly in the future so a future option
would be to skip C and just compile to web assembly and run it from your language of
choice.


