const express = require("express");
const cors = require("cors");
const pool = require("./db");

// IMPORTAR A ROTA DE CADASTRO DE PACIENTES
const cadastroPacienteRoutes = require("./routes/cadastropaciente");

const app = express();

app.use(cors());
app.use(express.json());

// ROTA DE TESTE
app.get("/", (req, res) => {
  res.send("Backend funcionando!");
});

// ROTA DE CADASTRO DE PACIENTES
app.use("/cadastropaciente", cadastroPacienteRoutes);

// INICIAR SERVIDOR
app.listen(4000, () => {
  console.log("Servidor rodando na porta 4000");
});
