const { Pool } = require("pg");

const pool = new Pool({
  user: "postgres",
  host: "postgres", // <-- nome do serviço no compose
  database: "dosecerta",
  password: "postgres",
  port: 5432,
});

module.exports = pool;
