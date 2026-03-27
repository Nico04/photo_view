library photo_view_gallery;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart'
    show LoadingBuilder, PhotoView, PhotoViewOptions, PhotoViewFrameBuilder;

import 'package:photo_view/src/controller/photo_view_controller.dart';
import 'package:photo_view/src/controller/photo_view_scalestate_controller.dart';
import 'package:photo_view/src/core/photo_view_gesture_detector.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';

/// A type definition for a [Function] that receives a index after a page change in [PhotoViewGallery]
typedef PhotoViewGalleryPageChangedCallback = void Function(int index);

/// A type definition for a [Function] that defines a page in [PhotoViewGallery.build]
typedef PhotoViewGalleryBuilder = PhotoViewGalleryPageOptions Function(
    BuildContext context, int index);

/// A [StatefulWidget] that shows multiple [PhotoView] widgets in a [PageView]
///
/// Some of [PhotoView] constructor options are passed direct to [PhotoViewGallery] constructor. Those options will affect the gallery in a whole.
///
/// Some of the options may be defined to each image individually, such as `initialScale` or `PhotoViewHeroAttributes`. Those must be passed via each [PhotoViewGalleryPageOptions].
///
/// Example of usage as a list of options:
/// ```
/// PhotoViewGallery(
///   pageOptions: <PhotoViewGalleryPageOptions>[
///     PhotoViewGalleryPageOptions(
///       imageProvider: AssetImage("assets/gallery1.jpg"),
///       options: PhotoViewOptions(heroAttributes: const PhotoViewHeroAttributes(tag: "tag1")),
///     ),
///     PhotoViewGalleryPageOptions(
///       imageProvider: AssetImage("assets/gallery2.jpg"),
///       options: PhotoViewOptions(
///         heroAttributes: const PhotoViewHeroAttributes(tag: "tag2"),
///         maxScale: PhotoViewComputedScale.contained * 0.3,
///       ),
///     ),
///   ],
///   backgroundDecoration: widget.backgroundDecoration,
///   pageController: widget.pageController,
///   onPageChanged: onPageChanged,
/// )
/// ```
///
/// Example of usage with builder pattern:
/// ```
/// PhotoViewGallery.builder(
///   scrollPhysics: const BouncingScrollPhysics(),
///   builder: (BuildContext context, int index) {
///     return PhotoViewGalleryPageOptions(
///       imageProvider: AssetImage(widget.galleryItems[index].image),
///       options: PhotoViewOptions(
///         initialScale: PhotoViewComputedScale.contained * 0.8,
///         minScale: PhotoViewComputedScale.contained * 0.8,
///         maxScale: PhotoViewComputedScale.covered * 1.1,
///         heroAttributes: HeroAttributes(tag: galleryItems[index].id),
///       ),
///     );
///   },
///   itemCount: galleryItems.length,
///   backgroundDecoration: widget.backgroundDecoration,
///   pageController: widget.pageController,
///   onPageChanged: onPageChanged,
/// )
/// ```
class PhotoViewGallery extends StatefulWidget {
  /// Construct a gallery with static items through a list of [PhotoViewGalleryPageOptions].
  const PhotoViewGallery({
    Key? key,
    required this.pageOptions,
    this.loadingBuilder,
    this.wantKeepAlive = false,
    this.gaplessPlayback = false,
    this.reverse = false,
    this.pageController,
    this.onPageChanged,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.scrollPhysics,
    this.scrollDirection = Axis.horizontal,
    this.customSize,
    this.allowImplicitScrolling = false,
    this.pageSnapping = true,
    this.enableThumbnails = true,
  })  : itemCount = null,
        builder = null,
        super(key: key);

  /// Construct a gallery with dynamic items.
  ///
  /// The builder must return a [PhotoViewGalleryPageOptions].
  const PhotoViewGallery.builder({
    Key? key,
    required this.itemCount,
    required this.builder,
    this.loadingBuilder,
    this.wantKeepAlive = false,
    this.gaplessPlayback = false,
    this.reverse = false,
    this.pageController,
    this.onPageChanged,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.scrollPhysics,
    this.scrollDirection = Axis.horizontal,
    this.customSize,
    this.allowImplicitScrolling = false,
    this.pageSnapping = true,
    this.enableThumbnails = true,
  })  : pageOptions = null,
        assert(itemCount != null),
        assert(builder != null),
        super(key: key);

  /// A list of options to describe the items in the gallery
  final List<PhotoViewGalleryPageOptions>? pageOptions;

  /// The count of items in the gallery, only used when constructed via [PhotoViewGallery.builder]
  final int? itemCount;

  /// Called to build items for the gallery when using [PhotoViewGallery.builder]
  final PhotoViewGalleryBuilder? builder;

  /// [ScrollPhysics] for the internal [PageView]
  final ScrollPhysics? scrollPhysics;

  /// Mirror to [PhotoView.loadingBuilder]
  final LoadingBuilder? loadingBuilder;

  /// Mirror to [PhotoView.wantKeepAlive]
  final bool wantKeepAlive;

  /// Mirror to [PhotoView.gaplessPlayback]
  final bool gaplessPlayback;

  /// Mirror to [PageView.reverse]
  final bool reverse;

  /// An object that controls the [PageView] inside [PhotoViewGallery]
  final PageController? pageController;

  /// An callback to be called on a page change
  final PhotoViewGalleryPageChangedCallback? onPageChanged;

  /// Mirror to [PhotoView.scaleStateChangedCallback]
  final ValueChanged<PhotoViewScaleState>? scaleStateChangedCallback;

  /// Mirror to [PhotoView.enableRotation]
  final bool enableRotation;

  /// Mirror to [PhotoView.customSize]
  final Size? customSize;

  /// The axis along which the [PageView] scrolls. Mirror to [PageView.scrollDirection]
  final Axis scrollDirection;

  /// When user attempts to move it to the next element, focus will traverse to the next page in the page view.
  final bool allowImplicitScrolling;

  final bool pageSnapping;

  /// Whether to show a thumbnails bar at the bottom of the gallery.
  final bool enableThumbnails;

  bool get _isBuilder => builder != null;

  @override
  State<StatefulWidget> createState() {
    return _PhotoViewGalleryState();
  }
}

class _PhotoViewGalleryState extends State<PhotoViewGallery> {
  static const itemHorizontalPadding = 6.0;

  late final _controller = widget.pageController ?? PageController();
  late final _thumbnailController = PageController(
    viewportFraction: 0.2,
    initialPage: _controller.initialPage,
  );

  late bool _showThumbnails = widget.enableThumbnails;

  int get itemCount => widget._isBuilder ? widget.itemCount! : widget.pageOptions!.length;

  @override
  Widget build(BuildContext context) {
    final child = PhotoViewGestureDetectorScope(   // Enable corner hit test
      axis: widget.scrollDirection,
      child: PageView.builder(
        reverse: widget.reverse,
        controller: _controller,
        onPageChanged: (index) {
          if (_thumbnailController.hasClients && _thumbnailController.page?.round() != index) {
            _thumbnailController.animateToPage(
              index,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            );
          }
          widget.onPageChanged?.call(index);
        },
        scrollDirection: widget.scrollDirection,
        physics: widget.scrollPhysics,
        allowImplicitScrolling: widget.allowImplicitScrolling,
        pageSnapping: widget.pageSnapping,
        itemCount: itemCount,
        itemBuilder: _buildItem,
      ),
    );

    if (!widget.enableThumbnails) {
      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth * _thumbnailController.viewportFraction - itemHorizontalPadding;
        final itemHeight = itemWidth * 4/3;

        return Stack(
          children: [
            // Photo View
            GestureDetector(
              onTap: () {
                setState(() {
                  _showThumbnails = !_showThumbnails;
                });
              },
              child: child,
            ),

            // Thumbnails
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: !_showThumbnails,
                child: AnimatedOpacity(
                  opacity: _showThumbnails ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: SizedBox(
                          height: itemHeight,
                          child: PageView.builder(
                            reverse: widget.reverse,
                            controller: _thumbnailController,
                            onPageChanged: (index) {
                              if (_controller.hasClients && _controller.page?.round() != index) {
                                _controller.jumpToPage(index);
                              }
                            },
                            itemCount: itemCount,
                            itemBuilder: _buildThumbnail,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final pageOption = _buildPageOption(context, index);
    final isCustomChild = pageOption.child != null;

    // Merge gallery-level enableRotation into page options
    final pageOptions = PhotoViewOptions(
      heroAttributes: pageOption.options.heroAttributes,
      enableRotation:
          pageOption.options.enableRotation || widget.enableRotation,
      maxScale: pageOption.options.maxScale,
      minScale: pageOption.options.minScale,
      initialScale: pageOption.options.initialScale,
      basePosition: pageOption.options.basePosition,
      scaleStateCycle: pageOption.options.scaleStateCycle,
      onTapUp: pageOption.options.onTapUp,
      onTapDown: pageOption.options.onTapDown,
      onScaleEnd: pageOption.options.onScaleEnd,
      gestureDetectorBehavior: pageOption.options.gestureDetectorBehavior,
      tightMode: pageOption.options.tightMode,
      filterQuality: pageOption.options.filterQuality,
      disableGestures: pageOption.options.disableGestures,
      enablePanAlways: pageOption.options.enablePanAlways,
      strictScale: pageOption.options.strictScale,
      backgroundDecoration: pageOption.options.backgroundDecoration,
      frameBuilder: pageOption.options.frameBuilder,
    );

    void scaleStateChangedCallback(PhotoViewScaleState scaleState) => widget.scaleStateChangedCallback?.call(scaleState);

    final PhotoView photoView = isCustomChild
        ? PhotoView.customChild(
            key: ObjectKey(index),
            child: pageOption.child,
            childSize: pageOption.childSize,
            wantKeepAlive: widget.wantKeepAlive,
            controller: pageOption.controller,
            scaleStateController: pageOption.scaleStateController,
            customSize: widget.customSize,
            scaleStateChangedCallback: scaleStateChangedCallback,
            options: pageOptions,
          )
        : PhotoView(
            key: ObjectKey(index),
            imageProvider: pageOption.imageProvider,
            loadingBuilder: widget.loadingBuilder,
            wantKeepAlive: widget.wantKeepAlive,
            controller: pageOption.controller,
            scaleStateController: pageOption.scaleStateController,
            customSize: widget.customSize,
            semanticLabel: pageOption.semanticLabel,
            gaplessPlayback: widget.gaplessPlayback,
            scaleStateChangedCallback: scaleStateChangedCallback,
            errorBuilder: pageOption.errorBuilder,
            options: pageOptions,
          );

    return ClipRect(
      child: photoView,
    );
  }

  PhotoViewGalleryPageOptions _buildPageOption(
      BuildContext context, int index) {
    if (widget._isBuilder) {
      return widget.builder!(context, index);
    }
    return widget.pageOptions![index];
  }

  Widget _buildThumbnail(BuildContext context, int index) {
    final pageOption = _buildPageOption(context, index);

    final child = pageOption.child ?? Image(
      image: pageOption.imageProvider!,
      fit: BoxFit.cover,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: itemHorizontalPadding / 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTap: () {
            if (_thumbnailController.hasClients) {
              _thumbnailController.jumpToPage(index);
            }
          },
          child: pageOption.thumbnailFrameBuilder?.call(context, child) ?? child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.pageController == null) _controller.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }
}

/// A helper class that wraps individual options of a page in [PhotoViewGallery]
///
/// The [PhotoViewOptions.maxScale], [PhotoViewOptions.minScale] and
/// [PhotoViewOptions.initialScale] may be [double] or a
/// [PhotoViewComputedScale] constant.
///
class PhotoViewGalleryPageOptions {
  PhotoViewGalleryPageOptions({
    Key? key,
    required this.imageProvider,
    this.semanticLabel,
    this.controller,
    this.scaleStateController,
    this.errorBuilder,
    this.thumbnailFrameBuilder,
    this.options = const PhotoViewOptions(),
  })  : child = null,
        childSize = null,
        assert(imageProvider != null);

  PhotoViewGalleryPageOptions.customChild({
    required this.child,
    this.semanticLabel,
    this.childSize,
    this.controller,
    this.scaleStateController,
    this.thumbnailFrameBuilder,
    this.options = const PhotoViewOptions(),
  })  : errorBuilder = null,
        imageProvider = null;

  /// Mirror to [PhotoView.imageProvider]
  final ImageProvider? imageProvider;

  /// Mirror to [PhotoView.semanticLabel]
  final String? semanticLabel;

  /// Mirror to [PhotoView.controller]
  final PhotoViewController? controller;

  /// Mirror to [PhotoView.scaleStateController]
  final PhotoViewScaleStateController? scaleStateController;

  /// Mirror to [PhotoView.child]
  final Widget? child;

  /// Mirror to [PhotoView.childSize]
  final Size? childSize;

  /// Mirror to [PhotoView.errorBuilder]
  final ImageErrorWidgetBuilder? errorBuilder;

  /// A builder that allows wrapping or decorating the gallery thumbnail.
  /// Similar to [Image.frameBuilder], this receives the built PhotoView content
  /// and returns a new widget. See also [PhotoViewFrameBuilder].
  final PhotoViewFrameBuilder? thumbnailFrameBuilder;

  /// Shared configuration options for gesture, scale and display behavior.
  /// See [PhotoViewOptions] for all available fields and their defaults.
  final PhotoViewOptions options;
}
