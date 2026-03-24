import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view_example/screens/common/app_bar.dart';
import 'package:photo_view_example/screens/common/example_button.dart';

class FrameBuilderExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExampleAppBarLayout(
      title: "Frame Builder",
      showGoBack: true,
      child: ListView(
        children: <Widget>[
          ExampleButtonNode(
            title: "Single image with overlay",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const _SingleFrameBuilderExample(),
                ),
              );
            },
          ),
          ExampleButtonNode(
            title: "Gallery with per-page overlay",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const _GalleryFrameBuilderExample(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SingleFrameBuilderExample extends StatelessWidget {
  const _SingleFrameBuilderExample();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: PhotoView(
          imageProvider: const AssetImage("assets/large-image.jpg"),
          frameBuilder: (context, child) {
            return Stack(
              children: [
                child,
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 24.0,
                    ),
                    child: const Text(
                      "A beautiful landscape — caption overlay via frameBuilder",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GalleryFrameBuilderExample extends StatefulWidget {
  const _GalleryFrameBuilderExample();

  @override
  State<_GalleryFrameBuilderExample> createState() =>
      _GalleryFrameBuilderExampleState();
}

class _GalleryFrameBuilderExampleState
    extends State<_GalleryFrameBuilderExample> {
  static const _images = [
    "assets/gallery1.jpg",
    "assets/gallery2.jpg",
    "assets/gallery3.jpg",
  ];

  static const _captions = [
    "Gallery image 1",
    "Gallery image 2",
    "Gallery image 3",
  ];

  late int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.black),
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: AssetImage(_images[index]),
              options: const PhotoViewOptions(
                initialScale: PhotoViewComputedScale.contained,
              ),
              frameBuilder: (context, child) {
                return Stack(
                  children: [
                    child,
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 24.0,
                        ),
                        child: Text(
                          _captions[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          itemCount: _images.length,
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}



