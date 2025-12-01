const express = require("express");
const router = express.Router();
const pool = require("../db");

// Rota para listar CIDs disponíveis
router.get("/cids", async (req, res) => {
  try {
    const result = await pool.query(`SELECT cid, nome FROM doenca ORDER BY cid`);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ erro: "Erro ao buscar CIDs" });
  }
});

// Rota para buscar pacientes com diagnóstico ativo e sem exame genético
router.get("/pacientes", async (req, res) => {
  const { cid } = req.query;

  if (!cid) {
    return res.status(400).json({ erro: "Parâmetro 'cid' é obrigatório" });
  }

  try {
    // TODO: Consulta 1
    const query = `
      
    `;
    const result = await pool.query(query, [cid]);
    res.json(result.rows);

  } catch (err) {
    console.error(err);
    res.status(500).json({ erro: "Erro ao buscar pacientes" });
  }
});

module.exports = router;
