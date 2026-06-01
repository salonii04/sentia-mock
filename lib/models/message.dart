class RewardMessageData {
  final bool awarded;
  final int grantedSeeds;
  final int previousSeeds;
  final int updatedSeeds;
  final String message;

  const RewardMessageData.awarded({
    required this.grantedSeeds,
    required this.previousSeeds,
    required this.updatedSeeds,
  })  : awarded = true,
        message = 'Reflection Reward Earned';

  const RewardMessageData.locked()
      : awarded = false,
        grantedSeeds = 0,
        previousSeeds = 0,
        updatedSeeds = 0,
        message = "You've already earned today's seeds.";
}

class Message {
  final String text;
  final bool isUser;
  final bool isTyping;
  final RewardMessageData? rewardData;

  Message({
    required this.text,
    required this.isUser,
    this.isTyping = false,
    this.rewardData,
  });

  bool get isReward => rewardData != null;

  Message copyWith({
    String? text,
    bool? isUser,
    bool? isTyping,
    RewardMessageData? rewardData,
  }) {
    return Message(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      isTyping: isTyping ?? this.isTyping,
      rewardData: rewardData ?? this.rewardData,
    );
  }
}
