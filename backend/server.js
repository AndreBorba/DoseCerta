const express = require("express");
const cors = require("cors");
const pool = require("./db");

// Rotas
const buscaPacienteRoutes = require("./routes/buscapaciente");
const buscaPessoaRoutes = require("./routes/buscapessoa");
const cadastroMedicoRoutes = require("./routes/cadastromedico");
const cadastroPacienteRoutes = require("./routes/cadastropaciente");
const buscaDiagnosticoSemGeneticoRoutes = require("./routes/diagnosticosemgenetico");

const app = express();

app.use(cors());
app.use(express.json());

// ROTA TESTE
app.get("/", (req, res) => {
  res.send("Backend funcionando!");
});

// Busca Paciente
app.use("/buscapaciente", buscaPacienteRoutes);

// Busca Pessoa
app.use("/buscapessoa", buscaPessoaRoutes);

// Cadastro Médico
app.use("/cadastromedico", cadastroMedicoRoutes);

// Cadastro Paciente
app.use("/cadastropaciente", cadastroPacienteRoutes);

// Busca Diagnostico sem Genetico
app.use("/diagnosticosemgenetico", buscaDiagnosticoSemGeneticoRoutes);

// Iniciar servidor
app.listen(4000, () => {
  console.log("Servidor rodando na porta 4000");
});
