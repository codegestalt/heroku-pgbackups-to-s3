#!/bin/bash

# Creating directory
echo "Creating directory: /etc/cron.custom"
mkdir -p /etc/cron.custom

# Downloading keep-alive.sh and save it into /etc/cron.custom directory
echo "Downloading file 'heroku-pgbackups-to-s3.sh' into /etc/cron.custom"
curl --silent --output /etc/cron.custom/heroku-pgbackups-to-s3.sh https://raw.githubusercontent.com/codegestalt/heroku-pgbackups-to-s3/master/heroku-pgbackups-to-s3.sh

# Add cronjob to the crontab file
echo "Adding cronjob to /etc/crontab"
curl --silent https://raw.githubusercontent.com/codegestalt/heroku-pgbackups-to-s3/master/crontab >> /etc/crontab

# Set permissions
echo "Setting permissions for /etc/cron.custom/heroku-pgbackups-to-s3.sh"
chmod 755 /etc/cron.custom/heroku-pgbackups-to-s3.sh

echo
echo "Done"
