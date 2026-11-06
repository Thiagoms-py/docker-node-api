# Flags API com Docker

## Imagem no Docker Hub

[thiagoms02/flags-api](https://hub.docker.com/r/thiagoms02/flags-api) — amd64 e arm64, com SBOM e provenance. Tags `1.0.0` e `latest` no mesmo digest:

```text
sha256:08feb43e4198b2dab678acd56f59a85e5ff196303e5f058490f1ddd1753d422b
```

```sh
docker pull --platform linux/amd64 thiagoms02/flags-api:1.0.0
```

## Como rodar (desenvolvimento)

Na pasta `docker-node-api`, com Docker e Compose v2:

```sh
cp .env.example .env
docker compose up
```

Valores já preenchidos. API: http://localhost:3000; PostgreSQL: `db:5432` na rede Docker.

- Watch: `docker compose up --watch` (sync em src; rebuild em package.json).
- Adminer: `docker compose --profile tools up -d`; http://localhost:8081. Sistema PostgreSQL, servidor `db`, usuário/senha/banco conforme `.env`.

## Como rodar (produção)

```sh
docker compose --profile tools down
cp .env.example .env
docker compose -f compose.prod.yaml up -d --wait
```

API na mesma porta; app e db devem ficar healthy. Dados persistem em volume nomeado. `.env` não é versionado; credenciais de exemplo são locais. Em servidor real, forneça segredos próprios por um gerenciador de segredos.

## Segurança e supply chain

[Scout completo](reports/scout-cves.txt), 05/11/2026, por arquitetura: **0 CRITICAL, 18 HIGH, 19 MEDIUM, 39 LOW**. Não há CRITICAL sem correção. Proxy-addr 2.0.8 corrige CVE-2026-90711 somente na imagem de produção, sem alterar os manifestos originais.
