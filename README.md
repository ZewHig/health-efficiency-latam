# Health Efficiency LATAM

Projeto pessoal de Engenharia de Dados e Business Intelligence para analisar a relação entre gastos em saúde e resultados de saúde pública em países da América Latina.

O projeto constrói um pipeline ELT utilizando dados públicos da World Bank API, com extração em Python, armazenamento em PostgreSQL via Docker, transformação com dbt Core e preparação de uma camada analítica para visualização em Power BI.

## Pergunta de negócio

Países da América Latina que gastam mais em saúde apresentam melhores indicadores de resultado?

## Objetivos do projeto

- Construir um pipeline de dados consumindo uma API pública.
- Armazenar dados brutos em PostgreSQL.
- Modelar dados em camadas usando dbt Core.
- Criar uma mart analítica para consumo em dashboard.
- Comparar indicadores de gasto em saúde, expectativa de vida, mortalidade infantil e população.
- Avaliar a qualidade e cobertura dos dados utilizados.
- Criar uma base analítica para desenvolvimento de dashboard em Power BI.

## Fonte dos dados

A fonte de dados utilizada é a World Bank Indicators API.

A API é pública, gratuita, não exige autenticação para este uso e retorna dados em JSON. O projeto utiliza indicadores de gasto em saúde, infraestrutura, resultados em saúde e contexto populacional.

## Países analisados

| País | Código |
|---|---|
| Brasil | BRA |
| Argentina | ARG |
| Chile | CHL |
| Colômbia | COL |
| México | MEX |
| Peru | PER |
| Uruguai | URY |

## Indicadores

| Código | Indicador | Tipo |
|---|---|---|
| SH.XPD.CHEX.PC.CD | Gasto corrente em saúde per capita | Entrada / gasto |
| SH.XPD.CHEX.GD.ZS | Gasto corrente em saúde como % do PIB | Entrada / gasto |
| SH.MED.BEDS.ZS | Leitos hospitalares por 1.000 pessoas | Infraestrutura |
| SH.MED.PHYS.ZS | Médicos por 1.000 pessoas | Infraestrutura |
| SP.DYN.LE00.IN | Expectativa de vida ao nascer | Resultado |
| SP.DYN.IMRT.IN | Mortalidade infantil | Resultado |
| SH.DYN.NCOM.ZS | Mortalidade prematura por doenças crônicas | Resultado |
| SP.POP.TOTL | População total | Contexto |

## Arquitetura

```text
World Bank API
    ↓
Python + requests + pandas
    ↓
CSV Raw Files
    ↓
PostgreSQL via Docker - schema raw
    ↓
dbt Core - staging, intermediate, marts
    ↓
Analytics Mart
    ↓
Power BI
```

## Tecnologias utilizadas

- Python
- Pandas
- Requests
- PostgreSQL
- Docker
- SQLAlchemy
- psycopg
- dbt Core
- dbt-postgres
- SQL
- Power BI
- Git/GitHub

## Estrutura do projeto

```text
health-efficiency-latam/
├── data/
│   ├── raw/
│   └── processed/
├── src/
│   ├── config.py
│   ├── extract_worldbank.py
│   ├── load_postgres.py
│   └── utils.py
├── sql/
│   ├── create_tables.sql
│   └── queries_analysis.sql
├── dbt/
│   └── health_efficiency/
│       ├── models/
│       │   ├── staging/
│       │   ├── intermediate/
│       │   └── marts/
│       ├── macros/
│       ├── dbt_project.yml
│       └── profiles.yml.example
├── dashboard/
│   ├── powerbi/
│   └── images/
├── docs/
│   ├── architecture.md
│   └── data_dictionary.md
├── docker-compose.yml
├── requirements.txt
├── .env.example
├── README.md
└── .gitignore
```

## Camadas de dados

O projeto foi organizado em camadas para separar ingestão, tratamento, modelagem e consumo analítico.

### Raw

Camada de dados brutos carregados no PostgreSQL a partir dos arquivos CSV extraídos da World Bank API.

Principais tabelas:

- `raw.raw_worldbank_indicators`
- `raw.raw_worldbank_countries`

### Staging

Camada de padronização dos dados brutos. Nesta etapa, os dados são renomeados, tipados e preparados para as transformações seguintes.

Principais modelos:

- `staging.stg_worldbank_health`
- `staging.stg_worldbank_countries`

### Intermediate

Camada intermediária responsável por reorganizar os indicadores em formato analítico, criando uma linha por país e ano com os principais indicadores como colunas.

Principal modelo:

- `intermediate.int_health_indicators_pivoted`

### Analytics

Camada final de consumo analítico, utilizada para exploração dos dados e construção do dashboard.

Principais modelos:

- `analytics.dim_country`
- `analytics.dim_indicator`
- `analytics.fct_health_indicators`
- `analytics.mart_country_health_efficiency`

## Como rodar localmente

### 1. Criar ambiente Python

```powershell
py -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Subir PostgreSQL com Docker

```powershell
docker.exe compose up -d
```

O banco PostgreSQL será disponibilizado em:

```text
Host: 127.0.0.1
Porta: 5433
Database: health_efficiency
User: postgres
Password: postgres
```

Sem Docker, crie manualmente um banco PostgreSQL chamado `health_efficiency` e ajuste a variável `DATABASE_URL`.

### 3. Configurar variáveis de ambiente

Crie um arquivo `.env` com base no `.env.example`.

Exemplo:

```env
DATABASE_URL=postgresql+psycopg://postgres:postgres@127.0.0.1:5433/health_efficiency
```

### 4. Extrair dados da World Bank API

```powershell
py src/extract_worldbank.py --start-year 2000 --end-year 2024
```

Isso gera os arquivos:

```text
data/raw/worldbank_health_indicators.csv
data/raw/worldbank_countries.csv
```

### 5. Criar tabelas e carregar dados no PostgreSQL

```powershell
py src/load_postgres.py --create-tables --replace
```

### 6. Configurar profile do dbt

Copie o arquivo de exemplo:

```powershell
mkdir $env:USERPROFILE\.dbt
copy dbt\health_efficiency\profiles.yml.example $env:USERPROFILE\.dbt\profiles.yml
```

O profile deve apontar para o PostgreSQL local na porta `5433`.

Exemplo de configuração:

```yaml
health_efficiency:
  target: dev
  outputs:
    dev:
      type: postgres
      host: 127.0.0.1
      user: postgres
      password: postgres
      port: 5433
      dbname: health_efficiency
      schema: analytics
      threads: 4
      keepalives_idle: 0
      connect_timeout: 10
```

### 7. Rodar dbt

```powershell
cd dbt\health_efficiency
dbt debug
dbt run
dbt test
dbt docs generate
```

### 8. Conectar no pgAdmin

Também é possível consultar o banco pelo pgAdmin 4.

Dados de conexão:

```text
Host name/address: 127.0.0.1
Port: 5433
Maintenance database: health_efficiency
Username: postgres
Password: postgres
```

### 9. Conectar Power BI

No Power BI Desktop:

1. Obter dados > PostgreSQL.
2. Servidor: `localhost:5433`
3. Banco: `health_efficiency`
4. Usar principalmente a tabela `analytics.mart_country_health_efficiency`.

Tabelas adicionais que também podem ser usadas:

- `analytics.fct_health_indicators`
- `analytics.dim_country`
- `analytics.dim_indicator`

## Validação dos dados

Após a execução do pipeline, a camada final contém:

- 7 países
- 8 indicadores
- Período de 2000 a 2024
- 1.400 registros na camada raw de indicadores
- 175 registros na mart analítica final

Consulta de validação:

```sql
select 
    count(*) as total_rows,
    count(distinct country_code) as total_countries,
    min(year) as first_year,
    max(year) as last_year
from analytics.mart_country_health_efficiency;
```

Resultado esperado:

```text
total_rows: 175
total_countries: 7
first_year: 2000
last_year: 2024
```

## Análise exploratória inicial

A análise exploratória mostrou que os principais indicadores possuem boa cobertura para o período analisado.

| Indicador | Cobertura |
|---|---:|
| Mortalidade infantil | 100,00% |
| Expectativa de vida | 100,00% |
| População total | 100,00% |
| Gasto em saúde como % do PIB | 97,14% |
| Gasto em saúde per capita | 97,14% |
| Mortalidade prematura por doenças crônicas | 88,00% |
| Leitos hospitalares | 70,29% |
| Médicos por 1.000 pessoas | 59,43% |

Por esse motivo, o dashboard utiliza como indicadores principais:

- Gasto em saúde per capita
- Gasto em saúde como percentual do PIB
- Expectativa de vida
- Mortalidade infantil
- População total
- Índice exploratório de eficiência

Indicadores de infraestrutura, como leitos hospitalares e médicos por 1.000 pessoas, são tratados como análise complementar devido à menor cobertura.

## Principais achados iniciais

Em 2023:

- O Uruguai apresentou o maior gasto em saúde per capita entre os países analisados.
- O Chile apresentou a maior expectativa de vida e a menor mortalidade infantil.
- O Brasil teve o maior gasto total estimado em saúde, devido ao tamanho da população.
- Peru e Colômbia apresentaram bons resultados de expectativa de vida mesmo com menor gasto per capita.
- O Brasil ficou abaixo da média dos demais países analisados em expectativa de vida e acima em mortalidade infantil.

## Dashboard

O dashboard em Power BI está em desenvolvimento.

Estrutura planejada:

1. Visão Geral
2. Brasil vs América Latina selecionada
3. Gasto em saúde vs Resultados
4. Índice exploratório de eficiência
5. Qualidade dos dados

## Entregáveis para portfólio

- Pipeline Python consumindo API pública.
- Banco PostgreSQL com camada raw.
- Transformações dbt com staging, intermediate e mart.
- Testes de qualidade no dbt.
- Análise exploratória com SQL.
- Dashboard Power BI.
- README explicando arquitetura, decisões e limitações.

## Limitação importante

O índice de eficiência criado neste projeto é exploratório. Ele não deve ser apresentado como métrica científica definitiva, porque eficiência em saúde depende de fatores econômicos, sociais, demográficos, epidemiológicos e institucionais que não estão todos modelados aqui.

O objetivo do índice é apoiar uma comparação analítica inicial entre os países selecionados, combinando indicadores de resultado em saúde e gasto per capita.

## Próximos passos

- Finalizar dashboard no Power BI.
- Adicionar imagens do dashboard na pasta `dashboard/images`.
- Atualizar o README com prints e explicação dos visuais.
- Criar documentação da metodologia do índice exploratório de eficiência.
- Avaliar inclusão de novos indicadores de contexto econômico e social.

## Autor

Matheus Donato

GitHub: https://github.com/ZewHig