const pool = require("../db");

exports.listarExamesPorCPF = async (req, res) => {
  const { cpf } = req.query;

  try {
    const { rows } = await pool.query(
      `SELECT 
        E.nro_protocolo,
        E.data_coleta,
        COALESCE(EC.tipo, EG.tipo) AS tipo,
        E.laboratorio
       FROM Exame E
       JOIN Pessoa P ON P.idpseudo = E.idpseudo_paciente
       LEFT JOIN Exame_Clinico EC ON EC.nro_protocolo = E.nro_protocolo
       LEFT JOIN Exame_Genetico EG ON EG.nro_protocolo = E.nro_protocolo
       WHERE P.cpf = $1
       ORDER BY E.data_coleta DESC`,
      [cpf]
    );

    res.json({ exames: rows });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
