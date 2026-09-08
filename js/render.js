// Pure-ish rendering helpers. Each function returns an HTML string.
// Event wiring happens in app.js after the HTML is inserted into the DOM.

function escapeHtml(str) {
  const div = document.createElement("div");
  div.textContent = str ?? "";
  return div.innerHTML;
}

function renderLinkList(links, keyLabel) {
  if (!links || links.length === 0) return "";
  return `<ul class="link-list">${links
    .map((l) => {
      const label = keyLabel ? `${escapeHtml(l.company)} — ${escapeHtml(l.title)}` : escapeHtml(l.title);
      return `<li><a href="${escapeHtml(l.url)}" target="_blank" rel="noopener">${label}</a></li>`;
    })
    .join("")}</ul>`;
}

// ---------- TOPICS ----------
function renderTopics(topics) {
  if (topics.length === 0) return `<div class="empty-state">No topics at this difficulty yet.</div>`;
  return `<div class="timeline">${topics
    .map(
      (t) => `
    <div class="timeline-item">
      <div class="timeline-dot"></div>
      <div class="card">
        <div class="card-title-row" data-toggle="topic-${t.id}">
          <h3>${escapeHtml(t.name)}</h3>
        </div>
        <div class="card-body hidden" id="topic-${t.id}">
          <p>${escapeHtml(t.summary)}</p>
          ${t.source_links?.length ? `<div class="section-label">Free sources to read further</div>${renderLinkList(t.source_links, false)}` : ""}
          ${t.blog_links?.length ? `<div class="section-label">Related engineering blog posts</div>${renderLinkList(t.blog_links, true)}` : ""}
        </div>
      </div>
    </div>`
    )
    .join("")}</div>`;
}

// ---------- PROBLEMS ----------
function statusFor(attempt) {
  if (!attempt) return { cls: "", label: "not attempted" };
  if (attempt.struggled) return { cls: "struggled", label: "struggled" };
  if (attempt.solution_revealed) return { cls: "solved", label: "reviewed" };
  return { cls: "attempted", label: "in progress" };
}

function renderProblems(problems, attemptsById) {
  if (problems.length === 0) return `<div class="empty-state">No problems at this difficulty yet.</div>`;
  return problems
    .map((p) => {
      const attempt = attemptsById[p.id];
      const status = statusFor(attempt);
      const hintsRevealed = attempt?.hints_revealed_count || 0;
      return `
      <div class="card">
        <div class="card-title-row" data-toggle="problem-${p.id}">
          <div style="display:flex;align-items:center;gap:8px;">
            <span class="status-dot ${status.cls}"></span>
            <h3>${escapeHtml(p.title)}</h3>
          </div>
        </div>
        <div class="card-body hidden" id="problem-${p.id}">
          <div class="section-label">My attempt (write this before revealing hints)</div>
          <textarea class="attempt-box" data-attempt="${p.id}" placeholder="Sketch your approach here...">${escapeHtml(attempt?.my_attempt_text || "")}</textarea>
          <div style="margin-top:8px;"><button class="btn btn-secondary" data-save-attempt="${p.id}">Save attempt</button></div>

          <details class="accordion">
            <summary>Hints (${hintsRevealed}/${p.hints.length} revealed)</summary>
            <div class="accordion-content">
              ${p.hints
                .map((h, i) =>
                  i < hintsRevealed
                    ? `<p>${i + 1}. ${escapeHtml(h)}</p>`
                    : i === hintsRevealed
                    ? `<button class="btn btn-secondary" data-reveal-hint="${p.id}">Reveal hint ${i + 1}</button>`
                    : ""
                )
                .join("")}
            </div>
          </details>

          <details class="accordion" ${attempt?.solution_revealed ? "open" : ""}>
            <summary>Solution</summary>
            <div class="accordion-content">
              ${
                attempt?.solution_revealed
                  ? `<p>${escapeHtml(p.solution)}</p>`
                  : `<button class="btn" data-reveal-solution="${p.id}">Reveal solution</button>`
              }
            </div>
          </details>

          <label class="toggle-row">
            <input type="checkbox" data-struggled="${p.id}" ${attempt?.struggled ? "checked" : ""} />
            Mark as struggled (resurfaces in Mistakes Log)
          </label>
        </div>
      </div>`;
    })
    .join("");
}

// ---------- FLASHCARDS ----------
function renderFlashcardStudy(card, showBack) {
  if (!card) {
    return `<div class="empty-state">No flashcards due right now — nice work. Use "Browse all" to review anyway.</div>`;
  }
  return `
    <div class="flashcard-label">${card.type === "tradeoff" ? "trade-off" : "definition"} · tap to flip</div>
    <div class="flashcard" id="flashcard-face">${escapeHtml(showBack ? card.back : card.front)}</div>
    ${
      showBack
        ? `<div class="flashcard-actions">
             <button class="btn btn-secondary" data-card-result="struggled">Struggled</button>
             <button class="btn" data-card-result="got-it">Got it</button>
           </div>`
        : ""
    }
  `;
}

// ---------- MISTAKES LOG ----------
function renderMistakes(struggledProblems, struggledCards) {
  if (struggledProblems.length === 0 && struggledCards.length === 0) {
    return `<div class="empty-state">Nothing marked as struggled yet — this fills in automatically as you study.</div>`;
  }
  let html = "";
  if (struggledProblems.length) {
    html += `<div class="section-label">Problems</div>`;
    html += struggledProblems
      .map((p) => `<div class="card"><div class="card-title-row" data-jump="problems"><h3>${escapeHtml(p.title)}</h3></div></div>`)
      .join("");
  }
  if (struggledCards.length) {
    html += `<div class="section-label">Flashcards</div>`;
    html += struggledCards
      .map((c) => `<div class="card"><div class="card-title-row" data-jump="flashcards"><h3>${escapeHtml(c.front)}</h3></div></div>`)
      .join("");
  }
  return html;
}

// ---------- SETTINGS ----------
function renderSettings(settings) {
  return `
    <div class="card">
      <div class="setting-row">
        <span>Difficulty filter</span>
        <select id="setting-difficulty">
          <option value="easy" ${settings.difficulty_filter === "easy" ? "selected" : ""}>Easy</option>
          <option value="medium" ${settings.difficulty_filter === "medium" ? "selected" : ""}>Medium</option>
          <option value="hard" ${settings.difficulty_filter === "hard" ? "selected" : ""}>Hard</option>
        </select>
      </div>
      <div class="setting-row">
        <span>Timer on by default</span>
        <input type="checkbox" id="setting-timer-enabled" ${settings.timer_enabled ? "checked" : ""} />
      </div>
      <div class="setting-row">
        <span>Default timer length</span>
        <select id="setting-timer-length">
          <option value="600" ${settings.timer_default_seconds == 600 ? "selected" : ""}>10 min</option>
          <option value="1200" ${settings.timer_default_seconds == 1200 ? "selected" : ""}>20 min</option>
          <option value="1800" ${settings.timer_default_seconds == 1800 ? "selected" : ""}>30 min</option>
        </select>
      </div>
      <div class="setting-row">
        <span>Signed in</span>
        <button class="btn btn-secondary" id="sign-out-btn">Sign out</button>
      </div>
    </div>
  `;
}
