-- ===============================================
-- INSERÇÃO COMPLETA EM TODAS AS TABELAS
-- ===============================================

-- ===============================================
-- 1) PESSOAS (base para paciente e médico)
-- ===============================================
INSERT INTO pessoa (cpf, nome_civil, data_nascimento, telefone_contato, genero)
VALUES 
('123.456.789-10', 'João Silva', '1980-05-10', '(11) 9999-0000', 'Masculino'),
('987.654.321-00', 'Maria Oliveira', '1995-08-20', '(21) 98888-7777', 'Feminino')
ON CONFLICT DO NOTHING;

-- Recupera IDs
-- João = médico
-- Maria = paciente
-- Vamos garantir manualmente:
-- João → id_pseudo = 1
-- Maria → id_pseudo = 2
-- (funciona em DB novo; se não, ajuste via SELECT)

-- ===============================================
-- 2) CONTAS
-- ===============================================
INSERT INTO conta (email, senha, id_pessoa)
VALUES 
('joao@medico.com', '123456', 1),
('maria@paciente.com', 'abc123', 2)
ON CONFLICT DO NOTHING;

-- ===============================================
-- 3) MÉDICO
-- ===============================================
INSERT INTO medico (id_pseudo, crm, especializacao, local_de_trabalho)
VALUES 
(1, 'CRM12345', 'Clínico Geral', 'Hospital Central')
ON CONFLICT DO NOTHING;

-- ===============================================
-- 4) PACIENTE
-- ===============================================
INSERT INTO paciente (id_pseudo, status_paciente, responsavel, historico_familiar)
VALUES 
(2, 'ATIVO', NULL, 'Histórico de diabetes na família')
ON CONFLICT DO NOTHING;

-- ===============================================
-- 5) CUIDADO (médico -> paciente)
-- ===============================================
INSERT INTO cuidado (id_paciente, id_medico, data_inicio, data_termino)
VALUES 
(2, 1, '2024-01-01', NULL)
ON CONFLICT DO NOTHING;

-- ===============================================
-- 6) PERFIL CLÍNICO
-- ===============================================
INSERT INTO perfil_clinico (id_paciente, data, peso_kg, altura_m, gravidez)
VALUES 
(2, '2024-01-15', 70.5, 1.68, FALSE)
ON CONFLICT DO NOTHING;

-- ===============================================
-- 7) MEDICAMENTOS (multi-valorado)
-- ===============================================
INSERT INTO medicamentos (id_paciente, data, medicamento)
VALUES
(2, '2024-01-15', 'Metformina'),
(2, '2024-01-15', 'Vitamina D')
ON CONFLICT DO NOTHING;

-- ===============================================
-- 8) ALERGIAS (multi-valorado)
-- ===============================================
INSERT INTO alergias (id_paciente, data, alergia)
VALUES
(2, '2024-01-15', 'Lactose'),
(2, '2024-01-15', 'Histamina')
ON CONFLICT DO NOTHING;

-- ===============================================
-- 9) HÁBITOS (multi-valorado)
-- ===============================================
INSERT INTO habitos (id_paciente, habito, data)
VALUES
(2, 'Sedentarismo', '2024-01-15'),
(2, 'Alimentação rica em carboidratos', '2024-01-15')
ON CONFLICT DO NOTHING;

-- ===============================================
-- 10) DOENÇA
-- ===============================================
INSERT INTO doenca (cid, nome)
VALUES 
('E11', 'Diabetes Tipo 2')
ON CONFLICT DO NOTHING;

-- ===============================================
-- 11) DIAGNÓSTICO
-- ===============================================
INSERT INTO diagnostico (id_paciente, cid_doenca, data_hora, status)
VALUES
(2, 'E11', '2024-01-20 10:00:00', TRUE)
RETURNING id_diagnostico;

-- Para referência manual:
-- id_diagnostico = 1

-- ===============================================
-- 12) SINTOMA
-- ===============================================
INSERT INTO sintoma (cid, nome, descricao)
VALUES
('S001', 'Fadiga', 'Cansaço persistente'),
('S002', 'Sede Excessiva', 'Paciente relata sede incomum')
ON CONFLICT DO NOTHING;

-- ===============================================
-- 13) OCORRÊNCIA DE SINTOMA (ligado ao diagnóstico)
-- ===============================================
INSERT INTO ocorrencia_sintoma (id_diagnostico, cid_sintoma, data_inicio, duracao, observacao)
VALUES
(1, 'S001', '2024-01-18 08:00:00', '2 semanas', 'Sintoma contínuo'),
(1, 'S002', '2024-01-19 09:30:00', '10 dias', 'Aumentando')
ON CONFLICT DO NOTHING;

-- ===============================================
-- 14) MODELO (IA)
-- ===============================================
INSERT INTO modelo (nome, url)
VALUES
('modelo_diabetes', 'https://storage.modelos.com/diabetes.pkl')
ON CONFLICT DO NOTHING;

-- ===============================================
-- 15) RECOMENDAÇÃO DE TRATAMENTO
-- ===============================================
INSERT INTO recomendacao_tratamento (id_diagnostico, nome_modelo, data_hora)
VALUES
(1, 'modelo_diabetes', '2024-01-20 12:00:00')
ON CONFLICT DO NOTHING;

-- ===============================================
-- 16) LABORATÓRIO
-- ===============================================
INSERT INTO laboratorio (cnpj, razao_social, endereco, cnes, email, telefone1, telefone2)
VALUES
('00.000.000/0001-00', 'Laboratório Central', 'Rua A, 123', '12345', 'contato@labcentral.com', '(11) 3333-3333', NULL)
ON CONFLICT DO NOTHING;

-- ===============================================
-- 17) EXAME (genérico)
-- ===============================================
INSERT INTO exame (nro_protocolo, id_paciente, cnpj_laboratorio, data_hora, tipo)
VALUES
(1001, 2, '00.000.000/0001-00', '2024-01-25 09:00:00', 'CLINICO'),
(1002, 2, '00.000.000/0001-00', '2024-01-26 09:00:00', 'GENETICO')
ON CONFLICT DO NOTHING;

-- ===============================================
-- 18) EXAME CLÍNICO (especialização)
-- ===============================================
INSERT INTO exame_clinico (nro_protocolo)
VALUES (1001)
ON CONFLICT DO NOTHING;

-- ===============================================
-- 19) EXAME GENÉTICO (especialização)
-- ===============================================
INSERT INTO exame_genetico (nro_protocolo, tipo_amostra, origem_genetica)
VALUES
(1002, 'Sangue', 'Ancestralidade Europeica')
ON CONFLICT DO NOTHING;

-- ===============================================
-- 20) FEATURES (do exame clínico)
-- ===============================================
INSERT INTO feature (nro_protocolo, nome, valor, unidade)
VALUES
(1001, 'Glicose', '180', 'mg/dL'),
(1001, 'Hemoglobina', '13.2', 'g/dL')
ON CONFLICT DO NOTHING;

-- ===============================================
-- 21) MARCADOR GENÉTICO
-- ===============================================
INSERT INTO marcador_genetico (hgvs, descricao)
VALUES
('NM_000059.4:c.2167G>A', 'Mutação associada ao gene BRCA2')
ON CONFLICT DO NOTHING;

-- ===============================================
-- 22) IDENTIFICA (exame genético ↔ marcador)
-- ===============================================
INSERT INTO identifica (nro_protocolo, hgvs)
VALUES
(1002, 'NM_000059.4:c.2167G>A')
ON CONFLICT DO NOTHING;

-- ===============================================
-- 23) ATRELA-SE (diagnóstico ↔ exame)
-- ===============================================
INSERT INTO atrela_se (id_diagnostico, nro_protocolo)
VALUES
(1, 1001),
(1, 1002)
ON CONFLICT DO NOTHING;

-- ===============================================
-- FIM DAS INSERÇÕES COMPLETAS
-- ===============================================