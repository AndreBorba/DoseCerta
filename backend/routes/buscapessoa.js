const express = require("express");
const router = express.Router();
const pool = require("../db");

// Buscar pessoa por nome OU CPF
router.get("/", async (req, res) => {
  const { termo } = req.query;

  try {
    let query = `
      SELECT 
        p.id_pseudo AS id,
        p.nome_civil AS nome,
        p.cpf,
        p.telefone_contato AS telefone,
        CASE WHEN pa.id_pseudo IS NOT NULL THEN 'Sim' ELSE 'Não' END AS eh_paciente,
        CASE WHEN m.id_pseudo IS NOT NULL THEN 'Sim' ELSE 'Não' END AS eh_medico
      FROM pessoa p
      LEFT JOIN paciente pa ON p.id_pseudo = pa.id_pseudo
      LEFT JOIN medico m ON p.id_pseudo = m.id_pseudo
    `;

    const values = [];

    if (termo && termo.trim() !== "") {
      query += ` WHERE p.nome_civil ILIKE $1 OR p.cpf = $2`;
      values.push(`%${termo}%`, termo);
    }

    query += ` ORDER BY p.id_pseudo`;

    const result = await pool.query(query, values);
    res.json(result.rows);

  } catch (error) {
    console.error("Erro ao buscar pessoa:", error);
    res.status(500).json({ erro: "Erro no servidor" });
  }
});

module.exports = router;