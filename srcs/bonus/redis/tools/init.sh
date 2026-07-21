#!/bin/bash

set -e

exec redis-server \
	--port $REDIS_PORT \
	--bind 0.0.0.0 \
	--protected-mode no \
	--maxmemory 128mb \
	--maxmemory-policy allkeys-lru
