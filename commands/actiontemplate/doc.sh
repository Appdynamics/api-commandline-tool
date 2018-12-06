#!/bin/bash
doc actiontemplate << EOF
These commands allow you to import and export email/http action templates.
A common use pattern is exporting the commands from one controller and importing
into another. Please note that the export is a list of templates and the import
expects a single object, so you need to split the json inbetween.
EOF
