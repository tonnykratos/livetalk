import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/live_manager.dart';
import 'live_streaming_screen.dart';
import 'space_room_screen.dart';

class CreateStreamScreen extends StatefulWidget {
  const CreateStreamScreen({super.key});

  @override
  State<CreateStreamScreen> createState() => _CreateStreamScreenState();
}

class _CreateStreamScreenState extends State<CreateStreamScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _hostNameController = TextEditingController(text: 'Creator');
  bool _isSpace = false;
  int _maxSeats = 10;

  @override
  Widget build(BuildContext context) {
    final liveManager = Provider.of<LiveManager>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text('Go Live or Create Space', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text(
              'Broadcast Configuration',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Google Recommended Settings: Ephemeral session with zero data retention upon exit.',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Mode Selector
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: false,
                  label: Text('TikTok Live (Solo)'),
                  icon: Icon(Icons.videocam),
                ),
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Multi-Seat Space'),
                  icon: Icon(Icons.group),
                ),
              ],
              selected: {_isSpace},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _isSpace = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),

            // Host Name
            TextField(
              controller: _hostNameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Your Host Name',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF1F1F1F),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Stream Title
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Room Title (e.g., Chill Vibes & Q&A)',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF1F1F1F),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Max Seats Slider (if Space mode is active, up to 10 seats)
            if (_isSpace) ...[
              const Text('Max Seat Capacity (Up to 10)', style: TextStyle(color: Colors.white70)),
              Slider(
                value: _maxSeats.toDouble(),
                min: 2,
                max: 10,
                divisions: 8,
                label: '$_maxSeats Seats',
                activeColor: Colors.deepPurpleAccent,
                onChanged: (val) {
                  setState(() {
                    _maxSeats = val.toInt();
                  });
                },
              ),
              Center(
                child: Text('$_maxSeats Seats Configured for Big Screen Focus', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ],

            const SizedBox(height: 20),

            // Start Broadcasting Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final title = _titleController.text.trim().isEmpty ? 'Live Stream Session' : _titleController.text.trim();
                final host = _hostNameController.text.trim().isEmpty ? 'Creator' : _hostNameController.text.trim();

                liveManager.createNewLiveOrSpace(
                  title: title,
                  hostName: host,
                  isSpace: _isSpace,
                  maxSeats: _isSpace ? _maxSeats : 1,
                );

                final createdItem = liveManager.activeStreams.first;

                Navigator.pop(context);

                // Navigate to Live or Space screen
                if (_isSpace) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SpaceRoomScreen(streamItem: createdItem)),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LiveStreamingScreen(streamItem: createdItem)),
                  );
                }
              },
              child: const Text('Start Broadcasting Now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
