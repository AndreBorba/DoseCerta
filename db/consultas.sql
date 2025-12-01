-- Listar os dados de contato (Nome, Telefone) e o diagnóstico de pacientes que possuem
-- uma determinada doença ativa (por exemplo, filtrando por um código CID específico
-- ou nome da doença), mas que ainda não realizaram nenhum exame genético vinculado
-- a esse diagnóstico.

SELECT
    p.nome_civil,
    p.telefone_contato,
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

-- Gerar um relatório estatístico que mostre, para cada Modelo de IA cadastrado
-- (agrupado por Nome do Modelo), a quantidade total de recomendações de tratamento
-- emitidas e quantos desses diagnósticos associados estão atualmente com status "inativo"
-- (o que pode sugerir cura ou fim do tratamento).

SELECT
    m.nome AS nome_modelo,
    COUNT(rt.id_diagnostico) AS total_recomendacoes,
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

-- Identificar pacientes que possuem um marcador genético específico de alto risco
-- (identificado pelo código HGVS, ex: uma variante no gene BRCA1) e que,
-- simultaneamente, possuem hábitos de risco registrados (ex: 'Tabagismo' ou 'Etilismo')
-- no seu histórico. O relatório deve retornar o ID do paciente, a descrição do
-- marcador e o peso mais recente registrado no perfil clínico.

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
JOIN
    habitos h ON p.id_pseudo = h.id_paciente
WHERE
    mg.hgvs = 'NC_000017.11:g.43045802T>G' -- Exemplo de HGVS para variante em BRCA1
    AND h.habito IN ('Tabagismo', 'Etilismo');
