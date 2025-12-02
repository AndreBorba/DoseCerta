-- ========================================================================================
-- CONSULTA 1 (COMPLEXIDADE MÉDIA): FILTRAGEM E ANTI-JUNÇÃO
-- OBJETIVO: Listar dados de contato e diagnóstico de pacientes com doença ativa
--           que não realizaram exame genético vinculado a esse diagnóstico.
-- ========================================================================================

SELECT
    p.id_pseudo,
    d.nome AS nome_doenca,
    diag.data_hora AS data_diagnostico
FROM
    pessoa p
JOIN
    paciente pac ON p.id_pseudo = pac.id_pseudo
JOIN
    diagnostico diag ON pac.id_pseudo = diag.id_paciente
JOIN
    doenca d ON diag.cid_doenca = d.cid
WHERE
    diag.status = TRUE -- Diagnóstico ativo
    AND d.cid = 'E11' -- Exemplo de filtro por CID. Pode ser alterado para filtrar por d.nome também.
    AND NOT EXISTS (
        SELECT 1
        FROM atrela_se ats
        JOIN exame ex ON ats.nro_protocolo = ex.nro_protocolo
        WHERE
            ats.id_diagnostico = diag.id_diagnostico
            AND UPPER(ex.tipo) = 'GENETICO'
    );

-- ========================================================================================
-- CONSULTA 2 (COMPLEXIDADE MÉDIA): AGRUPAMENTO E AGREGAÇÃO
-- OBJETIVO: Gerar relatório estatístico de recomendações de tratamento por Modelo de IA,
--           incluindo diagnósticos inativos.
-- ========================================================================================

SELECT
    m.nome AS nome_modelo,
    COUNT(rt.nome_modelo) AS total_recomendacoes,
    SUM(CASE WHEN diag.status = FALSE THEN 1 ELSE 0 END) AS diagnosticos_inativos
FROM
    modelo m
LEFT JOIN
    recomendacao_tratamento rt ON m.nome = rt.nome_modelo
LEFT JOIN
    diagnostico diag ON rt.id_diagnostico = diag.id_diagnostico
GROUP BY
    m.nome
ORDER BY
    m.nome;

-- ========================================================================================
-- CONSULTA 3 (COMPLEXIDADE ALTA): SUBQUERY CORRELACIONADA E MÚLTIPLOS JOINS
-- OBJETIVO: Identificar pacientes com marcador genético de alto risco e hábitos de risco,
--           retornando ID do paciente, descrição do marcador e peso mais recente.
-- ========================================================================================

SELECT DISTINCT
    p.id_pseudo,
    mg.descricao AS descricao_marcador,
    (
        SELECT pc.peso_kg
        FROM perfil_clinico pc
        WHERE pc.id_paciente = p.id_pseudo
        ORDER BY pc.data DESC
        LIMIT 1
    ) AS peso_mais_recente
FROM
    paciente p
JOIN
    exame ex ON p.id_pseudo = ex.id_paciente
JOIN
    exame_genetico eg ON ex.nro_protocolo = eg.nro_protocolo
JOIN
    identifica i ON eg.nro_protocolo = i.nro_protocolo
JOIN
    marcador_genetico mg ON i.hgvs = mg.hgvs
WHERE
    mg.hgvs = 'NC_000017.11:g.43045802T>G' -- Exemplo de HGVS para variante em BRCA1
    AND EXISTS (
        SELECT 1
        FROM habitos h
        WHERE h.id_paciente = p.id_pseudo AND h.habito IN ('Tabagismo', 'Etilismo')
    );

-- ========================================================================================
-- CONSULTA 4 (COMPLEXIDADE ALTA): AGRUPAMENTO E DIVERSIFICAÇÃO DE COMANDOS
-- OBJETIVO: Listar a prevalência de Marcadores Genéticos SOMÁTICOS em Câncer de Pulmão.
-- ========================================================================================

SELECT
    MG.hgvs,
    MG.descricao,
    COUNT(I.hgvs) AS total_ocorrencias
FROM
    diagnostico D
JOIN
    exame E ON D.id_paciente = E.id_paciente
JOIN
    exame_genetico EG ON E.nro_protocolo = EG.nro_protocolo
JOIN
    identifica I ON E.nro_protocolo = I.nro_protocolo
JOIN
    marcador_genetico MG ON I.hgvs = MG.hgvs
WHERE
    D.cid_doenca = 'C34' -- Filtro de Índice (Câncer de Pulmão)
    AND D.status = TRUE
    AND UPPER(EG.origem_genetica) = 'SOMATICO' -- Filtro de Tipo de Exame
GROUP BY
    MG.hgvs, MG.descricao
ORDER BY
    total_ocorrencias DESC
LIMIT 10;


-- ========================================================================================
-- CONSULTA 5 (COMPLEXIDADE EXTREMA): DIVISÃO RELACIONAL + GENERALIZAÇÃO (LGPD)
-- OBJETIVO: Pacientes com Câncer de Mama (C50) e Cobertura Genética Completa.
-- ========================================================================================

WITH marcadores_alvo AS (
    -- Conjunto Divisor (S): Requisitos Mandatórios
    SELECT 'BRCA1' AS hgvs
    UNION ALL
    SELECT 'BRCA2' AS hgvs
),

pacientes_c50 AS (
    -- Otimização: Driver Table. Filtra apenas pacientes com Câncer de Mama Ativo.
    SELECT
        P.id_pseudo,
        P.genero,
        P.data_nascimento
    FROM
        diagnostico D
    JOIN
        pessoa P ON D.id_paciente = P.id_pseudo
    WHERE
        D.cid_doenca = 'C50' -- Câncer de Mama
        AND D.status = TRUE
),

pacientes_com_marcadores AS (
    -- Subquery de suporte para o filtro de Divisão (Conjunto A)
    SELECT
        E.id_paciente,
        I.hgvs
    FROM
        exame E
    JOIN
        exame_genetico EG ON E.nro_protocolo = EG.nro_protocolo
    JOIN
        identifica I ON E.nro_protocolo = I.nro_protocolo
    WHERE
        UPPER(EG.origem_genetica) = 'GERMINATIVO'
)

SELECT
    -- Generalizacao das Idades (LGPD): Cálculo da Faixa Etária apenas
    CASE
        WHEN DATE_PART('year', CURRENT_DATE) - DATE_PART('year', PC.data_nascimento) <= 2 THEN '00-02 (Primeira Infância)'
        WHEN DATE_PART('year', CURRENT_DATE) - DATE_PART('year', PC.data_nascimento) <= 12 THEN '03-12 (Criança)'
        WHEN DATE_PART('year', CURRENT_DATE) - DATE_PART('year', PC.data_nascimento) < 18 THEN '13-17 (Adolescente)'
        WHEN DATE_PART('year', CURRENT_DATE) - DATE_PART('year', PC.data_nascimento) < 40 THEN '18-39 (Jovem Adulto)'
        WHEN DATE_PART('year', CURRENT_DATE) - DATE_PART('year', PC.data_nascimento) < 60 THEN '40-59 (Adulto)'
        ELSE '60+ (Idoso)'
    END AS faixa_etaria,
    
    PC.genero
FROM
    pacientes_c50 PC
WHERE
    -- Lógica da Divisão Relacional (NOT EXISTS ... EXCEPT)
    NOT EXISTS (
        -- Conjunto B (Requisitos)
        (SELECT hgvs FROM marcadores_alvo) EXCEPT
        -- Conjunto A (O que o paciente possui)
        (SELECT hgvs FROM pacientes_com_marcadores PM WHERE PM.id_paciente = PC.id_pseudo)
    )
ORDER BY
    faixa_etaria, PC.genero;