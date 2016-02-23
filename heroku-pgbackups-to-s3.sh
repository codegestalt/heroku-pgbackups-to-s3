#!/bin/bash

# 0. Setup env
# ============

# 0.1 Setup variables
# -------------------
backup_date=$(date +%Y-%m-%d-%H-%M-%S)
backup_year=${backup_date:0:4}
backup_month=${backup_date:5:2}
backup_root_dir="tmp"
backup_dir="$backup_root_dir/pgbackups/$backup_date"

# 0.2 Load env configs
# --------------------
source .heroku_pgbackups_to_s3_env

# 1. Capture and download pg backups
# ==================================
re="^([^=[:space:]]+)[[:space:]]?.*"
heroku_apps_output=$(heroku apps)
(echo "$heroku_apps_output") | while read line
do
  [[ "$line" =~ $re ]] && app="${BASH_REMATCH[1]}"
  if [ -n "$app" ];
  then
    echo "[$app] Capturing a new backup..."
    heroku_backup_output=$(heroku pg:backups capture -a "$app")
    heroku_backup_id=$(echo $heroku_backup_output | egrep -o 'b[[:digit:]]{3}')
  fi
  if [ -n "$heroku_backup_id" ];
  then
    echo "[$app] Downloading backup $heroku_backup_id..."
    heroku_backup_url=$(heroku pg:backups public-url "$heroku_backup_id" -q -a "$app")
    curl --create-dirs -o "$backup_dir"/"$app"-"$backup_date".dump "$heroku_backup_url"
    echo "[$app] Deleting backup $heroku_backup_id on Heroku..."
    heroku pg:backups delete "$heroku_backup_id" -a "$app" --confirm "$app"
  fi
  unset app
  unset heroku_backup_id
done

# 2. Compress and encrypt backups
# ===============================
tar -zcf "$backup_dir".tar.gz --directory="$backup_dir" .
gpg --output "$backup_dir".tar.gz.gpg --encrypt --recipient "$encryption_key" "$backup_dir".tar.gz

# 3. Upload backup to s3
# ======================
s3cmd put "$backup_dir".tar.gz.gpg s3://"$s3_bucket"/"$backup_year"/"$backup_month"/"$backup_date".tar.gz.gpg

# 4. Delete local backups
# =======================
rm -rf "$backup_dir"
rm "$backup_dir".tar.gz
rm "$backup_dir".tar.gz.gpg
