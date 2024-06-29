import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RemoteImage extends HookConsumerWidget {
  const RemoteImage(this.url, {super.key, this.width, this.height});

  final String url;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Image.network(
      url,
      width: width,
      height: height,
    );
  }
}
