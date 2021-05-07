#!/bin/bash

cd /data/SoE2021/
git pull

cd /srv/shiny-server/apps/

Rscript /home/ste748/build_app.R &
sleep 15
kill %1
