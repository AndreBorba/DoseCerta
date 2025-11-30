const express = require("express");
const pool = require("../db");

const router = express.Router();

router.post("/", async (req, res) => {
  const {
    nome,
    cpf,
    data_nascimento,
    genero,
    telefone,
    email,
    senha,
    responsavel,
    historico_familiar
  } = req.body;

  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const pessoaQuery = `
      INSERT INTO pessoa (cpf, nome_civil, data_nascimento, telefone_contato, genero)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id_pseudo
    `;

    const pessoaResult = await client.query(pessoaQuery, [
      cpf,
      nome,
      data_nascimento,
      telefone,
      genero
    ]);

    const idPessoa = pessoaResult.rows[0].id_pseudo;

    const pacienteQuery = `
      INSERT INTO paciente (id_pseudo, status_paciente, responsavel, historico_familiar)
      VALUES ($1, 'ATIVO', $2, $3)
    `;

    await client.query(pacienteQuery, [
      idPessoa,
      responsavel || null,
      historico_familiar
    ]);

    const contaQuery = `
      INSERT INTO conta (email, senha, id_pessoa)
      VALUES ($1, $2, $3)
    `;

    await client.query(contaQuery, [
      email,
      senha,
      idPessoa
    ]);

    await client.query("COMMIT");

    res.json({
      success: true,
      message: "Paciente cadastrado com sucesso!",
      id_pessoa: idPessoa
    });

  } catch (error) {
    await client.query("ROLLBACK");
    console.error(error);
    res.status(500).json({ success: false, error: error.message });
  } finally {
    client.release();
  }
});

module.exports = router;
