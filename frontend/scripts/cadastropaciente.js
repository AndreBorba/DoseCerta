const API_BASE = "http://localhost:4000";

// Habilita/desabilita campos de pessoa
function toggleCamposMedico() {
  const checked = document.getElementById("jaMedico").checked;
  document.getElementById("dadosPessoa").style.display = checked ? "none" : "block";

  const inputs = document.querySelectorAll("#dadosPessoa input, #dadosPessoa select");
  inputs.forEach(input => {
    input.required = !checked; // se já é médico, não precisa preencher
  });
}

// Verifica se CPF já está cadastrado como paciente
async function verificaMedico() {
  const cpf = document.querySelector('input[name="cpf"]').value.trim();
  if (!cpf) return;

  try {
    const resp = await fetch(`${API_BASE}/buscapessoa?termo=${encodeURIComponent(cpf)}`);
    const dados = await resp.json();

    // Se retornar medico, marca o checkbox e oculta os campos de pessoa
    if (dados.some(p => p.eh_medico === "Sim")) {
      document.getElementById("jaMedico").checked = true;
      toggleCamposMedico();
    }
  } catch (err) {
    console.error(err);
  }
}

// Cadastro de paciente
async function cadastrarPaciente(event) {
  event.preventDefault();

  const form = event.target;

  const data = {
    nome: form.nome.value.toUpperCase(),
    cpf: form.cpf.value,
    data_nascimento: form.data_nascimento.value,
    genero: form.genero.value,
    telefone: form.telefone.value,
    email: form.email.value.toUpperCase(),
    senha: form.senha.value,
    responsavel: form.responsavel.value || null,
    historico_familiar: form.historico_familiar.value.toUpperCase()
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

    if (json.success) {
      form.reset();
    }

  } catch (err) {
    console.error(err);
    alert("Erro ao cadastrar.");
  }
}