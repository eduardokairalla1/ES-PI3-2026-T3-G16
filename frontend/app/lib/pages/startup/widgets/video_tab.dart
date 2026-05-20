// Eduardo Kairalla - 24024241

// Content of the "Video" tab on the startup detail screen.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';

// --- WIDGET ---

class VideoTab extends StatelessWidget {
  final String? videoUrl;

  const VideoTab({super.key, this.videoUrl});

  @override
  Widget build(BuildContext context) {
    if (videoUrl == null || videoUrl!.isEmpty) {
      return _emptyState(context);
    }
    return _withVideo(context, videoUrl!);
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

  Widget _withVideo(BuildContext context, String url) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.play_circle_fill,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                Positioned(
                  bottom: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Vídeo de apresentação',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Link do vídeo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Row(
              children: [
                Icon(Icons.link, size: 18, color: AppColors.textSecondary(context)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    url,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link copiado!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.copy_outlined,
                      size: 16,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
