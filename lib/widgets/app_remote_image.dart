import 'dart:async';

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
    var timeout = false;
    return StatefulBuilder(
      builder: (context, setState) {
        Timer(Duration.zero, () {
          if (!context.mounted) return;
          var link = ref.read(postsLoader).getLinkPreview(url);
          if (link.ready && index == -1) setState(() => timeout = true);
        });
        Timer(Durations.extralong4, () {
          if (!context.mounted) return;
          if (index == -1) setState(() => timeout = true);
        });
        return timeout
            ? const Icon(Icons.error)
            : index == -1
                ? const Align(
                    alignment: Alignment.center,
                    child: SizedBox.square(
                      dimension: 50,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : SizedBox(
                    width: width,
                    height: height,
                    child: GalleryItem(index, url),
                  );
      },
    );
  }
}
