const pool = require("../db");
const bcrypt = require("bcrypt");

exports.cadastrarMedico = async (req, res) => {
  const { nome, cpf, crm, especializacao, email, senha } = req.body;

  try {
    const senhaHash = await bcrypt.hash(senha, 10);

    await pool.query("BEGIN");

    // Criar Pessoa
    const pessoa = await pool.query(
      `INSERT INTO Pessoa (nome, cpf)
       VALUES ($1, $2)
       RETURNING idpseudo`,
      [nome, cpf]
    );

    const idpseudo = pessoa.rows[0].idpseudo;

    // Criar Conta
    await pool.query(
      `INSERT INTO Conta (email, senha_hash, pessoa_id)
       VALUES ($1, $2, $3)`,
      [email, senhaHash, idpseudo]
    );

    // Criar Médico
    await pool.query(
      `INSERT INTO Medico (idpseudo, crm, especializacao)
       VALUES ($1, $2, $3)`,
      [idpseudo, crm, especializacao]
    );

    await pool.query("COMMIT");

    res.json({
      message: "Médico cadastrado com sucesso!",
      id: idpseudo,
    });

  } catch (err) {
    await pool.query("ROLLBACK");
    console.error(err);
    res.status(500).json({ error: err.message });
  }
};
