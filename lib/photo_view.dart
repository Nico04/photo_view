library photo_view;

import 'package:flutter/material.dart';

import 'package:photo_view/src/controller/photo_view_controller.dart';
import 'package:photo_view/src/controller/photo_view_scalestate_controller.dart';
import 'package:photo_view/src/photo_view_computed_scale.dart';
import 'package:photo_view/src/photo_view_options.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';
import 'package:photo_view/src/photo_view_wrappers.dart';

export 'src/controller/photo_view_controller.dart';
export 'src/controller/photo_view_scalestate_controller.dart';
export 'src/core/photo_view_gesture_detector.dart'
    show PhotoViewGestureDetectorScope;
export 'src/photo_view_computed_scale.dart';
export 'src/photo_view_options.dart';
export 'src/photo_view_scale_state.dart';
export 'src/utils/photo_view_hero_attributes.dart';

/// A [StatefulWidget] that contains all the photo view rendering elements.
///
/// Sample code to use within an image:
///
/// ```
/// PhotoView(
///  imageProvider: imageProvider,
///  loadingBuilder: (context, progress) => Center(
///            child: Container(
///              width: 20.0,
///              height: 20.0,
///              child: CircularProgressIndicator(
///                value: _progress == null
///                    ? null
///                    : _progress.cumulativeBytesLoaded /
///                        _progress.expectedTotalBytes,
///              ),
///            ),
///          ),
///  backgroundDecoration: BoxDecoration(color: Colors.black),
///  semanticLabel: 'Some label',
///  gaplessPlayback: false,
///  customSize: MediaQuery.of(context).size,
///  heroAttributes: const HeroAttributes(
///   tag: "someTag",
///   transitionOnUserGestures: true,
///  ),
///  scaleStateChangedCallback: this.onScaleStateChanged,
///  enableRotation: true,
///  controller:  controller,
///  minScale: PhotoViewComputedScale.contained * 0.8,
///  maxScale: PhotoViewComputedScale.covered * 1.8,
///  initialScale: PhotoViewComputedScale.contained,
///  basePosition: Alignment.center,
///  scaleStateCycle: scaleStateCycle
/// );
/// ```
///
/// You can customize to show an custom child instead of an image:
///
/// ```
/// PhotoView.customChild(
///  child: Container(
///    width: 220.0,
///    height: 250.0,
///    child: const Text(
///      "Hello there, this is a text",
///    )
///  ),
///  childSize: const Size(220.0, 250.0),
///  backgroundDecoration: BoxDecoration(color: Colors.black),
///  semanticLabel: 'Some label',
///  gaplessPlayback: false,
///  customSize: MediaQuery.of(context).size,
///  heroAttributes: const HeroAttributes(
///   tag: "someTag",
///   transitionOnUserGestures: true,
///  ),
///  scaleStateChangedCallback: this.onScaleStateChanged,
///  enableRotation: true,
///  controller:  controller,
///  minScale: PhotoViewComputedScale.contained * 0.8,
///  maxScale: PhotoViewComputedScale.covered * 1.8,
///  initialScale: PhotoViewComputedScale.contained,
///  basePosition: Alignment.center,
///  scaleStateCycle: scaleStateCycle
/// );
/// ```
/// The [maxScale], [minScale] and [initialScale] options may be [double] or a [PhotoViewComputedScale] constant
///
/// Sample using [maxScale], [minScale] and [initialScale]
///
/// ```
/// PhotoView(
///  imageProvider: imageProvider,
///  minScale: PhotoViewComputedScale.contained * 0.8,
///  maxScale: PhotoViewComputedScale.covered * 1.8,
///  initialScale: PhotoViewComputedScale.contained * 1.1,
/// );
/// ```
///
/// [customSize] is used to define the viewPort size in which the image will be
/// scaled to. This argument is rarely used. By default is the size that this widget assumes.
///
/// The argument [gaplessPlayback] is used to continue showing the old image
/// (`true`), or briefly show nothing (`false`), when the [imageProvider]
/// changes.By default it's set to `false`.
///
/// To use within an hero animation, specify [heroAttributes]. When
/// [heroAttributes] is specified, the image provider retrieval process should
/// be sync.
///
/// Sample using hero animation:
/// ```
/// // screen1
///   ...
///   Hero(
///     tag: "someTag",
///     child: Image.asset(
///       "assets/large-image.jpg",
///       width: 150.0
///     ),
///   )
/// // screen2
/// ...
/// child: PhotoView(
///   imageProvider: AssetImage("assets/large-image.jpg"),
///   heroAttributes: const HeroAttributes(tag: "someTag"),
/// )
/// ```
///
/// ## Frame Builder
///
/// Use [frameBuilder] to wrap the PhotoView content with your own widget,
/// for example to add an overlay on top of the zoomable content:
///
/// ```
/// PhotoView(
///   imageProvider: AssetImage("assets/large-image.jpg"),
///   frameBuilder: (context, child) {
///     return Stack(
///       children: [
///         child,
///         Positioned(
///           bottom: 16,
///           left: 16,
///           child: Text(
///             "Caption overlay",
///             style: TextStyle(color: Colors.white),
///           ),
///         ),
///       ],
///     );
///   },
/// )
/// ```
///
/// This also works in gallery mode via [PhotoViewGalleryPageOptions.frameBuilder].
///
/// **Note: If you don't want to the zoomed image do not overlaps the size of the container, use [ClipRect](https://docs.flutter.io/flutter/widgets/ClipRect-class.html)**
///
/// ## Controllers
///
/// Controllers, when specified to PhotoView widget, enables the author(you) to listen for state updates through a `Stream` and change those values externally.
///
/// While [PhotoViewScaleStateController] is only responsible for the `scaleState`, [PhotoViewController] is responsible for all fields os [PhotoViewControllerValue].
///
/// To use them, pass a instance of those items on [controller] or [scaleStateController];
///
/// Since those follows the standard controller pattern found in widgets like [PageView] and [ScrollView], whoever instantiates it, should [dispose] it afterwards.
///
/// Example of [controller] usage, only listening for state changes:
///
/// ```
/// class _ExampleWidgetState extends State<ExampleWidget> {
///
///   PhotoViewController controller;
///   double scaleCopy;
///
///   @override
///   void initState() {
///     super.initState();
///     controller = PhotoViewController()
///       ..outputStateStream.listen(listener);
///   }
///
///   @override
///   void dispose() {
///     controller.dispose();
///     super.dispose();
///   }
///
///   void listener(PhotoViewControllerValue value){
///     setState((){
///       scaleCopy = value.scale;
///     })
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Stack(
///       children: <Widget>[
///         Positioned.fill(
///             child: PhotoView(
///               imageProvider: AssetImage("assets/pudim.png"),
///               controller: controller,
///             );
///         ),
///         Text("Scale applied: $scaleCopy")
///       ],
///     );
///   }
/// }
/// ```
///
/// An example of [scaleStateController] with state changes:
/// ```
/// class _ExampleWidgetState extends State<ExampleWidget> {
///
///   PhotoViewScaleStateController scaleStateController;
///
///   @override
///   void initState() {
///     super.initState();
///     scaleStateController = PhotoViewScaleStateController();
///   }
///
///   @override
///   void dispose() {
///     scaleStateController.dispose();
///     super.dispose();
///   }
///
///   void goBack(){
///     scaleStateController.scaleState = PhotoViewScaleState.originalSize;
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Stack(
///       children: <Widget>[
///         Positioned.fill(
///             child: PhotoView(
///               imageProvider: AssetImage("assets/pudim.png"),
///               scaleStateController: scaleStateController,
///             );
///         ),
///         FlatButton(
///           child: Text("Go to original size"),
///           onPressed: goBack,
///         );
///       ],
///     );
///   }
/// }
/// ```
///
class PhotoView extends StatefulWidget {
  /// Creates a widget that displays a zoomable image.
  ///
  /// To show an image from the network or from an asset bundle, use their respective
  /// image providers, ie: [AssetImage] or [NetworkImage]
  ///
  /// Internally, the image is rendered within an [Image] widget.
  PhotoView({
    Key? key,
    required this.imageProvider,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.wantKeepAlive = false,
    this.semanticLabel,
    this.gaplessPlayback = false,
    this.scaleStateChangedCallback,
    this.controller,
    this.scaleStateController,
    this.customSize,
    this.errorBuilder,
    this.frameBuilder,
    this.options = const PhotoViewOptions(),
  })  : child = null,
        childSize = null,
        super(key: key);

  /// Creates a widget that displays a zoomable child.
  ///
  /// It has been created to resemble [PhotoView] behavior within widgets that aren't an image, such as [Container], [Text] or a svg.
  ///
  /// Instead of a [imageProvider], this constructor will receive a [child] and a [childSize].
  ///
  PhotoView.customChild({
    Key? key,
    required this.child,
    this.childSize,
    this.backgroundDecoration,
    this.wantKeepAlive = false,
    this.scaleStateChangedCallback,
    this.controller,
    this.scaleStateController,
    this.customSize,
    this.frameBuilder,
    this.options = const PhotoViewOptions(),
  })  : errorBuilder = null,
        imageProvider = null,
        semanticLabel = null,
        gaplessPlayback = false,
        loadingBuilder = null,
        super(key: key);

  /// Given a [imageProvider] it resolves into an zoomable image widget using. It
  /// is required
  final ImageProvider? imageProvider;

  /// While [imageProvider] is not resolved, [loadingBuilder] is called by [PhotoView]
  /// into the screen, by default it is a centered [CircularProgressIndicator]
  final LoadingBuilder? loadingBuilder;

  /// Show loadFailedChild when the image failed to load
  final ImageErrorWidgetBuilder? errorBuilder;

  /// Changes the background behind image, defaults to `Colors.black`.
  final BoxDecoration? backgroundDecoration;

  /// This is used to keep the state of an image in the gallery (e.g. scale state).
  /// `false` -> resets the state (default)
  /// `true`  -> keeps the state
  final bool wantKeepAlive;

  /// A Semantic description of the image.
  ///
  /// Used to provide a description of the image to TalkBack on Android, and VoiceOver on iOS.
  final String? semanticLabel;

  /// This is used to continue showing the old image (`true`), or briefly show
  /// nothing (`false`), when the `imageProvider` changes. By default it's set
  /// to `false`.
  final bool gaplessPlayback;

  /// Defines the size of the scaling base of the image inside [PhotoView],
  /// by default it is `MediaQuery.of(context).size`.
  final Size? customSize;

  /// A [Function] to be called whenever the scaleState changes, this happens when the user double taps the content ou start to pinch-in.
  final ValueChanged<PhotoViewScaleState>? scaleStateChangedCallback;

  /// The specified custom child to be shown instead of a image
  final Widget? child;

  /// The size of the custom [child]. [PhotoView] uses this value to compute the relation between the child and the container's size to calculate the scale value.
  final Size? childSize;

  /// A way to control PhotoView transformation factors externally and listen to its updates
  final PhotoViewControllerBase? controller;

  /// A way to control PhotoViewScaleState value externally and listen to its updates
  final PhotoViewScaleStateController? scaleStateController;

  /// A builder that allows wrapping or decorating the PhotoView content widget.
  /// Similar to [Image.frameBuilder], this receives the built PhotoView content and returns a new widget.
  /// See also [PhotoViewFrameBuilder].
  final PhotoViewFrameBuilder? frameBuilder;

  /// Shared configuration options for gesture, scale and display behavior.
  /// See [PhotoViewOptions] for all available fields and their defaults.
  final PhotoViewOptions options;

  bool get _isCustomChild {
    return child != null;
  }

  @override
  State<StatefulWidget> createState() {
    return _PhotoViewState();
  }
}

class _PhotoViewState extends State<PhotoView>
    with AutomaticKeepAliveClientMixin {
  // image retrieval

  // controller
  late bool _controlledController;
  late PhotoViewControllerBase _controller;
  late bool _controlledScaleStateController;
  late PhotoViewScaleStateController _scaleStateController;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _controlledController = true;
      _controller = PhotoViewController();
    } else {
      _controlledController = false;
      _controller = widget.controller!;
    }

    if (widget.scaleStateController == null) {
      _controlledScaleStateController = true;
      _scaleStateController = PhotoViewScaleStateController();
    } else {
      _controlledScaleStateController = false;
      _scaleStateController = widget.scaleStateController!;
    }

    _scaleStateController.outputScaleStateStream.listen(scaleStateListener);
  }

  @override
  void didUpdateWidget(PhotoView oldWidget) {
    if (widget.controller == null) {
      if (!_controlledController) {
        _controlledController = true;
        _controller = PhotoViewController();
      }
    } else {
      _controlledController = false;
      _controller = widget.controller!;
    }

    if (widget.scaleStateController == null) {
      if (!_controlledScaleStateController) {
        _controlledScaleStateController = true;
        _scaleStateController = PhotoViewScaleStateController();
      }
    } else {
      _controlledScaleStateController = false;
      _scaleStateController = widget.scaleStateController!;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (_controlledController) {
      _controller.dispose();
    }
    if (_controlledScaleStateController) {
      _scaleStateController.dispose();
    }
    super.dispose();
  }

  void scaleStateListener(PhotoViewScaleState scaleState) {
    if (widget.scaleStateChangedCallback != null) {
      widget.scaleStateChangedCallback!(_scaleStateController.scaleState);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        final computedOuterSize = widget.customSize ?? constraints.biggest;
        final backgroundDecoration = widget.backgroundDecoration ??
            const BoxDecoration(color: Colors.black);

        final Widget content = widget._isCustomChild
            ? CustomChildWrapper(
                child: widget.child!,
                childSize: widget.childSize,
                backgroundDecoration: backgroundDecoration,
                controller: _controller,
                scaleStateController: _scaleStateController,
                outerSize: computedOuterSize,
                options: widget.options,
              )
            : ImageWrapper(
                imageProvider: widget.imageProvider!,
                loadingBuilder: widget.loadingBuilder,
                backgroundDecoration: backgroundDecoration,
                semanticLabel: widget.semanticLabel,
                gaplessPlayback: widget.gaplessPlayback,
                controller: _controller,
                scaleStateController: _scaleStateController,
                outerSize: computedOuterSize,
                errorBuilder: widget.errorBuilder,
                options: widget.options,
              );

        return widget.frameBuilder?.call(context, content) ?? content;
      },
    );
  }

  @override
  bool get wantKeepAlive => widget.wantKeepAlive;
}

/// The default [ScaleStateCycle]
PhotoViewScaleState defaultScaleStateCycle(PhotoViewScaleState actual) {
  switch (actual) {
    case PhotoViewScaleState.initial:
      return PhotoViewScaleState.covering;
    case PhotoViewScaleState.covering:
      return PhotoViewScaleState.originalSize;
    case PhotoViewScaleState.originalSize:
      return PhotoViewScaleState.initial;
    case PhotoViewScaleState.zoomedIn:
    case PhotoViewScaleState.zoomedOut:
      return PhotoViewScaleState.initial;
  }
}

/// A type definition for a [Function] that receives the actual [PhotoViewScaleState] and returns the next one
/// It is used internally to walk in the "doubletap gesture cycle".
/// It is passed to [PhotoView.scaleStateCycle]
typedef ScaleStateCycle = PhotoViewScaleState Function(
  PhotoViewScaleState actual,
);

/// A type definition for a callback when the user taps up the photoview region
typedef PhotoViewImageTapUpCallback = Function(
  BuildContext context,
  TapUpDetails details,
  PhotoViewControllerValue controllerValue,
);

/// A type definition for a callback when the user taps down the photoview region
typedef PhotoViewImageTapDownCallback = Function(
  BuildContext context,
  TapDownDetails details,
  PhotoViewControllerValue controllerValue,
);

/// A type definition for a callback when a user finished scale
typedef PhotoViewImageScaleEndCallback = Function(
  BuildContext context,
  ScaleEndDetails details,
  PhotoViewControllerValue controllerValue,
);

/// A type definition for a callback to show a widget while the image is loading, a [ImageChunkEvent] is passed to inform progress
typedef LoadingBuilder = Widget Function(
  BuildContext context,
  ImageChunkEvent? event,
);

/// A type definition for a [Function] that receives the built [PhotoView]
/// content widget and returns a new widget wrapping or decorating it.
///
/// Similar to [Image.frameBuilder], this allows consumers to wrap the PhotoView
/// content with their own widgets, for example to add an overlay on top of it.
///
/// Example:
/// ```dart
/// PhotoView(
///   imageProvider: AssetImage("assets/large-image.jpg"),
///   frameBuilder: (context, child) {
///     return Stack(
///       children: [
///         child,
///         Positioned(
///           bottom: 16,
///           left: 16,
///           child: Text("Overlay caption"),
///         ),
///       ],
///     );
///   },
/// )
/// ```
typedef PhotoViewFrameBuilder = Widget Function(
  BuildContext context,
  Widget child,
);

