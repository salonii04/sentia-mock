import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GardenShopSheet extends StatelessWidget {
  final int currentSeeds;
  final List<String> boughtFlowers;
  final Function(String flower, int cost) onBuy;

  const GardenShopSheet({
    super.key,
    required this.currentSeeds,
    required this.boughtFlowers,
    required this.onBuy,
  });

  static void show(
    BuildContext context, {
    required int currentSeeds,
    required List<String> boughtFlowers,
    required Function(String flower, int cost) onBuy,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GardenShopSheet(
        currentSeeds: currentSeeds,
        boughtFlowers: boughtFlowers,
        onBuy: onBuy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flowers = [
      _FlowerItem('Rose', '🌹', 'Beautiful red roses', 30, AppColors.roseBlush),
      _FlowerItem('Jasmine', '🌸', 'Fragrant white flowers', 20, const Color(0xFFE8D5F0)),
      _FlowerItem('Sunflower', '🌻', 'Tall sunny flowers', 25, AppColors.goldenPetal),
      _FlowerItem('Tulip', '🌷', 'Elegant spring bloom', 15, const Color(0xFFFFB3BA)),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.softCream,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepForest.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightSage,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    const Text('🌸', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Text(
                      'Garden Shop',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGreenText,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.sageGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Text('🌱', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            '$currentSeeds',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.deepForest,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Horizontal preview shelf
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: flowers.length,
                  itemBuilder: (_, i) => _FlowerPreviewCard(flower: flowers[i]),
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: AppColors.divider, thickness: 1, indent: 24, endIndent: 24),
              const SizedBox(height: 4),
              // List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: flowers.length,
                  itemBuilder: (_, i) {
                    final flower = flowers[i];
                    return _FlowerListItem(
                      flower: flower,
                      canAfford: currentSeeds >= flower.cost,
                      onBuy: () => onBuy(flower.name, flower.cost),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FlowerItem {
  final String name;
  final String emoji;
  final String description;
  final int cost;
  final Color color;

  const _FlowerItem(this.name, this.emoji, this.description, this.cost, this.color);
}

class _FlowerPreviewCard extends StatelessWidget {
  final _FlowerItem flower;
  const _FlowerPreviewCard({required this.flower});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: flower.color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: flower.color, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(flower.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 4),
          Text(
            flower.name,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGreenText,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowerListItem extends StatelessWidget {
  final _FlowerItem flower;
  final bool canAfford;
  final VoidCallback onBuy;

  const _FlowerListItem({
    required this.flower,
    required this.canAfford,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.sageGreen.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: flower.color.withOpacity(0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(flower.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flower.name,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreenText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  flower.description,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: AppColors.earthBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('🌱', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 3),
                    Text(
                      '${flower.cost} Seeds',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sageGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: canAfford ? onBuy : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: canAfford
                    ? const LinearGradient(
                        colors: [Color(0xFF5A8C5E), Color(0xFF3A6B3F)],
                      )
                    : null,
                color: canAfford ? null : AppColors.divider,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Buy',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: canAfford ? Colors.white : AppColors.earthBrown,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
