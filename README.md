# Heroku PG:Backups to S3

This is a quick and dirty (a.k.a. ghetto coding) backup script for
creating postgresql backups on Heroku and archiving them on S3.

## Why does this exist?

We have a lot of applications with only 1 week database backup retention time.
If something happens to a database (hacked or whatever) and we don't notice it,
that data is gone for good.

This script tries to prevent this from happening by creating backups on Heroku and
storing them on S3.

## What does it do?

1. Captures and downloads a new pg backup from heroku to localhost for every app you've access to
2. Compress and encrypt all downloaded backups
3. Uploads the encrypted backups to s3
4. Cleans up all the downloaded backups from localhost

## Dependencies

- [Heroku Toolbelt](https://toolbelt.heroku.com) for accessing your Heroku backups
- [gpg](https://www.gnupg.org) for encryption
- [s3cmd](https://github.com/s3tools/s3cmd) for archiving to S3

## Install

Coming soon.

## Todo

- Push a notification to a Slack channel when backup is completed or failed e.g. `<Backup Bot> PG:Backup Status (15 successful, 2 failed [app1, app2])`
- Logfile which logs activities
