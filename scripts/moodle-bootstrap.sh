#!/usr/bin/env bash
# Todo o provisionamento acontece dentro do container.
# Ao usuario, basta executar: docker compose up -d
set -Eeuo pipefail

log() { printf '[moodle-setup] %s\n' "$*"; }
fatal() { printf '[moodle-setup] ERRO: %s\n' "$*" >&2; exit 1; }

cd /var/www/html
mkdir -p /var/www/moodledata
chown -R www-data:www-data /var/www/moodledata
chmod 0770 /var/www/moodledata

# O arquivo .gitkeep garante que o diretorio bind-mount ja vem no ZIP
# e que o proprietario da pasta corresponda ao usuario que o extraiu.
if [[ ! -f /var/www/html/public/index.php ]]; then
    extra="$(find /var/www/html -mindepth 1 -maxdepth 1 ! -name .gitkeep -print -quit)"
    [[ -z "$extra" ]] || fatal "A pasta ./moodle contem arquivos incompletos. Mova/limpe a pasta antes de iniciar."

    log 'Baixando codigo-fonte oficial: MOODLE_503_STABLE...'
    tempdir="$(mktemp -d)"
    trap 'rm -rf "$tempdir"' EXIT
    git clone --depth 1 --single-branch --branch MOODLE_503_STABLE \
        https://github.com/moodle/moodle.git "$tempdir/source"
    [[ -f "$tempdir/source/public/index.php" ]] || fatal 'Clone Moodle incompleto.'

    uid="$(stat -c '%u' /var/www/html)"
    gid="$(stat -c '%g' /var/www/html)"
    cp -a "$tempdir/source/." /var/www/html/
    rm -f /var/www/html/.gitkeep
    chown -R "$uid:$gid" /var/www/html
    log 'Codigo disponivel no host: ./moodle/'
    rm -rf "$tempdir"
    trap - EXIT
else
    log 'Codigo-fonte existente reutilizado (sem sobrescrever plugins).'
fi

[[ -f /var/www/html/admin/cli/install_database.php ]] || fatal 'Scripts de instalacao Moodle nao encontrados.'

if [[ ! -f /var/www/html/config.php ]]; then
    log 'Criando config.php para http://localhost:8080...'
    cat > /var/www/html/config.php <<'PHP'
<?php
// APENAS DESENVOLVIMENTO LOCAL: NAO USAR EM PRODUCAO.
unset($CFG);
global $CFG;
$CFG = new stdClass();
$CFG->dbtype    = 'pgsql';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'db';
$CFG->dbname    = 'moodle';
$CFG->dbuser    = 'moodle';
$CFG->dbpass    = 'MoodleDB@12345';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = [
    'dbpersist' => false,
    'dbport' => '5432',
    'dbsocket' => '',
];
$CFG->wwwroot = 'http://localhost:8080';
$CFG->dataroot = '/var/www/moodledata';
$CFG->admin = 'admin';
$CFG->directorypermissions = 02770;
$CFG->debug = E_ALL;
$CFG->debugdisplay = 1;
require_once(__DIR__ . '/public/lib/setup.php');
PHP
    chown "$(stat -c '%u' /var/www/html):$(stat -c '%g' /var/www/html)" /var/www/html/config.php
    chmod 0644 /var/www/html/config.php
fi

log 'Conferindo instalacao no PostgreSQL...'
if php /usr/local/bin/moodle-db-state.php; then
    log 'Banco ja instalado: nao sera recriado.'
else
    result="$?"
    case "$result" in
        10)
            log 'Banco vazio: iniciando instalacao Moodle automatica...'
            runuser -u www-data -- php -d memory_limit=512M /var/www/html/admin/cli/install_database.php \
                --lang=en \
                --adminuser=admin \
                --adminpass='AdminMoodle@12345' \
                --adminemail='admin@example.test' \
                --fullname='Moodle Local - Aula de TSI' \
                --shortname='Moodle TSI' \
                --agree-license
            php /usr/local/bin/moodle-db-state.php || fatal 'Instalacao terminou sem validar o banco.'
            log 'Moodle instalado com sucesso.'
            ;;
        20)
            fatal 'Banco parcialmente instalado. Para LABORATORIO: docker compose down -v, depois docker compose up -d.'
            ;;
        *)
            fatal 'Falha ao consultar o PostgreSQL. Consulte: docker compose logs db moodle'
            ;;
    esac
fi

log 'Iniciando Apache em http://localhost:8080'
# Preserva os ajustes de Apache e PHP feitos pelo entrypoint da imagem MoodleHQ.
exec moodle-docker-php-entrypoint apache2-foreground
