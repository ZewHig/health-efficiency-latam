# Dicionário de Dados

Este documento descreve os principais dados utilizados no projeto **Health Efficiency LATAM**, incluindo fontes, indicadores, tabelas e colunas da camada analítica.

## Fonte dos dados

Os dados são extraídos da World Bank Indicators API.

O projeto utiliza dados públicos de países selecionados da América Latina para o período de 2000 a 2024.

## Países analisados

| País | Código ISO3 |
|---|---|
| Brazil | BRA |
| Argentina | ARG |
| Chile | CHL |
| Colombia | COL |
| Mexico | MEX |
| Peru | PER |
| Uruguay | URY |

## Indicadores utilizados

| Código | Nome | Categoria | Unidade | Polaridade |
|---|---|---|---|---|
| SH.XPD.CHEX.PC.CD | Current health expenditure per capita | spending | current US$ | cost |
| SH.XPD.CHEX.GD.ZS | Current health expenditure (% of GDP) | spending | % of GDP | context |
| SH.MED.BEDS.ZS | Hospital beds per 1,000 people | infrastructure | per 1,000 people | context |
| SH.MED.PHYS.ZS | Physicians per 1,000 people | infrastructure | per 1,000 people | context |
| SP.DYN.LE00.IN | Life expectancy at birth | outcome | years | higher_is_better |
| SP.DYN.IMRT.IN | Infant mortality rate | outcome | per 1,000 live births | lower_is_better |
| SH.DYN.NCOM.ZS | Premature mortality from noncommunicable diseases | outcome | % probability between ages 30 and 70 | lower_is_better |
| SP.POP.TOTL | Population, total | context | people | context |

## Explicação da polaridade

| Polaridade | Significado |
|---|---|
| higher_is_better | Valores maiores indicam melhor resultado analítico |
| lower_is_better | Valores menores indicam melhor resultado analítico |
| cost | Indicador de custo ou gasto |
| context | Indicador usado para contexto, não para avaliação direta de melhor ou pior |

## Schemas do banco

O banco PostgreSQL utiliza os seguintes schemas:

| Schema | Descrição |
|---|---|
| raw | Dados brutos carregados a partir dos CSVs |
| staging | Dados padronizados pelo dbt |
| intermediate | Transformações intermediárias |
| analytics | Modelos finais para análise e dashboard |

## Tabela `raw.raw_worldbank_indicators`

Tabela bruta com os indicadores extraídos da World Bank API.

Granularidade:

```text
país + ano + indicador
```

| Coluna | Tipo esperado | Descrição |
|---|---|---|
| country_code | text | Código ISO3 do país |
| country_name | text | Nome do país |
| indicator_code | text | Código do indicador no World Bank |
| indicator_name | text | Nome do indicador |
| year | integer | Ano de referência |
| value | numeric | Valor do indicador |
| loaded_at | timestamp | Data e hora da carga |
| source | text | Fonte dos dados |

## Tabela `raw.raw_worldbank_countries`

Tabela bruta com informações dos países analisados.

| Coluna | Tipo esperado | Descrição |
|---|---|---|
| country_code | text | Código ISO3 do país |
| country_name | text | Nome do país |
| region | text | Região do país |
| income_group | text | Grupo de renda do país |
| longitude | numeric | Longitude |
| latitude | numeric | Latitude |
| loaded_at | timestamp | Data e hora da carga |
| source | text | Fonte dos dados |

## Modelo `staging.stg_worldbank_health`

Modelo de staging com os dados de indicadores padronizados.

Granularidade:

```text
país + ano + indicador
```

| Coluna | Descrição |
|---|---|
| country_code | Código ISO3 do país |
| country_name | Nome do país |
| indicator_code | Código do indicador |
| indicator_name | Nome do indicador |
| year | Ano de referência |
| value | Valor do indicador |
| loaded_at | Data e hora da carga |
| source | Fonte dos dados |

## Modelo `staging.stg_worldbank_countries`

Modelo de staging com os dados padronizados dos países.

| Coluna | Descrição |
|---|---|
| country_code | Código ISO3 do país |
| country_name | Nome do país |
| region | Região |
| income_group | Grupo de renda |
| longitude | Longitude |
| latitude | Latitude |
| loaded_at | Data e hora da carga |
| source | Fonte dos dados |

## Modelo `intermediate.int_health_indicators_pivoted`

Modelo intermediário que transforma os indicadores em colunas.

Granularidade:

```text
país + ano
```

| Coluna | Descrição |
|---|---|
| country_code | Código ISO3 do país |
| country_name | Nome do país |
| year | Ano de referência |
| health_exp_pc_usd | Gasto corrente em saúde per capita em dólares correntes |
| health_exp_pct_gdp | Gasto corrente em saúde como percentual do PIB |
| hospital_beds_per_1000 | Leitos hospitalares por 1.000 pessoas |
| physicians_per_1000 | Médicos por 1.000 pessoas |
| life_expectancy_years | Expectativa de vida ao nascer em anos |
| infant_mortality_per_1000 | Mortalidade infantil por 1.000 nascidos vivos |
| premature_ncd_mortality_pct | Mortalidade prematura por doenças crônicas |
| population_total | População total |
| last_loaded_at | Data mais recente de carga entre os indicadores |

## Modelo `analytics.dim_country`

Dimensão de países.

| Coluna | Descrição |
|---|---|
| country_code | Código ISO3 do país |
| country_name | Nome do país |
| region | Região |
| income_group | Grupo de renda |
| longitude | Longitude |
| latitude | Latitude |

## Modelo `analytics.dim_indicator`

Dimensão de indicadores.

| Coluna | Descrição |
|---|---|
| indicator_code | Código do indicador no World Bank |
| indicator_name | Nome do indicador |
| category | Categoria analítica do indicador |
| unit | Unidade de medida |
| polarity | Interpretação analítica do indicador |

## Modelo `analytics.fct_health_indicators`

Tabela fato com indicadores em formato longo.

Granularidade:

```text
país + ano + indicador
```

| Coluna | Descrição |
|---|---|
| country_code | Código ISO3 do país |
| indicator_code | Código do indicador |
| year | Ano de referência |
| value | Valor do indicador |
| loaded_at | Data e hora da carga |

Esta tabela é útil para análises dinâmicas por indicador, filtros e gráficos onde o usuário escolhe qual indicador deseja visualizar.

## Modelo `analytics.mart_country_health_efficiency`

Tabela analítica final do projeto.

Granularidade:

```text
país + ano
```

Esta é a principal tabela para consumo no Power BI.

| Coluna | Descrição |
|---|---|
| country_code | Código ISO3 do país |
| country_name | Nome do país |
| region | Região |
| income_group | Grupo de renda |
| year | Ano de referência |
| health_exp_pc_usd | Gasto corrente em saúde per capita em dólares correntes |
| health_exp_pct_gdp | Gasto corrente em saúde como percentual do PIB |
| hospital_beds_per_1000 | Leitos hospitalares por 1.000 pessoas |
| physicians_per_1000 | Médicos por 1.000 pessoas |
| life_expectancy_years | Expectativa de vida ao nascer em anos |
| infant_mortality_per_1000 | Mortalidade infantil por 1.000 nascidos vivos |
| premature_ncd_mortality_pct | Mortalidade prematura por doenças crônicas |
| population_total | População total |
| population_millions | População total em milhões |
| estimated_total_health_exp_usd | Gasto total estimado em saúde em dólares correntes |
| estimated_total_health_exp_billion_usd | Gasto total estimado em saúde em bilhões de dólares correntes |
| simple_efficiency_life_per_usd | Razão simples entre expectativa de vida e gasto per capita |
| life_expectancy_score | Score normalizado da expectativa de vida dentro de cada ano |
| infant_mortality_score | Score normalizado da mortalidade infantil dentro de cada ano |
| premature_ncd_mortality_score | Score normalizado da mortalidade prematura por doenças crônicas dentro de cada ano |
| health_exp_cost_score | Score normalizado do gasto per capita, onde menor gasto recebe maior pontuação |
| health_result_score | Score médio dos indicadores de resultado em saúde |
| exploratory_efficiency_score | Índice exploratório que combina resultado em saúde e custo |
| last_loaded_at | Data mais recente de carga entre os indicadores |

## Métricas derivadas

### `population_millions`

População total convertida para milhões.

Fórmula:

```text
population_total / 1.000.000
```

### `estimated_total_health_exp_usd`

Estimativa do gasto total em saúde em dólares correntes.

Fórmula:

```text
health_exp_pc_usd × population_total
```

### `estimated_total_health_exp_billion_usd`

Estimativa do gasto total em saúde em bilhões de dólares correntes.

Fórmula:

```text
estimated_total_health_exp_usd / 1.000.000.000
```

### `simple_efficiency_life_per_usd`

Razão simples entre expectativa de vida e gasto per capita.

Fórmula:

```text
life_expectancy_years / health_exp_pc_usd
```

Essa métrica é apenas exploratória e não deve ser interpretada isoladamente como eficiência real.

## Scores normalizados

Os scores são calculados dentro de cada ano, comparando os países analisados entre si.

### `life_expectancy_score`

Quanto maior a expectativa de vida, maior o score.

### `infant_mortality_score`

Quanto menor a mortalidade infantil, maior o score.

### `premature_ncd_mortality_score`

Quanto menor a mortalidade prematura por doenças crônicas, maior o score.

### `health_exp_cost_score`

Quanto menor o gasto per capita, maior o score de custo.

Essa lógica foi usada para comparar países que alcançam bons resultados com menor gasto per capita.

## Índice exploratório de eficiência

A coluna `exploratory_efficiency_score` combina:

- Score de expectativa de vida
- Score de mortalidade infantil
- Score de mortalidade prematura por doenças crônicas
- Score de custo baseado no gasto per capita

O índice é exploratório e serve para análise comparativa dentro do conjunto de países e anos selecionados.

Ele não deve ser interpretado como métrica científica definitiva de eficiência em saúde.

## Cobertura dos indicadores

Cobertura observada após a extração dos dados de 2000 a 2024:

| Indicador | Linhas totais | Linhas com valor | Linhas nulas | Cobertura |
|---|---:|---:|---:|---:|
| Mortalidade infantil | 175 | 175 | 0 | 100,00% |
| Expectativa de vida | 175 | 175 | 0 | 100,00% |
| População total | 175 | 175 | 0 | 100,00% |
| Gasto em saúde como % do PIB | 175 | 170 | 5 | 97,14% |
| Gasto em saúde per capita | 175 | 170 | 5 | 97,14% |
| Mortalidade prematura por doenças crônicas | 175 | 154 | 21 | 88,00% |
| Leitos hospitalares | 175 | 123 | 52 | 70,29% |
| Médicos por 1.000 pessoas | 175 | 104 | 71 | 59,43% |

## Observações sobre qualidade dos dados

- Expectativa de vida, mortalidade infantil e população possuem cobertura completa no período analisado.
- Indicadores de gasto em saúde possuem alta cobertura.
- Indicadores de infraestrutura, como leitos hospitalares e médicos por 1.000 pessoas, possuem mais valores ausentes.
- Por esse motivo, infraestrutura deve ser tratada como análise complementar no dashboard.
- O ano de 2024 pode conter dados incompletos em alguns indicadores, então 2023 é usado como ano principal para comparações recentes.

## Uso recomendado no Power BI

### Tabela principal

Usar como base principal:

```text
analytics.mart_country_health_efficiency
```

### Visuais recomendados

| Visual | Campos sugeridos |
|---|---|
| Ranking de gasto per capita | country_name, health_exp_pc_usd |
| Ranking de expectativa de vida | country_name, life_expectancy_years |
| Ranking de mortalidade infantil | country_name, infant_mortality_per_1000 |
| Série temporal Brasil vs países | year, country_name, health_exp_pc_usd, life_expectancy_years |
| Dispersão gasto vs expectativa de vida | health_exp_pc_usd, life_expectancy_years, population_total, country_name |
| Dispersão gasto vs mortalidade infantil | health_exp_pc_usd, infant_mortality_per_1000, population_total, country_name |
| Ranking de eficiência exploratória | country_name, exploratory_efficiency_score |
| Qualidade dos dados | indicator_name, coverage_pct |

## Limitações

- O projeto analisa apenas países selecionados da América Latina.
- Alguns indicadores possuem dados ausentes, principalmente infraestrutura.
- O índice de eficiência é exploratório.
- A análise não controla todos os fatores econômicos, sociais, epidemiológicos e institucionais que influenciam sistemas de saúde.
- O gasto total estimado é calculado a partir do gasto per capita multiplicado pela população, portanto deve ser interpretado como aproximação analítica.

## Próximas melhorias

- Adicionar indicadores econômicos, como PIB per capita.
- Adicionar indicadores sociais, como urbanização ou escolaridade.
- Criar documentação específica da metodologia do índice exploratório.
- Criar dashboard final no Power BI.
- Publicar imagens do dashboard na pasta `dashboard/images`.