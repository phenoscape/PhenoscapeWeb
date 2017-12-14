# PhenoscapeWeb

This is the web application powering http://fish.phenoscape.org, the legacy Phenoscape KB for fishes. It runs on top of the OBD-based Phenoscape Knowledgebase (a triple store implemented as a relational SQL database).

The following components are related:
* Data services (for delivering data from the OBD database to the web frontend): https://github.com/phenoscape/PhenoscapeOBD-WS
* Data ingest (for ingesting data into the OBD databae): https://github.com/phenoscape/PhenoscapeDataLoader
* Ontology-Based Database (OBD) schema and API code: https://github.com/phenoscape/OBDAPI (migrated from [SVN repo](https://sourceforge.net/p/obo/svn/HEAD/tree/OBDAPI/))

_Note that the Fish KB is legacy, and the current incarnation of the KB (covering vertebrates, in contrast to teleost fish only) does not use this software._ 
