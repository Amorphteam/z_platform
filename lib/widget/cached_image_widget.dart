import 'package:flutter/material.dart';
import 'dart:io';
import '../util/image_cache_helper.dart';

class CachedImageWidget extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const CachedImageWidget({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<CachedImageWidget> createState() => _CachedImageWidgetState();
}

class _CachedImageWidgetState extends State<CachedImageWidget> {
  final ImageCacheHelper _imageCacheHelper = ImageCacheHelper();
  String? _cachedImagePath;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadCachedImage();
  }

  Future<void> _loadCachedImage() async {
    if (widget.imageUrl.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    try {
      final cachedPath = await _imageCacheHelper.getCachedImagePath(widget.imageUrl);
      if (cachedPath != null) {
        setState(() {
          _cachedImagePath = cachedPath;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildContainer(
        child: widget.placeholder ?? const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasError || widget.imageUrl.isEmpty) {
      return _buildContainer(
        child: widget.errorWidget ?? const Center(
          child: Icon(Icons.error),
        ),
      );
    }

    if (_cachedImagePath != null) {
      // Use cached image
      return _buildContainer(
        child: ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.zero,
          child: Image.file(
            File(_cachedImagePath!),
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            errorBuilder: (context, error, stackTrace) {
              return widget.errorWidget ?? const Center(
                child: Icon(Icons.error),
              );
            },
          ),
        ),
      );
    } else {
      // Fallback to network image
      return _buildContainer(
        child: ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.zero,
          child: Image.network(
            widget.imageUrl,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return widget.placeholder ?? const Center(
                child: CircularProgressIndicator(),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return widget.errorWidget ?? const Center(
                child: Icon(Icons.error),
              );
            },
          ),
        ),
      );
    }
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: child,
    );
  }
} 