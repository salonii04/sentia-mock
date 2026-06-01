import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isReward) {
      return _RewardBubble(message: message);
    }
    if (message.isTyping) {
      return _TypingBubble();
    }
    return message.isUser
        ? _UserBubble(message: message)
        : _AIBubble(message: message);
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

class _RewardBubble extends StatefulWidget {
  final Message message;

  const _RewardBubble({required this.message});

  @override
  State<_RewardBubble> createState() => _RewardBubbleState();
}

class _RewardBubbleState extends State<_RewardBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rewardData = widget.message.rewardData;
    if (rewardData == null) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16, right: 48),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                margin: const EdgeInsets.only(right: 8, top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE5F5E6),
                  border: Border.all(
                    color: const Color(0xFF5A8C5E).withOpacity(0.45),
                    width: 1.2,
                  ),
                ),
                child: const Center(
                  child: Text('🌱', style: TextStyle(fontSize: 16)),
                ),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF70A774), Color(0xFF4C8550)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D4A2F).withOpacity(0.22),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: rewardData.awarded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🌱 Reflection Reward Earned',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '+${rewardData.grantedSeeds} Seeds',
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${rewardData.previousSeeds} → ${rewardData.updatedSeeds}',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          rewardData.message,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
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
              children: List.generate(
                  3, (i) => _Dot(controller: _controller, delay: i * 0.33)),
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
