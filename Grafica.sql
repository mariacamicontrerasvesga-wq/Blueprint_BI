<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <title>Gráfica RFM Cohort - Transaccional_RFM_Cohort</title>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    body { font-family: Arial, sans-serif; margin: 30px; background: #f9f9f9; }
    h2 { text-align:center; margin-bottom: 20px; }
    table { width:100%; border-collapse: collapse; margin-bottom:30px; }
    th, td { border:1px solid #ddd; padding:8px; text-align:center; }
    th { background:#007bff; color:white; }
    .chart-container { width:90%; margin: auto; }
    .controls { width:90%; margin:auto 0 20px; display:flex; gap:10px; align-items:center; }
  </style>
</head>
<body>

  <h2>📊 Estados por Mes — Transaccional_RFM_Cohort</h2>

  <!-- Controles (ej. filtrar por +RFM si quieres) -->
  <div class="controls">
    <label for="filterRfm">Filtro +RFM:</label>
    <input id="filterRfm" placeholder="ej. 444 (vacío = sin filtro)" />
    <button id="applyFilter">Aplicar filtro</button>
    <button id="resetFilter">Reset</button>
    <small style="margin-left:auto;color:#666">La gráfica se construye leyendo la tabla HTML o desde un endpoint.</small>
  </div>

  <!-- ============================
       Tabla que simula Transaccional_RFM_Cohort
       Columnas relevantes: idCustomer, Mes, Estado, +RFM, R_label, F_label, M_label
       ============================ -->
  <table id="dataTable">
    <thead>
      <tr>
        <th>idCustomer</th>
        <th>Mes</th>
        <th>Estado</th>
        <th>+RFM</th>
        <th>R_label</th>
        <th>F_label</th>
        <th>M_label</th>
      </tr>
    </thead>
    <tbody>
      <!-- Ejemplo: filas de la tabla Transaccional_RFM_Cohort -->
      <tr><td>101</td><td>Enero</td><td>Activo</td><td>444</td><td>Más reciente</td><td>Más frecuente</td><td>Mayor gasto</td></tr>
      <tr><td>102</td><td>Enero</td><td>Inactivo</td><td>321</td><td>Poco reciente</td><td>Baja frecuencia</td><td>Moderado gasto</td></tr>
      <tr><td>103</td><td>Febrero</td><td>Activo</td><td>233</td><td>Moderadamente reciente</td><td>Moderada frecuencia</td><td>Bajo gasto</td></tr>
      <tr><td>104</td><td>Febrero</td><td>Activo</td><td>144</td><td>Menos reciente</td><td>Más frecuente</td><td>Mayor gasto</td></tr>
      <tr><td>105</td><td>Marzo</td><td>Pendiente</td><td>233</td><td>Moderadamente reciente</td><td>Moderada frecuencia</td><td>Bajo gasto</td></tr>
      <tr><td>106</td><td>Marzo</td><td>Activo</td><td>444</td><td>Más reciente</td><td>Más frecuente</td><td>Mayor gasto</td></tr>
      <!-- Agrega/pega aquí tus filas reales o deja que un endpoint las genere -->
    </tbody>
  </table>

  <div class="chart-container">
    <canvas id="stackedChart" height="120"></canvas>
  </div>

  <script>
    // Paleta simple de colores (puedes ampliarla)
    const palette = ["#28a745","#dc3545","#ffc107","#007bff","#6f42c1","#20c997","#fd7e14","#6610f2"];

    // Orden de meses para poder ordenar correctamente
    const monthOrder = ["Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"];

    // Funcion para normalizar texto (por si hay variaciones de mayúsculas/minúsculas)
    function normalize(text){
      if(!text) return text;
      const t = text.trim();
      return t.charAt(0).toUpperCase() + t.slice(1).toLowerCase();
    }

    // Agrega opción a filtrar por +RFM
    const filterInput = document.getElementById('filterRfm');
    document.getElementById('applyFilter').addEventListener('click', () => { buildAndRenderChart(getAggregatedCounts()); });
    document.getElementById('resetFilter').addEventListener('click', () => { filterInput.value=''; buildAndRenderChart(getAggregatedCounts()); });

    // ===== Agregación: lee la tabla HTML y genera counts[mes][estado] =====
    function getAggregatedCounts(){
      const tbody = document.querySelector("#dataTable tbody");
      const rows = Array.from(tbody.querySelectorAll("tr"));
      const counts = {}; // { mes: { estado: count, ... }, ... }
      const rfmFilter = (filterInput.value || "").trim();

      rows.forEach(row => {
        const cells = row.querySelectorAll("td");
        const mes = normalize(cells[1]?.textContent || "");
        const estado = normalize(cells[2]?.textContent || "");
        const rfm = (cells[3]?.textContent || "").trim();

        // Si hay filtro +RFM y no coincide, saltar
        if (rfmFilter && rfm !== rfmFilter) return;

        if (!mes || !estado) return;
        if (!counts[mes]) counts[mes] = {};
        counts[mes][estado] = (counts[mes][estado] || 0) + 1;
      });

      return counts;
    }

    // ===== Construye labels y datasets para Chart.js =====
    function buildChartDataFromCounts(counts){
      // labels = meses presentes en counts, ordenados según monthOrder
      const presentMonths = Object.keys(counts)
        .sort((a,b) => monthOrder.indexOf(a) - monthOrder.indexOf(b));

      // obtener todos los estados únicos (en el orden que aparecen)
      const stateSet = new Set();
      presentMonths.forEach(m => Object.keys(counts[m] || {}).forEach(s => stateSet.add(s)));
      const states = Array.from(stateSet);

      // datasets: para cada estado crear arreglo con valores por mes (0 si no hay)
      const datasets = states.map((estado, idx) => ({
        label: estado,
        data: presentMonths.map(m => counts[m][estado] || 0),
        backgroundColor: palette[idx % palette.length]
      }));

      return { labels: presentMonths, datasets };
    }

    // ===== Crear Chart.js (se reutiliza si existe) =====
    let chartInstance = null;
    function buildAndRenderChart(counts) {
      const ctx = document.getElementById('stackedChart').getContext('2d');
      const chartData = buildChartDataFromCounts(counts);

      // destruir instancia previa si existe
      if (chartInstance) chartInstance.destroy();

      chartInstance = new Chart(ctx, {
        type: 'bar',
        data: chartData,
        options: {
          plugins: {
            title: { display: true, text: 'Estados de clientes por Mes (Transaccional_RFM_Cohort)', font: { size: 18 } },
            tooltip: { mode: 'index', intersect: false }
          },
          responsive: true,
          scales: {
            x: { stacked: true },
            y: { stacked: true, beginAtZero: true, title: { display: true, text: 'Número de clientes' } }
          }
        }
      });
    }

    // ===== Inicializar desde la tabla HTML =====
    buildAndRenderChart(getAggregatedCounts());

    // ======= OPCIONAL: cargar datos desde un endpoint REST que devuelva JSON =========
    // Si prefieres obtener los datos desde tu BD, configura un endpoint que devuelva filas:
    // [{ "idCustomer":101, "Mes":"Enero", "Estado":"Activo", "+RFM":"444", ... }, ...]
    // Luego descomenta y adapta la función fetchDataAndRender() y llama a ella en lugar de buildAndRenderChart(getAggregatedCounts()).
    /*
    async function fetchDataAndRender(){
      try {
        const res = await fetch('/api/transaccional_rfm_cohort'); // ajusta URL
        const rows = await res.json(); 
        // rows debe ser un array de objetos con propiedades Mes y Estado (y opcionales +RFM,...)
        const counts = {};
        const rfmFilter = (document.getElementById('filterRfm').value || "").trim();

        rows.forEach(r => {
          const mes = normalize(r.Mes);
          const estado = normalize(r.Estado);
          const rfm = (r["+RFM"] || "").trim();
          if (rfmFilter && rfm !== rfmFilter) return;
          if (!counts[mes]) counts[mes] = {};
          counts[mes][estado] = (counts[mes][estado] || 0) + 1;
        });

        buildAndRenderChart(counts);
      } catch (err) {
        console.error('Error al cargar datos:', err);
      }
    }
    // fetchDataAndRender();
    */

  </script>
</body>
</html>