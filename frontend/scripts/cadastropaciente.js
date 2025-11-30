const API_BASE = "http://localhost:4000";

async function cadastrarPaciente(event) {
  event.preventDefault();

  const form = event.target;

  const data = {
    nome: form.nome.value,
    cpf: form.cpf.value,
    data_nascimento: form.data_nascimento.value,
    genero: form.genero.value,
    telefone: form.telefone.value,
    email: form.email.value,
    senha: form.senha.value,
    responsavel: form.responsavel.value || null,
    historico_familiar: form.historico_familiar.value
  };

  try {
    const resp = await fetch(`${API_BASE}/cadastropaciente`, {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify(data)
    });

    const json = await resp.json();

    document.getElementById("resultado").textContent =
      JSON.stringify(json, null, 2);

  } catch (err) {
    console.error(err);
    alert("Erro ao cadastrar.");
  }
}