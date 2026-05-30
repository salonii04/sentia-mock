/// Represents a flower that has been purchased and placed in the garden.
class PlantedFlower {
  final String id;
  final String flowerType;

  /// Normalized position [0.0, 1.0] relative to the garden area's width/height.
  final double normalizedX;
  final double normalizedY;

  PlantedFlower({
    required this.flowerType,
    required this.normalizedX,
    required this.normalizedY,
    String? id,
  }) : id = id ??
            '${flowerType}_${DateTime.now().millisecondsSinceEpoch}';
}
