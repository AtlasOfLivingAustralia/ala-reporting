#!/bin/bash

cd /data/SoE2021/
git pull

cd /srv/shiny-server/apps/

Rscript /data/ala-reporting/shell_scripts/build_app.R &
sleep 15
kill %1
