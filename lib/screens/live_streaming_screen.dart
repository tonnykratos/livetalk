import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../providers/live_manager.dart';

class LiveStreamingScreen extends StatefulWidget {
  final LiveStreamItem streamItem;

  const LiveStreamingScreen({super.key, required this.streamItem});

  @override
  State<LiveStreamingScreen> createState() => _LiveStreamingScreenState();
}

class _LiveStreamingScreenState extends State<LiveStreamingScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String _statusMessage = 'Requesting camera & microphone permissions...';
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLikedAnimationActive = false;

  @override
  void initState() {
    super.initState();
    _initCameraAndPermissions();
  }

  Future<void> _initCameraAndPermissions() async {
    try {
      setState(() {
        _statusMessage = 'Requesting camera & microphone access...';
      });

      // Request permissions explicitly
      var cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
      }

      var micStatus = await Permission.microphone.status;
      if (!micStatus.isGranted) {
        micStatus = await Permission.microphone.request();
      }

      if (cameraStatus.isGranted && micStatus.isGranted) {
        setState(() {
          _statusMessage = 'Initializing camera hardware...';
        });

        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          final frontCamera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          );
          _cameraController = CameraController(
            frontCamera,
            ResolutionPreset.medium,
            enableAudio: true,
          );
          await _cameraController!.initialize();
          if (mounted) {
            setState(() {
              _isCameraInitialized = true;
              _statusMessage = '';
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _statusMessage = 'No camera device found (Emulator). Using simulation feed.';
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _statusMessage = 'Camera or Microphone permission denied. Please enable in settings.';
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'Camera init error: $e. Using simulation feed.';
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendComment(LiveManager manager) {
    if (_msgController.text.trim().isEmpty) return;
    manager.addChatMessage('You', _msgController.text.trim());
    _msgController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _sendLike() {
    setState(() {
      _isLikedAnimationActive = true;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isLikedAnimationActive = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final liveManager = Provider.of<LiveManager>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Real Camera Preview if initialized, otherwise fallback background image with status banner
          _isCameraInitialized && _cameraController != null
              ? CameraPreview(_cameraController!)
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.streamItem.backgroundPlaceholder,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.videocam_off, color: Colors.amberAccent, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              _statusMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
                              onPressed: _initCameraAndPermissions,
                              icon: const Icon(Icons.refresh, color: Colors.white),
                              label: const Text('Retry Camera Permission', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

          // Dark gradient overlay for readability of text and UI elements
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Top Bar (Host info, Viewer count, Close button)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(widget.streamItem.hostAvatar),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.streamItem.hostName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '${widget.streamItem.viewerCount + 1} watching',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('LIVE 🔴', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    // Ephemeral end: data is wiped immediately
                    liveManager.endLiveStream(widget.streamItem.id);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // Center Title / Tap to Like Gesture area
          GestureDetector(
            onTap: _sendLike,
            child: Container(color: Colors.transparent),
          ),

          // Bottom Chat & Interaction Bar
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live Stream Title Banner
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.streamItem.title,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 10),

                // Chat Messages List (Ephemeral)
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: liveManager.currentChatMessages.length,
                    itemBuilder: (context, index) {
                      final msg = liveManager.currentChatMessages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${msg.senderName}: ',
                                style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              TextSpan(
                                text: msg.message,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Text Input & Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msgController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Say something nice...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white24,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _sendComment(liveManager),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FloatingActionButton.small(
                      heroTag: 'send_btn',
                      backgroundColor: Colors.deepPurpleAccent,
                      onPressed: () => _sendComment(liveManager),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton.small(
                      heroTag: 'like_btn',
                      backgroundColor: Colors.pink,
                      onPressed: _sendLike,
                      child: const Icon(Icons.favorite, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Floating Like Animation Effect
          if (_isLikedAnimationActive)
            Positioned(
              right: 40,
              bottom: 120,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, -value * 100),
                    child: Opacity(
                      opacity: 1.0 - value,
                      child: const Icon(Icons.favorite, color: Colors.pinkAccent, size: 48),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
