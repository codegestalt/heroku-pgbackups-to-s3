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

**1. Install dependencies (Ubuntu / Debian)**

```
wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh
aptitude install gnupg s3cmd
```

**2. Login with Heroku**

```
heroku login
```

**3. Configure gpg**

Create a gpg key if you haven't already:

```
gpg --gen-key # more about this [here](http://serverfault.com/a/489148)
# make sure to backup your passphrase and secret key. If not backed up or forgotten, you backups will be useless!
gpg --armor --output file-enc-privkey.asc --export-secret-keys 'File Encryption Key'
```

To import an existing public key do the following:

```
# Export it from where you created it
gpg --armor --output file-enc-pubkey.txt --export 'File Encryption Key'
# transfer it to your backup server
scp file-enc-pubkey.txt user@your-backup-server.com:~/
# go to your backup server and import the public key
gpg --import file-enc-pubkey.txt
```

**4. Configure s3cmd**

```
s3cmd --configure # add your AWS Access Key ID and Secret Access Key
```

**5. Install script**

```
wget -O- https://raw.github.com/codegestalt/heroku-pgbackups-to-s3/master/install.sh | sh
```

**6. Edit configuration**

Now the last thing you need to do is edit the configuration `~/.heroku_pgbackups_to_s3_env.example` according to your needs:

```
encryption_key="File Encryption Key" # your public gpg encryption key
s3_bucket="your-s3-bucket" # your s3 backup bucket
```

## Todo

- Push a notification to a Slack channel when backup is completed or failed e.g. `<Backup Bot> PG:Backup Status (15 successful, 2 failed [app1, app2])`
- Logfile which logs activities

## Contribute

As said on the top, this is a quick and dirty script.
If you want to improve it, feel free to do so.
