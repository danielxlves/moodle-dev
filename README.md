
# Moodle 5.3 LTS com Docker Compose — Aula de TSI

Projeto para estudantes de **Tecnologia em Sistemas para Internet (TSI)** que querem executar o Moodle no próprio computador e conhecer seu código-fonte.

**Objetivo:** instalar o ambiente com um único comando, sem instalar PHP, Apache ou PostgreSQL separadamente.

> **Atenção:** este ambiente é apenas para estudo. As senhas são fixas e não devem ser usadas em produção nem expostas à internet.

## 1. O que preciso ter instalado?

- **Docker Desktop** (Windows/macOS) ou **Docker Engine + Compose** (Linux).
- Conexão com a internet na primeira execução.
- Porta **8080** disponível.

Não é necessário instalar PHP, PostgreSQL ou Git separadamente.

## 2. Como iniciar o Moodle?

Abra o terminal na pasta do projeto e execute:

```bash
docker compose up -d
```

Na primeira execução, o Docker prepara o ambiente, baixa o código oficial do Moodle, instala o banco e cria o usuário administrador.

Para acompanhar a instalação:

```bash
docker compose logs -f moodle
```

Depois que a instalação terminar, abra:

**http://localhost:8080**

## 3. Como entrar no Moodle?

O projeto cria automaticamente um usuário administrador.

| Campo | Valor |
|---|---|
| URL | http://localhost:8080 |
| Usuário | `admin` |
| Senha | `AdminMoodle@12345` |
| E-mail | `admin@example.test` |
| Perfil | Administrador |

Esses dados estão definidos no arquivo `scripts/moodle-bootstrap.sh`, pelos parâmetros `--adminuser`, `--adminpass` e `--adminemail`.

### E o usuário aluno?

O projeto ainda não cria um aluno automaticamente.

Para testar a experiência de estudante, entre com o administrador e acesse:

**Administração do site → Usuários → Contas → Adicionar um novo usuário.**

Crie um usuário com o nome de login `aluno`.

**Importante:** criar uma conta não matricula automaticamente o aluno em um curso.

## 4. Para que serve cada tecnologia?

| Tecnologia | Para que serve? |
|---|---|
| Moodle | Plataforma para cursos, atividades e alunos. |
| Docker | Executa aplicações em contêineres isolados. |
| Docker Compose | Inicia todos os serviços com um único comando. |
| PHP | Linguagem utilizada pelo Moodle. |
| Apache | Servidor que disponibiliza o site no navegador. |
| PostgreSQL | Banco que armazena usuários, cursos e configurações. |
| Cron | Executa tarefas agendadas automaticamente. |

### Qual imagem Docker utilizamos?

Utilizamos a imagem PHP/Apache mantida pela MoodleHQ:

`moodlehq/moodle-php-apache:8.4`

A imagem fornece o ambiente necessário para executar o Moodle.

O código-fonte da plataforma é baixado separadamente do repositório oficial:

https://github.com/moodle/moodle

## 5. Estrutura do projeto

```text
moodle-compose-pronto/
├── compose.yaml
├── Dockerfile
├── .dockerignore
├── .gitignore
├── README.md
├── ROTEIRO-VIDEO.md
├── apache/
│   └── moodle-router.conf
├── php/
│   └── 99-moodle.ini
├── scripts/
│   ├── moodle-bootstrap.sh
│   ├── moodle-db-state.php
│   └── moodle-cron.sh
└── moodle/
    └── .gitkeep
```

### Para que serve cada arquivo?

| Arquivo | Função |
|---|---|
| `compose.yaml` | Configura e inicia Moodle, banco e Cron. |
| `Dockerfile` | Prepara a imagem do servidor Moodle. |
| `.dockerignore` | Ignora arquivos desnecessários durante o build. |
| `.gitignore` | Evita versionar arquivos gerados. |
| `apache/moodle-router.conf` | Configura o Apache. |
| `php/99-moodle.ini` | Configura memória, uploads e limites do PHP. |
| `moodle-bootstrap.sh` | Baixa, configura e instala o Moodle automaticamente. |
| `moodle-db-state.php` | Verifica se o banco já foi instalado. |
| `moodle-cron.sh` | Executa tarefas periódicas do Moodle. |
| `moodle/` | Armazena o código-fonte para desenvolvimento. |

**Os três arquivos principais são:**

- `compose.yaml`: organiza os serviços.
- `Dockerfile`: prepara o ambiente.
- `moodle-bootstrap.sh`: automatiza a instalação.

## 6. Como funciona a instalação?

Ao executar:

```bash
docker compose up -d
```

O ambiente realiza as seguintes etapas:

1. Inicia o banco PostgreSQL.
2. Baixa o código-fonte do Moodle.
3. Configura a conexão com o banco.
4. Instala o Moodle e cria o administrador.
5. Inicia o servidor Apache.
6. Executa as tarefas agendadas pelo Cron.

Após a inicialização, o Moodle estará disponível em:

http://localhost:8080

## 7. Onde ficam os dados?

| Dado | Local |
|---|---|
| Código-fonte e plugins | Pasta `./moodle/` |
| Banco de dados | Volume `postgres_data` |
| Arquivos enviados | Volume `moodledata` |

O código-fonte pode ser aberto no VS Code para estudar o funcionamento do Moodle ou desenvolver plugins.

Os volumes Docker preservam os dados mesmo quando os contêineres são parados e removidos normalmente.

## 8. Comandos úteis

### Iniciar o ambiente

```bash
docker compose up -d
```

### Verificar os contêineres

```bash
docker compose ps
```

### Visualizar os logs

```bash
docker compose logs -f moodle
```

### Visualizar as tarefas agendadas

```bash
docker compose logs -f cron
```

### Parar o ambiente

```bash
docker compose down
```

### Iniciar novamente

```bash
docker compose up -d
```

### Remover os volumes de dados

```bash
docker compose down -v
```

**Cuidado:** o último comando apaga os volumes do banco e dos arquivos enviados, mas mantém a pasta local `moodle/`.

## 9. Problemas comuns

**O Moodle não abriu?**

Verifique se os contêineres estão funcionando:

```bash
docker compose ps
docker compose logs -f moodle
```

**A porta 8080 está ocupada?**

Verifique se outro programa está usando essa porta. Alterar a porta pode exigir também ajustar a URL configurada no Moodle.

**O download falhou?**

Confirme que o computador possui acesso à internet.

**O Moodle está demorando?**

Na primeira execução, é necessário baixar as imagens, o código-fonte e instalar o banco. Acompanhe os logs.

## 10. Links oficiais

- Moodle: https://moodle.org/
- Código-fonte: https://github.com/moodle/moodle
- Imagem MoodleHQ: https://hub.docker.com/r/moodlehq/moodle-php-apache
- Docker Compose: https://docs.docker.com/compose/

---

## Resumo

Para iniciar:

```bash
docker compose up -d
```

Para acessar:

**http://localhost:8080**

- **Usuário:** `admin`
- **Senha:** `AdminMoodle@12345`

**Observação:** o projeto foi preparado para automatizar a instalação, mas ainda não foi validado de ponta a ponta em uma máquina com Docker.
