#!/bin/sh

set -e

bin/docker_gems
yarn install
cd example_engine
yarn install
cd ..

bin/vite dev
