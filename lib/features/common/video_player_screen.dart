import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Full-screen tap-to-play video player. Accepts either a remote [url] or a
/// local file [filePath] (exactly one should be provided).
class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    super.key,
    this.url,
    this.filePath,
  }) : assert(url != null || filePath != null,
            'Provide either a url or a filePath');

  final String? url;
  final String? filePath;

  /// Opens the player as a full-screen route.
  static Future<void> open(
    BuildContext context, {
    String? url,
    String? filePath,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VideoPlayerScreen(url: url, filePath: filePath),
      ),
    );
  }

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.url != null
        ? VideoPlayerController.networkUrl(Uri.parse(widget.url!))
        : VideoPlayerController.file(File(widget.filePath!));
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _initialized = true);
      _controller
        ..setLooping(true)
        ..play();
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: _hasError
            ? const Text(
                'Unable to play this video',
                style: TextStyle(color: Colors.white),
              )
            : _initialized
                ? GestureDetector(
                    onTap: _togglePlayback,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(_controller),
                          VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                          ),
                          if (!_controller.value.isPlaying)
                            const Icon(
                              Icons.play_circle_fill,
                              color: Colors.white70,
                              size: 64,
                            ),
                        ],
                      ),
                    ),
                  )
                : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
