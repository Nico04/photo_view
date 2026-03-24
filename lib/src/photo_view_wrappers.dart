import 'package:flutter/widgets.dart';

import '../photo_view.dart';
import 'core/photo_view_core.dart';
import 'photo_view_default_widgets.dart';
import 'utils/photo_view_utils.dart';

/// Wrapper for image-based [PhotoView] content. Resolves the image stream and
/// displays loading/error states.
class ImageWrapper extends StatefulWidget {
  const ImageWrapper({
    Key? key,
    required this.imageProvider,
    required this.loadingBuilder,
    required this.backgroundDecoration,
    required this.semanticLabel,
    required this.gaplessPlayback,
    required this.controller,
    required this.scaleStateController,
    required this.outerSize,
    required this.errorBuilder,
    required this.options,
  }) : super(key: key);

  final ImageProvider imageProvider;
  final LoadingBuilder? loadingBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final String? semanticLabel;
  final bool gaplessPlayback;

  final BoxDecoration backgroundDecoration;
  final PhotoViewControllerBase controller;
  final PhotoViewScaleStateController scaleStateController;
  final Size outerSize;

  final PhotoViewOptions options;

  @override
  _ImageWrapperState createState() =>
      _ImageWrapperState();
}

class _ImageWrapperState extends State<ImageWrapper> {
  ImageStreamListener? _imageStreamListener;
  ImageStream? _imageStream;
  ImageChunkEvent? _loadingProgress;
  ImageInfo? _imageInfo;
  bool _loading = true;
  Size? _imageSize;
  Object? _lastException;
  StackTrace? _lastStack;

  @override
  void dispose() {
    super.dispose();
    _stopImageStream();
  }

  @override
  void didChangeDependencies() {
    _resolveImage();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(ImageWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageProvider != oldWidget.imageProvider) {
      _resolveImage();
    }
  }

  void _resolveImage() {
    final ImageStream newStream = widget.imageProvider.resolve(
      const ImageConfiguration(),
    );
    _updateSourceStream(newStream);
  }

  ImageStreamListener _getOrCreateListener() {
    void handleImageChunk(ImageChunkEvent event) {
      setState(() {
        _loadingProgress = event;
        _lastException = null;
      });
    }

    void handleImageFrame(ImageInfo info, bool synchronousCall) {
      final setupCB = () {
        _imageSize = Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        );
        _loading = false;
        _imageInfo = _imageInfo;

        _loadingProgress = null;
        _lastException = null;
        _lastStack = null;
      };
      synchronousCall ? setupCB() : setState(setupCB);
    }

    void handleError(dynamic error, StackTrace? stackTrace) {
      setState(() {
        _loading = false;
        _lastException = error;
        _lastStack = stackTrace;
      });
      assert(() {
        if (widget.errorBuilder == null) {
          throw error;
        }
        return true;
      }());
    }

    _imageStreamListener = ImageStreamListener(
      handleImageFrame,
      onChunk: handleImageChunk,
      onError: handleError,
    );

    return _imageStreamListener!;
  }

  void _updateSourceStream(ImageStream newStream) {
    if (_imageStream?.key == newStream.key) {
      return;
    }
    _imageStream?.removeListener(_imageStreamListener!);
    _imageStream = newStream;
    _imageStream!.addListener(_getOrCreateListener());
  }

  void _stopImageStream() {
    _imageStream?.removeListener(_imageStreamListener!);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildLoading(context);
    }

    if (_lastException != null) {
      return _buildError(context);
    }

    final scaleBoundaries = ScaleBoundaries(
      widget.options.minScale,
      widget.options.maxScale,
      widget.options.initialScale,
      widget.outerSize,
      _imageSize!,
    );

    return PhotoViewCore(
      imageProvider: widget.imageProvider,
      backgroundDecoration: widget.backgroundDecoration,
      semanticLabel: widget.semanticLabel,
      gaplessPlayback: widget.gaplessPlayback,
      controller: widget.controller,
      scaleStateController: widget.scaleStateController,
      scaleBoundaries: scaleBoundaries,
      options: widget.options,
    );
  }

  Widget _buildLoading(BuildContext context) {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context, _loadingProgress);
    }

    return PhotoViewDefaultLoading(
      event: _loadingProgress,
    );
  }

  Widget _buildError(BuildContext context) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _lastException!, _lastStack);
    }
    return PhotoViewDefaultError(
      decoration: widget.backgroundDecoration,
    );
  }
}

/// Wrapper for custom-child-based [PhotoView] content. Stateless since there
/// is no image stream to resolve.
class CustomChildWrapper extends StatelessWidget {
  const CustomChildWrapper({
    Key? key,
    required this.child,
    required this.childSize,
    required this.backgroundDecoration,
    required this.controller,
    required this.scaleStateController,
    required this.outerSize,
    required this.options,
  }) : super(key: key);

  final Widget child;
  final Size? childSize;

  final BoxDecoration backgroundDecoration;
  final PhotoViewControllerBase controller;
  final PhotoViewScaleStateController scaleStateController;
  final Size outerSize;

  final PhotoViewOptions options;

  @override
  Widget build(BuildContext context) {
    final scaleBoundaries = ScaleBoundaries(
      options.minScale,
      options.maxScale,
      options.initialScale,
      outerSize,
      childSize ?? outerSize,
    );

    return PhotoViewCore.customChild(
      customChild: child,
      backgroundDecoration: backgroundDecoration,
      controller: controller,
      scaleStateController: scaleStateController,
      scaleBoundaries: scaleBoundaries,
      options: options,
    );
  }
}


