import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class CommonExampleRouteWrapper extends StatelessWidget {
  const CommonExampleRouteWrapper({
    required this.imageProvider,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.basePosition = Alignment.center,
    this.filterQuality = FilterQuality.none,
    this.disableGestures = false,
    this.errorBuilder,
  });

  final ImageProvider imageProvider;
  final LoadingBuilder? loadingBuilder;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final dynamic initialScale;
  final Alignment basePosition;
  final FilterQuality filterQuality;
  final bool disableGestures;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: PhotoView(
          imageProvider: imageProvider,
          loadingBuilder: loadingBuilder,
          errorBuilder: errorBuilder,
          options: PhotoViewOptions(
            backgroundDecoration: backgroundDecoration ?? const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 1.0)),
            minScale: minScale ?? 0.0,
            maxScale: maxScale ?? double.infinity,
            initialScale: initialScale ?? PhotoViewComputedScale.contained,
            basePosition: basePosition,
            filterQuality: filterQuality,
            disableGestures: disableGestures,
          ),
        ),
      ),
    );
  }
}
