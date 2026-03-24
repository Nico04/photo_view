import 'package:flutter/material.dart';

import '../photo_view.dart';

/// Holds the shared configuration options used by both [PhotoView] and
/// [PhotoView.customChild] (and their gallery counterparts).
///
/// All fields have sensible defaults so a bare `const PhotoViewOptions()` is
/// valid.
class PhotoViewOptions {
  const PhotoViewOptions({
    this.heroAttributes,
    this.enableRotation = false,
    this.maxScale = double.infinity,
    this.minScale = 0.0,
    this.initialScale = PhotoViewComputedScale.contained,
    this.basePosition = Alignment.center,
    this.scaleStateCycle = defaultScaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.onScaleEnd,
    this.gestureDetectorBehavior,
    this.tightMode = false,
    this.filterQuality = FilterQuality.none,
    this.disableGestures = false,
    this.enablePanAlways = false,
    this.strictScale = false,
    this.backgroundDecoration = const BoxDecoration(color: Colors.black),
  });

  /// Attributes that are going to be passed to [PhotoViewCore]'s [Hero].
  /// Leave this property undefined if you don't want a hero animation.
  final PhotoViewHeroAttributes? heroAttributes;

  /// A flag that enables the rotation gesture support.
  final bool enableRotation;

  /// Defines the maximum size in which the image will be allowed to assume.
  /// Can be either a [double] (absolute value) or a [PhotoViewComputedScale],
  /// that can be multiplied by a double.
  final dynamic maxScale;

  /// Defines the minimum size in which the image will be allowed to assume.
  /// Can be either a [double] (absolute value) or a [PhotoViewComputedScale],
  /// that can be multiplied by a double.
  final dynamic minScale;

  /// Defines the initial size in which the image will assume in the mounting of
  /// the component. Can be either a [double] (absolute value) or a
  /// [PhotoViewComputedScale], that can be multiplied by a double.
  final dynamic initialScale;

  /// The alignment of the scale origin in relation to the widget size.
  final Alignment basePosition;

  /// Defines the next [PhotoViewScaleState] given the actual one.
  final ScaleStateCycle scaleStateCycle;

  /// A pointer that will trigger a tap has stopped contacting the screen at a
  /// particular location.
  final PhotoViewImageTapUpCallback? onTapUp;

  /// A pointer that might cause a tap has contacted the screen at a particular
  /// location.
  final PhotoViewImageTapDownCallback? onTapDown;

  /// A pointer that will trigger a scale has stopped contacting the screen at a
  /// particular location.
  final PhotoViewImageScaleEndCallback? onScaleEnd;

  /// [HitTestBehavior] to be passed to the internal gesture detector.
  final HitTestBehavior? gestureDetectorBehavior;

  /// Enables tight mode, making background container assume the size of the
  /// image/child. Useful when inside a [Dialog].
  final bool tightMode;

  /// Quality levels for image filters.
  final FilterQuality filterQuality;

  /// Removes gesture detector if `true`.
  /// Useful when custom gesture detector is used in child widget.
  final bool disableGestures;

  /// Enable pan the widget even if it's smaller than the whole parent widget.
  /// Useful when you want to drag a widget without restrictions.
  final bool enablePanAlways;

  /// Enable strictScale will restrict user scale gesture to the maxScale and
  /// minScale values.
  final bool strictScale;

  /// Changes the background behind image, defaults to `Colors.black`.
  final Decoration backgroundDecoration;
}
