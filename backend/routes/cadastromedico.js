const express = require("express");
const pool = require("../db");

const router = express.Router();

router.post("/", async (req, res) => {
  const {
    jaPaciente,
    nome,
    cpf,
    data_nascimento,
    genero,
    telefone,
    email,
    senha,
    crm,
    especializacao,
    local
  } = req.body;

  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    let idPessoa;

    // Verifica se a pessoa já existe
    const pessoaExistente = await client.query(
      "SELECT id_pseudo FROM pessoa WHERE cpf = $1",
      [cpf]
    );

    if (pessoaExistente.rows.length > 0) {
      idPessoa = pessoaExistente.rows[0].id_pseudo;
    } else {
      // Insere pessoa nova
      const pessoaResult = await client.query(
        `INSERT INTO pessoa (cpf, nome_civil, data_nascimento, telefone_contato, genero)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING id_pseudo`,
        [cpf, nome, data_nascimento, telefone, genero]
      );
      idPessoa = pessoaResult.rows[0].id_pseudo;
    }

    // Insere médico
    await client.query(
      `INSERT INTO medico (id_pseudo, crm, especializacao, local_de_trabalho)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (id_pseudo) DO UPDATE
       SET crm = EXCLUDED.crm,
           especializacao = EXCLUDED.especializacao,
           local_de_trabalho = EXCLUDED.local_de_trabalho`,
      [idPessoa, crm, especializacao, local]
    );

    // Insere/atualiza conta
    await client.query(
      `INSERT INTO conta (email, senha, id_pessoa)
       VALUES ($1, $2, $3)
       ON CONFLICT (id_pessoa) DO UPDATE
       SET email = EXCLUDED.email,
           senha = EXCLUDED.senha`,
      [email, senha, idPessoa]
    );

    await client.query("COMMIT");

    res.json({
      success: true,
      message: "Médico cadastrado com sucesso!",
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
