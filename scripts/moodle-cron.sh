#!/usr/bin/env bash
# Cron oficial do Moodle a cada minuto, sem precisar configurar cron no host.
set -Eeuo pipefail
cd /var/www/html
printf '[moodle-cron] Cron iniciado; intervalo: 60 segundos.\n'
while :; do
    if ! runuser -u www-data -- php admin/cli/cron.php; then
        printf '[moodle-cron] Aviso: execucao do cron retornou erro; tentaremos novamente.\n' >&2
    fi
    sleep 60
done
