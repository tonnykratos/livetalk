class ChatMessage {
  final String id;
  final String senderName;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderName,
    required this.message,
    required this.timestamp,
  });
}

class SeatParticipant {
  final String userId;
  final String name;
  final String avatarUrl;
  final bool isHost;
  final bool isMuted;
  final bool isCameraOn;
  final int seatIndex;

  SeatParticipant({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    this.isHost = false,
    this.isMuted = false,
    this.isCameraOn = true,
    required this.seatIndex,
  });

  SeatParticipant copyWith({
    bool? isMuted,
    bool? isCameraOn,
  }) {
    return SeatParticipant(
      userId: userId,
      name: name,
      avatarUrl: avatarUrl,
      isHost: isHost,
      isMuted: isMuted ?? this.isMuted,
      isCameraOn: isCameraOn ?? this.isCameraOn,
      seatIndex: seatIndex,
    );
  }
}

class LiveStreamItem {
  final String id;
  final String hostName;
  final String hostAvatar;
  final String title;
  final int viewerCount;
  final int likeCount;
  final bool isSpace; // true if multi-seat space (up to 10 seats), false if tiktok solo/duet live
  final int maxSeats;
  final List<SeatParticipant> seats;
  final String backgroundPlaceholder;

  LiveStreamItem({
    required this.id,
    required this.hostName,
    required this.hostAvatar,
    required this.title,
    required this.viewerCount,
    required this.likeCount,
    this.isSpace = false,
    this.maxSeats = 1,
    required this.seats,
    required this.backgroundPlaceholder,
  });
}
