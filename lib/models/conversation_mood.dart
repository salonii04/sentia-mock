/// Tracks which conversational branch the user is currently engaged in.
///
/// This enum is the single source of truth that drives the reactive
/// environment overlays on the **Garden Tab**.  The Home page background
/// is always static and is never affected by this value.
enum ConversationMood {
  /// No branch has been selected yet.
  /// Garden shows the plain background with no overlay.
  neutral,

  /// Branch A — Melancholic / Setback track.
  /// Triggers the dark atmospheric rain + mist overlay on the Garden Tab.
  sadExamTrack,

  /// Branch B — Joyous / Achievement track.
  /// Triggers the bright rainbow + sunshine overlay on the Garden Tab.
  happyProposalTrack,
}
