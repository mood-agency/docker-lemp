#!/usr/bin/env bash

set -e
error=false

export DB_HOST='db:3306'

for env in "DB_NAME" "DB_USER" "DB_PASSWORD" "WP_HOME" "WP_SITEURL"; do
  if [ -z "${!env}" ]; then
    error=true
    echo >&2 "error: $env required"
  fi
done

if ! [ -e "web/" -a -e "web/wp/wp-includes/version.php" ]; then
  error=true
  echo >&2 "WordPress not found in $(pwd)"
fi

if [ "$error" = true ]; then
  echo >&2 'errors occurred, exiting'
  exit 1
fi

UNIQUES=(
  AUTH_KEY
  SECURE_AUTH_KEY
  LOGGED_IN_KEY
  NONCE_KEY
  AUTH_SALT
  SECURE_AUTH_SALT
  LOGGED_IN_SALT
  NONCE_SALT
)

for unique in "${UNIQUES[@]}"; do
  unique_value=${!unique}
  if [ ! -z "$unique_value" ]; then
    eval "$unique_value=$(head -c1M /dev/urandom | sha1sum | cut -d' ' -f1)"
    export "$unique"
  fi
done

TERM=dumb php -- "$DB_HOST" "$DB_USER" "$DB_PASSWORD" "$DB_NAME" <<'EOPHP'
<?php
// database might not exist, so let's try connecting to it

$stderr = fopen('php://stderr', 'w');

list($host, $port) = explode(':', $argv[1], 2);

$maxTries = 10;
do {
	$mysql = new mysqli($host, $argv[2], $argv[3], '', (int)$port);
	if ($mysql->connect_error) {
		fwrite($stderr, "\n" . 'MySQL Connection Error: (' . $mysql->connect_errno . ') ' . $mysql->connect_error . "\n");
		--$maxTries;
		if ($maxTries <= 0) {
			exit(1);
		}
		sleep(3);
	}
} while ($mysql->connect_error);

$mysql->close();
EOPHP

# Install WP
if [ -z "$WP_INSTALL" ] || [ ! $(wp core is-installed) ]; then
  wp core install \
    --allow-root \
    --url="$WP_SITEURL" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL"
fi

exec "$@"
