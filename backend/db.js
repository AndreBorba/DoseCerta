console.log("db.js foi carregado!");
// require("dotenv").config();

const { Pool } = require("pg");

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASS,
  port: 5432,
});

pool.on("connect", () => {
  console.log("Conectado ao PostgreSQL!");
});

pool.on("error", (err) => {
  console.error("Erro no pool do PostgreSQL:", err);
});

module.exports = pool;