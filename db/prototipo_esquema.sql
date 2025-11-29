-- Tabela 1: Pessoa
-- Armazena dados pessoais genéricos, servindo como base para Paciente e Médico.
CREATE TABLE Pessoa (
    IdPseudo NUMBER(10) NOT NULL,
    CPF CHAR(14) NOT NULL,
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
    nome VARCHAR2(50),
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


-- Tabela 4: Modelo
-- Tabela de domínio para armazenar os Modelos de IA (nome e URL).
CREATE TABLE Modelo (
    nome VARCHAR2(100) NOT NULL,
    url VARCHAR2(255) NOT NULL,
    CONSTRAINT PK_MODELO PRIMARY KEY(nome),
    CONSTRAINT SQ_MODELO UNIQUE(url)
);


-- Tabela 5: Laboratorio
-- Armazena dados cadastrais dos laboratórios.
CREATE TABLE Laboratorio (
    CNPJ VARCHAR2(18) NOT NULL,
    razao_social VARCHAR2(50) NOT NULL,
    endereco VARCHAR2(200),
    CNES VARCHAR2(20) NOT NULL,
    email VARCHAR2(60),
    telefone1 VARCHAR2(20),
    telefone2 VARCHAR2(20),
    CONSTRAINT PK_LABORATORIO PRIMARY KEY(CNPJ),
    CONSTRAINT SK_LABORATORIO UNIQUE(CNES),
    CONSTRAINT CK_CNPJ CHECK(REGEXP_LIKE(CNPJ, '[0-9]{2}\.[0-9]{3}\.[0-9]{3}/[0-9]{4}\-[0-9]{2}'))
);


-- Tabela 6: Marcadores_Geneticos
-- Tabela de domínio para armazenar os marcadores genéticos (HGVS e descrição).
CREATE TABLE Marcadores_Geneticos (
    HGVS VARCHAR2(100) NOT NULL,
    descricao VARCHAR2(500),
    CONSTRAINT PK_MARCADORES_GENETICOS PRIMARY KEY(HGVS)
);


-- Tabela 7: Conta
-- Armazena dados de autenticação (login/senha) e associa a uma Pessoa (1:1).
CREATE TABLE Conta (
    email VARCHAR2(60) NOT NULL,
    senha VARCHAR2(50) NOT NULL, -- verificar se esse not null pode ficar aqui pq no relacional ta sem
    pessoa NUMBER(10) NOT NULL,
    CONSTRAINT PK_CONTA PRIMARY KEY(email),
    CONSTRAINT SK_CONTA_PESSOA UNIQUE(pessoa), -- Garante a relação 1:1
    CONSTRAINT FK_CONTA_PESSOA FOREIGN KEY(pessoa)
        REFERENCES Pessoa(IdPseudo) ON DELETE CASCADE
    -- Note 9 (aplicação): "Um paciente menor de idade não pode possuir uma conta."
);


-- Tabela 8: Medico
-- Especialização de Pessoa. Armazena dados específicos do médico.
CREATE TABLE Medico (
    IdPseudo NUMBER(10) NOT NULL,
    CRM VARCHAR2(20) NOT NULL,
    especializacao VARCHAR2(50),
    local_de_trabalho VARCHAR2(50),
    CONSTRAINT PK_MEDICO PRIMARY KEY(IdPseudo),
    CONSTRAINT SK_MEDICO_CRM UNIQUE(CRM),
    CONSTRAINT FK_MEDICO_PESSOA FOREIGN KEY(IdPseudo) REFERENCES Pessoa(IdPseudo) ON DELETE CASCADE
);


-- Tabela 9: Paciente
-- Especialização de Pessoa. Armazena dados específicos do paciente.
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

    -- ver notes 4 e 6, tem que resolver eles
);