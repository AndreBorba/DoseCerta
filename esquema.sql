-- Tabela 1: Pessoa
-- Armazena dados pessoais genéricos, servindo como base para Paciente e Médico.
CREATE TABLE Pessoa (
    IdPseudo NUMBER(10) NOT NULL,
    CPF CHAR(11) NOT NULL,
    nome_civil VARCHAR2(60) NOT NULL,
    data_nascimento DATE NOT NULL,
    telefone_contato VARCHAR2(20) NOT NULL,
    genero VARCHAR2(30),
    CONSTRAINT PK_PESSOA PRIMARY KEY(IdPseudo),
    CONSTRAINT SK_PESSOA_CPF UNIQUE(CPF),
    CONSTRAINT CK_CPF CHECK(REGEXP_LIKE(CPF, '[0-9]{3}\.[0-9]{3}\.[0-9]{3}\-[0-9]{2}'))
);

-- Tabela 2: Doenca
-- Tabela de domínio para armazenar as doenças (CID e nome).
CREATE TABLE Doenca (
    CID VARCHAR2(8) NOT NULL,
    nome VARCHAR2(100),
    CONSTRAINT PK_DOENCA PRIMARY KEY(CID)
);


-- Tabela 3: Sintoma
-- Tabela de domínio para armazenar os sintomas (CID, nome, descrição).
CREATE TABLE Sintoma (
    CID VARCHAR2(8) NOT NULL,
    nome VARCHAR2(50),
    descricao VARCHAR2(500),
    CONSTRAINT PK_SINTOMA PRIMARY KEY(CID)
);

-- --------
-- Tabela 4: Modelo
-- Tabela de domínio para armazenar os Modelos de IA (nome e URL).
-- --------
CREATE TABLE Modelo (
    nome VARCHAR2(100) NOT NULL,
    url VARCHAR2(255) NOT NULL,
    CONSTRAINT PK_MODELO PRIMARY KEY(nome),
    CONSTRAINT UQ_MODELO_URL UNIQUE(url)
);

-- --------
-- Tabela 5: Laboratorio
-- Armazena dados cadastrais dos laboratórios.
-- --------
CREATE TABLE Laboratorio (
    CNPJ VARCHAR2(18) NOT NULL,
    razao_social VARCHAR2(100) NOT NULL,
    endereco VARCHAR2(255),
    CNES VARCHAR2(20) NOT NULL,
    email VARCHAR2(100),
    telefone1 VARCHAR2(20),
    telefone2 VARCHAR2(20),
    CONSTRAINT PK_LABORATORIO PRIMARY KEY(CNPJ),
    CONSTRAINT UQ_LABORATORIO_CNES UNIQUE(CNES)
);

-- --------
-- Tabela 6: Marcadores_Geneticos
-- Tabela de domínio para armazenar os marcadores genéticos (HGVS e descrição).
-- --------
CREATE TABLE Marcadores_Geneticos (
    HGVS VARCHAR2(100) NOT NULL,
    descricao VARCHAR2(500),
    CONSTRAINT PK_MARCADORES_GENETICOS PRIMARY KEY(HGVS)
);

-- --------
-- Tabela 7: Conta
-- Armazena dados de autenticação (login/senha) e associa a uma Pessoa (1:1).
-- --------
CREATE TABLE Conta (
    email VARCHAR2(100) NOT NULL,
    senha VARCHAR2(100) NOT NULL, -- Em um sistema real, armazenar o HASH da senha.
    pessoa NUMBER(10) NOT NULL,
    CONSTRAINT PK_CONTA PRIMARY KEY(email),
    CONSTRAINT UQ_CONTA_PESSOA UNIQUE(pessoa), -- Garante a relação 1:1
    CONSTRAINT FK_CONTA_PESSOA FOREIGN KEY(pessoa) REFERENCES Pessoa(IdPseudo) ON DELETE CASCADE
    -- Note 9 (aplicação): "Um paciente menor de idade não pode possuir uma conta."
);

-- --------
-- Tabela 8: Medico
-- Especialização de Pessoa. Armazena dados específicos do médico.
-- --------
CREATE TABLE Medico (
    IdPseudo NUMBER(10) NOT NULL,
    CRM VARCHAR2(20) NOT NULL,
    especializacao VARCHAR2(100),
    local_de_trabalho VARCHAR2(100),
    CONSTRAINT PK_MEDICO PRIMARY KEY(IdPseudo),
    CONSTRAINT UQ_MEDICO_CRM UNIQUE(CRM),
    CONSTRAINT FK_MEDICO_PESSOA FOREIGN KEY(IdPseudo) REFERENCES Pessoa(IdPseudo) ON DELETE CASCADE
);

-- --------
-- Tabela 9: Paciente
-- Especialização de Pessoa. Armazena dados específicos do paciente.
-- --------
CREATE TABLE Paciente (
    IdPseudo NUMBER(10) NOT NULL,
    status VARCHAR2(10) NOT NULL,
    responsavel NUMBER(10),
    historico_familiar CLOB, -- CLOB para textos longos (laudos)
    CONSTRAINT PK_PACIENTE PRIMARY KEY(IdPseudo),
    CONSTRAINT FK_PACIENTE_PESSOA FOREIGN KEY(IdPseudo) REFERENCES Pessoa(IdPseudo) ON DELETE CASCADE,
    CONSTRAINT FK_PACIENTE_RESPONSAVEL FOREIGN KEY(responsavel) REFERENCES Paciente(IdPseudo) ON DELETE SET NULL,
    CONSTRAINT CK_PACIENTE_STATUS CHECK(status IN ('ativo', 'inativo')),
    -- Note 5: "Paciente não pode ser responsável de si mesmo."
    CONSTRAINT CK_PACIENTE_AUTORESPONSAVEL CHECK(IdPseudo != responsavel)
    -- Note 4 (aplicação/trigger): "Se Paciente for menor de idade... responsável deve ser não nulo."
    -- Note 6 (aplicação): "Fazer verificação por documento legal se Responsável é..."
);

-- --------
-- Tabela 10: Cuidado
-- Agregação que representa o relacionamento de cuidado entre Médico e Paciente.
-- --------
CREATE TABLE Cuidado (
    Paciente NUMBER(10) NOT NULL,
    Medico NUMBER(10) NOT NULL,
    data_inicio DATE NOT NULL,
    data_de_termino DATE,
    CONSTRAINT PK_CUIDADO PRIMARY KEY(Paciente, Medico, data_inicio),
    CONSTRAINT FK_CUIDADO_PACIENTE FOREIGN KEY(Paciente) REFERENCES Paciente(IdPseudo) ON DELETE CASCADE,
    CONSTRAINT FK_CUIDADO_MEDICO FOREIGN KEY(Medico) REFERENCES Medico(IdPseudo) ON DELETE CASCADE,
    -- Note 1: "data de término... deve ser posterior à data de início..."
    CONSTRAINT CK_CUIDADO_DATAS CHECK(data_de_termino IS NULL OR data_de_termino > data_inicio),
    -- Note 2: "Os IdPseudo de Médico e de Paciente... devem ser distintos"
    CONSTRAINT CK_CUIDADO_PACIENTE_MEDICO CHECK(Paciente != Medico)
);

-- Note 3: "Para um mesmo Médico e Paciente só pode haver um Cuidado ativo (data_de_termino IS NULL)."
-- Isto é implementado com um índice único funcional (Oracle).
CREATE UNIQUE INDEX UQ_CUIDADO_ATIVO ON Cuidado (
    CASE WHEN data_de_termino IS NULL THEN Paciente ELSE NULL END,
    CASE WHEN data_de_termino IS NULL THEN Medico ELSE NULL END
);

-- --------
-- Tabela 11: Perfil_Clinico
-- Armazena o histórico de perfis clínicos (peso, altura, etc.) do Paciente.
-- --------
CREATE TABLE Perfil_Clinico (
    Paciente NUMBER(10) NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    peso NUMBER(5, 2), -- Ex: 120.50
    altura NUMBER(3, 2), -- Ex: 1.75
    gravidez CHAR(1),
    CONSTRAINT PK_PERFIL_CLINICO PRIMARY KEY(Paciente, data_hora),
    CONSTRAINT FK_PERFIL_PACIENTE FOREIGN KEY(Paciente) REFERENCES Paciente(IdPseudo) ON DELETE CASCADE,
    CONSTRAINT CK_PERFIL_GRAVIDEZ CHECK(gravidez IN ('S', 'N', NULL)) -- Permitir nulo se não aplicável
);

-- --------
-- Tabela 12: Medicamentos
-- Atributo multivalorado de Perfil_Clinico.
-- --------
CREATE TABLE Medicamentos (
    Paciente NUMBER(10) NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    medicamento VARCHAR2(100) NOT NULL,
    CONSTRAINT PK_MEDICAMENTOS PRIMARY KEY(Paciente, data_hora, medicamento),
    CONSTRAINT FK_MEDICAMENTOS_PERFIL FOREIGN KEY(Paciente, data_hora) REFERENCES Perfil_Clinico(Paciente, data_hora) ON DELETE CASCADE
);

-- --------
-- Tabela 13: Alergias
-- Atributo multivalorado de Perfil_Clinico.
-- --------
CREATE TABLE Alergias (
    Paciente NUMBER(10) NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    alergia VARCHAR2(100) NOT NULL,
    CONSTRAINT PK_ALERGIAS PRIMARY KEY(Paciente, data_hora, alergia),
    CONSTRAINT FK_ALERGIAS_PERFIL FOREIGN KEY(Paciente, data_hora) REFERENCES Perfil_Clinico(Paciente, data_hora) ON DELETE CASCADE
);

-- --------
-- Tabela 14: Habitos
-- Atributo multivalorado de Perfil_Clinico.
-- --------
CREATE TABLE Habitos (
    Paciente NUMBER(10) NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    habito VARCHAR2(100) NOT NULL,
    CONSTRAINT PK_HABITOS PRIMARY KEY(Paciente, data_hora, habito),
    CONSTRAINT FK_HABITOS_PERFIL FOREIGN KEY(Paciente, data_hora) REFERENCES Perfil_Clinico(Paciente, data_hora) ON DELETE CASCADE
);

-- --------
-- Tabela 15: Diagnostico
-- Agregação que associa um Paciente a uma Doença em uma data/hora.
-- --------
CREATE TABLE Diagnostico (
    Id NUMBER(10) GENERATED AS IDENTITY NOT NULL, -- Chave artificial (J9)
    Paciente NUMBER(10) NOT NULL,
    Doenca VARCHAR2(10) NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    status VARCHAR2(10) NOT NULL,
    CONSTRAINT PK_DIAGNOSTICO PRIMARY KEY(Id),
    CONSTRAINT FK_DIAGNOSTICO_PACIENTE FOREIGN KEY(Paciente) REFERENCES Paciente(IdPseudo) ON DELETE CASCADE,
    CONSTRAINT FK_DIAGNOSTICO_DOENCA FOREIGN KEY(Doenca) REFERENCES Doenca(CID), -- ON DELETE RESTRICT (padrão)
    -- Chave natural mantida como unique (J9)
    CONSTRAINT UQ_DIAGNOSTICO_NATURAL UNIQUE(Paciente, Doenca, data_hora),
    CONSTRAINT CK_DIAGNOSTICO_STATUS CHECK(status IN ('ativo', 'inativo'))
);

-- Note 7: "Para um mesmo Paciente e Doença só pode haver um diagnóstico ativo (status = 'ativo')."
-- Implementado com um índice único funcional (Oracle).
CREATE UNIQUE INDEX UQ_DIAGNOSTICO_ATIVO ON Diagnostico (
    CASE WHEN status = 'ativo' THEN Paciente ELSE NULL END,
    CASE WHEN status = 'ativo' THEN Doenca ELSE NULL END
);

-- --------
-- Tabela 16: Ocorrencia_Sintoma
-- Agregação que associa Sintomas a um Diagnóstico.
-- --------
CREATE TABLE Ocorrencia_Sintoma (
    Diagnostico NUMBER(10) NOT NULL,
    Sintoma_CID VARCHAR2(10) NOT NULL,
    data_inicio DATE NOT NULL,
    duracao VARCHAR2(50),
    observacao VARCHAR2(500),
    CONSTRAINT PK_OCORRENCIA_SINTOMA PRIMARY KEY(Diagnostico, Sintoma_CID, data_inicio),
    CONSTRAINT FK_OCORRENCIA_DIAGNOSTICO FOREIGN KEY(Diagnostico) REFERENCES Diagnostico(Id) ON DELETE CASCADE,
    CONSTRAINT FK_OCORRENCIA_SINTOMA FOREIGN KEY(Sintoma_CID) REFERENCES Sintoma(CID) -- ON DELETE RESTRICT (padrão)
);

-- --------
-- Tabela 17: Recomendacao_Tratamento
-- Agregação que armazena a recomendação de um Modelo para um Diagnóstico.
-- --------
CREATE TABLE Recomendacao_Tratamento (
    Diagnostico NUMBER(10) NOT NULL,
    Modelo VARCHAR2(100) NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    CONSTRAINT PK_RECOMENDACAO PRIMARY KEY(Diagnostico, Modelo, data_hora),
    CONSTRAINT FK_RECOMENDACAO_DIAGNOSTICO FOREIGN KEY(Diagnostico) REFERENCES Diagnostico(Id) ON DELETE CASCADE,
    CONSTRAINT FK_RECOMENDACAO_MODELO FOREIGN KEY(Modelo) REFERENCES Modelo(nome) -- ON DELETE RESTRICT (padrão)
);

-- --------
-- Tabela 18: Exame
-- Agregação que representa um exame, realizado por um Laboratório para um Paciente.
-- --------
CREATE TABLE Exame (
    Nro_Protocolo VARCHAR2(50) NOT NULL,
    Paciente NUMBER(10) NOT NULL,
    Laboratorio VARCHAR2(18) NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    tipo VARCHAR2(10) NOT NULL,
    CONSTRAINT PK_EXAME PRIMARY KEY(Nro_Protocolo),
    CONSTRAINT FK_EXAME_PACIENTE FOREIGN KEY(Paciente) REFERENCES Paciente(IdPseudo) ON DELETE CASCADE,
    CONSTRAINT FK_EXAME_LABORATORIO FOREIGN KEY(Laboratorio) REFERENCES Laboratorio(CNPJ), -- ON DELETE RESTRICT (padrão)
    -- Note 8: Ajuda a garantir a restrição de disjunção no nível do SGBD.
    CONSTRAINT CK_EXAME_TIPO CHECK(tipo IN ('clinico', 'genetico'))
);

-- --------
-- Tabela 19: Exame_Clinico
-- Especialização de Exame.
-- --------
CREATE TABLE Exame_Clinico (
    Nro_Protocolo VARCHAR2(50) NOT NULL,
    CONSTRAINT PK_EXAME_CLINICO PRIMARY KEY(Nro_Protocolo),
    CONSTRAINT FK_EXAME_CLINICO_EXAME FOREIGN KEY(Nro_Protocolo) REFERENCES Exame(Nro_Protocolo) ON DELETE CASCADE
);

-- --------
-- Tabela 20: Features
-- Atributo multivalorado de Exame_Clinico (e.g., "Glicose", "70", "mg/dL").
-- --------
CREATE TABLE Features (
    Exame_Clinico VARCHAR2(50) NOT NULL,
    nome VARCHAR2(100) NOT NULL,
    valor VARCHAR2(50),
    unidade_de_medida VARCHAR2(20),
    CONSTRAINT PK_FEATURES PRIMARY KEY(Exame_Clinico, nome),
    CONSTRAINT FK_FEATURES_EXAME_CLINICO FOREIGN KEY(Exame_Clinico) REFERENCES Exame_Clinico(Nro_Protocolo) ON DELETE CASCADE
);

-- --------
-- Tabela 21: Exame_Genetico
-- Especialização de Exame.
-- --------
CREATE TABLE Exame_Genetico (
    Nro_Protocolo VARCHAR2(50) NOT NULL,
    tipo_de_amostra VARCHAR2(50),
    origem_genetica VARCHAR2(20),
    CONSTRAINT PK_EXAME_GENETICO PRIMARY KEY(Nro_Protocolo),
    CONSTRAINT FK_EXAME_GENETICO_EXAME FOREIGN KEY(Nro_Protocolo) REFERENCES Exame(Nro_Protocolo) ON DELETE CASCADE,
    CONSTRAINT CK_EXAME_GENETICO_ORIGEM CHECK(origem_genetica IN ('germinativo', 'somatico'))
);

-- --------
-- Tabela 22: Identifica
-- Relacionamento N:M entre Exame_Genetico e Marcadores_Geneticos.
-- --------
CREATE TABLE Identifica (
    Exame_Genetico VARCHAR2(50) NOT NULL,
    Marcador_Genetico VARCHAR2(100) NOT NULL,
    CONSTRAINT PK_IDENTIFICA PRIMARY KEY(Exame_Genetico, Marcador_Genetico),
    CONSTRAINT FK_IDENTIFICA_EXAME FOREIGN KEY(Exame_Genetico) REFERENCES Exame_Genetico(Nro_Protocolo) ON DELETE CASCADE,
    CONSTRAINT FK_IDENTIFICA_MARCADOR FOREIGN KEY(Marcador_Genetico) REFERENCES Marcadores_Geneticos(HGVS) -- ON DELETE RESTRICT (padrão)
);

-- --------
-- Tabela 23: Atrela_se
-- Relacionamento N:M entre Diagnostico e Exame.
-- --------
CREATE TABLE Atrela_se (
    Diagnostico NUMBER(10) NOT NULL,
    Exame VARCHAR2(50) NOT NULL,
    CONSTRAINT PK_ATRELA_SE PRIMARY KEY(Diagnostico, Exame),
    CONSTRAINT FK_ATRELA_SE_DIAGNOSTICO FOREIGN KEY(Diagnostico) REFERENCES Diagnostico(Id) ON DELETE CASCADE,
    CONSTRAINT FK_ATRELA_SE_EXAME FOREIGN KEY(Exame) REFERENCES Exame(Nro_Protocolo) ON DELETE CASCADE
    -- Note (aplicação): "garantir a consistência de informações desse ciclo..."
    -- (Exame e Diagnóstico devem ser do mesmo Paciente).
    -- Isso requer um TRIGGER para ser validado no SGBD.
);