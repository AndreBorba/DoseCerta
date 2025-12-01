const API_BASE = "http://localhost:4000";

// Preenche dropdown de CIDs
async function carregarCIDs() {
  try {
    const resp = await fetch(`${API_BASE}/diagnosticosemgenetico/cids`);
    const dados = await resp.json();
    const select = document.getElementById("cid");

    select.innerHTML = "<option value=''>-- Selecione uma doença --</option>";

    dados.forEach(c => {
      const option = document.createElement("option");
      option.value = c.cid;
      option.textContent = `${c.cid} - ${c.nome}`;
      select.appendChild(option);
    });
  } catch (err) {
    console.error("Erro ao carregar CIDs:", err);
  }
}

// Buscar pacientes pelo CID
async function buscarDiagnosticoSemGenetico(e) {
  e.preventDefault();
  const cid = document.getElementById("cid").value;
  const tabela = document.getElementById("tabelaResultados");

  tabela.innerHTML = "<tr><td colspan='3'>Buscando...</td></tr>";

  try {
    const url = `${API_BASE}/diagnosticosemgenetico/pacientes?cid=${encodeURIComponent(cid)}`;
    const resp = await fetch(url);
    const dados = await resp.json();

    if (!Array.isArray(dados) || dados.length === 0) {
      tabela.innerHTML = "<tr><td colspan='3'>Nenhum paciente encontrado</td></tr>";
      return;
    }

    tabela.innerHTML = "";
    dados.forEach(p => {
      tabela.innerHTML += `
        <tr>
          <td>${p.nome}</td>
          <td>${p.telefone || "-"}</td>
          <td>${p.diagnostico}</td>
        </tr>
      `;
    });
  } catch (err) {
    console.error("Erro ao buscar pacientes:", err);
    tabela.innerHTML = "<tr><td colspan='3'>Erro ao buscar</td></tr>";
  }
}

// Carrega CIDs ao abrir a página
window.addEventListener("DOMContentLoaded", carregarCIDs);
