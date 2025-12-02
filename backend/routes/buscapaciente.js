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
        pm.nome_civil AS nomemedico,
        pm.id_pseudo AS idmedico,
        pp.nome_civil AS nomepaciente,
        pp.id_pseudo AS idpaciente,
        TO_CHAR(c.data_inicio, 'DD/MM/YYYY') AS dataini,
        TO_CHAR(c.data_termino, 'DD/MM/YYYY') AS datafim
      FROM pessoa pp
      JOIN (SELECT * FROM cuidado 
            WHERE (data_termino is NULL) or 
                  (data_termino > NOW())) c
          ON pp.id_pseudo = c.id_paciente
      JOIN pessoa pm ON pm.id_pseudo = c.id_medico
      WHERE pm.nome_civil ILIKE $1
         OR pm.cpf = $2
      ORDER BY pp.nome_civil, pm.nome_civil;
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
