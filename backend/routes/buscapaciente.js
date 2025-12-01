const express = require("express");
const router = express.Router();
const pool = require("../db");

// Buscar paciente por nome OU CPF
router.get("/", async (req, res) => {
  const { termo } = req.query;

  if (!termo) {
    return res.status(400).json({ erro: "Parâmetro 'termo' é obrigatório" });
  }

  try {
    const query = `
      SELECT 
        p.id_pseudo AS id,
        p.nome_civil AS nome,
        p.cpf,
        p.telefone_contato AS telefone,
        pa.status_paciente AS status
      FROM pessoa p
      JOIN paciente pa ON pa.id_pseudo = p.id_pseudo
      WHERE p.nome_civil ILIKE $1
         OR p.cpf = $2
      ORDER BY p.nome_civil;
    `;

    const values = [`%${termo}%`, termo];

    const result = await pool.query(query, values);

    res.json(result.rows);

  } catch (error) {
    console.error("Erro ao buscar paciente:", error);
    res.status(500).json({ erro: "Erro no servidor" });
  }
});

module.exports = router;
