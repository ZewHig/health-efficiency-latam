# Arquitetura do Projeto

Este documento descreve a arquitetura do projeto **Health Efficiency LATAM**, incluindo a origem dos dados, processo de extração, armazenamento, transformação e consumo analítico.

## Visão geral

O projeto segue uma arquitetura ELT:

```text
Extract
Load
Transform
```

Os dados são extraídos da World Bank API com Python, salvos em arquivos CSV, carregados em um banco PostgreSQL e transformados com dbt Core. A camada final é preparada para consumo analítico em Power BI.

## Fluxo da arquitetura

```text
World Bank API
    ↓
Python Extract
    ↓
CSV Raw Files
    ↓
PostgreSQL Docker
    ↓
Schema raw
    ↓
dbt staging
    ↓
dbt intermediate
    ↓
dbt analytics
    ↓
Power BI Dashboard
```

## Componentes da arquitetura

## 1. World Bank API

A World Bank API é a fonte dos dados utilizados no projeto.

Ela fornece dados em formato JSON para indicadores econômicos, sociais, demográficos e de saúde.

O projeto utiliza indicadores relacionados a:

- Gasto em saúde
- Infraestrutura de saúde
- Resultados de saúde pública
- População

## 2. Extração com Python

A extração é feita pelo script:

```text
src/extract_worldbank.py
```

Responsabilidades do script:

- Ler a lista de países configurada no projeto.
- Ler a lista de indicadores configurada no projeto.
- Fazer requisições para a World Bank API.
- Tratar paginação da API.
- Padronizar os dados retornados.
- Filtrar o período de interesse.
- Salvar arquivos CSV na pasta `data/raw`.

Arquivos gerados:

```text
data/raw/worldbank_health_indicators.csv
data/raw/worldbank_countries.csv
```

## 3. Arquivos CSV Raw

Os arquivos CSV funcionam como uma camada intermediária entre a API e o banco de dados.

Essa etapa ajuda a:

- Manter uma cópia local dos dados extraídos.
- Facilitar auditoria dos dados brutos.
- Permitir recarga no banco sem precisar consultar a API novamente.
- Separar extração e carga.

## 4. PostgreSQL com Docker

O PostgreSQL é executado em um container Docker.

Arquivo responsável:

```text
docker-compose.yml
```

Configuração local utilizada:

```text
Host: 127.0.0.1
Porta externa: 5433
Porta interna do container: 5432
Database: health_efficiency
User: postgres
Password: postgres
```

A porta externa `5433` foi utilizada para evitar conflito com instalações locais de PostgreSQL na porta padrão `5432`.

## 5. Carga no PostgreSQL

A carga dos dados é feita pelo script:

```text
src/load_postgres.py
```

Responsabilidades do script:

- Conectar ao PostgreSQL.
- Criar schemas e tabelas raw.
- Ler os arquivos CSV extraídos.
- Ajustar tipos de dados antes da carga.
- Carregar os dados no schema `raw`.

Principais tabelas carregadas:

```text
raw.raw_worldbank_indicators
raw.raw_worldbank_countries
```

## 6. Modelagem com dbt Core

O dbt Core é utilizado para transformar os dados dentro do PostgreSQL.

O projeto dbt está em:

```text
dbt/health_efficiency/
```

O dbt organiza as transformações em camadas:

```text
staging
intermediate
marts
```

## Camadas dbt

### Staging

A camada staging padroniza os dados brutos.

Responsabilidades:

- Renomear campos.
- Padronizar tipos.
- Remover inconsistências básicas.
- Preparar os dados para transformações posteriores.

Principais modelos:

```text
staging.stg_worldbank_health
staging.stg_worldbank_countries
```

### Intermediate

A camada intermediate reorganiza os indicadores em formato analítico.

Responsabilidades:

- Transformar indicadores em colunas.
- Criar uma linha por país e ano.
- Preparar a base para a mart final.

Principal modelo:

```text
intermediate.int_health_indicators_pivoted
```

### Analytics / Marts

A camada analytics contém os modelos finais de consumo.

Responsabilidades:

- Criar dimensões.
- Criar tabela fato.
- Criar mart analítica final.
- Calcular métricas derivadas.
- Preparar os dados para Power BI.

Principais modelos:

```text
analytics.dim_country
analytics.dim_indicator
analytics.fct_health_indicators
analytics.mart_country_health_efficiency
```

## 7. Mart analítica final

A principal tabela analítica do projeto é:

```text
analytics.mart_country_health_efficiency
```

Ela contém uma linha por país e ano.

Exemplo de granularidade:

```text
Brazil - 2000
Brazil - 2001
Brazil - 2002
...
Chile - 2023
Uruguay - 2024
```

A mart contém métricas como:

- Gasto em saúde per capita
- Gasto em saúde como percentual do PIB
- Leitos hospitalares por 1.000 pessoas
- Médicos por 1.000 pessoas
- Expectativa de vida
- Mortalidade infantil
- Mortalidade prematura por doenças crônicas
- População total
- População em milhões
- Gasto total estimado em saúde
- Índice exploratório de eficiência

## 8. Power BI

O Power BI será utilizado para construir o dashboard final.

Tabelas principais para consumo:

```text
analytics.mart_country_health_efficiency
analytics.fct_health_indicators
analytics.dim_country
analytics.dim_indicator
```

A tabela `mart_country_health_efficiency` será usada para as principais análises comparativas.

A tabela `fct_health_indicators` pode ser usada para visuais mais dinâmicos por indicador.

## Modelo lógico simplificado

```text
dim_country
    ↓
fct_health_indicators
    ↑
dim_indicator

mart_country_health_efficiency
```

A mart final é uma tabela analítica já consolidada, criada para facilitar o consumo no Power BI.

## Granularidade dos dados

### Raw

Granularidade:

```text
país + ano + indicador
```

Exemplo:

```text
Brazil | 2023 | Life expectancy at birth | 75.85
Brazil | 2023 | Population, total | 211140729
Brazil | 2023 | Current health expenditure per capita | 1009.84
```

### Mart final

Granularidade:

```text
país + ano
```

Exemplo:

```text
Brazil | 2023 | health_exp_pc_usd | life_expectancy_years | population_total
```

## Volume esperado

Com a configuração atual:

```text
7 países
8 indicadores
25 anos
```

Volume esperado:

```text
raw.raw_worldbank_indicators: 1.400 registros
analytics.mart_country_health_efficiency: 175 registros
```

Cálculo:

```text
7 países × 8 indicadores × 25 anos = 1.400 registros raw
7 países × 25 anos = 175 registros na mart final
```

## Decisões de arquitetura

### Uso de Docker

O Docker foi utilizado para padronizar o ambiente PostgreSQL e evitar dependência de uma instalação local do banco.

### Uso de PostgreSQL

O PostgreSQL foi escolhido por ser um banco relacional robusto, amplamente utilizado em projetos de dados e compatível com dbt e Power BI.

### Uso de dbt Core

O dbt Core foi utilizado para organizar as transformações SQL, criar camadas de modelagem e aplicar testes de qualidade.

### Uso de mart analítica

A mart final simplifica o consumo no Power BI, evitando que todas as regras de negócio precisem ser recriadas no dashboard.

### Uso de CSV raw

Os CSVs foram mantidos como camada intermediária para facilitar auditoria, reprocessamento e versionamento dos dados extraídos.

## Limitações da arquitetura

- O pipeline é executado manualmente.
- Não há orquestrador como Airflow ou Prefect nesta versão.
- Não há camada de monitoramento automatizada.
- A base usa apenas países selecionados da América Latina.
- O índice de eficiência é exploratório e não deve ser interpretado como métrica científica definitiva.

## Possíveis evoluções

- Adicionar orquestração com Airflow ou Prefect.
- Criar pipeline incremental.
- Adicionar mais indicadores econômicos e sociais.
- Criar camada de snapshots históricos.
- Publicar dashboard final em Power BI Service.
- Adicionar testes automatizados no pipeline Python.
- Criar documentação dbt com `dbt docs generate`.