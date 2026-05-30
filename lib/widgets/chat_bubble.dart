import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isTyping) {
      return _TypingBubble();
    }
    return message.isUser ? _UserBubble(message: message) : _AIBubble(message: message);
  }
}

class _AIBubble extends StatelessWidget {
  final Message message;
  const _AIBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 8, bottom: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.warmCream,
              border: Border.all(color: AppColors.lightSage, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sageGreen.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/penguin_avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Text('🐧', style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sageGreen.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: AppColors.lightSage.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGreenText,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final Message message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5A8C5E), Color(0xFF3A6B3F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepForest.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 80),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 8, bottom: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.warmCream,
              border: Border.all(color: AppColors.lightSage, width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/penguin_avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Text('🐧', style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(
                color: AppColors.lightSage.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _Dot(controller: _controller, delay: i * 0.33)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  const _Dot({required this.controller, required this.delay});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final progress = (controller.value - delay).clamp(0.0, 1.0);
        final t = (progress < 0.5) ? progress * 2 : (1 - progress) * 2;
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.sageGreen.withOpacity(0.4 + 0.6 * t),
          ),
          transform: Matrix4.translationValues(0, -4 * t, 0),
        );
      },
    );
  }
}
