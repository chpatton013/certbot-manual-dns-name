#!/usr/bin/env bash
set -euo pipefail

# Check for all required variables.
[ ! -z "$CERTBOT_DOMAIN" ]
[ ! -z "$CERTBOT_VALIDATION" ]
[ ! -z "$NAME_DNS_USERNAME" ]
[ ! -z "$NAME_DNS_API_TOKEN" ]

domain="$CERTBOT_DOMAIN"
secret="$CERTBOT_VALIDATION"
username="$NAME_DNS_USERNAME"
api_token="$NAME_DNS_API_TOKEN"
propagation_time="${NAME_DNS_PROPAGATION_TIME:-604800}" # Default 1 week
debug="${NAME_DNS_DEBUG:-}"

host=_acme-challenge

function sleep_until() {
  local deadline now
  deadline="$1"
  now="$(date +%s)"
  readonly deadline now

  sleep $((deadline - now))
}

function dig_record() {
  dig TXT "$host.$domain" | grep --quiet "$secret"
}

function check_record() {
  local deadline
  deadline="$1"
  readonly deadline

  sleep_until "$deadline"

  echo -n $deadline: Checking for record... >&2
  if dig_record; then
    echo Record found! >&2
    exit 0
  fi
  echo Record not found >&2
}

cat >&2 <<EOF
Certbot Manual Name.com Auth Hook
  CERTBOT_DOMAIN: '$domain'
  CERTBOT_VALIDATION: '$secret'
  NAME_DNS_USERNAME: '$username'
  NAME_DNS_API_TOKEN: '$api_token'
  NAME_DNS_PROPAGATION_TIME: '$propagation_time'
  NAME_DNS_DEBUG: '$debug'
EOF

if [ -z "$debug" ]; then
  endpoint="https://api.name.com/v4/domains/$domain/records"
else
  endpoint="https://api.dev.name.com/v4/domains/$domain/records"
fi

echo "Setting TXT Record for $host.$domain" >&2
curl \
    --silent \
    --user "$username:$api_token" \
    --request POST \
    --data "{\"host\":\"$host\",\"type\":\"TXT\",\"answer\":\"$secret\",\"ttl\":300}" \
    "$endpoint" \
  | python -c "import sys,json;print(json.load(sys.stdin)['id'])" \
  > "/tmp/certbot-dns-name.$domain"

echo Waiting at most $propagation_time seconds for DNS record propagation >&2
start_time="$(date +%s)"
end_time="$((start_time + propagation_time))"

# Use an exponential backoff while waiting for propagation for the first day.
# If we don't see our record in that time, fallback to once-per-day polling.
max_delay_increment=86400 # One day
delay_increment=1
deadline="$((start_time + delay_increment))"
check_record "$start_time"
while [ "$deadline" -lt "$end_time" ]; do
  check_record "$deadline"
  delay_increment=$((delay_increment * 2))
  if [ "$delay_increment" -gt "$max_delay_increment" ]; then
    delay_increment="$max_delay_increment"
  fi
  deadline=$((deadline + delay_increment))
done
check_record "$end_time"

echo DNS record did not propagate after $propagation_time seconds! >&2
exit 1
