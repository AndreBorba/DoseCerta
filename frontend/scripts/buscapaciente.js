const API_BASE = "http://localhost:4000";

async function buscarPaciente(e) {
  e.preventDefault();

  const termo = document.getElementById("termo").value.trim();
  const tabela = document.getElementById("tabelaResultados");

  tabela.innerHTML = "<tr><td colspan='5'>Buscando...</td></tr>";

  try {
    const resp = await fetch(`${API_BASE}/buscapaciente?termo=${encodeURIComponent(termo)}`);
    const dados = await resp.json();

    if (!Array.isArray(dados) || dados.length === 0) {
      tabela.innerHTML = "<tr><td colspan='5'>Nenhum paciente encontrado</td></tr>";
      return;
    }

    tabela.innerHTML = "";

    dados.forEach(p => {
      tabela.innerHTML += `
        <tr>
          <td>${p.id}</td>
          <td>${p.nome}</td>
          <td>${p.cpf}</td>
          <td>${p.telefone || "-"}</td>
          <td>${p.status}</td>
        </tr>
      `;
    });

  } catch (error) {
    console.error("Erro ao buscar paciente:", error);
    tabela.innerHTML = "<tr><td colspan='5'>Erro ao buscar</td></tr>";
  }
}
