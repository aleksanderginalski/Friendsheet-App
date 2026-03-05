// lib/presentation/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

// Interface for video player functionality — enables testing without platform channels
abstract class VideoPlayerControllerInterface {
  bool get isInitialized;
  double get aspectRatio;
  Duration get position;
  Duration get duration;
  Future<void> initialize();
  Future<void> play();
  void addListener(VoidCallback listener);
  void removeListener(VoidCallback listener);
  Future<void> dispose();
  // Returns the widget used to render the video frame
  Widget buildView();
}

// Production adapter wrapping the real VideoPlayerController
class VideoPlayerControllerAdapter implements VideoPlayerControllerInterface {
  final VideoPlayerController _controller;

  VideoPlayerControllerAdapter(this._controller);

  @override
  bool get isInitialized => _controller.value.isInitialized;

  @override
  double get aspectRatio => _controller.value.aspectRatio;

  @override
  Duration get position => _controller.value.position;

  @override
  Duration get duration => _controller.value.duration;

  @override
  Future<void> initialize() => _controller.initialize();

  @override
  Future<void> play() => _controller.play();

  @override
  void addListener(VoidCallback listener) => _controller.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _controller.removeListener(listener);

  @override
  Future<void> dispose() => _controller.dispose();

  @override
  Widget buildView() => VideoPlayer(_controller);
}

// Displays animated splash — MP4 + app name, navigates to nextScreen on completion
class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  // Injected in tests; null means create the real asset controller in production
  final VideoPlayerControllerInterface? controller;

  const SplashScreen({
    super.key,
    required this.nextScreen,
    this.controller,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerControllerInterface _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        VideoPlayerControllerAdapter(
          VideoPlayerController.asset('assets/animations/splash.mp4'),
        );
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _controller.play();
      _controller.addListener(_onVideoProgress);
    });
  }

  // Called on each video controller update — triggers navigation when done
  void _onVideoProgress() {
    if (_navigated) return;
    final position = _controller.position;
    final duration = _controller.duration;
    if (duration > Duration.zero && position >= duration) {
      _navigated = true;
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => widget.nextScreen),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_controller.isInitialized)
            AspectRatio(
              aspectRatio: _controller.aspectRatio,
              child: _controller.buildView(),
            ),
          const SizedBox(height: 16),
          Text(
            'Friendsheet',
            style: GoogleFonts.pacifico(
              fontSize: 32,
              color: const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }
}
