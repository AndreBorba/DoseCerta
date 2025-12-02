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
    const query = `
      SELECT
          p.nome_civil AS nome,
          d.nome AS diagnostico
      FROM pessoa p
      JOIN paciente pac ON p.id_pseudo = pac.id_pseudo
      JOIN diagnostico diag ON pac.id_pseudo = diag.id_paciente
      JOIN doenca d ON diag.cid_doenca = d.cid
      WHERE diag.status = TRUE
        AND d.cid = $1
        AND NOT EXISTS (
            SELECT 1
            FROM atrela_se ats
            JOIN exame ex ON ats.nro_protocolo = ex.nro_protocolo
            WHERE ats.id_diagnostico = diag.id_diagnostico
              AND UPPER(ex.tipo) = 'GENETICO'
        )
      ORDER BY p.nome_civil;
    `;

    const result = await pool.query(query, [cid]);
    res.json(result.rows);

  } catch (err) {
    console.error(err);
    res.status(500).json({ erro: "Erro ao buscar pacientes" });
  }
});


module.exports = router;
