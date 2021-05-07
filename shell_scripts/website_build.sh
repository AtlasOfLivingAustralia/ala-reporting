#!/bin/bash

cd /data/science
git pull
cd analytics_site
Rscript build_site.R
rm -r /srv/shiny-server/site_libs/
cp docs/index.html /srv/shiny-server/
cp -r /data/science/analytics_site/docs/site_libs /srv/shiny-server/
