import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum Mood { excited, happy, calm, disgusted, angry, sad }

enum WeatherState { sunny, rainyOvercast }

// ─────────────────────────────────────────────────────────────────────────────
// Mood metadata
// ─────────────────────────────────────────────────────────────────────────────

class MoodInfo {
  final Mood mood;
  final Color color;
  final String emoji;
  final String label;

  const MoodInfo({
    required this.mood,
    required this.color,
    required this.emoji,
    required this.label,
  });
}

/// Ordered legend entries for the Profile mood legend row.
/// All colours are tonal variants of green to reflect the organic wellness theme.
const List<MoodInfo> kMoodLegend = [
  MoodInfo(mood: Mood.excited,   color: Color(0xFF0A3D0A), emoji: '🌲', label: 'Excited'),
  MoodInfo(mood: Mood.happy,     color: Color(0xFF1B5E20), emoji: '🌿', label: 'Happy'),
  MoodInfo(mood: Mood.calm,      color: Color(0xFF6B8F6E), emoji: '🍃', label: 'Calm'),
  MoodInfo(mood: Mood.disgusted, color: Color(0xFF556B2F), emoji: '🫒', label: 'Disgusted'),
  MoodInfo(mood: Mood.angry,     color: Color(0xFF4CAF50), emoji: '🧪', label: 'Angry'),
  MoodInfo(mood: Mood.sad,       color: Color(0xFF90A898), emoji: '🌫️', label: 'Sad'),
];

// ─────────────────────────────────────────────────────────────────────────────
// June 2025 mood map (day → mood)
// ─────────────────────────────────────────────────────────────────────────────
// June 1, 2025 = Sunday.  June 3rd is always Sad → triggers rainy weather.

const Map<int, Mood> kJuneMoodMap = {
  1:  Mood.calm,
  2:  Mood.happy,
  3:  Mood.sad,        // ← Diary day; triggers WeatherState.rainyOvercast
  4:  Mood.calm,
  5:  Mood.excited,
  6:  Mood.happy,
  7:  Mood.calm,
  8:  Mood.disgusted,
  9:  Mood.calm,
  10: Mood.happy,
  11: Mood.excited,
  12: Mood.calm,
  13: Mood.angry,
  14: Mood.calm,
  15: Mood.happy,
  16: Mood.calm,
  17: Mood.disgusted,
  18: Mood.happy,
  19: Mood.excited,
  20: Mood.calm,
  21: Mood.happy,
  22: Mood.calm,
  23: Mood.excited,
  24: Mood.happy,
  25: Mood.calm,
  26: Mood.happy,
  27: Mood.excited,
  28: Mood.calm,
  29: Mood.happy,
  30: Mood.excited,
};

// ─────────────────────────────────────────────────────────────────────────────
// Helper functions
// ─────────────────────────────────────────────────────────────────────────────

WeatherState weatherForMood(Mood mood) =>
    mood == Mood.sad ? WeatherState.rainyOvercast : WeatherState.sunny;

Color colorForMood(Mood mood) =>
    kMoodLegend.firstWhere((m) => m.mood == mood).color;

MoodInfo infoForMood(Mood mood) =>
    kMoodLegend.firstWhere((m) => m.mood == mood);
