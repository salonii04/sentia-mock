import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/conversation_mood.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/top_bar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Pip dialogue reply sequences
// User types freely each turn; these are Pip's scripted responses in order.
// ─────────────────────────────────────────────────────────────────────────────

const _kSadReplies = [
  'It sounds like you are carrying a really heavy weight right now. Please know that it makes complete sense to feel overwhelmed when you care so deeply, but your mind might be jumping to some really harsh conclusions about yourself right now. Would you like to tell me a bit more about what happened? 🐧🌱',
  "Oh, I can see how deeply this hurts, and it makes complete sense that seeing that disappointment feels so heavy right now. Please remember that a difficult exam season doesn't mean your parents' trust and hope are gone forever, even if it feels completely broken today. If you feel up to it, what is one small thing we can do right now just to help you feel a little more grounded? 🐧❄️",
  "When a setback like an exam happens, it is easy to fall into all-or-nothing thinking and forget your own worth. To shift your mindset, remember that a grade measures a specific day's performance, not your intelligence or potential. To lighten your mood right now, step away from your desk, change your physical environment, and focus on one small, comforting action completely unrelated to academics.",
  "That sounds like a beautiful way to spend your time. Pouring your energy into a creative writing project is a wonderful, productive outlet—not because it proves your worth, but because it lets you connect with a part of yourself that you love. Let the words just flow without any pressure for them to be perfect; enjoy the process, and I hope it brings you a sense of peace and comfort this evening. ✍️✨",
];

const _kHappyReplies = [
  "Oh, my little penguin heart is waddling with joy for you! 🐧✨ It is so wonderful to see all your dedication, late nights, and hard work recognized like this. Let's take a moment to just sit in the sunshine of this happy moment together—how are you planning to celebrate your well-deserved win today? 🌱🌸",
  "That sounds like a perfect, cozy way to celebrate! 📚✨ You earned every bit of that rest, so enjoy your book and that delicious meal to the absolute fullest. The Mind Garden is blooming bright today, and I'm just so glad to be here sharing this happy space with you. 🐧🌙",
];

/// Shown when the user's text doesn't match any keyword route.
const _kFallbackReply =
    "I'm right here with you! 🐧💙 Feel free to share how you're feeling — whether something's weighing on your heart, or you have some exciting news to celebrate. I'm listening.";

// ─────────────────────────────────────────────────────────────────────────────
// Keyword route detection
// ─────────────────────────────────────────────────────────────────────────────

const _kSadKeywords = ['miserable', 'failed', 'parents', 'ridiculous'];
const _kHappyKeywords = [
  "won't believe it",
  'proposal',
  'approved',
  'feedback'
];

/// Scans [text] for route keywords and returns the matched [ConversationMood].
/// Returns [ConversationMood.neutral] if no keyword is found.
ConversationMood _detectRoute(String text) {
  final lower = text.toLowerCase();
  if (_kSadKeywords.any((k) => lower.contains(k))) {
    return ConversationMood.sadExamTrack;
  }
  if (_kHappyKeywords.any((k) => lower.contains(k))) {
    return ConversationMood.happyProposalTrack;
  }
  return ConversationMood.neutral;
}

List<String> _repliesFor(ConversationMood mood) =>
    mood == ConversationMood.sadExamTrack ? _kSadReplies : _kHappyReplies;

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  final int currentSeeds;
  final List<Message> messages;
  final Function(List<Message>) onMessagesChanged;

  /// Propagates the detected mood to SentiaShell → GardenScreen overlay.
  final Function(ConversationMood) onConversationMoodChanged;
  final Future<RewardMessageData> Function(ConversationMood)
      onConversationCompleted;

  const HomeScreen({
    super.key,
    required this.currentSeeds,
    required this.messages,
    required this.onMessagesChanged,
    required this.onConversationMoodChanged,
    required this.onConversationCompleted,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Currently active branch (neutral until first keyword match).
  ConversationMood _activeBranch = ConversationMood.neutral;

  /// Index into the active branch's reply list.
  /// 0 → Pip hasn't responded yet; increments after each Pip reply.
  int _messageStep = 0;

  bool _isTyping = false;
  bool _branchComplete = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOut,
      );
    }
  }

  // ── Send handler ───────────────────────────────────────────────────────────

  Future<void> _onSend() async {
    if (_isTyping || _branchComplete) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    // ── Route detection: fires only once, on the first message in neutral ──
    if (_activeBranch == ConversationMood.neutral) {
      final detected = _detectRoute(text);
      if (detected != ConversationMood.neutral) {
        setState(() => _activeBranch = detected);
        // Immediately propagate → Garden overlay switches.
        widget.onConversationMoodChanged(detected);
      }
      // If still neutral (no keyword match), _activeBranch stays neutral
      // and _executeStep will use the fallback reply.
    }

    await _executeStep(text);
  }

  // ── Dialogue step executor ─────────────────────────────────────────────────

  Future<void> _executeStep(String userText) async {
    // ── User bubble ────────────────────────────────────────────────────────
    final base = [
      ...widget.messages,
      Message(text: userText, isUser: true),
    ];
    widget.onMessagesChanged(base);
    setState(() => _isTyping = true);

    await Future.delayed(const Duration(milliseconds: 260));
    if (mounted) _scrollToBottom();

    // ── Pip typing indicator ───────────────────────────────────────────────
    widget.onMessagesChanged([
      ...base,
      Message(text: '...', isUser: false, isTyping: true),
    ]);
    await Future.delayed(const Duration(milliseconds: 280));
    if (mounted) _scrollToBottom();

    // ── Resolve reply & delay ──────────────────────────────────────────────
    final String reply;
    bool nowComplete = false;

    if (_activeBranch == ConversationMood.neutral) {
      // Unrecognised input — gentle nudge (shorter wait, feels lighter)
      await Future.delayed(const Duration(milliseconds: 1600));
      reply = _kFallbackReply;
    } else {
      final replies = _repliesFor(_activeBranch);

      if (_messageStep >= replies.length) {
        // Guard: all replies exhausted; silently close
        if (mounted) {
          widget.onMessagesChanged(base); // remove typing bubble
          setState(() {
            _isTyping = false;
            _branchComplete = true;
          });
        }
        return;
      }

      // Sad track feels heavier → slightly longer pause
      final delay = _activeBranch == ConversationMood.sadExamTrack
          ? const Duration(milliseconds: 2800)
          : const Duration(milliseconds: 2200);
      await Future.delayed(delay);

      reply = replies[_messageStep];
      nowComplete = (_messageStep + 1) >= replies.length;
    }

    if (!mounted) return;

    // ── Pip response bubble ────────────────────────────────────────────────
    final messagesWithReply = [
      ...base,
      Message(text: reply, isUser: false),
    ];
    widget.onMessagesChanged(messagesWithReply);

    setState(() {
      _isTyping = false;
      if (_activeBranch != ConversationMood.neutral) {
        _messageStep++;
        _branchComplete = nowComplete;
      }
    });

    if (nowComplete && _activeBranch != ConversationMood.neutral) {
      final rewardData = await widget.onConversationCompleted(_activeBranch);
      if (!mounted) return;

      final rewardText = rewardData.awarded
          ? '🌱 Reflection Reward Earned'
          : "You've already earned today's seeds.";
      widget.onMessagesChanged([
        ...messagesWithReply,
        Message(
          text: rewardText,
          isUser: false,
          rewardData: rewardData,
        ),
      ]);
    }

    await Future.delayed(const Duration(milliseconds: 260));
    if (mounted) _scrollToBottom();
  }

  // ── Build helpers ──────────────────────────────────────────────────────────

  String get _pillLabel {
    switch (_activeBranch) {
      case ConversationMood.sadExamTrack:
        return 'Pip • Here for you 💙';
      case ConversationMood.happyProposalTrack:
        return 'Pip • Celebrating with you 🌟';
      default:
        return 'Pip • Your companion';
    }
  }

  bool get _showHintBanner =>
      _activeBranch == ConversationMood.neutral && widget.messages.length <= 1;

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Stack(
      children: [
        // ── Background — permanently static, never weather-modified ───
        Positioned.fill(
          child: Image.asset(
            'assets/images/home_background.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A7C4E), Color(0xFF1A3020)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),

        // ── Fixed gradient vignette ────────────────────────────────────
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.15),
                  Colors.transparent,
                  Colors.black.withOpacity(0.48),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // ── UI layout ──────────────────────────────────────────────────
        Column(
          children: [
            SafeArea(
              bottom: false,
              child: TopBar(currentSeeds: widget.currentSeeds),
            ),

            // Companion pill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(children: [_CompanionPill(label: _pillLabel)]),
            ),

            // Keyword-route hint banner — dissolves after first message
            if (_showHintBanner) const _RouteHintBanner(),

            // Message list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  bottomPad > 0 ? bottomPad + 80 : 100,
                ),
                itemCount: widget.messages.length,
                itemBuilder: (_, i) => ChatBubble(message: widget.messages[i]),
              ),
            ),

            // Input bar — always free-text; disabled only while Pip is typing
            _ChatInput(
              controller: _controller,
              isTyping: _isTyping,
              branchComplete: _branchComplete,
              activeBranch: _activeBranch,
              onSend: _onSend,
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Companion pill
// ─────────────────────────────────────────────────────────────────────────────

class _CompanionPill extends StatelessWidget {
  final String label;
  const _CompanionPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/penguin_avatar.png',
            width: 22,
            height: 22,
            errorBuilder: (_, __, ___) =>
                const Text('🐧', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Route hint banner — shown only before the first user message
// ─────────────────────────────────────────────────────────────────────────────

class _RouteHintBanner extends StatelessWidget {
  const _RouteHintBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.13),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
        ),
        child: Row(
          children: [
            const Text('💬', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Share what\'s on your mind',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Type freely — I\'ll understand how you\'re feeling and respond accordingly.',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11.5,
                      color: Colors.white.withOpacity(0.80),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat input bar
// ─────────────────────────────────────────────────────────────────────────────

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isTyping;
  final bool branchComplete;
  final ConversationMood activeBranch;
  final VoidCallback onSend;

  const _ChatInput({
    required this.controller,
    required this.isTyping,
    required this.branchComplete,
    required this.activeBranch,
    required this.onSend,
  });

  bool get _canSend => !isTyping && !branchComplete;

  String get _hint {
    if (branchComplete) return 'Conversation complete ✨';
    if (isTyping) return 'Pip is typing…';
    if (activeBranch == ConversationMood.neutral)
      return 'Share how you\'re feeling…';
    return 'Tell me more…';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 90),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left icon button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.image_outlined,
                color: AppColors.sageGreen, size: 22),
          ),
          const SizedBox(width: 8),

          // Text field — always free-text, hint changes by state
          Expanded(
            child: TextField(
              controller: controller,
              enabled: _canSend,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: AppColors.darkGreenText,
              ),
              decoration: InputDecoration(
                hintText: _hint,
                hintStyle: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: AppColors.mutedBrown.withOpacity(0.6),
                ),
                border: InputBorder.none,
                suffixIcon: Icon(Icons.mic_none_rounded,
                    color: AppColors.sageGreen, size: 22),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: _canSend ? onSend : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: _canSend
                    ? const LinearGradient(
                        colors: [Color(0xFF5A8C5E), Color(0xFF3A6B3F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: _canSend ? null : AppColors.divider,
                shape: BoxShape.circle,
                boxShadow: _canSend
                    ? [
                        BoxShadow(
                          color: AppColors.sageGreen.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.send_rounded,
                color: _canSend ? Colors.white : AppColors.mutedBrown,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
