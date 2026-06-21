# Health Efficiency LATAM

Projeto pessoal de engenharia de dados e BI para analisar a relação entre gastos em saúde e resultados de saúde pública em países da América Latina.

## Pergunta de negócio

Países da América Latina que gastam mais em saúde apresentam melhores indicadores de resultado?

## Fonte dos dados

World Bank Indicators API.

A API é pública, gratuita, não exige autenticação para este uso e retorna dados em JSON. O projeto usa indicadores de gasto, infraestrutura e resultado em saúde.

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

## Arquitetura

```text
World Bank API
    ↓
Python + requests + pandas
    ↓
PostgreSQL - schema raw
    ↓
dbt Core - staging, intermediate, marts
    ↓
Power BI
```

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

## Como rodar localmente

### 1. Criar ambiente Python

```bash
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
# .venv\Scripts\activate   # Windows
pip install -r requirements.txt
```

### 2. Subir PostgreSQL com Docker

```bash
docker compose up -d
```

Sem Docker, crie manualmente um banco PostgreSQL chamado `health_efficiency`.

### 3. Configurar variáveis de ambiente

```bash
cp .env.example .env
```

Ajuste `DATABASE_URL` se necessário.

### 4. Extrair dados da World Bank API

```bash
python src/extract_worldbank.py --start-year 2000 --end-year 2024
```

Isso gera:

```text
data/raw/worldbank_health_indicators.csv
data/raw/worldbank_countries.csv
```

### 5. Criar tabelas e carregar no PostgreSQL

```bash
python src/load_postgres.py --create-tables --replace
```

### 6. Rodar dbt

Copie o exemplo de profile:

```bash
mkdir -p ~/.dbt
cp dbt/health_efficiency/profiles.yml.example ~/.dbt/profiles.yml
```

Rode os modelos:

```bash
cd dbt/health_efficiency
dbt debug
dbt run
dbt test
dbt docs generate
```

### 7. Conectar Power BI

No Power BI Desktop:

1. Obter dados > PostgreSQL.
2. Servidor: `localhost`.
3. Banco: `health_efficiency`.
4. Usar a tabela principal: `analytics.mart_country_health_efficiency`.

## Entregáveis para portfólio

- Pipeline Python consumindo API pública.
- Banco PostgreSQL com camada raw.
- Transformações dbt com staging, intermediate e mart.
- Testes de qualidade no dbt.
- Dashboard Power BI.
- README explicando arquitetura, decisões e limitações.

## Limitação importante

O índice de eficiência criado neste projeto é exploratório. Ele não deve ser apresentado como métrica científica definitiva, porque eficiência em saúde depende de fatores econômicos, sociais, demográficos e epidemiológicos que não estão todos modelados aqui.
