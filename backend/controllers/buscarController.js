const pool = require("../db");

exports.buscarPaciente = async (req, res) => {
  const termo = `%${req.query.termo}%`;

  try {
    const { rows } = await pool.query(
      `SELECT idpseudo, nome, cpf, telefone
       FROM Pessoa
       WHERE nome ILIKE $1 OR cpf ILIKE $1`,
      [termo]
    );

    res.json({ resultados: rows });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.buscarMedico = async (req, res) => {
  const termo = `%${req.query.termo}%`;

  try {
    const { rows } = await pool.query(
      `SELECT M.idpseudo, P.nome, P.cpf, M.crm, M.especializacao
       FROM Medico M
       JOIN Pessoa P ON P.idpseudo = M.idpseudo
       WHERE P.nome ILIKE $1 OR M.crm ILIKE $1`,
      [termo]
    );

    res.json({ resultados: rows });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
