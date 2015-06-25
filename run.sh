#!/bin/bash
echo  $DATABASE_PORT > /tmp/cs.txt
sed -i -e 's/tcp/postgres/g' /tmp/cs.txt
export DATABASE_URL=$(cat /tmp/cs.txt)
cd /tmp/pushy
bundle exec rackup config.ru -p 3000
