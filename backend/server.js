const express = require("express");
const cors = require("cors");

const pacienteRoutes = require("./routes/paciente");
const medicoRoutes = require("./routes/medico");
const examesRoutes = require("./routes/exames");
const buscarRoutes = require("./routes/buscar");

const app = express();
app.use(cors());
app.use(express.json());

app.use("/api", pacienteRoutes);
app.use("/api", medicoRoutes);
app.use("/api", examesRoutes);
app.use("/api", buscarRoutes);

app.listen(4000, () => {
  console.log("🔥 Servidor rodando em http://localhost:4000");
});
