const state = {
  data: null,
  runtime: null,
  search: "",
  status: "",
  location: "",
};

const labels = {
  verified: "Verified",
  in_progress: "In progress",
  review_needed: "Review needed",
  blocked: "Blocked",
  not_started: "Not started",
  ready: "Ready",
};

function pathLink(path) {
  return `/${path.split("/").map(encodeURIComponent).join("/")}`;
}

function renderStatusStrip(summary) {
  const order = ["verified", "in_progress", "review_needed", "blocked", "not_started"];
  document.querySelector("#status-strip").innerHTML = order
    .map(
      (key) => `
        <div class="status-stat ${key}">
          <strong>${summary.counts[key] || 0}</strong>
          <span>${labels[key]}</span>
        </div>`,
    )
    .join("");
}

function renderEfforts(efforts) {
  const element = document.querySelector("#current-efforts");
  if (!efforts.length) {
    element.innerHTML = '<div class="empty-state">No active claim work is recorded.</div>';
    return;
  }
  element.innerHTML = efforts
    .map(
      (claim) => `
        <div class="effort">
          <div class="claim-id">${claim.id}</div>
          <div class="effort-title">
            ${claim.title}
            <small>${claim.engine} · ${claim.location} · source ${claim.lines}</small>
            <div class="mini-progress"><span style="width:${claim.progress}%"></span></div>
          </div>
          <div class="effort-value">${claim.progress}%</div>
        </div>`,
    )
    .join("");
}

function renderLocations(environments) {
  document.querySelector("#execution-locations").innerHTML = environments
    .map(
      (item) => `
        <div class="execution-card ${item.location}">
          <header>
            <strong>${item.title}</strong>
            <span class="status ${item.status}">${labels[item.status] || item.status}</span>
          </header>
          <p>${item.version}<br>${item.host}<br><code>${item.command}</code></p>
          <small>${item.notes}</small>
        </div>`,
    )
    .join("");
}

function renderJobs(jobs) {
  const element = document.querySelector("#remote-jobs");
  if (!jobs.length) {
    element.innerHTML =
      '<div class="empty-state">No remote Magma jobs are running. The first remote batch will follow the degree-3 SageMath baseline.</div>';
    return;
  }
  element.innerHTML = jobs
    .map(
      (job) => `
        <div class="remote-job">
          <header><strong>${job.id}</strong><span class="status ${job.status}">${labels[job.status] || job.status}</span></header>
          <p>${job.summary}<br>${job.host} · ${job.screen || "no screen session"}</p>
        </div>`,
    )
    .join("");
}

function renderResults(results) {
  const element = document.querySelector("#recent-results");
  if (!results.length) {
    element.innerHTML = '<div class="empty-state">No evidence has been recorded yet.</div>';
    return;
  }
  element.innerHTML = results
    .slice()
    .reverse()
    .slice(0, 8)
    .map(
      (item) => `
        <div class="result-item">
          <time>${item.timestamp}</time>
          <p><span class="claim-id">${item.claim_id}</span> · ${item.summary}</p>
        </div>`,
    )
    .join("");
}

function matchesFilters(claim) {
  const haystack = `${claim.id} ${claim.title} ${claim.category} ${claim.engine} ${claim.notes}`.toLowerCase();
  return (
    (!state.search || haystack.includes(state.search)) &&
    (!state.status || claim.status === state.status) &&
    (!state.location || claim.location === state.location)
  );
}

function renderClaims() {
  const claims = state.data.claims.filter(matchesFilters);
  document.querySelector("#claim-rows").innerHTML = claims
    .map(
      (claim) => `
        <tr>
          <td>
            <span class="claim-id">${claim.id}</span>
            <div class="claim-title">${claim.title}</div>
          </td>
          <td><a class="source-ref" href="${pathLink(claim.source)}">${claim.lines}</a></td>
          <td><span class="engine">${claim.engine}</span></td>
          <td><span class="location ${claim.location}">${claim.location}</span></td>
          <td><span class="status ${claim.status}">${labels[claim.status] || claim.status}</span></td>
          <td>
            <div class="progress-cell">${claim.progress}%</div>
            <div class="mini-progress"><span style="width:${claim.progress}%"></span></div>
          </td>
          <td>
            <div class="artifact-list">
              ${
                claim.artifacts.length
                  ? claim.artifacts.map((path) => `<a href="${pathLink(path)}">${path.split("/").pop()}</a>`).join("")
                  : '<span class="source-ref">pending</span>'
              }
            </div>
          </td>
        </tr>`,
    )
    .join("");
}

function bindFilters() {
  document.querySelector("#search").addEventListener("input", (event) => {
    state.search = event.target.value.trim().toLowerCase();
    renderClaims();
  });
  document.querySelector("#status-filter").addEventListener("change", (event) => {
    state.status = event.target.value;
    renderClaims();
  });
  document.querySelector("#location-filter").addEventListener("change", (event) => {
    state.location = event.target.value;
    renderClaims();
  });
}

async function loadDashboard() {
  const response = await fetch(`/dashboard/status.json?ts=${Date.now()}`, { cache: "no-store" });
  if (!response.ok) {
    throw new Error(`Dashboard status request failed: ${response.status}`);
  }
  state.data = await response.json();
  document.querySelector("#updated-at").textContent =
    `Last generated ${state.data.generated_at} · ${state.data.summary.total} tracked claims · arXiv 2606.02429`;
  document.querySelector("#overall-progress").textContent = `${state.data.summary.overall_progress}%`;
  document.querySelector("#setup-progress").textContent = `${state.data.summary.setup_readiness}%`;
  renderStatusStrip(state.data.summary);
  renderEfforts(state.data.current_efforts);
  renderLocations(state.data.environments);
  renderJobs(state.data.remote_jobs);
  renderResults(state.data.recent_results);
  renderClaims();
}

bindFilters();
loadDashboard().catch((error) => {
  document.querySelector("#updated-at").textContent = error.message;
});
setInterval(() => loadDashboard().catch(() => {}), 10000);
