#!/bin/sh

set -e

case "${1:-}" in
    "webserver")
        exec /usr/bin/tini -- /usr/sbin/nginx -g "daemon off;"
        ;;
    "laravel")
        exec /usr/bin/tini -- /usr/local/sbin/php-fpm
        ;;
    "laravel-scheduler")
        exec /usr/bin/tini -- /usr/local/bin/php /usr/src/app/artisan schedule:work
        ;;
    "laravel-worker")
        exec /usr/bin/tini -- /usr/local/bin/php /usr/src/app/artisan queue:work
        ;;
    "/bin/sh" | "sh" | "/bin/bash" | "bash" )
        exec "$@"
        ;;
    *)
        echo "Usage: ${0} {webserver|laravel|laravel-scheduler|laravel-worker|bash|sh}" >&2
        exit 3
        ;;
esac