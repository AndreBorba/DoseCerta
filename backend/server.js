const express = require("express");
const cors = require("cors");
const pool = require("./db");

// Rotas
const cadastroPacienteRoutes = require("./routes/cadastropaciente");
const cadastroMedicoRoutes = require("./routes/cadastromedico");
const buscaPacienteRoutes = require("./routes/buscapaciente");
const buscaPessoaRoutes = require("./routes/buscapessoa");
const buscaDiagnosticoSemGeneticoRoutes = require("./routes/diagnosticosemgenetico");

const app = express();

app.use(cors());
app.use(express.json());

// ROTA TESTE
app.get("/", (req, res) => {
  res.send("Backend funcionando!");
});

// Cadastro Paciente
app.use("/cadastropaciente", cadastroPacienteRoutes);

// Cadastro Médico
app.use("/cadastromedico", cadastroMedicoRoutes);

// Busca Paciente
app.use("/buscapaciente", buscaPacienteRoutes);

// Busca Pessoa
app.use("/buscapessoa", buscaPessoaRoutes);

// Busca Diagnostico sem Genetico
app.use("/diagnosticosemgenetico", buscaDiagnosticoSemGeneticoRoutes);

// Iniciar servidor
app.listen(4000, () => {
  console.log("Servidor rodando na porta 4000");
});
