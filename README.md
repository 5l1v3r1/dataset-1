
# dataset   [![DOI](https://data.caltech.edu/badge/79394591.svg)](https://data.caltech.edu/badge/latestdoi/79394591)

_dataset_ is a command line tool, go package and python package you can use to manage 
[JSON](https://en.wikipedia.org/wiki/JSON) objects stored on local disc or in the cloud 
(e.g. Amazon S3 and Google Cloud Storage). It stores the JSON objects in collections as plain 
UTF-8 text. This means the objects can be accessed with common Unix text processing tools as well as
most programming languages with text processing support. The [dataset](docs/dataset.html)
command line tool supports common data manage operations such as initialization of collections,
creation, reading, updating and delete JSON objects in the collection. Some of its enhanced
features include the ability to import and export JSON object to and from CSV files,
Excel Workbook sheets and Google Sheets. It supports key filter and sorting as well as
mapping collection content into [grids](docs/grids.html) and data [frames](docs/frames.html).
It even includes an experimental search feature by the integrating [Blevesearch](https://blevesearch.com)
indexing and search engine library developed by [CouchDB]().

See [getting-started-with-datataset.md](how-to/getting-started-with-dataset.html) for a tour of functionality.


## Origin story

The inspiration for creating _dataset_ was the desire to process metadata as JSON object collections 
using simple Unix shell utilities and data pipelines. The core use case evolved at [Caltech Library](https://library.caltech.edu)
working with various repository systems' API (e.g. [EPrints](https://en.wikipedia.org/wiki/EPrints) and
and [Invenio](https://en.wikipedia.org/wiki/Invenio)). It has allowed
the library to easily build aggregated views of hetrogeious content (see https://feeds.library.caltech.edu)
as well as facilitate ad-hoc analysis and data enhancement for a number of internal library projects.


## Design choices

_dataset_ isn't a database or repository system. It is intended to be simplier and easier to use with
minimal setup (e.g. `dataset init mycollection.ds` would create a new collection).  It built around a few simple
abstractions (e.g. dataset stores JSON objects in collections, collections are a folder containing a JSON
file called collections.json and buckets containing the JSON objects and any attachments, the collections.json
file describes the mapping of keys to buckets).  It takes minimal system resources
and keeps all content, except JSON object attachments, in plain UTF-8 text (attachments are kept in tar files).
In the typcial library processing pattern of "harvest", "transform" and "redeploy" dataset provides a convienent 
way to store intermediate results in a data processing pipeline. 

Care has been taken to keep _dataset_ simple enough and light weight enough that it will run on a machine
as small as a Raspberry Pi while being equally comformatable on a more resource rich server or desktop
environment.

Currently dataset provides a command line tool called `dataset` as well as a Go package and Python 3.6 Package.
It can be integrated into other programming languages that provide support for C shared libraries. _dataset_
itself is written in [Go](https://golang.org).

## Features

[dataset](docs/dataest) supports 

- Basic storage actions ([create](docs/create.html), [read](docs/read.html), [update](docs/update.html) and [delete](docs/delete.html))
- listing of collection [keys](docs/keys.html) (including filtering and sorting)
- import/export  of [CSV](how-to/import-csv-rows-as-json-documents.html) files, Excel Workbook sheets and [Google Sheets](how-to/gsheet-integration.html)
- An experimental full text [search](how-to/searchable-datasets.html) interface based on [Blevesearch](https://blevesearch.com)
- The ability to reshape data by performing simple object [joins](docs/join.html)
- The ability to create data [grids](docs/grid.html) and [frames](docs/frame.html) from collections based 
  on keys lists and [dot paths](docs/dotpath.html) into the JSON objects stored

You can work with dataset collections via the [command line tool](docs/dataset.html), via Go using the 
[dataset package](https://godoc.org/github.com/caltechlibrary/dataset) or in
Python 3.6 using a python package.  _dataset_ is useful for general data science applications which 
need intermediate JSON object storage but not a full blown database.


### Limitations of _dataset_

_dataset_ has many limitations, some are listed below

+ it is not a multi-process, multi-user data store (it's just files on disc without any locking)
+ it is not a repository management system
+ it is not a general purpose multiuser database system
+ it does not supply version control on collections or objects (though integrating it with git 
  or mercurial is trivial)

## Example

Below is a simple example of shell based interactoin with dataset colletions using the command line
dataset tool.

```shell
    # Create a collection "mystuff.ds", the ".ds" lets the bin/dataset command know that's the collection to use. 
    bin/dataset mystuff.ds init
    # if successful then you should see an OK otherwise an error message

    # Create a JSON document 
    bin/dataset mystuff.ds create freda '{"name":"freda","email":"freda@inverness.example.org"}'
    # If successful then you should see an OK otherwise an error message

    # Read a JSON document
    bin/dataset mystuff.ds read freda
    
    # Path to JSON document
    bin/dataset mystuff.ds path freda

    # Update a JSON document
    bin/dataset mystuff.ds update freda '{"name":"freda","email":"freda@zbs.example.org", "count": 2}'
    # If successful then you should see an OK or an error message

    # List the keys in the collection
    bin/dataset mystuff.ds keys

    # Get keys filtered for the name "freda"
    bin/dataset mystuff.ds keys '(eq .name "freda")'

    # Join freda-profile.json with "freda" adding unique key/value pairs
    bin/dataset mystuff.ds join append freda freda-profile.json

    # Join freda-profile.json overwriting in commont key/values adding unique key/value pairs
    # from freda-profile.json
    bin/dataset mystuff.ds join overwrite freda freda-profile.json

    # Delete a JSON document
    bin/dataset mystuff.ds delete freda

    # Import data from a CSV file using column 1 as key
    bin/dataset -quiet -nl=false mystuff.ds import-csv my-data.csv 1

    # To remove the collection just use the Unix shell command
    rm -fR mystuff.ds
```

## Releases

Compiled versions are provided for Linux (amd64), Mac OS X (amd64), Windows 10 (amd64) and Raspbian (ARM7). 
See https://github.com/caltechlibrary/dataset/releases.

