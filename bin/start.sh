#!/bin/sh

export LIBPROCESS_PORT="${PORT1}"
exec java $JVM_OPTS ${JAVA_OPTIONS} -jar /chronos/chronos.jar $@ --http_port $PORT0
