# Arquitetura do projeto

## Objetivo

Construir um pipeline pequeno, reproduzível e apresentável para portfólio, demonstrando consumo de API, persistência em banco, transformação SQL com dbt e visualização em Power BI.

## Fluxo

```text
World Bank API
    ↓ extração por indicador e país
src/extract_worldbank.py
    ↓ arquivos CSV locais
/data/raw
    ↓ carga em PostgreSQL
src/load_postgres.py
    ↓ schema raw
dbt Core
    ↓ staging → intermediate → marts
Power BI
```

## Camadas

### 1. Extração

Script: `src/extract_worldbank.py`

Responsabilidades:

- Montar chamadas para a World Bank Indicators API.
- Buscar os dados dos países e indicadores definidos em `src/config.py`.
- Tratar paginação.
- Normalizar JSON em formato tabular.
- Gravar CSVs em `data/raw`.

### 2. Carga

Script: `src/load_postgres.py`

Responsabilidades:

- Criar schemas e tabelas raw.
- Carregar CSVs para PostgreSQL.
- Preservar dados brutos em formato longo.

### 3. Transformação

Ferramenta: dbt Core.

Camadas:

- `staging`: limpeza leve, padronização de tipos e nomes.
- `intermediate`: pivot dos indicadores por país e ano.
- `marts`: dimensões, fato e tabela final para dashboard.

### 4. BI

Ferramenta: Power BI Desktop.

Tabela principal:

- `analytics.mart_country_health_efficiency`

## Decisões de escopo

- O projeto começa com 7 países para manter o escopo controlado.
- O período padrão é 2000 a 2024, mas pode ser alterado via CLI ou `.env`.
- O índice de eficiência é exploratório e serve para visualização, não para conclusão científica definitiva.

## Como explicar em entrevista

Este projeto simula um pipeline ELT real:

1. Extraio dados externos de uma API institucional.
2. Carrego a camada bruta em PostgreSQL.
3. Uso dbt para separar limpeza, transformação intermediária e mart analítico.
4. Aplico testes básicos de qualidade.
5. Entrego uma tabela final consumível por Power BI.
6. Documento limitações e decisões de modelagem.
