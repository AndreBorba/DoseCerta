-- =========================================================
-- SCRIPT DE LIMPEZA GERAL
-- =========================================================
TRUNCATE TABLE atrela_se CASCADE;
TRUNCATE TABLE identifica CASCADE;
TRUNCATE TABLE marcador_genetico CASCADE;
TRUNCATE TABLE feature CASCADE;
TRUNCATE TABLE exame_genetico CASCADE;
TRUNCATE TABLE exame_clinico CASCADE;
TRUNCATE TABLE exame CASCADE;
TRUNCATE TABLE laboratorio CASCADE;
TRUNCATE TABLE recomendacao_tratamento CASCADE;
TRUNCATE TABLE modelo CASCADE;
TRUNCATE TABLE ocorrencia_sintoma CASCADE;
TRUNCATE TABLE sintoma CASCADE;
TRUNCATE TABLE diagnostico RESTART IDENTITY CASCADE;
TRUNCATE TABLE doenca CASCADE;
TRUNCATE TABLE habitos CASCADE;
TRUNCATE TABLE alergias CASCADE;
TRUNCATE TABLE medicamentos CASCADE;
TRUNCATE TABLE perfil_clinico CASCADE;
TRUNCATE TABLE cuidado CASCADE;
TRUNCATE TABLE paciente CASCADE;
TRUNCATE TABLE medico CASCADE;
TRUNCATE TABLE conta CASCADE;
TRUNCATE TABLE pessoa RESTART IDENTITY CASCADE;


-- =========================================================
-- PARTE 1: PESSOAS (MÉDICOS E PACIENTES)
-- A ordem de inserção define os IDs gerados (1 a 9)
-- =========================================================

-- 1. Médicos (IDs 1 e 2)
INSERT INTO pessoa (cpf, nome_civil, data_nascimento, genero, telefone_contato) VALUES
('111.111.111-11', 'Ricardo Oliveira', '1970-11-20', 'M', '551199991111'),
('222.222.222-22', 'Camila Santos', '1985-05-15', 'F', '551199992222');

-- 2. Pacientes - Grupo 1 (IDs 3, 4, 5)
INSERT INTO pessoa (cpf, nome_civil, data_nascimento, genero, telefone_contato) VALUES
('333.333.333-33', 'Ana Pereira', '1960-03-01', 'F', '551199993333'),
('444.444.444-44', 'Beatriz Costa', '1975-06-15', 'F', '551199994444'),
('555.555.555-55', 'Carlos Menezes', '1980-09-20', 'M', '551199995555');

-- 3. Responsável Legal e Menor de Idade (IDs 6 e 7)
INSERT INTO pessoa (cpf, nome_civil, data_nascimento, genero, telefone_contato) VALUES
('666.666.666-66', 'Mário Souza', '1990-01-01', 'M', '551199996666'),
('777.777.777-77', 'Laura Souza', '2010-12-05', 'F', '551199997777');

-- 4. Pacientes - Grupo 2 (IDs 8 e 9)
INSERT INTO pessoa (cpf, nome_civil, data_nascimento, genero, telefone_contato) VALUES
('888.888.888-88', 'Diana Lima', '1985-06-15', 'F', '551199998888'),
('999.999.999-99', 'Érica Rocha', '2000-01-01', 'F', '551199999999');

-- 5. Pacientes e Médicos (IDs 10 e 11)
INSERT INTO pessoa (cpf, nome_civil, data_nascimento, genero, telefone_contato) VALUES
('010.010.010-10', 'Laura Pereira', '1985-06-15', 'F', '551199991010'),
('011.011.011-11', 'Érica Laura', '2000-01-01', 'F', '551199990011');

-- 6. Pacientes para teste de Consulta 1 (IDS 12 a 16)
INSERT INTO pessoa (cpf, nome_civil, data_nascimento, genero, telefone_contato) VALUES
('121.121.121-21', 'Fernando Alves', '1988-07-22', 'M', '551198888121'),
('131.131.131-31', 'Gabriela Martins', '1992-03-10', 'F', '551198888131'),
('141.141.141-41', 'Lucas Ferreira', '1995-05-12', 'M', '551198888141'),
('151.151.151-51', 'Mariana Costa', '1987-09-08', 'F', '551198888151'),
('161.161.161-61', 'Paulo Oliveira', '1978-11-20', 'M', '551198888161');

-- =========================================================
-- CADASTROS ESPECÍFICOS (MÉDICO, PACIENTE, CONTA)
-- =========================================================

-- Médicos
INSERT INTO medico (id_pseudo, crm, especializacao, local_de_trabalho) VALUES
(1, 'CRM/SP 123456', 'Oncologia', 'Hospital Oncológico Central'),
(2, 'CRM/SP 987654', 'Cardiologia', 'Clínica CardioGen'),
(10, 'CRM/MG 121212', 'Dermatologista', NULL),
(11, 'CRM/MG 554554', 'Ortopedista', 'Ortopedia BH');

-- Pacientes
INSERT INTO paciente (id_pseudo, status_paciente, responsavel, historico_familiar) VALUES
(3, 'ATIVO', NULL, 'Mãe com câncer de mama aos 50 anos.'),
(4, 'ATIVO', NULL, 'Pai fumante e com enfisema.'),
(5, 'ATIVO', NULL, 'Histórico de diabetes e hipertensão na família.'),
(6, 'ATIVO', NULL, NULL), -- Responsável legal cadastrado como paciente
(7, 'ATIVO', 6, 'Avó materna com Alzheimer.'),
(8, 'ATIVO', NULL, 'Irmã com câncer de mama.'),
(9, 'ATIVO', NULL, 'Sem histórico familiar conhecido.'),
(10, 'ATIVO', NULL, 'Mãe com diabetes tipo II.'),
(11, 'ATIVO', NULL, 'Sem histórico familiar conhecido.'),
(12, 'ATIVO', NULL, 'Pai com hipertensão.'),
(13, 'ATIVO', NULL, 'Mãe com diabetes.'),
(14, 'ATIVO', NULL, 'Sem histórico familiar conhecido.'),
(15, 'ATIVO', NULL, 'Pai com hipertensão.'),
(16, 'ATIVO', NULL, 'Mãe com câncer.');

-- Contas de Acesso
INSERT INTO conta (email, senha, id_pessoa) VALUES
('ricardo.med@hospital.com', 'hash_segura_1', 1),
('camila.med@cardiogen.com', 'hash_segura_2', 2),
('mario.souza@email.com', 'hash_segura_3', 6),
('erica.laura@ortobh.com', 'hash_segura_4', 11);


-- =========================================================
-- PARTE 2: CUIDADOS (VÍNCULOS MÉDICO-PACIENTE)
-- =========================================================
INSERT INTO cuidado (id_paciente, id_medico, data_inicio, data_termino) VALUES 
(3, 1, '2025-01-01', NULL),
(4, 1, '2025-01-15', NULL),
(8, 1, '2025-02-01', NULL),
(9, 1, '2025-02-05', NULL),
(5, 2, '2025-02-10', NULL),
(10, 11, '2023-02-10', '2025-02-10'),
(9, 10, '2025-08-08', NULL),
(9, 11, '2021-05-05', '2024-03-07');


-- =========================================================
-- PARTE 3: DOENÇAS, SINTOMAS E DIAGNÓSTICOS
-- =========================================================
INSERT INTO doenca (cid, nome) VALUES
('C50', 'Neoplasia Maligna da Mama'),
('C34', 'Neoplasia Maligna de Brônquios e Pulmão'),
('I10', 'Hipertensão Essencial Primária'),
('E11', 'Diabetes Mellitus Tipo 2'),
('G30', 'Doença de Alzheimer'),
('J45', 'Asma');

INSERT INTO sintoma (cid, nome, descricao) VALUES
('R51', 'Cefaleia', 'Dor de cabeça persistente.'),
('R06.0', 'Dispneia', 'Falta de ar, dificuldade para respirar.'),
('R20', 'Parestesia', 'Formigamento ou dormência.'),
('R00.0', 'Taquicardia', 'Aceleração anormal dos batimentos cardíacos.');

-- Diagnósticos (IDs gerados automaticamente: 1 a 12)
INSERT INTO diagnostico (id_paciente, cid_doenca, data_hora, status) VALUES 
(3, 'C50', '2024-12-01 10:00:00', TRUE), -- ID 1 (Ana)
(4, 'C34', '2025-01-15 12:00:00', TRUE), -- ID 2 (Bia)
(5, 'I10', '2019-10-20 13:00:00', TRUE), -- ID 3 (Carlos)
(5, 'E11', '2021-03-05 14:00:00', TRUE), -- ID 4 (Carlos)
(8, 'C50', '2025-02-01 15:00:00', TRUE), -- ID 5 (Diana)
(9, 'C50', '2025-02-05 16:00:00', TRUE), -- ID 6 (Érica)
(7, 'J45', '2023-08-10 17:00:00', TRUE), -- ID 7 (Laura)
(12, 'C50', '2025-05-01 09:00:00', TRUE),  -- Fernando: Câncer de mama, sem exame genético
(13, 'E11', '2025-05-03 10:00:00', TRUE),  -- Gabriela: Diabetes, sem exame genético
(14, 'C50', '2025-05-10 10:00:00', FALSE),  -- Inativo → não aparece
(15, 'E11', '2025-05-11 11:00:00', TRUE),   -- Ativo, mas com exame genético vinculado → não aparece
(16, 'J45', '2025-05-12 12:00:00', FALSE);   -- Ativo, mas CID diferente da busca → não aparece

-- Ocorrências de Sintomas
INSERT INTO ocorrencia_sintoma (id_diagnostico, cid_sintoma, data_inicio, duracao, observacao) VALUES
(1, 'R51', '2025-04-01 08:00:00', '2 dias', 'Relacionado à quimioterapia.'),
(2, 'R00.0', '2025-04-05 10:00:00', '1 semana', 'Sintoma comum da hipertensão.');


-- =========================================================
-- PARTE 4: PERFIL CLÍNICO, HÁBITOS E MEDICAMENTOS
-- =========================================================
INSERT INTO perfil_clinico (id_paciente, data, peso_kg, altura_m, gravidez) VALUES 
(3, '2025-04-01', 95.00, 1.76, FALSE),
(4, '2025-04-05', 65.00, 1.65, FALSE),
(5, '2025-04-10', 115.00, 1.80, FALSE),
(6, '2025-01-01', 80.00, 1.75, FALSE),
(7, '2025-04-15', 50.00, 1.55, FALSE),
(8, '2025-04-20', 60.00, 1.60, FALSE),
(9, '2025-04-25', 75.00, 1.70, FALSE);

INSERT INTO habitos (id_paciente, habito, data) VALUES 
(4, 'TABAGISMO', '2025-04-05'), 
(5, 'ALCOOLISMO (MODERADO)', '2025-04-10'), 
(3, 'SEDENTARISMO', '2025-04-01'), 
(6, 'PRÁTICA DE EXERCÍCIOS', '2025-01-01');

INSERT INTO alergias (id_paciente, data, alergia) VALUES 
(3, '2025-04-01', 'PENICILINA'), 
(5, '2025-04-10', 'SULFA'), 
(4, '2025-04-05', 'DIPIRONA'), 
(8, '2025-04-20', 'AMOXICILINA');

INSERT INTO medicamentos (id_paciente, data, medicamento) VALUES 
(5, '2025-04-10', 'METFORMINA (Diabetes)'), 
(5, '2025-04-10', 'ENALAPRIL (Hipertensão)'), 
(3, '2025-04-01', 'TAMOXIFENO (Câncer)'), 
(7, '2025-04-15', 'CORTICOIDE (Asma)');


-- =========================================================
-- PARTE 5: LABORATÓRIOS, MARCADORES E EXAMES
-- =========================================================
INSERT INTO laboratorio (cnpj, razao_social, cnes, endereco) VALUES
('00.000.000/0001-01', 'LAB GENE BR', '11111', 'Rua Alfa, 100'),
('00.000.000/0002-02', 'LAB CLINICO SA', '22222', 'Av. Beta, 200');

INSERT INTO marcador_genetico (hgvs, descricao) VALUES
('BRCA1', 'Gene de Suscetibilidade ao Câncer de Mama 1'),
('BRCA2', 'Gene de Suscetibilidade ao Câncer de Mama 2'),
('EGFR L858R', 'Mutações de Câncer de Pulmão (Somático)'),
('T790M', 'Mutações de Câncer de Pulmão (Somático)'),
('CYP2C19', 'Metabolismo de Clopidogrel'),
('VKORC1', 'Metabolismo de Varfarina');

INSERT INTO modelo (nome, url) VALUES
('ONCO_BRCA_V1', 'http://modelo.com/brca'),
('CARDIO_HIPER_V2', 'http://modelo.com/cardio'),
('PULMAO_EGFR_V1', 'http://modelo.com/egfr');

-- RECOMENDAÇÕES DE TRATAMENTO (2+ Inserções)
INSERT INTO recomendacao_tratamento (id_diagnostico, nome_modelo, data_hora, texto_recomendacao) VALUES
(1, 'ONCO_BRCA_V1', '2025-01-05 10:00:00', 'Quimioterapia padrão + terapia alvo devido ao BRCA1.'),
(2, 'PULMAO_EGFR_V1', '2025-02-15 11:00:00', 'Uso de inibidores de tirosina quinase devido à mutação EGFR.'),
(3, 'CARDIO_HIPER_V2', '2025-03-01 09:00:00', 'Ajuste de anti-hipertensivo e monitoramento quinzenal.');

-- EXAMES E DETALHES (Genéticos e Clínicos)

-- Exame 1: Ana Pereira (Genético)
INSERT INTO exame (nro_protocolo, id_paciente, cnpj_laboratorio, data_hora, tipo) VALUES (1001, 3, '00.000.000/0001-01', '2025-01-05 09:00:00', 'GENETICO');
INSERT INTO exame_genetico (nro_protocolo, tipo_amostra, origem_genetica) VALUES (1001, 'SANGUINEA', 'GERMINATIVO');
INSERT INTO identifica (nro_protocolo, hgvs) VALUES (1001, 'BRCA1'), (1001, 'BRCA2');

-- Exame 2: Diana Lima (Genético)
INSERT INTO exame (nro_protocolo, id_paciente, cnpj_laboratorio, data_hora, tipo) VALUES (1002, 8, '00.000.000/0001-01', '2025-02-01 10:00:00', 'GENETICO');
INSERT INTO exame_genetico (nro_protocolo, tipo_amostra, origem_genetica) VALUES (1002, 'SANGUINEA', 'GERMINATIVO');
INSERT INTO identifica (nro_protocolo, hgvs) VALUES (1002, 'BRCA1'), (1002, 'BRCA2');

-- Exame 3: Érica Rocha (Genético)
INSERT INTO exame (nro_protocolo, id_paciente, cnpj_laboratorio, data_hora, tipo) VALUES (1003, 9, '00.000.000/0001-01', '2025-02-05 11:00:00', 'GENETICO');
INSERT INTO exame_genetico (nro_protocolo, tipo_amostra, origem_genetica) VALUES (1003, 'SANGUINEA', 'GERMINATIVO');
INSERT INTO identifica (nro_protocolo, hgvs) VALUES (1003, 'BRCA1'), (1003, 'BRCA2');

-- Exame 4: Beatriz Costa (Genético Somático)
INSERT INTO exame (nro_protocolo, id_paciente, cnpj_laboratorio, data_hora, tipo) VALUES (1004, 4, '00.000.000/0001-01', '2025-02-15 12:00:00', 'GENETICO');
INSERT INTO exame_genetico (nro_protocolo, tipo_amostra, origem_genetica) VALUES (1004, 'TUMOR', 'SOMATICO');
INSERT INTO identifica (nro_protocolo, hgvs) VALUES (1004, 'EGFR L858R'), (1004, 'T790M');

-- Exame 5: Carlos Menezes (Clínico)
INSERT INTO exame (nro_protocolo, id_paciente, cnpj_laboratorio, data_hora, tipo) VALUES (1005, 5, '00.000.000/0002-02', '2025-02-15 11:00:00', 'CLINICO');
INSERT INTO exame_clinico (nro_protocolo) VALUES (1005);
INSERT INTO feature (nro_protocolo, nome, valor, unidade) VALUES
(1005, 'GLICOSE', '135', 'mg/dL'),
(1005, 'HEMOGLOBINA', '14.2', 'g/dL');

-- Exame 6: Ana Pereira (Outro Genético)
INSERT INTO exame (nro_protocolo, id_paciente, cnpj_laboratorio, data_hora, tipo) VALUES (1006, 3, '00.000.000/0001-01', '2025-03-01 13:00:00', 'GENETICO');
INSERT INTO exame_genetico (nro_protocolo, tipo_amostra, origem_genetica) VALUES (1006, 'SANGUINEA', 'GERMINATIVO');
INSERT INTO identifica (nro_protocolo, hgvs) VALUES (1006, 'CYP2C19');

-- Exame 7: Mário Souza (Clínico - Checkup)
INSERT INTO exame (nro_protocolo, id_paciente, cnpj_laboratorio, data_hora, tipo) VALUES (1007, 6, '00.000.000/0002-02', '2025-01-10 08:00:00', 'CLINICO');
INSERT INTO exame_clinico (nro_protocolo) VALUES (1007);
INSERT INTO feature (nro_protocolo, nome, valor, unidade) VALUES
(1007, 'COLESTEROL TOTAL', '190', 'mg/dL'),
(1007, 'TRIGLICERIDEOS', '150', 'mg/dL');

-- Exame 8: Laura Souza (Clínico - Asma)
INSERT INTO exame (nro_protocolo, id_paciente, cnpj_laboratorio, data_hora, tipo) VALUES (1008, 7, '00.000.000/0002-02', '2025-04-16 14:00:00', 'CLINICO');
INSERT INTO exame_clinico (nro_protocolo) VALUES (1008);
INSERT INTO feature (nro_protocolo, nome, valor, unidade) VALUES
(1008, 'EOSINOFILOS', '450', '/mm3'),
(1008, 'IGE TOTAL', '120', 'UI/mL');

-- Exame 9 e 10: Teste de Consulta 1 Positiva
INSERT INTO exame (nro_protocolo, id_paciente, cnpj_laboratorio, data_hora, tipo) VALUES
(1009, 12, '00.000.000/0002-02', '2025-05-02 08:00:00', 'CLINICO'),
(1010, 13, '00.000.000/0002-02', '2025-05-04 11:00:00', 'CLINICO');
INSERT INTO exame_clinico (nro_protocolo) VALUES (1009), (1010);
INSERT INTO feature (nro_protocolo, nome, valor, unidade) VALUES
(1009, 'GLICOSE', '120', 'mg/dL'),
(1010, 'PRESSAO_SISTOLICA', '130', 'mmHg');

-- Exame 11: Teste de Consulta 1 Negativa
INSERT INTO exame (nro_protocolo, id_paciente, cnpj_laboratorio, data_hora, tipo) VALUES
(1011, 15, '00.000.000/0001-01', '2025-05-11 10:00:00', 'GENETICO');
INSERT INTO exame_genetico (nro_protocolo, tipo_amostra, origem_genetica) VALUES
(1011, 'SANGUINEA', 'GERMINATIVO');
INSERT INTO identifica (nro_protocolo, hgvs) VALUES
(1011, 'BRCA1');


-- =========================================================
-- PARTE 6: ATRELA-SE (Vincula Exames a Diagnósticos)
-- =========================================================
INSERT INTO atrela_se (id_diagnostico, nro_protocolo) VALUES (1, 1001); -- Ana C50 -> Exame BRCA
INSERT INTO atrela_se (id_diagnostico, nro_protocolo) VALUES (2, 1004); -- Bia C34 -> Exame EGFR
INSERT INTO atrela_se (id_diagnostico, nro_protocolo) VALUES (3, 1005); -- Carlos I10 -> Exame Clinico
INSERT INTO atrela_se (id_diagnostico, nro_protocolo) VALUES (5, 1002); -- Diana C50 -> Exame BRCA
INSERT INTO atrela_se (id_diagnostico, nro_protocolo) VALUES (6, 1003); -- Erica C50 -> Exame BRCA
INSERT INTO atrela_se (id_diagnostico, nro_protocolo) VALUES (7, 1008); -- Laura J45 -> Exame Clinico
INSERT INTO atrela_se (id_diagnostico, nro_protocolo) VALUES (11, 1011); -- Mariana E11 -> EXame BRCA1

