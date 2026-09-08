# System Design Study App

A personal, cross-device system design study tool: topics, problems (with hints/solutions),
flashcards, an estimation drills section, and a mistakes log — backed by Supabase so your
progress syncs between your phone and computer.

No build step. Plain HTML/CSS/JS, deployable straight to GitHub Pages.

## 1. Create your Supabase project

1. Go to https://supabase.com and sign up (free tier is enough).
2. Create a new project. Pick any name/region/password (save the DB password somewhere safe).
   password: aBtH8k1V7ZBAF9Tv
3. Wait for it to finish provisioning (~2 minutes).

## 2. Set up the database

1. In your Supabase project, open **SQL Editor** (left sidebar) > **New query**.
2. Paste the entire contents of `sql/schema.sql` and click **Run**.
3. New query again, paste the entire contents of `sql/seed.sql`, click **Run**.
   This loads real starter content (8 easy topics forming the "single server → +DB → +cache →
   +load balancer → +replication" story, plus medium/hard topics, 3 problems, 8 flashcards,
   2 estimation drills). Add more anytime via **Table Editor**.

## 3. Turn on email sign-in

1. In Supabase: **Authentication > Providers**, make sure **Email** is enabled (it is by default).
2. **Authentication > URL Configuration**: set **Site URL** to wherever you'll host this
   (e.g. `https://yourusername.github.io/your-repo-name/`). You can update this later once
   you know your real GitHub Pages URL.
3. That's it — the app uses passwordless "magic link" sign-in (you enter your email, click a
   link Supabase emails you, you're in). No password to manage.

## 4. Connect the app to your project

1. In Supabase: **Project Settings > API**.
2. Copy the **Project URL** and the **anon public** key.
3. Open `js/config.js` in this project and paste them in:

```js
const SUPABASE_URL = "https://xxxxxxxx.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOि...";
```

Never use the `service_role` key here — only the `anon` key is safe for client-side code.

## 5. Test locally (optional but recommended)

You can't just double-click `index.html` (browsers block some features on `file://` URLs).
Instead, from this folder, run a tiny local server:

```bash
python3 -m http.server 8000
```

Then visit `http://localhost:8000` in your browser. Sign in with your email, check your inbox
for the magic link, and you should land in the app.

## 6. Deploy to GitHub Pages

1. Create a new GitHub repository and push this whole folder to it.
2. In the repo: **Settings > Pages**.
3. Under **Source**, choose the branch (usually `main`) and root folder, then save.
4. GitHub gives you a URL like `https://yourusername.github.io/your-repo-name/`.
5. Go back to Supabase **Authentication > URL Configuration** and update the **Site URL**
   (and add it to **Redirect URLs** too) to match this real URL, so the magic-link email
   redirects correctly.

## 7. Add it to your phone's home screen

- **iPhone (Safari)**: open the GitHub Pages URL, tap Share > **Add to Home Screen**.
- **Android (Chrome)**: open the URL, tap the ⋮ menu > **Add to Home Screen** / **Install app**.

It'll open full-screen like a native app from then on.

## Adding your own content later

Everything in **Topics**, **Problems**, **Flashcards**, and **Estimation Drills** lives in
Supabase tables — add, edit, or remove rows anytime via **Table Editor** in the Supabase
dashboard. No code changes needed. Keep summaries in your own words and link out to sources
rather than pasting large excerpts, for both copyright and readability reasons.

## Project structure

```
index.html            – page shell, 4-tab nav + auth screen
css/style.css          – all styling (design tokens at the top)
js/config.js           – YOUR Supabase URL + anon key go here
js/supabaseClient.js   – all database/auth calls
js/render.js           – HTML-generating functions per view
js/app.js              – state, view switching, event wiring, spaced-repetition logic
sql/schema.sql         – table definitions + Row Level Security policies
sql/seed.sql           – starter content (topics/problems/flashcards/drills)
manifest.json          – lets the app be added to your phone's home screen
```
