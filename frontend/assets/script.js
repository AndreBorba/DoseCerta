const API_BASE = "http://localhost:4000/api";

// Função padrão de POST
async function apiPost(url, body) {
  const resp = await fetch(`${API_BASE}${url}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  return resp.json();
}

// Função GET
async function apiGet(url) {
  const resp = await fetch(`${API_BASE}${url}`);
  return resp.json();
}

// Cadastro de Paciente
async function cadastrarPaciente(e) {
  e.preventDefault();
  const f = new FormData(e.target);
  const body = Object.fromEntries(f.entries());

  const result = await apiPost("/register", body);
  document.getElementById("resultado").innerText =
    JSON.stringify(result, null, 2);
}

// Cadastro de Médico
async function cadastrarMedico(e) {
  e.preventDefault();
  const f = new FormData(e.target);
  const body = Object.fromEntries(f.entries());

  const result = await apiPost("/register-medico", body);
  document.getElementById("resultado").innerText =
    JSON.stringify(result, null, 2);
}

// Buscar Paciente por nome ou CPF
async function buscarPaciente(e) {
  e.preventDefault();
  const termo = document.getElementById("termo").value;

  const data = await apiGet(`/buscar-paciente?termo=${termo}`);

  let html = "";
  for (const p of data.resultados) {
    html += `
      <tr>
        <td>${p.idpseudo}</td>
        <td>${p.nome}</td>
        <td>${p.cpf}</td>
        <td>${p.telefone}</td>
      </tr>`;
  }

  document.getElementById("tabelaResultados").innerHTML = html;
}

// Buscar exames
async function buscarExames(e) {
  e.preventDefault();
  const cpf = document.getElementById("cpf-exame").value;

  const data = await apiGet(`/exams?cpf=${cpf}`);

  let html = "";
  for (const ex of data.exames) {
    html += `
      <tr>
        <td>${ex.nro_protocolo}</td>
        <td>${ex.tipo}</td>
        <td>${new Date(ex.data_coleta).toLocaleString()}</td>
        <td>${ex.laboratorio}</td>
      </tr>`;
  }

  document.getElementById("tabelaExames").innerHTML = html;
}
