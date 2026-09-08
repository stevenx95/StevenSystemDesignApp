const state = {
  session: null,
  userId: null,
  settings: null,
  topics: [],
  problems: [],
  flashcards: [],
  attemptsById: {},
  reviewsById: {},
  currentView: "topics",
  currentCard: null,
  currentCardShowingBack: false,
};

const viewTitles = {
  topics: "Topics",
  problems: "Problems",
  flashcards: "Flashcards",
  mistakes: "Mistakes Log",
  settings: "Settings",
};

// ---------- Boot ----------
async function boot() {
  const session = await DB.getSession();
  if (session) {
    await onSignedIn(session);
  } else {
    document.getElementById("auth-screen").classList.remove("hidden");
  }

  DB.onAuthChange(async (session) => {
    if (session && !state.session) {
      await onSignedIn(session);
    }
  });

  document.getElementById("auth-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const email = document.getElementById("auth-email").value.trim();
    const msg = document.getElementById("auth-message");
    msg.textContent = "Sending link...";
    try {
      const { error } = await DB.signInWithMagicLink(email);
      if (error) throw error;
      msg.textContent = "Check your email for a sign-in link.";
    } catch (err) {
      msg.textContent = "Something went wrong: " + err.message;
    }
  });

  document.querySelectorAll(".nav-item").forEach((btn) => {
    btn.addEventListener("click", () => switchView(btn.dataset.view));
  });
}

async function onSignedIn(session) {
  state.session = session;
  state.userId = session.user.id;
  document.getElementById("auth-screen").classList.add("hidden");
  document.getElementById("app").classList.remove("hidden");

  const [settings, topics, problems, flashcards, attempts, reviews] = await Promise.all([
    DB.getSettings(state.userId),
    DB.getTopics(),
    DB.getProblems(),
    DB.getFlashcards(),
    DB.getProblemAttempts(state.userId),
    DB.getFlashcardReviews(state.userId),
  ]);

  state.settings = settings;
  state.topics = topics;
  state.problems = problems;
  state.flashcards = flashcards;
  state.attemptsById = Object.fromEntries(attempts.map((a) => [a.problem_id, a]));
  state.reviewsById = Object.fromEntries(reviews.map((r) => [r.flashcard_id, r]));

  switchView("topics");
}

// ---------- View switching ----------
function switchView(view) {
  state.currentView = view;
  document.querySelectorAll(".nav-item").forEach((b) => b.classList.toggle("active", b.dataset.view === view));
  document.querySelectorAll(".view").forEach((v) => v.classList.add("hidden"));
  document.getElementById(`view-${view}`).classList.remove("hidden");
  document.getElementById("view-title").textContent = viewTitles[view];
  document.getElementById("difficulty-badge").classList.toggle("hidden", view === "settings");
  document.getElementById("difficulty-badge").textContent = state.settings.difficulty_filter;

  if (view === "topics") renderTopicsView();
  if (view === "problems") renderProblemsView();
  if (view === "flashcards") renderFlashcardsView();
  if (view === "mistakes") renderMistakesView();
  if (view === "settings") renderSettingsView();
}

function byDifficulty(items) {
  const order = { easy: 1, medium: 2, hard: 3 };
  const max = order[state.settings.difficulty_filter];
  return items.filter((i) => order[i.difficulty] <= max);
}

// ---------- Topics ----------
function renderTopicsView() {
  const container = document.getElementById("view-topics");
  container.innerHTML = renderTopics(byDifficulty(state.topics));
  container.querySelectorAll("[data-toggle]").forEach((el) => {
    el.addEventListener("click", () => {
      document.getElementById(el.dataset.toggle).classList.toggle("hidden");
    });
  });
}

// ---------- Problems ----------
function renderProblemsView() {
  const container = document.getElementById("view-problems");
  container.innerHTML = renderProblems(byDifficulty(state.problems), state.attemptsById);

  container.querySelectorAll("[data-toggle]").forEach((el) => {
    el.addEventListener("click", () => document.getElementById(el.dataset.toggle).classList.toggle("hidden"));
  });

  container.querySelectorAll("[data-save-attempt]").forEach((btn) => {
    btn.addEventListener("click", async () => {
      const problemId = btn.dataset.saveAttempt;
      const text = container.querySelector(`[data-attempt="${problemId}"]`).value;
      const updated = await DB.upsertProblemAttempt(state.userId, problemId, { my_attempt_text: text });
      state.attemptsById[problemId] = updated;
      btn.textContent = "Saved";
      setTimeout(() => (btn.textContent = "Save attempt"), 1200);
    });
  });

  container.querySelectorAll("[data-reveal-hint]").forEach((btn) => {
    btn.addEventListener("click", async () => {
      const problemId = btn.dataset.revealHint;
      const current = state.attemptsById[problemId]?.hints_revealed_count || 0;
      const updated = await DB.upsertProblemAttempt(state.userId, problemId, { hints_revealed_count: current + 1 });
      state.attemptsById[problemId] = updated;
      renderProblemsView();
    });
  });

  container.querySelectorAll("[data-reveal-solution]").forEach((btn) => {
    btn.addEventListener("click", async () => {
      const problemId = btn.dataset.revealSolution;
      const updated = await DB.upsertProblemAttempt(state.userId, problemId, { solution_revealed: true });
      state.attemptsById[problemId] = updated;
      renderProblemsView();
    });
  });

  container.querySelectorAll("[data-struggled]").forEach((cb) => {
    cb.addEventListener("change", async () => {
      const problemId = cb.dataset.struggled;
      const updated = await DB.upsertProblemAttempt(state.userId, problemId, { struggled: cb.checked });
      state.attemptsById[problemId] = updated;
    });
  });
}

// ---------- Flashcards ----------
function pickNextCard() {
  const now = new Date();
  const due = byDifficulty(state.flashcards).filter((c) => {
    const review = state.reviewsById[c.id];
    return !review || new Date(review.next_due_at) <= now;
  });
  return due.length ? due[Math.floor(Math.random() * due.length)] : null;
}

function renderFlashcardsView() {
  state.currentCard = pickNextCard();
  state.currentCardShowingBack = false;
  paintFlashcard();
}

function paintFlashcard() {
  const container = document.getElementById("view-flashcards");
  container.innerHTML = renderFlashcardStudy(state.currentCard, state.currentCardShowingBack);

  const face = document.getElementById("flashcard-face");
  if (face) {
    face.addEventListener("click", () => {
      state.currentCardShowingBack = !state.currentCardShowingBack;
      paintFlashcard();
    });
  }

  container.querySelectorAll("[data-card-result]").forEach((btn) => {
    btn.addEventListener("click", async () => {
      const struggled = btn.dataset.cardResult === "struggled";
      await rateCurrentCard(struggled);
      renderFlashcardsView();
    });
  });
}

async function rateCurrentCard(struggled) {
  const card = state.currentCard;
  const prevReview = state.reviewsById[card.id];
  const prevEase = prevReview?.ease_factor ?? 2.5;
  const now = new Date();

  let nextDue, easeFactor;
  if (struggled) {
    easeFactor = Math.max(1.3, prevEase - 0.2);
    nextDue = new Date(now.getTime() + 10 * 60 * 1000); // resurface in 10 min
  } else {
    easeFactor = Math.min(3.0, prevEase + 0.1);
    const prevIntervalDays = prevReview
      ? Math.max(1, (new Date(prevReview.next_due_at) - new Date(prevReview.last_reviewed_at || now)) / 86400000)
      : 1;
    const nextIntervalDays = Math.min(60, Math.max(1, prevIntervalDays * easeFactor));
    nextDue = new Date(now.getTime() + nextIntervalDays * 86400000);
  }

  const updated = await DB.upsertFlashcardReview(state.userId, card.id, {
    last_reviewed_at: now.toISOString(),
    next_due_at: nextDue.toISOString(),
    ease_factor: easeFactor,
    struggled,
  });
  state.reviewsById[card.id] = updated;
}

// ---------- Mistakes log ----------
function renderMistakesView() {
  const struggledProblems = state.problems.filter((p) => state.attemptsById[p.id]?.struggled);
  const struggledCards = state.flashcards.filter((c) => state.reviewsById[c.id]?.struggled);
  const container = document.getElementById("view-mistakes");
  container.innerHTML = renderMistakes(struggledProblems, struggledCards);
  container.querySelectorAll("[data-jump]").forEach((el) => {
    el.addEventListener("click", () => switchView(el.dataset.jump));
  });
}

// ---------- Settings ----------
function renderSettingsView() {
  const container = document.getElementById("view-settings");
  container.innerHTML = renderSettings(state.settings);

  document.getElementById("setting-difficulty").addEventListener("change", async (e) => {
    state.settings = await DB.updateSettings(state.userId, { difficulty_filter: e.target.value });
    document.getElementById("difficulty-badge").textContent = state.settings.difficulty_filter;
  });
  document.getElementById("setting-timer-enabled").addEventListener("change", async (e) => {
    state.settings = await DB.updateSettings(state.userId, { timer_enabled: e.target.checked });
  });
  document.getElementById("setting-timer-length").addEventListener("change", async (e) => {
    state.settings = await DB.updateSettings(state.userId, { timer_default_seconds: parseInt(e.target.value, 10) });
  });
  document.getElementById("sign-out-btn").addEventListener("click", async () => {
    await DB.signOut();
    window.location.reload();
  });
}

boot();
