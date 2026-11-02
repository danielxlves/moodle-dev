# Imagem PHP+Apache mantida pelo projeto Moodle (nao traz o codigo LMS embutido).
FROM moodlehq/moodle-php-apache:8.4

COPY php/99-moodle.ini /usr/local/etc/php/conf.d/99-moodle.ini
COPY apache/moodle-router.conf /etc/apache2/conf-enabled/99-moodle-router.conf
COPY scripts/moodle-bootstrap.sh /usr/local/bin/moodle-bootstrap.sh
COPY scripts/moodle-cron.sh /usr/local/bin/moodle-cron.sh
COPY scripts/moodle-db-state.php /usr/local/bin/moodle-db-state.php

RUN chmod 0755 /usr/local/bin/moodle-bootstrap.sh /usr/local/bin/moodle-cron.sh \
 && chmod 0644 /usr/local/bin/moodle-db-state.php \
 && a2enmod rewrite
