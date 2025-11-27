const pool = require("../db");
const bcrypt = require("bcrypt");

exports.cadastrarPaciente = async (req, res) => {
  const {
    nome,
    cpf,
    data_nascimento,
    genero,
    telefone,
    email,
    senha,
    historico_familiar,
  } = req.body;

  try {
    const senhaHash = await bcrypt.hash(senha, 10);

    await pool.query("BEGIN");

    // 1) Criar Pessoa
    const pessoa = await pool.query(
      `INSERT INTO Pessoa (nome, cpf, data_nascimento, genero, telefone)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING idpseudo`,
      [nome, cpf, data_nascimento, genero, telefone]
    );

    const idpseudo = pessoa.rows[0].idpseudo;

    // 2) Criar Conta
    await pool.query(
      `INSERT INTO Conta (email, senha_hash, pessoa_id)
       VALUES ($1, $2, $3)`,
      [email, senhaHash, idpseudo]
    );

    // 3) Criar Paciente
    await pool.query(
      `INSERT INTO Paciente (idpseudo, historico_familiar)
       VALUES ($1, $2)`,
      [idpseudo, historico_familiar || null]
    );

    await pool.query("COMMIT");

    res.json({
      message: "Paciente cadastrado com sucesso!",
      id: idpseudo,
    });

  } catch (err) {
    await pool.query("ROLLBACK");
    console.error(err);
    res.status(500).json({ error: err.message });
  }
};
