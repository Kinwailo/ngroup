import 'dart:async';

import 'package:collection/collection.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:sanitize_filename/sanitize_filename.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../core/adaptive.dart';
import 'post_controller.dart';

class GalleryView extends ConsumerWidget {
  const GalleryView({super.key});

  static var path = 'gallery';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var images = ref.watch(postImagesProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: GridView.extent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: images
              .mapIndexed((index, e) => GalleryItem(index, 'gallery-image'))
              .toList(),
        ),
      ),
    );
  }
}

class GalleryItem extends ConsumerWidget {
  const GalleryItem(this.index, this.tag, {super.key});

  final int index;
  final String tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var images = ref.watch(postImagesProvider);

    return index >= images.length
        ? const SizedBox.shrink()
        : InkWell(
            onTap: () => GalleryItemView.show(context, index, tag),
            child: Hero(
              tag: '$tag + $index',
              child: Image(
                image: images[index].image,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
              ),
            ),
          );
  }
}

class PhotoViewDismissible {
  PhotoViewDismissible(this.dismissible, this.layoutHeight, this.provider);

  final ValueNotifier<bool> dismissible;
  final ValueNotifier<double> layoutHeight;
  final ImageProvider provider;
  final _imageHeight = ValueNotifier(0.0);

  StreamSubscription? _subscription;
  ImageStreamListener? _streamListener;
  var conf = const ImageConfiguration();

  PhotoViewController? _controller;
  PhotoViewController get controller => _getController();

  PhotoViewController _getController() {
    if (_controller != null) return _controller!;
    _controller = PhotoViewController();
    var photoViewStream = _controller!.outputStateStream;

    _streamListener = ImageStreamListener((ImageInfo info, bool _) {
      _imageHeight.value = info.image.height.toDouble();
      info.dispose();
    });
    provider.resolve(conf).addListener(_streamListener!);

    _subscription = photoViewStream.listen((e) {
      var bottom = _imageHeight.value * (e.scale ?? 1.0);
      bottom += 2 * e.position.dy;
      bottom -= layoutHeight.value;
      dismissible.value = bottom <= 0;
    });
    return _controller!;
  }

  void dispose() {
    if (_controller == null) return;
    _subscription?.cancel();
    provider.resolve(conf).removeListener(_streamListener!);
    _controller?.dispose();
  }
}

class GalleryItemView extends HookConsumerWidget {
  const GalleryItemView(this.index, this.tag, {super.key});

  static void show(BuildContext context, int index, String tag) {
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (_) => GalleryItemView(index, tag)));
  }

  final int index;
  final String tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var images = ref.watch(postImagesProvider);

    final page = useState(index);
    final pageController = usePageController(initialPage: index);

    final dismissible = useState(false);
    final layoutHeight = useValueNotifier(0.0);
    final photoViewDismissibles = useMemoized(() => <PhotoViewDismissible>[]);
    useEffect(() {
      void dispose(item) => item.dispose();
      photoViewDismissibles.forEach(dispose);
      photoViewDismissibles
        ..clear()
        ..addAll(List.generate(
            images.length,
            (i) => PhotoViewDismissible(
                  dismissible,
                  layoutHeight,
                  images[i].image,
                )));
      return () => photoViewDismissibles.forEach(dispose);
    }, [images]);

    final ui = useState(true);
    final animation = useAnimationController(
      initialValue: 1.0,
      duration: Durations.short2,
    );
    useAnimation(animation);
    useValueChanged(
      ui.value,
      (_, __) => ui.value ? animation.forward() : animation.reverse(),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Opacity(
          opacity: animation.value,
          child: BackButton(
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop()),
        ),
        title: Opacity(
          opacity: animation.value,
          child: Text(images[page.value].image.filename),
        ),
        backgroundColor: Colors.black.withOpacity(0.3 * animation.value),
        actions: Adaptive.isDesktop
            ? null
            : [
                Opacity(
                  opacity: animation.value,
                  child: IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => save(images[page.value])),
                ),
              ],
      ),
      floatingActionButton: !Adaptive.isDesktop
          ? null
          : Opacity(
              opacity: animation.value,
              child: FloatingActionButton(
                mini: true,
                heroTag: null,
                elevation: 0,
                hoverElevation: 0,
                highlightElevation: 0,
                focusElevation: 0,
                backgroundColor: Colors.transparent,
                child: const Icon(Icons.save),
                onPressed: () => save(images[page.value]),
              ),
            ),
      floatingActionButtonLocation: Adaptive.isDesktop
          ? FloatingActionButtonLocation.miniEndFloat
          : FloatingActionButtonLocation.endFloat,
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => ui.value = !ui.value,
            onSecondaryTap: () =>
                Navigator.of(context, rootNavigator: true).pop(),
            child: Dismissible(
              key: Key('$index'),
              direction: dismissible.value
                  ? DismissDirection.up
                  : DismissDirection.none,
              dismissThresholds: const {DismissDirection.up: 0.1},
              onUpdate: (d) {
                if (d.reached && !d.previousReached) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  layoutHeight.value = constraints.maxHeight;
                  return PhotoViewGallery.builder(
                    backgroundDecoration: const BoxDecoration(),
                    pageController: pageController,
                    itemCount: images.length,
                    onPageChanged: (index) => page.value = index,
                    builder: (_, index) => PhotoViewGalleryPageOptions(
                      imageProvider: images[index].image,
                      controller: photoViewDismissibles[index].controller,
                      // scaleStateController: scaleStateController,
                      initialScale: PhotoViewComputedScale.contained,
                      minScale: PhotoViewComputedScale.contained * 0.2,
                      maxScale: PhotoViewComputedScale.covered * 4.0,
                      heroAttributes:
                          PhotoViewHeroAttributes(tag: '$tag + $index'),
                    ),
                  );
                },
              ),
            ),
          ),
          !Adaptive.isDesktop
              ? Container()
              : Opacity(
                  opacity: animation.value,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          mini: true,
                          heroTag: null,
                          elevation: 0,
                          hoverElevation: 0,
                          highlightElevation: 0,
                          focusElevation: 0,
                          backgroundColor: Colors.transparent,
                          child: const Icon(Icons.arrow_back),
                          onPressed: () => pageController.animateToPage(
                              (page.value - 1).clamp(0, images.length),
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOutCubic),
                        ),
                        FloatingActionButton(
                          mini: true,
                          heroTag: null,
                          elevation: 0,
                          hoverElevation: 0,
                          highlightElevation: 0,
                          focusElevation: 0,
                          backgroundColor: Colors.transparent,
                          child: const Icon(Icons.arrow_forward),
                          onPressed: () => pageController.animateToPage(
                              (page.value + 1).clamp(0, images.length),
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOutCubic),
                        ),
                      ],
                    ),
                  ),
                ),
          Opacity(
            opacity: animation.value,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SmoothPageIndicator(
                  controller: pageController, // PageController
                  count: images.length,
                  effect: WormEffect(
                    dotWidth: 12,
                    dotHeight: 12,
                    type: WormType.thin,
                    dotColor: colorScheme.primary.withOpacity(0.3),
                    activeDotColor: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void save(PostImage image) async {
    var filename = sanitizeFilename(image.image.filename);
    var mime = MediaType.guessFromFileName(image.image.filename);
    Adaptive.saveBinary(image.image.data, 'Save Image', filename, mime.text);
  }
}
