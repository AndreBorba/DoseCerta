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