<?php
/**
 * Consulta o PostgreSQL para distinguir banco vazio, Moodle instalado
 * e instalacao parcial. Exit status: 0=instalado, 10=vazio,
 * 20=parcial/inconsistente, 30=erro de conexao/consulta.
 * Todas as credenciais sao fixas EXCLUSIVAMENTE para laboratorio local.
 */
$db = @pg_connect('host=db port=5432 dbname=moodle user=moodle password=MoodleDB@12345 connect_timeout=5');
if (!$db) {
    fwrite(STDERR, "Nao foi possivel conectar ao PostgreSQL.\n");
    exit(30);
}
$query = @pg_query($db, "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'mdl_%'");
if (!$query) {
    fwrite(STDERR, "Falha ao consultar as tabelas Moodle.\n");
    exit(30);
}
$tables = (int)pg_fetch_result($query, 0, 0);
if ($tables === 0) {
    exit(10);
}
$version = @pg_query($db, "SELECT value FROM mdl_config WHERE name = 'version' LIMIT 1");
if ($version && pg_num_rows($version) === 1) {
    exit(0);
}
fwrite(STDERR, "Banco contem tabelas Moodle mas nao possui versao completa.\n");
exit(20);
