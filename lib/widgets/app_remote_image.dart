import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../post/gallery_view.dart';
import '../post/post_controller.dart';

class RemoteImage extends HookConsumerWidget {
  const RemoteImage(this.url, {super.key, this.width, this.height});

  final String url;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var index = ref.watch(postImagesProvider
        .select((images) => images.indexWhere((e) => e.url == url)));
    return index == -1
        ? const Align(
            alignment: Alignment.center,
            child: SizedBox.square(
              dimension: 50,
              child: CircularProgressIndicator(),
            ),
          )
        : GalleryItem(index, url);
  }
}
