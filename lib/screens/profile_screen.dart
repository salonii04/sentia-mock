import 'package:flutter/material.dart';
import '../models/mood.dart';
import '../models/conversation_mood.dart';
import '../theme/app_theme.dart';
import '../widgets/diary_modal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// June 2025 calendar constants
// June 1, 2025 = Sunday → 6 leading blank cells in a Mon–Sun grid
// ─────────────────────────────────────────────────────────────────────────────
const int _kJuneLeadingBlanks = 6;
const int _kJuneDays = 30;

// ─────────────────────────────────────────────────────────────────────────────
// Diary entry resolver
// ─────────────────────────────────────────────────────────────────────────────

/// Returns the correct June 3 diary entry string for [mood].
/// Falls back to the sad-track entry when no conversation has occurred yet
/// (neutral), since the default calendar cell is the pale grayish-green
/// associated with the melancholic mood.
String getDiaryEntry(ConversationMood mood) {
  return mood == ConversationMood.happyProposalTrack
      ? kDiaryHappyEntry
      : kDiarySadEntry; // neutral + sadExamTrack both default to sad entry
}

// ─────────────────────────────────────────────────────────────────────────────
// ProfileScreen
// ─────────────────────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  /// The active conversation mood — used to resolve the June 3 diary entry.
  final ConversationMood conversationMood;

  const ProfileScreen({
    super.key,
    required this.conversationMood,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Selected day for highlight ring — defaults to June 3 (the diary day).
  int _selectedDay = 3;

  void _onDayTap(int day) {
    setState(() => _selectedDay = day);
    if (day == 3) {
      DiaryModal.show(
        context,
        entryText: getDiaryEntry(widget.conversationMood),
        onSave: () {}, // preserves all state — no resets triggered
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.softCream,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'My Profile',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreenText,
                ),
              ),
              const SizedBox(height: 24),
              _ProfileHeader(),
              const SizedBox(height: 20),
              _StatsCard(),
              const SizedBox(height: 24),
              // Activity section label
              Row(
                children: [
                  Text(
                    'Mood Activity',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreenText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• June 2025',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.earthBrown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _JuneCalendarGrid(
                selectedDay: _selectedDay,
                onDayTap: _onDayTap,
              ),
              const SizedBox(height: 24),
              Text(
                'Mood Legend',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreenText,
                ),
              ),
              const SizedBox(height: 10),
              const _MoodLegendRow(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile header card
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.sageGreen.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF3A5F3E),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lightSage, width: 3),
            ),
            child: const Center(
              child: Icon(Icons.person_rounded, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@Marionette',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreenText,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sageGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'JOINED 2025',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.sageGreen,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.softCream,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider, width: 1),
            ),
            child: Icon(Icons.settings_outlined,
                color: AppColors.earthBrown, size: 20),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats card (gradient)
// ─────────────────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.deepForest, const Color(0xFF4A7C4E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepForest.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          _StatItem(emoji: '🔥', value: '10', label: 'Streak'),
          _StatDivider(),
          _StatItem(emoji: '🌱', value: '420', label: 'Seeds'),
          _StatDivider(),
          _StatItem(emoji: '💎', value: '50', label: 'Points'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _StatItem(
      {required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.70))),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 50,
        color: Colors.white.withOpacity(0.20),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// June 2025 calendar grid
// ─────────────────────────────────────────────────────────────────────────────

class _JuneCalendarGrid extends StatelessWidget {
  final int selectedDay;
  final Function(int day) onDayTap;

  const _JuneCalendarGrid(
      {required this.selectedDay, required this.onDayTap});

  @override
  Widget build(BuildContext context) {
    const totalCells = _kJuneLeadingBlanks + _kJuneDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.sageGreen.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Day-of-week header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((d) {
              return SizedBox(
                width: 36,
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.earthBrown.withOpacity(0.70),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: totalCells,
            itemBuilder: (_, i) {
              if (i < _kJuneLeadingBlanks) return const SizedBox.shrink();
              final dayNum = i - _kJuneLeadingBlanks + 1;
              final mood = kJuneMoodMap[dayNum];
              final cellColor = mood != null
                  ? colorForMood(mood)
                  : const Color(0xFFEEEEEE);
              final isSelected = dayNum == selectedDay;
              final isDiaryDay = dayNum == 3;

              return GestureDetector(
                onTap: () => onDayTap(dayNum),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  decoration: BoxDecoration(
                    color: cellColor,
                    borderRadius: BorderRadius.circular(9),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 2.5)
                        : isDiaryDay
                            ? Border.all(
                                color: AppColors.deepForest, width: 2)
                            : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.28),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$dayNum',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: mood != null
                            ? Colors.white.withOpacity(0.92)
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          // Hint row
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colorForMood(Mood.sad),
                  borderRadius: BorderRadius.circular(4),
                  border:
                      Border.all(color: AppColors.deepForest, width: 1.5),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'Tap June 3 to read your diary entry',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10.5,
                  color: AppColors.earthBrown,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mood legend — horizontally scrollable chip row
// ─────────────────────────────────────────────────────────────────────────────

class _MoodLegendRow extends StatelessWidget {
  const _MoodLegendRow();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: kMoodLegend.map((info) {
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: info.color.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                  color: info.color.withOpacity(0.35), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: info.color,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(width: 7),
                Text(info.emoji,
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 5),
                Text(
                  info.label,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGreenText,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
