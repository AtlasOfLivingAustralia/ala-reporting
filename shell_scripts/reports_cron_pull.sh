#!/bin/bash
cd /data/ala-reporting
git pull
cp /data/ala-reporting/reports/* /srv/shiny-server/apps/reports/

# copy data trends app: note- do a similar thing for other apps
cp -r /data/ala-reporting/apps/data_trends /srv/shiny-server/apps/
