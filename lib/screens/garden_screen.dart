import 'package:flutter/material.dart';
import '../models/planted_flower.dart';
import '../models/conversation_mood.dart';
import '../theme/app_theme.dart';
import '../widgets/top_bar.dart';
import '../widgets/garden_shop_sheet.dart';
import '../widgets/rain_overlay.dart';
import '../widgets/rainbow_overlay.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const List<Offset> _kFallbackSlots = [
  Offset(0.14, 0.62),
  Offset(0.78, 0.58),
  Offset(0.11, 0.72),
  Offset(0.82, 0.70),
  Offset(0.16, 0.52),
  Offset(0.75, 0.48),
  Offset(0.10, 0.80),
  Offset(0.85, 0.78),
];

const Map<String, String> _kFlowerEmoji = {
  'Rose': '🌹',
  'Jasmine': '🌸',
  'Sunflower': '🌻',
  'Tulip': '🌷',
};

/// Overcast desaturation + cool-tint colour matrix.
const List<double> _kOvercastMatrix = [
  0.28, 0.55, 0.17, 0, -30,
  0.28, 0.55, 0.17, 0, -22,
  0.28, 0.55, 0.17, 0, -12,
  0,    0,    0,    1,   0,
];

// ─────────────────────────────────────────────────────────────────────────────
// GardenScreen
// ─────────────────────────────────────────────────────────────────────────────

class GardenScreen extends StatefulWidget {
  final int currentSeeds;
  final List<String> boughtFlowers;
  final List<PlantedFlower> plantedFlowers;
  final String? selectedFlowerToPlant;

  /// Drives the reactive environment overlay.
  /// sadExamTrack → rain / mist
  /// happyProposalTrack → rainbow / sunshine
  /// neutral → plain background, no overlay
  final ConversationMood conversationMood;

  final Function(String flower, int cost) onBuy;
  final Function(PlantedFlower flower) onPlantFlower;
  final VoidCallback onCancelPlanting;

  const GardenScreen({
    super.key,
    required this.currentSeeds,
    required this.boughtFlowers,
    required this.plantedFlowers,
    required this.selectedFlowerToPlant,
    required this.conversationMood,
    required this.onBuy,
    required this.onPlantFlower,
    required this.onCancelPlanting,
  });

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen>
    with SingleTickerProviderStateMixin {
  bool _showBanner = false;
  late AnimationController _bannerController;
  late Animation<Offset> _bannerSlide;

  @override
  void initState() {
    super.initState();
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _bannerSlide = Tween<Offset>(
      begin: const Offset(0, -1.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _bannerController, curve: Curves.easeOutBack));
  }

  @override
  void didUpdateWidget(GardenScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedFlowerToPlant != null &&
        oldWidget.selectedFlowerToPlant == null) {
      _showBannerFor4s();
    }
    if (widget.selectedFlowerToPlant == null &&
        oldWidget.selectedFlowerToPlant != null) {
      _bannerController.reverse();
      setState(() => _showBanner = false);
    }
  }

  void _showBannerFor4s() {
    setState(() => _showBanner = true);
    _bannerController.forward(from: 0);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && widget.selectedFlowerToPlant != null) {
        _bannerController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  void _handleGardenTap(TapUpDetails details, BoxConstraints constraints) {
    if (widget.selectedFlowerToPlant == null) return;
    final nx =
        (details.localPosition.dx / constraints.maxWidth).clamp(0.05, 0.95);
    final ny =
        (details.localPosition.dy / constraints.maxHeight).clamp(0.25, 0.88);
    widget.onPlantFlower(PlantedFlower(
      flowerType: widget.selectedFlowerToPlant!,
      normalizedX: nx,
      normalizedY: ny,
    ));
  }

  void _plantAtNextSlot() {
    if (widget.selectedFlowerToPlant == null) return;
    final idx = widget.plantedFlowers.length % _kFallbackSlots.length;
    final slot = _kFallbackSlots[idx];
    widget.onPlantFlower(PlantedFlower(
      flowerType: widget.selectedFlowerToPlant!,
      normalizedX: slot.dx,
      normalizedY: slot.dy,
    ));
  }

  // ── Convenience getters ──────────────────────────────────────────────────

  bool get _isPlanting => widget.selectedFlowerToPlant != null;
  bool get _hasFlowers => widget.plantedFlowers.isNotEmpty;
  bool get _isRainy =>
      widget.conversationMood == ConversationMood.sadExamTrack;
  bool get _isSunny =>
      widget.conversationMood == ConversationMood.happyProposalTrack;

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Background layer — switches on mood change ─────────────
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 900),
            child: KeyedSubtree(
              key: ValueKey(widget.conversationMood),
              child: _buildBackground(),
            ),
          ),
        ),

        // ── Gradient vignette ──────────────────────────────────────
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(_isRainy ? 0.20 : 0.12),
                  Colors.transparent,
                  Colors.black.withOpacity(_isRainy ? 0.58 : _isSunny ? 0.28 : 0.38),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),

        // ── Rain overlay (sad / setback track) ─────────────────────
        if (_isRainy)
          const Positioned.fill(
            child: RepaintBoundary(child: RainOverlay()),
          ),

        // ── Rainbow overlay (happy / achievement track) ─────────────
        // Isolated in RepaintBoundary; plants render on top of it.
        if (_isSunny)
          const Positioned.fill(
            child: RepaintBoundary(child: RainbowOverlay()),
          ),

        // ── Planting mode tint ─────────────────────────────────────
        if (_isPlanting)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF4CAF50).withOpacity(0.07),
            ),
          ),

        // ── Interactive canvas with planted flowers ─────────────────
        Positioned.fill(
          child: LayoutBuilder(builder: (ctx, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapUp: _isPlanting
                  ? (d) => _handleGardenTap(d, constraints)
                  : null,
              child: Stack(
                clipBehavior: Clip.none,
                children: widget.plantedFlowers.map((f) {
                  const flowerSize = 56.0;
                  final left =
                      f.normalizedX * constraints.maxWidth - flowerSize / 2;
                  final top =
                      f.normalizedY * constraints.maxHeight - flowerSize;
                  return Positioned(
                    left: left.clamp(0.0, constraints.maxWidth - flowerSize),
                    top: top.clamp(0.0, constraints.maxHeight - flowerSize),
                    // Flowers sit on top of whichever overlay is active.
                    child: _AnimatedPlantedFlower(flower: f),
                  );
                }).toList(),
              ),
            );
          }),
        ),

        // ── Top bar + title pill ───────────────────────────────────
        Column(
          children: [
            SafeArea(
              bottom: false,
              child: TopBar(currentSeeds: widget.currentSeeds),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Row(
                children: [
                  _GardenTitlePill(
                    isPlanting: _isPlanting,
                    mood: widget.conversationMood,
                    flowerCount: widget.plantedFlowers.length,
                    selectedFlower: widget.selectedFlowerToPlant,
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Bottom action panel
            if (_isPlanting)
              _PlantingModePanel(
                flowerType: widget.selectedFlowerToPlant!,
                onFallbackPlant: _plantAtNextSlot,
                onCancel: widget.onCancelPlanting,
              )
            else
              _BuyFlowersPanel(
                hasFlowers: _hasFlowers,
                plantedFlowers: widget.plantedFlowers,
                currentSeeds: widget.currentSeeds,
                boughtFlowers: widget.boughtFlowers,
                onBuy: widget.onBuy,
              ),
            const SizedBox(height: 108),
          ],
        ),

        // ── Instruction banner (spring slide-in) ───────────────────
        if (_showBanner)
          _PlantingInstructionBanner(
            slide: _bannerSlide,
            flowerType: widget.selectedFlowerToPlant ?? '',
          ),
      ],
    );
  }

  Widget _buildBackground() {
    if (_isRainy) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(_kOvercastMatrix),
        child: Image.asset(
          'assets/images/home_background.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _FallbackBackground(mood: widget.conversationMood),
        ),
      );
    }
    // sunny & neutral: use plain background; rainbow overlay handles the rest
    return Image.asset(
      'assets/images/home_background.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _FallbackBackground(mood: widget.conversationMood),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated planted flower — pure emoji text, no container, no clip.
// Flowers render cleanly over both rain and rainbow overlays.
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedPlantedFlower extends StatefulWidget {
  final PlantedFlower flower;
  const _AnimatedPlantedFlower({required this.flower});

  @override
  State<_AnimatedPlantedFlower> createState() => _AnimatedPlantedFlowerState();
}

class _AnimatedPlantedFlowerState extends State<_AnimatedPlantedFlower>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _kFlowerEmoji[widget.flower.flowerType] ?? '🌺';
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: 52,
            // Drop shadows give depth without any backing shape,
            // so the flower blends organically into the terrain.
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.30),
                blurRadius: 10,
                offset: const Offset(2, 7),
              ),
              Shadow(
                color: Colors.green.shade900.withOpacity(0.18),
                blurRadius: 18,
                offset: Offset.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Garden title pill
// ─────────────────────────────────────────────────────────────────────────────

class _GardenTitlePill extends StatelessWidget {
  final bool isPlanting;
  final ConversationMood mood;
  final int flowerCount;
  final String? selectedFlower;

  const _GardenTitlePill({
    required this.isPlanting,
    required this.mood,
    required this.flowerCount,
    required this.selectedFlower,
  });

  @override
  Widget build(BuildContext context) {
    final String emoji;
    final String label;
    final Color bgColor;

    if (isPlanting) {
      emoji = '🌱';
      label = 'Planting ${selectedFlower ?? ''}…';
      bgColor = AppColors.sageGreen.withOpacity(0.55);
    } else if (mood == ConversationMood.sadExamTrack) {
      emoji = '🌧️';
      label = flowerCount > 0 ? 'Garden · $flowerCount planted · Rainy' : 'Garden · Rainy Day';
      bgColor = Colors.blueGrey.withOpacity(0.40);
    } else if (mood == ConversationMood.happyProposalTrack) {
      emoji = '🌈';
      label = flowerCount > 0 ? 'Garden · $flowerCount planted · Blooming!' : 'Garden · Blooming! ✨';
      bgColor = const Color(0xFF2E7D32).withOpacity(0.55);
    } else {
      emoji = flowerCount > 0 ? '🌺' : '🌿';
      label = flowerCount > 0
          ? 'My Garden · $flowerCount ${flowerCount == 1 ? "flower" : "flowers"}'
          : 'My Garden';
      bgColor = Colors.white.withOpacity(0.22);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: mood != ConversationMood.neutral
            ? Border.all(color: Colors.white.withOpacity(0.40), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Planting-mode bottom panel
// ─────────────────────────────────────────────────────────────────────────────

class _PlantingModePanel extends StatelessWidget {
  final String flowerType;
  final VoidCallback onFallbackPlant;
  final VoidCallback onCancel;

  const _PlantingModePanel({
    required this.flowerType,
    required this.onFallbackPlant,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.93),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepForest.withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                  color: AppColors.sageGreen.withOpacity(0.45), width: 1.5),
            ),
            child: Row(
              children: [
                Text(_kFlowerEmoji[flowerType] ?? '🌺',
                    style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tap to plant your $flowerType!',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreenText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Touch any spot on the grass',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            color: AppColors.earthBrown),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onFallbackPlant,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.82),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.sageGreen.withOpacity(0.4)),
                    ),
                    child: Center(
                      child: Text(
                        'Auto-place',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.sageGreen,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.82),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.redAccent.withOpacity(0.35)),
                    ),
                    child: const Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
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
// Buy-flowers bottom panel
// ─────────────────────────────────────────────────────────────────────────────

class _BuyFlowersPanel extends StatelessWidget {
  final bool hasFlowers;
  final List<PlantedFlower> plantedFlowers;
  final int currentSeeds;
  final List<String> boughtFlowers;
  final Function(String, int) onBuy;

  const _BuyFlowersPanel({
    required this.hasFlowers,
    required this.plantedFlowers,
    required this.currentSeeds,
    required this.boughtFlowers,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasFlowers) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _buildChips()),
            ),
            const SizedBox(height: 14),
          ],
          GestureDetector(
            onTap: () => GardenShopSheet.show(
              context,
              currentSeeds: currentSeeds,
              boughtFlowers: boughtFlowers,
              onBuy: onBuy,
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5A8C5E), Color(0xFF3A6B3F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepForest.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌸', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Text(
                    hasFlowers ? 'Buy More Flowers  ›' : 'Buy Flowers  ›',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChips() {
    final counts = <String, int>{};
    for (final f in plantedFlowers) {
      counts[f.flowerType] = (counts[f.flowerType] ?? 0) + 1;
    }
    return counts.entries.map((e) {
      return Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppColors.lightSage.withOpacity(0.5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_kFlowerEmoji[e.key] ?? '🌺',
                style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 5),
            Text(
              '${e.key} ×${e.value}',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGreenText,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Planting instruction banner (spring slide-in from top)
// ─────────────────────────────────────────────────────────────────────────────

class _PlantingInstructionBanner extends StatelessWidget {
  final Animation<Offset> slide;
  final String flowerType;

  const _PlantingInstructionBanner({
    required this.slide,
    required this.flowerType,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top + 72;
    return Positioned(
      top: topPad,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: slide,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepForest.withOpacity(0.22),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
                color: AppColors.sageGreen.withOpacity(0.45), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.sageGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(_kFlowerEmoji[flowerType] ?? '🌺',
                      style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Planting mode active!',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepForest,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap anywhere on the grass to plant your flower!',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: AppColors.earthBrown),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fallback gradient background (when image asset fails to load)
// ─────────────────────────────────────────────────────────────────────────────

class _FallbackBackground extends StatelessWidget {
  final ConversationMood mood;
  const _FallbackBackground({required this.mood});

  @override
  Widget build(BuildContext context) {
    final colors = mood == ConversationMood.sadExamTrack
        ? [const Color(0xFF2B3A4A), const Color(0xFF1A2535)]
        : mood == ConversationMood.happyProposalTrack
            ? [const Color(0xFF5A9E5E), const Color(0xFF2E7D32)]
            : [const Color(0xFF5A8F5D), const Color(0xFF3A6B3F)];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
