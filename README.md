# 🧬 **DoseCerta — Protótipo de Plataforma de Medicina de Precisão**

<h1 align="center">
    <p> Um Sistema para Gerenciamento de Pacientes, Médicos, Exames Clínicos e Genéticos e Análise de IA 🏥 </p>
</h1>


## 🚨 About

A **DoseCerta** é um protótipo desenvolvido para a disciplina de **SCC0640 - Bases de Dados**, com o objetivo de demonstrar a aplicação prática da modelagem conceitual, lógica e física apresentada no documento do projeto.

O sistema simula um ambiente clínico onde pacientes, médicos e exames do segmento de medicina de precisão são cadastrados e consultados por meio de uma interface web. As funcionalidades implementadas ilustram o uso de:

- Integridade referencial
- Regras de negócio
- Consultas SQL envolvendo múltiplas tabelas
- Transações e operações CRUD

O foco do trabalho é mostrar como o banco de dados projetado pode ser integrado a uma aplicação funcional por meio de uma API REST.

---

## 🔨 Tools & Technologies

* **PostgreSQL** — SGBD utilizado para armazenar todas as entidades e consultas do projeto.
* **Node.js + Express** — API REST responsável por conectar o frontend ao banco, executando transações e queries SQL.
* **Fetch API** — Comunicação entre interface e backend.
* **HTML, CSS, JavaScript** — Interface web simples para interação com o sistema.
* **Docker** — Contêinerização do ambiente, permitindo subir banco e backend de forma padronizada e reproduzível.

---

## 🕹️ How to Run

### 1) Clonando repositório

```bash
# Clone o projeto
git clone https://github.com/AndreBorba/DoseCerta.git

# Entre no diretório do backend
cd DoseCerta

# Build imagens docker
docker compose up -d --build

# Caso esteja rebuildando a imagem, 
# é necessário apagar o volume anterior
docker compose down -v

# Caso já tenha a imagem buildada, basta subir ela
docker compose up -d
```

### 2) Acessando o banco PostgreSQL no contêiner

```bash
# Opt1: Acesso ao terminal
docker exec -it postgres_container psql -U postgres -d dosecerta

# Opt2: Executar SQL de consultas
docker exec -it postgres_container psql -U postgres -d dosecerta < db/consultas.sql
```

### 3) Acessando interface Web

[http://localhost:8080/](http://localhost:8080/)

---

## 📄 Work Organization

O projeto é dividido em três partes principais — **database (db)** (PostgreSQL), **backend** (API em Node.js) e **frontend** (interface web). A seguir está a estrutura completa de diretórios:

```
DoseCerta/
├── backend/
│   ├── server.js                 # Inicialização do servidor Express
│   ├── db.js                     # Conexão PostgreSQL
│   ├── package.json              # Dependências do backend
│   ├── Dockerfile                # Instruções Docker do backend
│   │
│   └── routes/                   # Rotas da API
│       ├── buscapaciente.js
│       ├── buscapessoa.js
│       ├── cadastromedico.js
│       ├── cadastropaciente.js
│       └── diagnosticosemgenetico.js
│
├── db/                           # SQL de DDL e DML
│   ├── esquema.sql
│   ├── insercoes.sql
│   └── consultas.sql
│
├── frontend/
│   ├── index.html                # Página inicial
│   ├── Dockerfile                # Instruções Docker do frontend
│   │
│   ├── pages/                    # Arquivos HTML (páginas)
│   │   ├── buscapaciente.html    # Busca de pacientes em cuidado por um médico
│   │   ├── buscapessoa.html      # Busca de pessoas
│   │   ├── cadastromedico.html   # Cadastro de médicos
│   │   ├── cadastropaciente.html # Cadastro de pacientes
│   │   └── diagnosticosemgenetico.html # Busca de pacientes com diagnóstico e sem exame genético
│   │
│   ├── scripts/                  # Arquivos JavaScript (comunicação com API)
│   │   ├── buscapaciente.js
│   │   ├── buscapessoa.js
│   │   ├── cadastromedico.js
│   │   ├── cadastropaciente.js
│   │   └── diagnosticosemgenetico.js
│   │
│   └── style/                    # Arquivos CSS (estilização)
│       └── styles.css
│
├── docker-compose.yml            # Compose para execução do contêiner
└── README.md                     # Documentação do projeto
```

## 👥 Project Owners

* André Vargas Vilalba Codorniz
* Carolina Elias de Almeida Américo
* Caroline Severiano Clapis
* João Pedro Gomes
* Rhayna Christiani Vasconcelos Marques Casado