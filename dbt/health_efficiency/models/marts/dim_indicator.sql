{{ config(materialized='table') }}

SELECT *
FROM (
    VALUES
        ('SH.XPD.CHEX.PC.CD', 'Current health expenditure per capita', 'spending', 'current US$', 'cost'),
        ('SH.XPD.CHEX.GD.ZS', 'Current health expenditure (% of GDP)', 'spending', '% of GDP', 'context'),
        ('SH.MED.BEDS.ZS', 'Hospital beds per 1,000 people', 'infrastructure', 'per 1,000 people', 'context'),
        ('SH.MED.PHYS.ZS', 'Physicians per 1,000 people', 'infrastructure', 'per 1,000 people', 'context'),
        ('SP.DYN.LE00.IN', 'Life expectancy at birth', 'outcome', 'years', 'higher_is_better'),
        ('SP.DYN.IMRT.IN', 'Infant mortality rate', 'outcome', 'per 1,000 live births', 'lower_is_better'),
        ('SH.DYN.NCOM.ZS', 'Premature mortality from noncommunicable diseases', 'outcome', '% probability between ages 30 and 70', 'lower_is_better')
) AS indicators(indicator_code, indicator_name, category, unit, polarity)
