import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TopBar extends StatelessWidget {
  final int currentSeeds;

  const TopBar({super.key, required this.currentSeeds});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SeedPill(seeds: currentSeeds),
          _StreakPill(),
        ],
      ),
    );
  }
}

class _SeedPill extends StatelessWidget {
  final int seeds;
  const _SeedPill({required this.seeds});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.sageGreen.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.lightSage.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 5),
          Text(
            '$seeds Seeds',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreenText,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 4),
          Text(
            '3',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreenText,
            ),
          ),
          const SizedBox(width: 2),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.earthBrown),
        ],
      ),
    );
  }
}
