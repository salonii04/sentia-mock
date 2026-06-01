import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Diary content strings — selected by ConversationMood at call-site
// ─────────────────────────────────────────────────────────────────────────────

const kDiarySadEntry =
    "I was feeling completely miserable and overwhelmed today, convinced I had ruined everything after failing a couple of my end-semester exams and seeing my parents' disappointment. Talking to Pip helped me catch my breath and step away from those harsh, all-or-nothing thoughts. Instead of drowning in stress tonight, I decided to take a break and pour my energy into my creative writing project to find a little peace.";

const kDiaryHappyEntry =
    "What an amazing day! The project proposal I worked so hard on finally got approved, and the feedback was incredible. Pip shared the excitement with me, which made the win feel even sweeter after all those late nights. I'm finishing the evening celebrating exactly the way I want to — ordering a great meal and completely losing myself in a good book with a clear mind.";

// ─────────────────────────────────────────────────────────────────────────────
// DiaryModal
// ─────────────────────────────────────────────────────────────────────────────

class DiaryModal extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onSave;

  /// The diary entry text to display inside the notebook lines.
  final String entryText;

  const DiaryModal({
    super.key,
    required this.onClose,
    required this.onSave,
    required this.entryText,
  });

  /// Show the diary modal.
  ///
  /// [entryText] is resolved by the caller via [getDiaryEntry] so the modal
  /// itself is mood-agnostic — state is read exactly once at open-time and
  /// the modal never mutates any upstream state layer.
  static void show(
    BuildContext context, {
    required String entryText,
    required VoidCallback onSave,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Diary',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, anim1, anim2) => DiaryModal(
        entryText: entryText,
        onClose: () => Navigator.of(context).pop(),
        onSave: () {
          Navigator.of(context).pop();
          onSave();
        },
      ),
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9F0),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.earthBrown.withOpacity(0.25),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
                  decoration: BoxDecoration(
                    color: AppColors.deepForest,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dear Diary,',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'June 2nd, 2026',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13,
                                color: AppColors.lightSage,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onClose,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Notebook body ───────────────────────────────────
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                    child: _NotebookLines(text: entryText),
                  ),
                ),

                // ── Save button ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: GestureDetector(
                    onTap: onSave,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3A5F3E), Color(0xFF2D4A2F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepForest.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Save',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notebook-lined text renderer
// ─────────────────────────────────────────────────────────────────────────────

class _NotebookLines extends StatelessWidget {
  final String text;
  const _NotebookLines({required this.text});

  @override
  Widget build(BuildContext context) {
    final lines = _splitIntoLines(text, 38);
    const lineHeight = 36.0;

    return Stack(
      children: [
        // Horizontal rule lines behind the text
        Column(
          children: List.generate(lines.length, (_) {
            return Container(
              height: lineHeight,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.sageGreen.withOpacity(0.20),
                    width: 1,
                  ),
                ),
              ),
            );
          }),
        ),
        // Text layer
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: AppColors.darkGreenText,
              height: lineHeight / 14.5,
            ),
          ),
        ),
      ],
    );
  }

  List<String> _splitIntoLines(String text, int charsPerLine) {
    final words = text.split(' ');
    final lines = <String>[];
    String current = '';
    for (final word in words) {
      if ((current + ' ' + word).trim().length > charsPerLine) {
        lines.add(current.trim());
        current = word;
      } else {
        current = (current + ' ' + word).trim();
      }
    }
    if (current.isNotEmpty) lines.add(current);
    return lines;
  }
}
