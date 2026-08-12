--Importante! Na importação da base observar o delimiter(;) e o column name(first line).
-- Comando para verificar a versão do sqlite.
SELECT sqlite_version() AS versao_sqlite;

--Exibir a estrutura (colunas e tipos) da tabela indicada.
PRAGMA table_info(acidentes_prf_2025);

-- Contar o total de ocorrências na tabela indicada.
SELECT COUNT(*) AS total_ocorrencias FROM acidentes_prf_2025;

-- Remove a view anterior se ela existir.
DROP VIEW IF EXISTS vw_acidentes_base;

-- Cria uma coluna binária acidente_ fatal (se houver mortes = 1, se não houver = 0) na tabela indicada.
CREATE VIEW vw_acidentes_base AS SELECT  *,
CASE WHEN CAST(mortos AS INTEGER) >= 1 THEN 1
ELSE 0
END AS acidente_fatal FROM acidentes_prf_2025;

-- Calculo das métricas gerais: total de acidentes, total de fatais e % da letalidade.
SELECT
 COUNT(*) AS total_acidentes,
 SUM(acidente_fatal) AS acidentes_fatais,
 ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base;

-- Agregando acidentes, mortos e % fatais por UF. Filtro com 100 ocorrências.
SELECT uf,
 COUNT(*) AS total_acidentes,
 SUM(acidente_fatal) AS acidentes_fatais,
 SUM(CAST(mortos AS INTEGER)) AS total_mortos,
 ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY uf
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

--Lista das 30 rodovias mais letais com número absoluto de mortos.
SELECT br,
 COUNT(*) AS total_acidentes,
 SUM(CAST(mortos AS INTEGER)) AS total_mortos,
 SUM(acidente_fatal) AS acidentes_fatais,
 ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
WHERE br IS NOT NULL
GROUP BY br
HAVING COUNT(*) >= 100
ORDER BY total_mortos DESC
LIMIT 30;

--Evolução dos acidentes por Ano e Mês extraídos das datas.
SELECT
 CAST(strftime('%Y', data_inversa) AS INTEGER) AS ano,
 CAST(strftime('%m', data_inversa) AS INTEGER) AS mes,
 COUNT(*) AS total_acidentes,
 SUM(CAST(mortos AS INTEGER)) AS total_mortos,
 SUM(acidente_fatal) AS acidentes_fatais,
 ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY ano, mes
ORDER BY ano, mes;

-- Quais tipos de acidente apresentam maior percentual de ocorrências fatais.
SELECT tipo_acidente,
 COUNT(*) AS total_acidentes,
 SUM(acidente_fatal) AS acidentes_fatais,
 ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY tipo_acidente
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

--Quais causas declaradas estão associadas a maior fatalidade.
SELECT causa_acidente,
 COUNT(*) AS total_acidentes,
 SUM(acidente_fatal) AS acidentes_fatais,
 ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY causa_acidente
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC
LIMIT 30;

--Gravidade do acidente de acordo com as fases do dia.
SELECT fase_dia,
 COUNT(*) AS total_acidentes,
 SUM(acidente_fatal) AS acidentes_fatais,
 ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY fase_dia
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

--Influência da condição meteorológica na % de acidentes fatais.
SELECT condicao_metereo,
 COUNT(*) AS total_acidentes,
 SUM(acidente_fatal) AS acidentes_fatais,
 ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY condicao_metereo
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

--Investiga se pistas simples, duplas ou múltiplas apresentam diferenças na proporção de fatalidade.
SELECT  tipo_pista,
 COUNT(*) AS total_acidentes,
 SUM(acidente_fatal) AS acidentes_fatais,
 ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY tipo_pista
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

--Combinação de duas variáveis: tipo de pista e fase do dia.
SELECT tipo_pista, fase_dia,
 COUNT(*) AS total_acidentes,
 SUM(acidente_fatal) AS acidentes_fatais,
 ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS cobertura_perc,
 ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY tipo_pista, fase_dia
HAVING COUNT(*) >= 100
ORDER BY perc_fatais DESC;

--Comparação da taxa de fatalidade de cada tipo de acidente com a taxa geral da base (lift).
WITH taxa_global AS (
 SELECT 1.0 * SUM(acidente_fatal) / COUNT(*) AS taxa
 FROM vw_acidentes_base
)
SELECT tipo_acidente,
 COUNT(*) AS total_acidentes,
 SUM(acidente_fatal) AS acidentes_fatais,
 ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS cobertura_perc,
 ROUND(1.0 * SUM(acidente_fatal) / COUNT(*), 4) AS confianca,
 ROUND((1.0 * SUM(acidente_fatal) / COUNT(*)) / taxa, 2) AS lift
FROM vw_acidentes_base
CROSS JOIN taxa_global
GROUP BY tipo_acidente, taxa
HAVING COUNT(*) >= 100
ORDER BY lift DESC;

--View de indicadores mensais. Organização da lógica de agregação para reutilização em relatórios e dashboards.
DROP VIEW IF EXISTS vw_indicadores_mensais;
CREATE VIEW vw_indicadores_mensais AS
SELECT
 CAST(strftime('%Y', data_inversa) AS INTEGER) AS ano,
 CAST(strftime('%m', data_inversa) AS INTEGER) AS mes,
 COUNT(*) AS total_acidentes,
 SUM(CAST(mortos AS INTEGER)) AS total_mortos,
 SUM(acidente_fatal) AS acidentes_fatais,
 ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
GROUP BY ano, mes;

--Views por UF e BR. Analisa a mesma rodovia separadamente em cada estado.
DROP VIEW IF EXISTS vw_indicadores_uf_br;
CREATE VIEW vw_indicadores_uf_br AS
SELECT uf, br,
 COUNT(*) AS total_acidentes,
 SUM(CAST(mortos AS INTEGER)) AS total_mortos,
 SUM(acidente_fatal) AS acidentes_fatais,
 ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS perc_fatais
FROM vw_acidentes_base
WHERE br IS NOT NULL
GROUP BY uf, br;
SELECT *
FROM vw_indicadores_uf_br
ORDER BY total_mortos DESC;
SELECT *
FROM vw_indicadores_mensais
ORDER BY ano, mes;

-- Base analítica para seleção apenas dos campos necessários para análise, visualização ou modelagem posterior.
DROP VIEW IF EXISTS vw_base_analitica;
CREATE VIEW vw_base_analitica AS
SELECT
 data_inversa,
 dia_semana,
 horario,
 uf,
 br,
 municipio,
 causa_acidente,
 tipo_acidente,
 classificacao_acidente,
 fase_dia,
 condicao_meteorologica,
 tipo_pista,
 tracado_via,
 uso_solo,
 CAST(mortos AS INTEGER) AS mortos,
 acidente_fatal
FROM vw_acidentes_base;
SELECT *
FROM vw_base_analitica
LIMIT 20;

-- Base preliminar para modelagem. Indicado para selecionar variáveis explicativas e uma variável-alvo em uma tabela limpa e consistente.
DROP VIEW IF EXISTS vw_base_modelavel_preliminar;
CREATE VIEW vw_base_modelavel_preliminar AS
SELECT
 uf,
 br,
 municipio,
 CAST(strftime('%m', data_inversa) AS INTEGER) AS mes,
 dia_semana,
 fase_dia,
 causa_acidente,
 tipo_acidente,
 condicao_meteorologica,
 tipo_pista,
 tracado_via,
 uso_solo,
 acidente_fatal
FROM vw_acidentes_base;
SELECT *
FROM vw_base_modelavel_preliminar
LIMIT 20;

