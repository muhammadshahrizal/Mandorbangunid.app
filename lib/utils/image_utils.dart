import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

const String _imageOptimizerBaseUrl =
    'http://192.168.1.23/mandorbangun.id/api/optimize-image.php';

bool _isRemoteImageUrl(String imagePath) {
  final normalizedPath = imagePath.trim();
  return normalizedPath.startsWith('http://') ||
      normalizedPath.startsWith('https://');
}

String getOptimizedImageUrl(String imagePath, {String size = 'medium'}) {
  final normalizedPath = imagePath.trim();
  if (normalizedPath.isEmpty) {
    return '';
  }

  if (_isRemoteImageUrl(normalizedPath)) {
    return normalizedPath;
  }

  int width = 800;
  if (size == 'thumb') {
    width = 300;
  } else if (size == 'large') {
    width = 1200;
  }

  final encodedPath = Uri.encodeComponent(normalizedPath);
  return '$_imageOptimizerBaseUrl?path=$encodedPath&width=$width';
}

Widget _buildImageFallback() {
  return Container(
    color: const Color(0xFF151515),
    child: const Icon(Icons.image_not_supported, color: Colors.grey),
  );
}

Widget buildSafeNetworkImage(
  String imageUrl, {
  BoxFit fit = BoxFit.cover,
  int? cacheWidth,
}) {
  final normalizedUrl = imageUrl.trim();

  if (normalizedUrl.isEmpty) {
    return _buildImageFallback();
  }

  if (!_isRemoteImageUrl(normalizedUrl)) {
    return Image.asset(
      normalizedUrl,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Asset image load error: $normalizedUrl - $error');
        return _buildImageFallback();
      },
    );
  }

  return CachedNetworkImage(
    imageUrl: normalizedUrl,
    fit: fit,
    memCacheWidth: cacheWidth,
    fadeInDuration: const Duration(milliseconds: 300),
    fadeOutDuration: const Duration(milliseconds: 300),
    placeholder: (context, url) => Container(
      color: const Color(0xFF151515),
      child: const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
            strokeWidth: 2,
          ),
        ),
      ),
    ),
    errorWidget: (context, url, error) {
      debugPrint('Image load error: $url - $error');
      return _buildImageFallback();
    },
    httpHeaders: const {
      'Connection': 'keep-alive',
      'Cache-Control': 'max-age=2592000',
    },
  );
}
