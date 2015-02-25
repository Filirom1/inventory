#!/bin/bash

cd /app
bundle exec unicorn -c /app/docker/unicorn/unicorn.rb -E production -D
/usr/sbin/nginx
