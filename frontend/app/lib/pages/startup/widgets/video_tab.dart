// Eduardo Kairalla - 24024241

// Content of the "Video" tab on the startup detail screen.

// --- IMPORTS ---
import 'package:chewie/chewie.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';
import 'package:video_player/video_player.dart';

// --- WIDGET ---

class VideoTab extends StatelessWidget {
  final String? videoUrl;

  const VideoTab({super.key, this.videoUrl});

  @override
  Widget build(BuildContext context) {
    if (videoUrl == null || videoUrl!.isEmpty) {
      return _emptyState(context);
    }
    return _VideoPlayer(storagePath: videoUrl!);
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.videocam_off_outlined,
              size: 38,
              color: AppColors.textMuted(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum vídeo disponível',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'O empreendedor ainda não adicionou\num vídeo de apresentação.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted(context),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPlayer extends StatefulWidget {
  final String storagePath;
  const _VideoPlayer({required this.storagePath});

  @override
  State<_VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<_VideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController?      _chewieController;
  bool                   _hasError = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final url = await FirebaseStorage.instance
          .ref(widget.storagePath)
          .getDownloadURL();

      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }

      _videoController  = controller;
      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay:        false,
        looping:         false,
        allowFullScreen: true,
        allowMuting:     true,
      );
      setState(() {});
    } catch (e, st) {
      debugPrint('VideoTab error: $e\n$st');
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.textMuted(context)),
            const SizedBox(height: 12),
            Text(
              'Não foi possível carregar o vídeo.',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ],
        ),
      );
    }

    if (_chewieController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: Chewie(controller: _chewieController!),
          ),
        ),
      ),
    );
  }
}
