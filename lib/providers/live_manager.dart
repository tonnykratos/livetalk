import 'package:flutter/foundation.dart';
import '../models/app_models.dart';

class LiveManager extends ChangeNotifier {
  // Ephemeral active streams list
  final List<LiveStreamItem> _activeStreams = [
    LiveStreamItem(
      id: '1',
      hostName: 'Jessica Taylor',
      hostAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      title: 'Late Night Chill & Q&A ✨ Ask me anything!',
      viewerCount: 1420,
      likeCount: 8930,
      isSpace: false,
      maxSeats: 1,
      seats: [
        SeatParticipant(
          userId: 'u1',
          name: 'Jessica Taylor',
          avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
          isHost: true,
          seatIndex: 0,
        )
      ],
      backgroundPlaceholder: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800',
    ),
    LiveStreamItem(
      id: '2',
      hostName: 'Tech Talk Live Space',
      hostAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      title: 'Future of AI & Mobile Development (10-Seat Panel)',
      viewerCount: 3850,
      likeCount: 24500,
      isSpace: true,
      maxSeats: 10,
      seats: [
        SeatParticipant(
          userId: 'u_host',
          name: 'Alex Rivera (Host)',
          avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
          isHost: true,
          seatIndex: 0,
        ),
        SeatParticipant(
          userId: 'u2',
          name: 'Sarah Chen',
          avatarUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
          seatIndex: 1,
        ),
        SeatParticipant(
          userId: 'u3',
          name: 'Marcus Brody',
          avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
          seatIndex: 2,
        ),
        SeatParticipant(
          userId: 'u4',
          name: 'Elena Rostova',
          avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
          seatIndex: 3,
        ),
      ],
      backgroundPlaceholder: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=800',
    ),
    LiveStreamItem(
      id: '3',
      hostName: 'DJ Neon Vibes',
      hostAvatar: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
      title: 'Synthwave Live Session 🎧 Drop your song requests!',
      viewerCount: 920,
      likeCount: 5400,
      isSpace: false,
      maxSeats: 1,
      seats: [
        SeatParticipant(
          userId: 'u_dj',
          name: 'DJ Neon',
          avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
          isHost: true,
          seatIndex: 0,
        )
      ],
      backgroundPlaceholder: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800',
    ),
  ];

  List<LiveStreamItem> get activeStreams => _activeStreams;

  // Active room chat & state for current session
  final List<ChatMessage> _currentChatMessages = [
    ChatMessage(id: 'c1', senderName: 'Liam', message: 'Hello everyone! 🔥', timestamp: DateTime.now().subtract(const Duration(seconds: 10))),
    ChatMessage(id: 'c2', senderName: 'Sophia', message: 'Amazing stream quality!', timestamp: DateTime.now().subtract(const Duration(seconds: 5))),
    ChatMessage(id: 'c3', senderName: 'David', message: 'Greetings from New York!', timestamp: DateTime.now()),
  ];

  List<ChatMessage> get currentChatMessages => _currentChatMessages;

  String? _focusedParticipantId;
  String? get focusedParticipantId => _focusedParticipantId;

  void setFocusedParticipant(String? participantId) {
    _focusedParticipantId = participantId;
    notifyListeners();
  }

  void addChatMessage(String senderName, String message) {
    _currentChatMessages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderName: senderName,
        message: message,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void createNewLiveOrSpace({
    required String title,
    required String hostName,
    required bool isSpace,
    required int maxSeats,
  }) {
    final newStream = LiveStreamItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      hostName: hostName,
      hostAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      title: title,
      viewerCount: 1,
      likeCount: 0,
      isSpace: isSpace,
      maxSeats: maxSeats,
      seats: [
        SeatParticipant(
          userId: 'host_me',
          name: '$hostName (Host)',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
          isHost: true,
          seatIndex: 0,
        )
      ],
      backgroundPlaceholder: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800',
    );
    _activeStreams.insert(0, newStream);
    notifyListeners();
  }

  // Ephemeral end live: clear session data completely
  void endLiveStream(String streamId) {
    _activeStreams.removeWhere((s) => s.id == streamId);
    _currentChatMessages.clear();
    _focusedParticipantId = null;
    notifyListeners();
  }

  void joinSeat(String streamId, SeatParticipant participant) {
    final index = _activeStreams.indexWhere((s) => s.id == streamId);
    if (index != -1) {
      final stream = _activeStreams[index];
      if (stream.seats.length < stream.maxSeats) {
        final updatedSeats = List<SeatParticipant>.from(stream.seats)..add(participant);
        _activeStreams[index] = LiveStreamItem(
          id: stream.id,
          hostName: stream.hostName,
          hostAvatar: stream.hostAvatar,
          title: stream.title,
          viewerCount: stream.viewerCount + 1,
          likeCount: stream.likeCount,
          isSpace: stream.isSpace,
          maxSeats: stream.maxSeats,
          seats: updatedSeats,
          backgroundPlaceholder: stream.backgroundPlaceholder,
        );
        notifyListeners();
      }
    }
  }

  void leaveSeat(String streamId, String userId) {
    final index = _activeStreams.indexWhere((s) => s.id == streamId);
    if (index != -1) {
      final stream = _activeStreams[index];
      final updatedSeats = stream.seats.where((seat) => seat.userId != userId).toList();
      _activeStreams[index] = LiveStreamItem(
        id: stream.id,
        hostName: stream.hostName,
        hostAvatar: stream.hostAvatar,
        title: stream.title,
        viewerCount: stream.viewerCount,
        likeCount: stream.likeCount,
        isSpace: stream.isSpace,
        maxSeats: stream.maxSeats,
        seats: updatedSeats,
        backgroundPlaceholder: stream.backgroundPlaceholder,
      );
      notifyListeners();
    }
  }

  // Ephemeral wipe on app close or session reset
  void clearAllData() {
    _activeStreams.clear();
    _currentChatMessages.clear();
    _focusedParticipantId = null;
    notifyListeners();
  }
}
