# Plano do dashboard Power BI

Tabela principal sugerida:

- `analytics.mart_country_health_efficiency`

## Página 1 — Visão Geral

Objetivo: mostrar o tamanho e o contexto do dataset.

Visuais:

- Card: número de países.
- Card: período analisado.
- Card: gasto médio em saúde per capita.
- Card: expectativa de vida média.
- Card: mortalidade infantil média.
- Segmentadores: país, ano.
- Linha temporal: expectativa de vida média por ano.
- Linha temporal: gasto per capita médio por ano.

## Página 2 — Brasil vs América Latina

Objetivo: comparar Brasil com os demais países selecionados.

Visuais:

- Linha: gasto per capita por ano, com destaque para Brasil.
- Linha: expectativa de vida por ano.
- Linha: mortalidade infantil por ano.
- Tabela: último ano disponível por país.

## Página 3 — Gasto x Resultado

Objetivo: avaliar relação visual entre gasto e resultado.

Visuais:

- Dispersão:
  - eixo X: `health_exp_pc_usd`
  - eixo Y: `life_expectancy_years`
  - legenda/cor: `country_name`
  - play axis: `year`, se desejar animar
- Dispersão alternativa:
  - eixo X: `health_exp_pc_usd`
  - eixo Y: `infant_mortality_per_1000`

## Página 4 — Infraestrutura de Saúde

Objetivo: comparar capacidade de infraestrutura e profissionais.

Visuais:

- Barras: `hospital_beds_per_1000` por país.
- Barras: `physicians_per_1000` por país.
- Linha temporal por país para ambos os indicadores.

## Página 5 — Eficiência Exploratória

Objetivo: criar uma leitura comparativa, sem tratar como verdade científica.

Visuais:

- Ranking por `exploratory_efficiency_score`.
- Matriz: país, ano, gasto, expectativa, mortalidade infantil, score.
- Tooltip explicando que o score é exploratório.

## Página 6 — Qualidade dos Dados

Objetivo: mostrar maturidade de engenharia de dados.

Visuais:

- Card: total de registros.
- Card: data da última carga.
- Barras: quantidade de valores nulos por indicador.
- Tabela: primeiro e último ano disponível por país.
- Texto: fonte dos dados e limitações.
