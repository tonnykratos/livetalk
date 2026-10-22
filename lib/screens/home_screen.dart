import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/live_manager.dart';
import 'create_stream_screen.dart';
import 'live_streaming_screen.dart';
import 'space_room_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final liveManager = Provider.of<LiveManager>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text('LiveTalk 🔴 (TikTok Live & Spaces)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white54),
            tooltip: 'Ephemeral Reset (Wipe All Data)',
            onPressed: () {
              liveManager.clearAllData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All ephemeral sessions & data wiped successfully.')),
              );
            },
          ),
        ],
      ),
      body: liveManager.activeStreams.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam_off, size: 64, color: Colors.white38),
                  const SizedBox(height: 16),
                  const Text('No live streams or spaces right now.', style: TextStyle(color: Colors.white60, fontSize: 16)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateStreamScreen()),
                      );
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Start First Live / Space', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: liveManager.activeStreams.length,
              itemBuilder: (context, index) {
                final stream = liveManager.activeStreams[index];
                return Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      if (stream.isSpace) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SpaceRoomScreen(streamItem: stream)),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LiveStreamingScreen(streamItem: stream)),
                        );
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail Banner
                        Stack(
                          children: [
                            Image.network(
                              stream.backgroundPlaceholder,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              height: 180,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: stream.isSpace ? Colors.deepPurple : Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  stream.isSpace ? 'SPACE (${stream.seats.length}/${stream.maxSeats} SEATS)' : 'TIKTOK LIVE',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.remove_red_eye, color: Colors.white, size: 12),
                                    const SizedBox(width: 4),
                                    Text('${stream.viewerCount}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              left: 12,
                              right: 12,
                              child: Text(
                                stream.title,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        // Host info footer
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(stream.hostAvatar),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  stream.hostName,
                                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 14),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateStreamScreen()),
          );
        },
        icon: const Icon(Icons.live_tv, color: Colors.white),
        label: const Text('Go Live / Space', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
