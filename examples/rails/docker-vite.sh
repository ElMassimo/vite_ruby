#!/bin/sh

set -e

bin/docker_gems
pnpm install

bin/vite dev
