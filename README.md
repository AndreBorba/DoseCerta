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
* **bcrypt** — Hashing de senhas para a entidade Conta.
* **HTML, CSS, JavaScript** — Interface web simples para interação com o sistema.
* **Bootstrap 5** — Estilização do frontend com layout responsivo.
* **Fetch API** — Comunicação entre interface e backend.
* **Docker** — Contêinerização do ambiente, permitindo subir banco e backend de forma padronizada e reproduzível.

---

## 🕹️ How to Run

### 1) Clonando repositório

```bash
# Clone o projeto
git clone https://github.com/AndreBorba/DoseCerta.git

# Entre no diretório do backend
cd DoseCerta

# Caso esteja rebuildando a imagem, é necessário apagar o volume anterior
docker compose down -v

# Build imagens docker
docker compose up -d --build

# Caso já tenha a imagem buildada, basta subir ela
docker compose up -d
```

### 2) Acessando o banco PostgreSQL no contêiner

```bash
docker exec -it postgres_container psql -U postgres -d dosecerta
```

### 3) Acessando interface Web

```
http://localhost:8080/
```
---

## 📄 Work Organization

O projeto é dividido em duas partes principais — **backend** (API em Node.js) e **frontend** (interface web). A seguir está a estrutura completa de diretórios:

```
DoseCerta/
├── backend/
│   ├── server.js                # Inicialização do servidor Express
│   ├── db.js                    # Conexão PostgreSQL
│   ├── package.json             # Dependências do backend
│   ├── Dockerfile               # Instruções Docker do backend
│   │
│   ├── routes/                  # Rotas da API
│   │   ├── paciente.js
│   │   ├── medico.js
│   │   ├── exames.js
│   │   └── buscar.js
│   │
│   ├── controllers/             # Lógica das rotas (camada de controle)
│       ├── pacienteController.js
│       ├── medicoController.js
│       ├── examesController.js
│       └── buscarController.js
│
├── db/                          # SQL de DDL e DML
│   ├── esquema.sql
│   ├── insercao.sql
│   ├── consultas.sql
│
├── frontend/
│   ├── index.html               # Página inicial
│   ├── cadastro-paciente.html   # Tela de cadastro de paciente
│   ├── cadastro-medico.html     # Tela de cadastro de médico
│   ├── buscar-paciente.html     # Tela de busca de paciente
│   ├── buscar-exames.html       # Tela de busca de exames
│   ├── Dockerfile               # Instruções Docker do frontend
│   │
│   ├── assets/                  # Arquivos estáticos
│       ├── styles.css           # Estilização da interface
│       └── script.js            # Funções de comunicação com a API
│
├── docker-compose.yml           # Compose para execução do contêiner
└── README.md                    # Documentação do projeto
```

## 👥 Project Owners

* André Vargas Vilalba Codorniz
* Carolina Elias de Almeida Américo
* Caroline Severiano Clapis
* João Pedro Gomes
* Rhayna Christiani Vasconcelos Marques Casado