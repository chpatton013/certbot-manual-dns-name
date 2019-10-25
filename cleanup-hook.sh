#!/usr/bin/env bash
set -euo pipefail

# Check for all required variables.
[ ! -z "$CERTBOT_DOMAIN" ]
[ ! -z "$NAME_DNS_USERNAME" ]
[ ! -z "$NAME_DNS_API_TOKEN" ]

domain="$CERTBOT_DOMAIN"
username="$NAME_DNS_USERNAME"
api_token="$NAME_DNS_API_TOKEN"
debug="${NAME_DNS_DEBUG:-}"

cat >&2 <<EOF
Certbot Manual Name.com Cleanup Hook
  CERTBOT_DOMAIN: '$domain'
  NAME_DNS_USERNAME: '$username'
  NAME_DNS_API_TOKEN: '$api_token'
  NAME_DNS_DEBUG: '$debug'
EOF

record_id_file="/tmp/certbot-dns-name.$domain"
if [ ! -f "$record_id_file" ]; then
  exit
fi

record_id="$(cat "$record_id_file")"

echo "Deleting temporary file with TXT Record ID" >&2
rm --force "$record_id_file"

if [ -z "$record_id" ]; then
  exit
fi

if [ -z "$domain" ]; then
  endpoint="https://api.name.com/v4/domains/$domain/records/$record_id"
else
  endpoint="https://api.dev.name.com/v4/domains/$domain/records/$record_id"
fi

echo "Deleting TXT Record for _acme-challenge.$domain ($record_id)" >&2
curl --silent --user "$username:$api_token" --request DELETE "$endpoint"
