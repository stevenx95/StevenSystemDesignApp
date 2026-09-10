const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const DB = {
  // ---------- Auth ----------
  async getSession() {
    const { data } = await supabaseClient.auth.getSession();
    return data.session;
  },
  onAuthChange(cb) {
    supabaseClient.auth.onAuthStateChange((_event, session) => cb(session));
  },
  async signInWithMagicLink(email) {
    return supabaseClient.auth.signInWithOtp({ email });
  },
  async signOut() {
    return supabaseClient.auth.signOut();
  },

  // ---------- Content (read-only from client) ----------
  async getTopics() {
    const { data, error } = await supabaseClient.from("topics").select("*").order("sequence_order");
    if (error) throw error;
    return data;
  },
  async getProblems() {
    const { data, error } = await supabaseClient.from("problems").select("*");
    if (error) throw error;
    return data;
  },
  async getFlashcards() {
    const { data, error } = await supabaseClient.from("flashcards").select("*");
    if (error) throw error;
    return data;
  },
  async getEstimationDrills() {
    const { data, error } = await supabaseClient.from("estimation_drills").select("*");
    if (error) throw error;
    return data;
  },

  // ---------- Personal: settings ----------
  async getSettings(userId) {
    const { data, error } = await supabaseClient
      .from("user_settings")
      .select("*")
      .eq("user_id", userId)
      .maybeSingle();
    if (error) throw error;
    if (!data) {
      // First login — create default settings row
      const { data: created, error: insertErr } = await supabaseClient
        .from("user_settings")
        .insert({ user_id: userId })
        .select()
        .single();
      if (insertErr) throw insertErr;
      return created;
    }
    return data;
  },
  async updateSettings(userId, patch) {
    const { data, error } = await supabaseClient
      .from("user_settings")
      .update({ ...patch, updated_at: new Date().toISOString() })
      .eq("user_id", userId)
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  // ---------- Personal: problem attempts ----------
  async getProblemAttempts(userId) {
    const { data, error } = await supabaseClient.from("problem_attempts").select("*").eq("user_id", userId);
    if (error) throw error;
    return data;
  },
  async upsertProblemAttempt(userId, problemId, patch) {
    const { data, error } = await supabaseClient
      .from("problem_attempts")
      .upsert(
        { user_id: userId, problem_id: problemId, ...patch, updated_at: new Date().toISOString() },
        { onConflict: "user_id,problem_id" }
      )
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  // ---------- Personal: flashcard reviews ----------
  async getFlashcardReviews(userId) {
    const { data, error } = await supabaseClient.from("flashcard_reviews").select("*").eq("user_id", userId);
    if (error) throw error;
    return data;
  },
  async upsertFlashcardReview(userId, flashcardId, patch) {
    const { data, error } = await supabaseClient
      .from("flashcard_reviews")
      .upsert(
        { user_id: userId, flashcard_id: flashcardId, ...patch },
        { onConflict: "user_id,flashcard_id" }
      )
      .select()
      .single();
    if (error) throw error;
    return data;
  },
};
