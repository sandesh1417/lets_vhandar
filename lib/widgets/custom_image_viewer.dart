import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_vhandar/widgets/custom_shimmer.dart';

final _cacheManager = CacheManager(
  Config(
    'vhandar_img_cache',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 150,
  ),
);

const _kPlaceholderSvg = 'assets/images/placeholder.svg';

enum ImageType { network, asset, file, svg }

class CustomImageViewer extends StatelessWidget {
  final String? path;
  final double? height;
  final double? width;
  final BoxFit fit;
  final String placeholder;
  final Color? color;
  final double? borderRadius;
  final Widget? errorWidget;

  const CustomImageViewer({
    super.key,
    required this.path,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.placeholder = 'assets/images/placeholder.png',
    this.color,
    this.borderRadius,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return _buildBorderRadius(
      child: _buildImageWidget(),
    );
  }

  Widget _buildBorderRadius({required Widget child}) {
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius!),
        child: child,
      );
    }
    return child;
  }

  Widget _buildImageWidget() {
    if (path == null || path!.isEmpty) {
      return _buildPlaceholder();
    }

    if (path!.startsWith('http') || path!.startsWith('https')) {
      return CachedNetworkImage(
        imageUrl: path!,
        cacheManager: _cacheManager,
        height: height,
        width: width,
        fit: fit,
        // Gentle cross-fade so images never "snap" in over the shimmer.
        fadeInDuration: const Duration(milliseconds: 280),
        fadeOutDuration: const Duration(milliseconds: 120),
        placeholderFadeInDuration: const Duration(milliseconds: 150),
        placeholder: (context, url) => _buildLoadingWidget(),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildErrorWidget(),
      );
    } else if (path!.endsWith('.svg')) {
      return SvgPicture.asset(
        path!,
        height: height,
        width: width,
        fit: fit,
        colorFilter:
            color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      );
    } else if (path!.startsWith('/') || path!.contains('users/')) {
      return Image.file(
        File(path!),
        height: height,
        width: width,
        fit: fit,
      );
    } else {
      return Image.asset(
        path!,
        height: height,
        width: width,
        fit: fit,
        color: color,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildErrorWidget(),
      );
    }
  }

  Widget _buildPlaceholder() {
    return SvgPicture.asset(
      _kPlaceholderSvg,
      height: height,
      width: width,
      fit: BoxFit.contain,
    );
  }

  Widget _buildLoadingWidget() {
    return const CustomShimmer.rectangular();
  }

  Widget _buildErrorWidget() {
    return SvgPicture.asset(
      _kPlaceholderSvg,
      height: height,
      width: width,
      fit: BoxFit.contain,
    );
  }
}
