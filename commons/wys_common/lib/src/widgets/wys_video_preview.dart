import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class WysVideoPreview extends StatefulWidget {
  const WysVideoPreview({super.key, required this.videoUrl});

  final String videoUrl;

  static void show(BuildContext context, String videoUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WysVideoPreview(videoUrl: videoUrl),
      ),
    );
  }

  @override
  State<WysVideoPreview> createState() => _WysVideoPreviewState();
}

class _WysVideoPreviewState extends State<WysVideoPreview> {
  VideoPlayerController? _videoPlayerController;
  bool _isPlaying = false;
  bool _isFullScreen = false;
  bool _showControls = true;
  double _playbackSpeed = 1.0;
  String _audioMode = '自动';
  Timer? _hideTimer;
  Timer? _fadeTimer;
  bool _isFadingOut = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        viewType: (Platform.isAndroid || Platform.isOhos)
            ? VideoViewType.platformView
            : VideoViewType.textureView,
      );
      await _videoPlayerController!.initialize();
      _videoPlayerController!.addListener(_onVideoChanged);
      if (mounted) {
        setState(() => _initialized = true);
      }
      _play();
    } catch (e) {
      debugPrint('Video initialization error: $e');
    }
  }

  void _onVideoChanged() {
    if (mounted) {
      setState(() {
        _isPlaying = _videoPlayerController!.value.isPlaying;
      });
    }
  }

  void _play() {
    _videoPlayerController?.play();
    if (mounted) {
      setState(() => _isPlaying = true);
    }
    _startHideTimer();
  }

  void _pause() {
    _videoPlayerController?.pause();
    if (mounted) {
      setState(() => _isPlaying = false);
    }
    _startHideTimer();
  }

  void _togglePlay() {
    if (_isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  void _seekTo(double value) {
    _videoPlayerController?.seekTo(Duration(milliseconds: value.toInt()));
    _startHideTimer();
  }

  void _setPlaybackSpeed(double speed) {
    _videoPlayerController?.setPlaybackSpeed(speed);
    if (mounted) {
      setState(() => _playbackSpeed = speed);
    }
    _startHideTimer();
  }

  void _toggleFullScreen() {
    if (mounted) {
      setState(() {
        _isFullScreen = !_isFullScreen;
      });
    }
    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _startHideTimer();
  }

  void _startHideTimer() {
    _cancelHideTimer();
    _cancelFadeTimer();
    if (mounted) {
      setState(() {
        _showControls = true;
        _isFadingOut = false;
      });
    }
    _hideTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _isFadingOut = true;
        });
      }
      _fadeTimer = Timer(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _showControls = false;
            _isFadingOut = false;
          });
        }
      });
    });
  }

  void _cancelHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  void _cancelFadeTimer() {
    _fadeTimer?.cancel();
    _fadeTimer = null;
  }

  void _toggleControls() {
    _cancelHideTimer();
    _cancelFadeTimer();
    if (mounted) {
      setState(() {
        _showControls = !_showControls;
        _isFadingOut = false;
      });
    }
    if (_showControls) {
      _startHideTimer();
    }
  }

  void _onBackPressed() {
    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _cancelHideTimer();
    _cancelFadeTimer();
    _videoPlayerController?.removeListener(_onVideoChanged);
    _videoPlayerController?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildVideoPlayer(),
          if (_initialized) _buildControls(),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    return Center(
      child: AspectRatio(
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        child: VideoPlayer(_videoPlayerController!),
      ),
    );
  }

  Widget _buildControls() {
    return Stack(
      children: [
        GestureDetector(
          onTap: _toggleControls,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
          ),
        ),
        AnimatedOpacity(
          opacity: (_showControls || _isFadingOut) ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: _buildControlContent(),
        ),
      ],
    );
  }

  Widget _buildControlContent() {
    return Stack(
      children: [
        _buildPlayPauseButton(),
        _buildBackButton(),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 20, 8, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
            child: Column(
              children: [
                _buildProgressBar(),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildBottomBar(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 10,
      child: GestureDetector(
        onTap: _onBackPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: const Icon(Icons.arrow_back, size: 24, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return Center(
      child: GestureDetector(
        onTap: _togglePlay,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            size: 36,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final position = _videoPlayerController!.value.position;
    final duration = _videoPlayerController!.value.duration;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
        overlayColor: Colors.transparent,
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.white30,
        thumbColor: Colors.white,
      ),
      child: Slider(
        value: position.inMilliseconds.toDouble(),
        max: duration.inMilliseconds.toDouble(),
        onChanged: _seekTo,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Row(
      children: [
        _buildTimeText(),
        const Spacer(),
        _buildSettingsButton(),
        const SizedBox(width: 16),
        _buildFullScreenButton(),
      ],
    );
  }

  Widget _buildTimeText() {
    final position = _videoPlayerController!.value.position;
    final duration = _videoPlayerController!.value.duration;
    return Text(
      '${_formatDuration(position)} / ${_formatDuration(duration)}',
      style: const TextStyle(
        fontSize: 12,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSettingsButton() {
    return GestureDetector(
      onTap: _showSettingsMenu,
      behavior: HitTestBehavior.opaque,
      child: const Icon(
        Icons.settings,
        size: 24,
        color: Colors.white,
      ),
    );
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 160,
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(178, 0, 0, 0),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSettingsItem(
                        title: '速度',
                        value: _speedLabel,
                        icon: Icons.speed,
                        onTap: () => _showSpeedSubMenu(),
                      ),
                      const Divider(color: Colors.white24),
                      _buildSettingsItem(
                        title: '音频',
                        value: _audioMode,
                        icon: Icons.volume_up,
                        onTap: () => _showAudioSubMenu(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.white70),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  void _showSpeedSubMenu() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 160,
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(178, 0, 0, 0),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSpeedItem(0.25, '0.25倍'),
                      _buildSpeedItem(0.5, '0.5倍'),
                      _buildSpeedItem(0.75, '0.75倍'),
                      _buildSpeedItem(1.0, '正常'),
                      _buildSpeedItem(1.25, '1.25倍'),
                      _buildSpeedItem(1.5, '1.5倍'),
                      _buildSpeedItem(2.0, '2倍'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpeedItem(double speed, String label) {
    final isSelected = _playbackSpeed == speed;
    return GestureDetector(
      onTap: () {
        _setPlaybackSpeed(speed);
        Navigator.pop(context);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : const SizedBox(),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAudioSubMenu() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 160,
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(178, 0, 0, 0),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAudioItem('自动'),
                      _buildAudioItem('立体声'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAudioItem(String mode) {
    final isSelected = _audioMode == mode;
    return GestureDetector(
      onTap: () {
        if (mounted) {
          setState(() => _audioMode = mode);
        }
        Navigator.pop(context);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              child: isSelected
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : const SizedBox(),
            ),
            Row(
              children: [
                Text(
                  mode,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (mode == '立体声')
                  const Text(
                    ' 0.13 Mbps',
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _speedLabel {
    if (_playbackSpeed == 0.25) return '0.25倍';
    if (_playbackSpeed == 0.5) return '0.5倍';
    if (_playbackSpeed == 0.75) return '0.75倍';
    if (_playbackSpeed == 1.0) return '正常';
    if (_playbackSpeed == 1.25) return '1.25倍';
    if (_playbackSpeed == 1.5) return '1.5倍';
    if (_playbackSpeed == 2.0) return '2倍';
    return '${_playbackSpeed}x';
  }

  Widget _buildFullScreenButton() {
    return GestureDetector(
      onTap: _toggleFullScreen,
      behavior: HitTestBehavior.opaque,
      child: Icon(
        _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
        size: 24,
        color: Colors.white,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inHours}:$minutes:$seconds'.replaceFirst('0:', '');
  }
}