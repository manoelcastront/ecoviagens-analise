/* =====================================================
BLOCO: VENDAS
Objetivo: Entender faturamento, ticket médio e fidelização
===================================================== */
-- Quanto a empresa está faturando com experiências sustentáveis?
-- Receita Bruta Mensal (considera apenas reservas concluídas)
WITH
	RECEITARESERVAS AS (
		SELECT
			DATE_PART('year', R.DATA_RESERVA) AS ANO_RESERVA,
			DATE_PART('month', R.DATA_RESERVA) AS MES_RESERVA_NUM,
			SUM(R.QTD_PESSOAS * O.PRECO) AS RECEITA_RESERVA_MES
		FROM
			ECOVIAGENS.RESERVA R
			JOIN ECOVIAGENS.OFERTA O ON O.ID_OFERTA = R.ID_OFERTA
		WHERE
			R.STATUS = 'Concluída'
		GROUP BY
			1,
			2
	)
SELECT
	CONCAT(
		RR.ANO_RESERVA,
		'/',
		TRIM(
			TO_CHAR(
				MAKE_DATE(RR.ANO_RESERVA::INT, RR.MES_RESERVA_NUM::INT, 1),
				'Mon'
			)
		)
	) AS MES_RESERVA,
	RR.RECEITA_RESERVA_MES,
	ROUND(
		100.0 * (
			(
				RR.RECEITA_RESERVA_MES / LAG(RR.RECEITA_RESERVA_MES) OVER (
					ORDER BY
						RR.ANO_RESERVA,
						RR.MES_RESERVA_NUM
				)
			) - 1.0
		),
		2
	) AS VARIACAO_PCT
FROM
	RECEITARESERVAS RR;

-- Qual é o valor médio gasto por cliente em cada reserva?
-- Ticket Médio (Todo Período) = Receita total / Número de reservas
SELECT
	ROUND(
		SUM(R.QTD_PESSOAS * O.PRECO) * 1.0 / COUNT(R.ID_RESERVA),
		2
	) AS TICKET_MEDIO
FROM
	ECOVIAGENS.RESERVA R
	JOIN ECOVIAGENS.OFERTA O ON O.ID_OFERTA = R.ID_OFERTA
WHERE
	R.STATUS = 'Concluída';

-- Ticket Médio Mensal (média por mês, com base nas reservas concluídas)
SELECT
	CONCAT(
		DATE_PART('year', R.DATA_RESERVA),
		'/',
		TRIM(
			TO_CHAR(
				MAKE_DATE(
					DATE_PART('year', R.DATA_RESERVA)::INT,
					DATE_PART('month', R.DATA_RESERVA)::INT,
					1
				),
				'Mon'
			)
		)
	) AS MES_RESERVA,
	ROUND(
		SUM(R.QTD_PESSOAS * O.PRECO) * 1.0 / COUNT(R.ID_RESERVA),
		2
	) AS TICKET_MEDIO_RESERVA,
	ROUND(
		SUM(R.QTD_PESSOAS * O.PRECO) * 1.0 / SUM(R.QTD_PESSOAS),
		2
	) AS TICKET_MEDIO_PESSOA,
	ROUND(SUM(R.QTD_PESSOAS) * 1.0 / COUNT(R.ID_RESERVA), 2) AS MEDIA_PESSOAS_RESERVA
FROM
	ECOVIAGENS.RESERVA R
	JOIN ECOVIAGENS.OFERTA O ON O.ID_OFERTA = R.ID_OFERTA
WHERE
	R.STATUS = 'Concluída'
GROUP BY
	DATE_PART('year', R.DATA_RESERVA),
	DATE_PART('month', R.DATA_RESERVA)
ORDER BY
	DATE_PART('year', R.DATA_RESERVA),
	DATE_PART('month', R.DATA_RESERVA);

-- Ticket Médio por Pessoa = Receita total / Número de pessoas
SELECT
	ROUND(
		SUM(R.QTD_PESSOAS * O.PRECO) * 1.0 / SUM(R.QTD_PESSOAS),
		2
	) AS TICKET_MEDIO
FROM
	ECOVIAGENS.RESERVA R
	JOIN ECOVIAGENS.OFERTA O ON O.ID_OFERTA = R.ID_OFERTA
WHERE
	R.STATUS = 'Concluída';

-- Mediana do Preço Unitário das ofertas
-- Usado como benchmark para comparar preços
SELECT
	PERCENTILE_CONT(0.5) WITHIN GROUP (
		ORDER BY
			O.PRECO
	)
FROM
	ECOVIAGENS.OFERTA O;

-- Estamos conseguindo fidelizar nossos clientes?
-- Taxa de Recompra = % de clientes com 2+ reservas
SELECT
	COUNT(*) AS TOTAL_CLIENTES,
	COUNT(*) FILTER (
		WHERE
			TB1.RESERVAS >= 2
	) AS CLIENTES_RECOMPRA,
	ROUND(
		100.0 * COUNT(*) FILTER (
			WHERE
				TB1.RESERVAS >= 2
		) / COUNT(*),
		2
	) AS TAXA_RECOMPRA_PCT
FROM
	(
		SELECT
			R.ID_CLIENTE,
			COUNT(R.ID_RESERVA) AS RESERVAS
		FROM
			ECOVIAGENS.RESERVA R
		WHERE
			R.STATUS = 'Concluída'
		GROUP BY
			1
	) AS TB1;

/* =====================================================
BLOCO: SATISFAÇÃO DO CLIENTE
===================================================== */
-- Quais tipos de oferta são mais populares entre os viajantes?
-- Métricas: número de reservas e número de pessoas
SELECT
	O.TIPO_OFERTA,
	COUNT(R.ID_RESERVA) AS QTD_RESERVAS,
	SUM(R.QTD_PESSOAS) AS QTD_PESSOAS,
	ROUND(
		100.0 * COUNT(R.ID_RESERVA) / SUM(COUNT(R.ID_RESERVA)) OVER (),
		2
	) AS QTD_RESERVAS_PCT,
	ROUND(
		100.0 * SUM(R.QTD_PESSOAS) / SUM(SUM(R.QTD_PESSOAS)) OVER (),
		2
	) AS QTD_PESSOAS_PCT
FROM
	ECOVIAGENS.RESERVA R
	JOIN ECOVIAGENS.OFERTA O ON O.ID_OFERTA = R.ID_OFERTA
	-- WHERE r.status = 'Concluída'  (opcional: filtrar só concluídas)
GROUP BY
	1
ORDER BY
	2 DESC;

-- Quais experiências estão recebendo as melhores avaliações?
-- Avaliação Média por Experiência
-- Inclui média geral do site e benchmark fixo (3.5)
WITH
	MEDIAGERAL AS (
		SELECT
			ROUND(AVG(A.NOTA), 2) AS MEDIA_GERAL
		FROM
			ECOVIAGENS.AVALIACAO A
	),
	BENCHMARK AS (
		SELECT
			3.5 AS BENCHMARK
	)
SELECT
	O.ID_OFERTA,
	MAX(O.TITULO) AS TITULO,
	ROUND(AVG(A.NOTA), 2) AS MEDIA_NOTA,
	COUNT(A.ID_AVALIACAO) AS QTD_AVALIACOES,
	MAX(MG.MEDIA_GERAL) AS MEDIA_GERAL,
	MAX(B.BENCHMARK) AS BENCHMARK
FROM
	ECOVIAGENS.AVALIACAO A
	JOIN ECOVIAGENS.OFERTA O ON O.ID_OFERTA = A.ID_OFERTA
	JOIN MEDIAGERAL MG ON 1 = 1
	JOIN BENCHMARK B ON 1 = 1
GROUP BY
	1
ORDER BY
	3 DESC;

-- Avaliação Média por Operador (ranking de operadores)
SELECT
	O2.ID_OPERADOR,
	MAX(O2.NOME) AS NOME_OPERADOR,
	ROUND(AVG(A.NOTA), 2) AS MEDIA_NOTA_OPERADOR
FROM
	ECOVIAGENS.AVALIACAO A
	JOIN ECOVIAGENS.OFERTA O1 ON O1.ID_OFERTA = A.ID_OFERTA
	JOIN ECOVIAGENS.OPERADOR O2 ON O1.ID_OPERADOR = O2.ID_OPERADOR
GROUP BY
	O2.ID_OPERADOR
ORDER BY
	MEDIA_NOTA_OPERADOR DESC;

-- Quais operadores se destacam dentro de cada tipo de experiência?
-- Avaliação Média por Operador por Tipo de Oferta
SELECT
	O2.NOME AS NOME_FANTASIA,
	O1.TIPO_OFERTA,
	ROUND(AVG(A.NOTA), 2) AS MEDIA_NOTA
FROM
	ECOVIAGENS.AVALIACAO A
	JOIN ECOVIAGENS.OFERTA O1 ON O1.ID_OFERTA = A.ID_OFERTA
	JOIN ECOVIAGENS.OPERADOR O2 ON O1.ID_OPERADOR = O2.ID_OPERADOR
WHERE
	A.NOTA IS NOT NULL
GROUP BY
	O2.NOME,
	O1.TIPO_OFERTA
ORDER BY
	O1.TIPO_OFERTA,
	MEDIA_NOTA DESC;

/* =====================================================
BLOCO: PARTICIPAÇÃO NA PLATAFORMA
===================================================== */
-- Quantos clientes estão chegando à plataforma?
-- Número de novos clientes
-- Define "novo cliente" pelo mês da primeira reserva
WITH
	PRIMEIRARESERVA AS (
		SELECT
			R.ID_CLIENTE,
			MIN(R.DATA_RESERVA) AS DATA_PRIMEIRA_RESERVA
		FROM
			ECOVIAGENS.RESERVA R
		GROUP BY
			R.ID_CLIENTE
	),
	PRIMEIRARESERVAYM AS (
		SELECT
			ID_CLIENTE,
			DATE_PART('year', DATA_PRIMEIRA_RESERVA)::INT AS ANO,
			DATE_PART('month', DATA_PRIMEIRA_RESERVA)::INT AS MES
		FROM
			PRIMEIRARESERVA
	)
SELECT
	CONCAT(
		PR.ANO,
		'/',
		TO_CHAR(MAKE_DATE(PR.ANO, PR.MES, 1), 'Mon')
	) AS MES_NOME,
	COUNT(PR.ID_CLIENTE) AS NOVOS_CLIENTES
FROM
	PRIMEIRARESERVAYM PR
GROUP BY
	PR.ANO,
	PR.MES
ORDER BY
	PR.ANO,
	PR.MES;

-- Com que frequência os clientes fiéis fazem novas reservas?
-- Tempo Médio entre Reservas (considera clientes com 2+ reservas concluídas)
WITH
	CLIENTESRESERVAS AS (
		SELECT
			R.ID_CLIENTE,
			COUNT(R.ID_RESERVA) AS RESERVAS
		FROM
			ECOVIAGENS.RESERVA R
		WHERE
			R.STATUS = 'Concluída'
		GROUP BY
			R.ID_CLIENTE
		HAVING
			COUNT(R.ID_RESERVA) >= 2
	),
	DAYSDIFF AS (
		SELECT
			R.ID_CLIENTE,
			(
				R.DATA_RESERVA - LAG(R.DATA_RESERVA) OVER (
					PARTITION BY
						R.ID_CLIENTE
					ORDER BY
						R.DATA_RESERVA
				)
			)::NUMERIC AS DAYS_DIFF
		FROM
			ECOVIAGENS.RESERVA R
			JOIN CLIENTESRESERVAS CR ON R.ID_CLIENTE = CR.ID_CLIENTE
		WHERE
			R.STATUS = 'Concluída'
	)
SELECT
	ROUND(AVG(DAYS_DIFF), 2) AS TEMPO_MEDIO_ENTRE_RESERVAS
FROM
	DAYSDIFF
WHERE
	DAYS_DIFF IS NOT NULL;

/* =====================================================
BLOCO: PRÁTICAS SUSTENTÁVEIS
===================================================== */
-- Quantas ofertas têm práticas sustentáveis implementadas?
-- Conta ofertas únicas vinculadas a práticas
SELECT
	COUNT(*) AS OFERTAS_COM_PRATICAS
FROM
	(
		SELECT
			OP.ID_OFERTA
		FROM
			ECOVIAGENS.OFERTA_PRATICA OP
		GROUP BY
			OP.ID_OFERTA
	) AS TB;

-- Número Médio de Práticas por Oferta
SELECT
	ROUND(AVG(NUM_PRATICAS), 2) AS MEDIA_PRATICAS_POR_OFERTA
FROM
	(
		SELECT
			ID_OFERTA,
			COUNT(ID_PRATICA) AS NUM_PRATICAS
		FROM
			ECOVIAGENS.OFERTA_PRATICA
		GROUP BY
			ID_OFERTA
	) AS TB;

-- Percentual de Ofertas com Práticas Sustentáveis
SELECT
	COUNT(DISTINCT O.ID_OFERTA) AS TOTAL_OFERTAS,
	COUNT(DISTINCT OP.ID_OFERTA) AS OFERTAS_COM_PRATICAS,
	ROUND(
		100 * COUNT(DISTINCT OP.ID_OFERTA) * 1.0 / COUNT(DISTINCT O.ID_OFERTA),
		2
	) AS PCT_OFERTAS_COM_PRATICAS
FROM
	ECOVIAGENS.OFERTA O
	LEFT JOIN ECOVIAGENS.OFERTA_PRATICA OP ON OP.ID_OFERTA = O.ID_OFERTA;

-- Quais práticas sustentáveis aparecem com mais frequência nas reservas?
-- Conta reservas concluídas associadas a cada prática
SELECT
	PS.ID_PRATICA,
	PS.DESCRICAO,
	COUNT(DISTINCT R.ID_RESERVA) AS TOTAL_RESERVAS
FROM
	ECOVIAGENS.RESERVA R
	JOIN ECOVIAGENS.OFERTA_PRATICA OP ON R.ID_OFERTA = OP.ID_OFERTA
	JOIN ECOVIAGENS.PRATICA_SUSTENTAVEL PS ON PS.ID_PRATICA = OP.ID_PRATICA
WHERE
	R.STATUS = 'Concluída'
GROUP BY
	PS.ID_PRATICA
ORDER BY
	TOTAL_RESERVAS DESC;