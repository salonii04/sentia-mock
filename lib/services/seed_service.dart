import 'package:shared_preferences/shared_preferences.dart';

enum SeedMood { sad, happy, anxious, reflective }

class SeedRewardResult {
  final bool awarded;
  final int currentSeeds;
  final int grantedAmount;

  const SeedRewardResult({
    required this.awarded,
    required this.currentSeeds,
    required this.grantedAmount,
  });
}

/// Persistent seed manager for garden purchases and daily reflection rewards.
///
/// Integration note:
/// Use [grantDailyReward] when a reflection/chat flow completes.
/// It enforces one reward per calendar day using local date persistence.
class SeedService {
  static const int initialSeeds = 50;
  static const _currentSeedsKey = 'seed_current_count';
  static const _lastRewardDateKey = 'seed_last_reward_date';

  static const Map<SeedMood, int> _rewardMap = {
    SeedMood.sad: 5,
    SeedMood.happy: 3,
    SeedMood.anxious: 7,
    SeedMood.reflective: 10,
  };

  Future<int> getCurrentSeeds() async {
    final prefs = await SharedPreferences.getInstance();
    final storedSeeds = prefs.getInt(_currentSeedsKey);
    if (storedSeeds != null) {
      return storedSeeds;
    }
    await prefs.setInt(_currentSeedsKey, initialSeeds);
    return initialSeeds;
  }

  Future<int> setCurrentSeeds(int seeds) async {
    final normalizedSeeds = seeds < 0 ? 0 : seeds;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentSeedsKey, normalizedSeeds);
    return normalizedSeeds;
  }

  Future<int> spendSeeds(int amount) async {
    final current = await getCurrentSeeds();
    final updated = (current - amount).clamp(0, 1 << 31).toInt();
    return setCurrentSeeds(updated);
  }

  Future<SeedRewardResult> grantDailyReward({
    required SeedMood mood,
    DateTime? dateTime,
  }) async {
    final now = dateTime ?? DateTime.now();
    final todayKey = _formatDateKey(now);
    final prefs = await SharedPreferences.getInstance();
    final lastRewardDate = prefs.getString(_lastRewardDateKey);

    final currentSeeds = await getCurrentSeeds();
    if (lastRewardDate == todayKey) {
      return SeedRewardResult(
        awarded: false,
        currentSeeds: currentSeeds,
        grantedAmount: 0,
      );
    }

    final reward = _rewardMap[mood] ?? 0;
    final updatedSeeds = currentSeeds + reward;
    await prefs.setInt(_currentSeedsKey, updatedSeeds);
    await prefs.setString(_lastRewardDateKey, todayKey);

    return SeedRewardResult(
      awarded: true,
      currentSeeds: updatedSeeds,
      grantedAmount: reward,
    );
  }

  String _formatDateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
