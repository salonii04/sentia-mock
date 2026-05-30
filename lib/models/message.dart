class Message {
  final String text;
  final bool isUser;
  final bool isTyping;

  Message({
    required this.text,
    required this.isUser,
    this.isTyping = false,
  });

  Message copyWith({String? text, bool? isUser, bool? isTyping}) {
    return Message(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}
