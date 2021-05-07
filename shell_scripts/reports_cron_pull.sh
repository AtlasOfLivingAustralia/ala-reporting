#!/bin/bash
cd /data/ala-reporting
git pull
cp /data/ala-reporting/reports/* /srv/shiny-server/apps/reports/
