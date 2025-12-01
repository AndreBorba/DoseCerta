-- Primeiro, derruba as tabelas se já existirem
-- (isso facilita na hora de ajustar o modelo durante o desenvolvimento)
DROP TABLE IF EXISTS atrela_se CASCADE;
DROP TABLE IF EXISTS identifica CASCADE;
DROP TABLE IF EXISTS marcador_genetico CASCADE;
DROP TABLE IF EXISTS feature CASCADE;
DROP TABLE IF EXISTS exame_genetico CASCADE;
DROP TABLE IF EXISTS exame_clinico CASCADE;
DROP TABLE IF EXISTS exame CASCADE;
DROP TABLE IF EXISTS laboratorio CASCADE;

DROP INDEX IF EXISTS uq_diagnostico_ativo;
DROP INDEX IF EXISTS uq_cuidado_ativo;

DROP TABLE IF EXISTS recomendacao_tratamento CASCADE;
DROP TABLE IF EXISTS modelo CASCADE;
DROP TABLE IF EXISTS ocorrencia_sintoma CASCADE;
DROP TABLE IF EXISTS sintoma CASCADE;
DROP TABLE IF EXISTS diagnostico CASCADE;
DROP TABLE IF EXISTS doenca CASCADE;

DROP TABLE IF EXISTS habitos CASCADE;
DROP TABLE IF EXISTS alergias CASCADE;
DROP TABLE IF EXISTS medicamentos CASCADE;
DROP TABLE IF EXISTS perfil_clinico CASCADE;
DROP TABLE IF EXISTS cuidado CASCADE;
DROP TABLE IF EXISTS paciente CASCADE;
DROP TABLE IF EXISTS medico CASCADE;
DROP TABLE IF EXISTS conta CASCADE;
DROP TABLE IF EXISTS pessoa CASCADE;


-- Tabela 1: Pessoa
-- Armazena dados pessoais genéricos, servindo como base para Paciente e Médico.
CREATE TABLE pessoa(
    id_pseudo BIGINT GENERATED ALWAYS AS IDENTITY, -- Chave artificial auto-incrementada para privacidade (padrão SQL de geração automática)
    cpf CHAR(14) NOT NULL,
    nome_civil VARCHAR(60) NOT NULL,
    data_nascimento DATE NOT NULL,
    telefone_contato VARCHAR(20),
    genero VARCHAR(30),

    CONSTRAINT pk_pessoa PRIMARY KEY (id_pseudo),
    CONSTRAINT uk_pessoa UNIQUE (cpf),
    CONSTRAINT ck_pessoa_formato_cpf 
        CHECK (cpf ~ '^[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}$')
);


-- Tabela 2: Conta
-- Tabela para armazenar os dados da conta do paciente ou tutor.
CREATE TABLE conta(
email VARCHAR(100),
senha VARCHAR(50) NOT NULL,
id_pessoa BIGINT NOT NULL,

CONSTRAINT pk_conta PRIMARY KEY (email),
CONSTRAINT uk_conta UNIQUE (id_pessoa),
CONSTRAINT fk_pessoa FOREIGN KEY (id_pessoa)
    REFERENCES pessoa(id_pseudo) 
);


-- Tabela 3: Médico
-- Especialização de Pessoa. Armazena dados específicos do médico.
CREATE TABLE medico(
    id_pseudo BIGINT,
    crm VARCHAR(15) NOT NULL,
    especializacao VARCHAR(50),
    local_de_trabalho VARCHAR(150),

    CONSTRAINT pk_medico PRIMARY KEY (id_pseudo),
    CONSTRAINT uk_medico UNIQUE (crm),
    CONSTRAINT fk_medico FOREIGN KEY (id_pseudo)
        REFERENCES pessoa(id_pseudo)
);


-- Tabela 4: Paciente
-- Especialização de Pessoa. Armazena dados específicos do paciente.
CREATE TABLE paciente(
    id_pseudo BIGINT,
    status_paciente VARCHAR(8) NOT NULL, -- pode ser apenas "ativo" ou "inativo"
    responsavel BIGINT, -- variavel que é usada no caso do paciente ser menor de idade
    historico_familiar TEXT, -- Considerando que o histórico familiar vai ser armazenado somente em forma de texto

    CONSTRAINT pk_paciente PRIMARY KEY (id_pseudo),
    CONSTRAINT fk_paciente_pessoa FOREIGN KEY (id_pseudo)
        REFERENCES pessoa(id_pseudo),

    -- Abaixo encontra-se o auto relacionamento. O responsável acaba por ter que cadastrar-se como um paciente também
    CONSTRAINT fk_paciente_paciente FOREIGN KEY (responsavel)
        REFERENCES paciente(id_pseudo),

    -- Respeitando o Note 5: paciente não pode ser responsável de si mesmo
    CONSTRAINT ck_paciente_autoresponsavel CHECK(responsavel IS NULL OR responsavel <> id_pseudo),

    CONSTRAINT ck_tipo_status CHECK(UPPER(status_paciente) IN ('ATIVO', 'INATIVO'))   
);

-- Tabela 5: Cuidado
-- Agregação que representa o relacionamento de cuidado entre Médico e Paciente.
CREATE TABLE cuidado(
    id_paciente BIGINT NOT NULL,
    id_medico BIGINT NOT NULL,
    data_inicio DATE NOT NULL,
    data_termino DATE,

    CONSTRAINT pk_cuidado PRIMARY KEY (id_paciente, id_medico, data_inicio),
    CONSTRAINT fk_cuidado_paciente FOREIGN KEY (id_paciente)
        REFERENCES paciente(id_pseudo),
    CONSTRAINT fk_cuidado_medico FOREIGN KEY (id_medico)
        REFERENCES medico(id_pseudo),

    -- Validando Note1 AINDA PRECISO VER SOBRE A IMPLICAÇÃO DELE EM "ATIVO/INATIVO"
    CONSTRAINT ck_cuidado_datas_validas
        CHECK(
            data_termino IS NULL
            OR (data_termino >= data_inicio AND data_termino <= CURRENT_DATE)
        ),
    
    -- Validando Note2 -> paciente não pode ser o próprio médico
    CONSTRAINT ck_cuidado_paciente_medico CHECK (id_paciente <> id_medico)
);

-- Tabela 6: Perfil_Clinico
-- Armazena o histórico de perfis clínicos (peso, altura, etc.) do Paciente.
CREATE TABLE perfil_clinico(
    id_paciente BIGINT NOT NULL,
    data DATE NOT NULL,
    peso_kg NUMERIC(5,2),
    altura_m NUMERIC(3,2),
    gravidez BOOLEAN,

    CONSTRAINT pk_perfil_clinico PRIMARY KEY (id_paciente, data),
    CONSTRAINT fk_perfil_clinico FOREIGN KEY (id_paciente)
        REFERENCES paciente(id_pseudo)
);

-- Tabela 7: Medicamentos
-- Atributo multivalorado de perfil_clinico que se tornou uma nova tabela.
CREATE TABLE medicamentos(
    id_paciente BIGINT NOT NULL,
    data DATE NOT NULL,
    medicamento VARCHAR(100) NOT NULL,

    CONSTRAINT pk_medicamentos PRIMARY KEY (id_paciente, data, medicamento),
    CONSTRAINT fk_medicamentos FOREIGN KEY (id_paciente, data)
        REFERENCES perfil_clinico(id_paciente, data)
);

-- Tabela 8: Alergias
-- Atributo multivalorado de perfil_clinico que se tornou uma nova tabela.
CREATE TABLE alergias(
    id_paciente BIGINT NOT NULL,
    data DATE NOT NULL,
    alergia VARCHAR(100),

    CONSTRAINT pk_alergias PRIMARY KEY (id_paciente, data, alergia),
    CONSTRAINT fk_alergias FOREIGN KEY (id_paciente, data)
        REFERENCES perfil_clinico(id_paciente, data)
);

-- Tabela 9: Habitos
-- Atributo multivalorado de perfil_clinico que se tornou uma nova tabela.
CREATE TABLE habitos(
    id_paciente BIGINT NOT NULL,
    habito VARCHAR(100) NOT NULL,
    data DATE NOT NULL,

    CONSTRAINT pk_habitos PRIMARY KEY (id_paciente, habito, data),
    CONSTRAINT fk_habitos FOREIGN KEY (id_paciente, data)
        REFERENCES perfil_clinico(id_paciente, data)
);

-- Tabela 10: Doença
-- Cataloga as diferentes doenças.
CREATE TABLE doenca(
    cid VARCHAR(10) NOT NULL,
    nome VARCHAR(100),

    CONSTRAINT pk_doenca PRIMARY KEY (cid)
);

-- Tabela 11: Diagnostico
-- Agregação que associa um Paciente a uma Doença.
CREATE TABLE diagnostico(
    id_diagnostico BIGINT GENERATED ALWAYS AS IDENTITY, -- Chave artificial auto-incrementada para privacidade (padrão SQL de geração automática)
    id_paciente BIGINT NOT NULL,
    cid_doenca VARCHAR(10) NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    status BOOLEAN NOT NULL, -- 1 = ativo; 0 = inativo / "curado"

    CONSTRAINT pk_diagnostico PRIMARY KEY (id_diagnostico),
    CONSTRAINT uk_diagnostico UNIQUE (id_paciente, cid_doenca, data_hora),
    CONSTRAINT fk_diag_paciente FOREIGN KEY (id_paciente)
        REFERENCES paciente(id_pseudo),
    CONSTRAINT fk_diag_doenca FOREIGN KEY (cid_doenca)
        REFERENCES doenca(cid)
);

-- Tabela 12: Sintoma
-- Cataloga os diferentes tipos de sintomas existentes.
CREATE TABLE sintoma(
    cid VARCHAR(10) NOT NULL,
    nome VARCHAR(100),
    descricao TEXT,

    CONSTRAINT pk_sintoma PRIMARY KEY (cid)
);

-- Tabela 13: Ocorrência de Sintoma
-- Registro do sintoma específico de cada paciente, atrelado ao seu diagnóstico.
CREATE TABLE ocorrencia_sintoma(
    id_diagnostico BIGINT NOT NULL,
    cid_sintoma VARCHAR(10) NOT NULL,
    data_inicio TIMESTAMP NOT NULL,
    duracao VARCHAR(50), -- aqui deve ser inserido algo como "5 meses"
    observacao TEXT,

    CONSTRAINT pk_ocorrencia_sintoma PRIMARY KEY (id_diagnostico, cid_sintoma, data_inicio),
    CONSTRAINT fk_ocorrencia_diag FOREIGN KEY (id_diagnostico)
        REFERENCES diagnostico (id_diagnostico),
    CONSTRAINT fk_ocorrencia_sintoma FOREIGN KEY (cid_sintoma)
        REFERENCES sintoma(cid)
);

-- Tabela 14: Modelo
-- Aqui são guardados os links para utiização dos modelos de machine learning que irão propor um tratamento para o paciente
CREATE TABLE modelo(
    nome VARCHAR(100) NOT NULL,
    url  VARCHAR(255) NOT NULL,

    CONSTRAINT pk_modelo PRIMARY KEY (nome),
    CONSTRAINT uk_modelo_url UNIQUE (url)
);

-- Tabela 15: Recomendação de Tratamento
-- Agregação que armazena a recomendação de um Modelo para um Diagnóstico.
CREATE TABLE recomendacao_tratamento(
    id_diagnostico BIGINT NOT NULL,
    nome_modelo VARCHAR(100) NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    texto_recomendacao TEXT NOT NULL,

    CONSTRAINT pk_recomendacao_tratamento PRIMARY KEY (id_diagnostico, nome_modelo, data_hora),
    CONSTRAINT fk_reco_diag FOREIGN KEY (id_diagnostico)
        REFERENCES diagnostico(id_diagnostico),
    CONSTRAINT fk_reco_modelo FOREIGN KEY (nome_modelo)
        REFERENCES modelo(nome)
);

-- Tabela 16: Laboratório
-- Armazena dados cadastrais dos laboratórios.
CREATE TABLE laboratorio(
    cnpj CHAR(18) NOT NULL,
    razao_social VARCHAR(100),
    endereco VARCHAR(200),
    cnes VARCHAR(20),
    email VARCHAR(100),
    telefone1 VARCHAR(20),
    telefone2 VARCHAR(20),

    CONSTRAINT pk_laboratorio PRIMARY KEY (cnpj),
    CONSTRAINT uk_laboratorio_cnes UNIQUE (cnes)
);

-- Tabela 17: Exame
-- Agregação que representa um exame, realizado por um Laboratório para um Paciente.
CREATE TABLE exame(
    nro_protocolo BIGINT,
    id_paciente BIGINT NOT NULL,
    cnpj_laboratorio CHAR(18) NOT NULL,
    data_hora TIMESTAMP,
    tipo VARCHAR(10) NOT NULL,  -- 'CLINICO' ou 'GENETICO'

    CONSTRAINT pk_exame PRIMARY KEY (nro_protocolo),
    CONSTRAINT fk_exame_paciente FOREIGN KEY (id_paciente)
        REFERENCES paciente(id_pseudo),
    CONSTRAINT fk_exame_laboratorio FOREIGN KEY (cnpj_laboratorio)
        REFERENCES laboratorio(cnpj),

    -- tipos válidos de exame-> especialização total/disjunção ficam a cargo da aplicação (Note 8)
    CONSTRAINT ck_exame_tipo_valido
        CHECK (UPPER(tipo) IN ('CLINICO', 'GENETICO'))
);

-- Tabela 18: Exame Clínico
-- Especialização de Exame.
CREATE TABLE exame_clinico(
    nro_protocolo BIGINT NOT NULL,

    CONSTRAINT pk_exame_clinico PRIMARY KEY (nro_protocolo),
    CONSTRAINT fk_exame_clinico_exame FOREIGN KEY (nro_protocolo)
        REFERENCES exame(nro_protocolo)
);

-- Tabela 19: Exame Genético
-- Especialização de Exame.
CREATE TABLE exame_genetico(
    nro_protocolo BIGINT NOT NULL,
    tipo_amostra VARCHAR(100),
    origem_genetica VARCHAR(15) NOT NULL,

    CONSTRAINT pk_exame_genetico PRIMARY KEY (nro_protocolo),
    CONSTRAINT fk_exame_genetico_exame FOREIGN KEY (nro_protocolo)
        REFERENCES exame(nro_protocolo),
	CONSTRAINT ck_origem_genetica CHECK (UPPER(origem_genetica) IN ('SOMATICO', 'GERMINATIVO'))
);

-- Tabela 20: Features
-- Atributo multivalorado de Exame_Clinico (exemplo: "Glicose", "70", "mg/dL"). Cada laudo clínico tem várias features
CREATE TABLE feature(
    nro_protocolo BIGINT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    valor VARCHAR(15) NOT NULL,
    unidade VARCHAR(50),

    CONSTRAINT pk_feature PRIMARY KEY (nro_protocolo, nome),
    CONSTRAINT fk_feature_exame_clinico FOREIGN KEY (nro_protocolo)
        REFERENCES exame_clinico(nro_protocolo)
);

-- Tabela 21: Marcadores Genéticos
-- Cataloga os diferentes marcadores genéticos com suas descrições
CREATE TABLE marcador_genetico(
    hgvs VARCHAR(100),
    descricao TEXT,

    CONSTRAINT pk_marcador_genetico PRIMARY KEY (hgvs)
);

-- Tabela 22: Identifica
-- Relacionamento N:M entre Exame_Genetico e Marcadores_Geneticos
CREATE TABLE identifica(
    nro_protocolo BIGINT NOT NULL,
    hgvs VARCHAR(100) NOT NULL,

    CONSTRAINT pk_identifica PRIMARY KEY (nro_protocolo, hgvs),
    CONSTRAINT fk_identifica_exame_genetico FOREIGN KEY (nro_protocolo)
        REFERENCES exame_genetico(nro_protocolo),
    CONSTRAINT fk_identifica_marcador FOREIGN KEY (hgvs)
        REFERENCES marcador_genetico(hgvs)
);

-- Tabela 23: Atrela-se
-- Relacionamento N:M entre Diagnostico e Exame
CREATE TABLE atrela_se(
    id_diagnostico BIGINT NOT NULL,
    nro_protocolo  BIGINT NOT NULL,

    CONSTRAINT pk_atrela_se PRIMARY KEY (id_diagnostico, nro_protocolo),
    CONSTRAINT fk_atrela_se_diag FOREIGN KEY (id_diagnostico)
        REFERENCES diagnostico(id_diagnostico),
    CONSTRAINT fk_atrela_se_exame FOREIGN KEY (nro_protocolo)
        REFERENCES exame(nro_protocolo)
);

-- =========================================================
-- ÍNDICES E RESTRIÇÕES ADICIONAIS
-- =========================================================

-- Note 3: para um mesmo médico e paciente, só pode haver um cuidado ATIVO
-- (ou seja, com data_termino IS NULL). Então só podemos ter um "data_termino" NULL
CREATE UNIQUE INDEX uq_cuidado_ativo
ON cuidado (id_paciente, id_medico)
WHERE data_termino IS NULL;

-- Note 7: para um mesmo Paciente e Doença só pode haver um diagnóstico ativo
CREATE UNIQUE INDEX uq_diagnostico_ativo
ON diagnostico (id_paciente, cid_doenca)
WHERE status = TRUE;