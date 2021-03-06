/*
Package dataset provides a common approach for storing JSON object documents
on local disc. It is intended as a single user system for intermediate
processing of JSON content for analysis or batch processing.  It is not a
database management system (if you need a JSON database system I would
suggest looking at Couchdb, Mongo and Redis as a starting point).

The approach dataset takes is to store JSON documents in a pairtree structure under the collection folder. The keys are the JSON document names.
JSON documents (and possibly their attachments) are then stored based on
that assignment in the pairtree.  Conversely the collection.json document
is used to find and retrieve documents from the collection. The layout of
the metadata is as follows

+ Collection - a directory
	+ Collection/collection.json - metadata for retrieval
	+ Collection/[Pairtree] - holds individual JSON docs and attachments

A key feature of dataset is to be Posix shell friendly. This has
lead to storing the JSON documents in a directory structure that
standard Posix tooling can traverse. It has also mean that the JSON
documents themselves remain on "disc" as plain text. This has facilitated
integration with many other applications, programming langauages and
systems.

Attachments are non-JSON documents explicitly "attached" that share the
same pairtree path but are placed in a sub directory called "_". If the
document name is "Jane.Doe.json" and the attachment is photo.jpg
the JSON document is "pairtree/Ja/ne/.D/e./Jane.Doe.json" and the photo
is in "pairtree/Ja/ne/.D/e./_/photo.jpg".

Additional operations beside storing and reading JSON documents are also
supported. These include creating lists (arrays) of JSON documents from
a list of keys, listing keys in the collection, counting documents in the
collection, indexing and searching by indexes.

The primary use case driving the development of dataset is harvesting
API content for library systems (e.g. EPrints, Invenio, ArchivesSpace,
ORCID, CrossRef, OCLC). The harvesting needed to be done in such a
way as to leverage existing Posix tooling (e.g. grep, sed, etc) for
processing and analysis.

Initial use case:

Caltech Library has many repository, catelog and record management systems
(e.g. EPrints, Invenion, ArchivesSpace, Islandora, Invenio). It is common
practice to harvest data from these systems for analysis or processing.
Harvested records typically come in XML or JSON format. JSON has proven a
flexibly way for working with the data and in our more modern tools the
common format we use to move data around. We needed a way to standardize
how we stored these JSON records for intermediate processing to allow us
to use the growing ecosystem of JSON related tooling available under
Posix/Unix compatible systems.

*/
package dataset
