#!/bin/sh

set -e

bin/docker_gems
yarn install

bin/vite dev
