import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tivi_tea/core/utils/media_utils.dart';
import 'package:tivi_tea/features/common/video_player_screen.dart';
import 'package:tivi_tea/features/services/view/widgets/delete_icon.dart';

/// Renders a single piece of media (image or video) from either a local file
/// path or a remote URL. Videos show a thumbnail with a play overlay and open
/// a full-screen player on tap. An optional delete button can be shown.
class MediaTile extends StatelessWidget {
  const MediaTile({
    super.key,
    required this.path,
    required this.isNetwork,
    this.onDelete,
    this.borderRadius = 16.0,
  });

  /// Local file path (when [isNetwork] is false) or remote URL (when true).
  final String path;
  final bool isNetwork;
  final VoidCallback? onDelete;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isVideo = MediaUtils.isVideo(path);
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: isVideo ? _buildVideo(context) : _buildImage(),
        ),
        if (onDelete != null)
          Positioned(
            top: 8,
            left: 8,
            child: DeleteIcon(deleteImage: onDelete!),
          ),
      ],
    );
  }

  Widget _buildImage() {
    if (isNetwork) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        progressIndicatorBuilder: (_, __, ___) =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (_, __, ___) => _errorBox(),
      );
    }
    return Image.file(File(path), fit: BoxFit.cover);
  }

  Widget _buildVideo(BuildContext context) {
    return GestureDetector(
      onTap: () => isNetwork
          ? VideoPlayerScreen.open(context, url: path)
          : VideoPlayerScreen.open(context, filePath: path),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _videoThumbnail(),
          Container(color: Colors.black26),
          const Center(
            child: Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoThumbnail() {
    if (isNetwork) {
      return CachedNetworkImage(
        imageUrl: MediaUtils.cloudinaryVideoThumbnail(path),
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => Container(color: Colors.black87),
      );
    }
    // No cheap way to render a local video frame without an extra package;
    // show a neutral placeholder behind the play icon.
    return Container(color: Colors.black87);
  }

  Widget _errorBox() => Container(
        color: const Color(0xFFE8E8EB),
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
      );
}
