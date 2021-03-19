#!/bin/sh

bundle check || bundle install
rm -f tmp/pids/server.pid
bin/rails server -b 0.0.0.0
