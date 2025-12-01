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
-- OBJETIVO: Coorte de Pacientes com Câncer de Mama (C50) e Cobertura Genética Completa.
-- ========================================================================================

WITH marcadores_alvo AS (
    -- Conjunto Divisor: Requisitos Mandatórios (BRCA1, BRCA2)
    SELECT 'BRCA1' AS hgvs
    UNION ALL
    SELECT 'BRCA2' AS hgvs
),

pacientes_c50 AS (
    -- OTIMIZAÇÃO: Driver Table (Filtra pacientes relevantes antes de processar)
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

-- Subquery de suporte para o filtro de Divisão
pacientes_com_marcadores AS (
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
    -- GENERALIZAÇÃO (LGPD): Cálculo da Faixa Etária
    CASE
        WHEN DATE_PART('year', CURRENT_DATE) - DATE_PART('year', PC.data_nascimento) <= 2 THEN '00-02 (Primeira Infância)'
        WHEN DATE_PART('year', CURRENT_DATE) - DATE_PART('year', PC.data_nascimento) <= 12 THEN '03-12 (Criança)'
        WHEN DATE_PART('year', CURRENT_DATE) - DATE_PART('year', PC.data_nascimento) < 18 THEN '13-17 (Adolescente)'
        WHEN DATE_PART('year', CURRENT_DATE) - DATE_PART('year', PC.data_nascimento) < 40 THEN '18-39 (Jovem Adulto)'
        WHEN DATE_PART('year', CURRENT_DATE) - DATE_PART('year', PC.data_nascimento) < 60 THEN '40-59 (Adulto)'
        ELSE '60+ (Idoso)'
    END AS faixa_etaria,
    
    PC.genero,
    
    -- SUBQUERY ESCALAR: Cálculo e Generalização do IMC (Lazy Evaluation)
    (
        SELECT
            CASE
                WHEN prof.peso_kg IS NULL OR prof.altura_m IS NULL OR prof.altura_m = 0 THEN 'DADO_AUSENTE'
                WHEN (prof.peso_kg / (prof.altura_m * prof.altura_m)) < 18.5 THEN 'ABAIXO_PESO'
                WHEN (prof.peso_kg / (prof.altura_m * prof.altura_m)) < 25.0 THEN 'NORMAL'
                WHEN (prof.peso_kg / (prof.altura_m * prof.altura_m)) < 30.0 THEN 'SOBREPESO'
                ELSE 'OBESIDADE'
            END
        FROM perfil_clinico prof
        WHERE prof.id_paciente = PC.id_pseudo
        ORDER BY prof.data DESC
        LIMIT 1
    ) AS faixa_imc
FROM
    pacientes_c50 PC
WHERE
    -- LÓGICA DA DIVISÃO RELACIONAL (NOT EXISTS ... EXCEPT)
    NOT EXISTS (
        -- Conjunto B (Requisitos)
        (SELECT hgvs FROM marcadores_alvo)

        EXCEPT

        -- Conjunto A (O que o paciente possui)
        (SELECT hgvs FROM pacientes_com_marcadores PM WHERE PM.id_paciente = PC.id_pseudo)
    )
ORDER BY
    faixa_etaria, PC.genero;