#!/bin/bash

cd /data/science
git pull
cd analytics_site
Rscript build_site.R
cp docs/index.html /srv/shiny-server/
