# Dicionário de dados

## raw.raw_worldbank_indicators

Tabela bruta em formato longo, extraída da World Bank Indicators API.

| Coluna | Tipo esperado | Descrição |
|---|---:|---|
| country_code | texto | Código ISO3 do país. |
| country_name | texto | Nome do país retornado pela API. |
| indicator_code | texto | Código do indicador World Bank. |
| indicator_name | texto | Nome do indicador retornado pela API. |
| year | inteiro | Ano da observação. |
| value | numérico | Valor do indicador. Pode ser nulo. |
| loaded_at | timestamp | Data/hora da carga. |

## raw.raw_worldbank_countries

Metadados dos países.

| Coluna | Tipo esperado | Descrição |
|---|---:|---|
| country_code | texto | Código ISO3 do país. |
| country_name | texto | Nome do país. |
| iso2_code | texto | Código ISO2. |
| region | texto | Região World Bank. |
| income_group | texto | Grupo de renda World Bank. |
| lending_type | texto | Tipo de empréstimo/relacionamento. |
| capital_city | texto | Capital. |
| longitude | numérico | Longitude da capital. |
| latitude | numérico | Latitude da capital. |
| loaded_at | timestamp | Data/hora da carga. |

## analytics.dim_country

Dimensão de país para análises no Power BI.

## analytics.dim_indicator

Dimensão manual de indicadores, contendo categoria, unidade e polaridade analítica.

| Polaridade | Significado |
|---|---|
| higher_is_better | Quanto maior, melhor. |
| lower_is_better | Quanto menor, melhor. |
| cost | Indicador de custo/gasto. |
| context | Indicador contextual, sem julgamento direto. |

## analytics.fct_health_indicators

Tabela fato em formato longo.

## analytics.mart_country_health_efficiency

Tabela final em formato wide, uma linha por país e ano.

| Coluna | Descrição |
|---|---|
| country_code | Código ISO3 do país. |
| country_name | Nome do país. |
| region | Região World Bank. |
| income_group | Grupo de renda. |
| year | Ano. |
| health_exp_pc_usd | Gasto corrente em saúde per capita. |
| health_exp_pct_gdp | Gasto corrente em saúde como % do PIB. |
| hospital_beds_per_1000 | Leitos hospitalares por 1.000 pessoas. |
| physicians_per_1000 | Médicos por 1.000 pessoas. |
| life_expectancy_years | Expectativa de vida ao nascer. |
| infant_mortality_per_1000 | Mortalidade infantil por 1.000 nascidos vivos. |
| premature_ncd_mortality_pct | Probabilidade de morte prematura por doenças crônicas. |
| simple_efficiency_life_per_usd | Expectativa de vida dividida por gasto per capita. Métrica exploratória. |
| life_expectancy_score | Normalização anual de expectativa de vida. |
| infant_mortality_score | Normalização anual invertida de mortalidade infantil. |
| premature_ncd_mortality_score | Normalização anual invertida de mortalidade prematura. |
| health_exp_cost_score | Normalização anual invertida de gasto per capita. |
| health_result_score | Média dos scores de resultado em saúde. |
| exploratory_efficiency_score | Score exploratório combinando resultado e menor gasto relativo. |
| last_loaded_at | Data/hora da última carga considerada. |
