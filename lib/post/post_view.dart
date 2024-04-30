import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../core/adaptive.dart';
import '../core/string_utils.dart';
import '../core/datetime_utils.dart';
import '../core/theme.dart';
import '../home/filter_controller.dart';
import '../home/home_controller.dart';
import 'capture_view.dart';
import 'gallery_view.dart';
import '../settings/settings.dart';
import 'post_controller.dart';
import 'thread_controller.dart';

class PostView extends HookConsumerWidget {
  const PostView({super.key});

  static var path = 'posts';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;

    var posts = ref.watch(postsProvider);
    var loader = ref.read(postsLoader);

    final scrollControl = ref.read(postListScrollProvider);
    ref.listen(postsProvider,
        (_, __) => scrollControl.jumpLastId((id) => loader.getIndex(id)));
    useEffect(() {
      ref.read(rightNavigator).onPathChanged = (old, now) {
        if (old == PostView.path) {
          scrollControl.saveLast((i) => loader.getId(i));
        }
      };
      return null;
      // return () => scrollControl.saveLast((i) => loader.getId(i));
    });

    useAutomaticKeepAlive();

    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTap: () => ref.read(postsLoader).select(null),
        child: Stack(
          children: [
            const PostProgress(),
            Padding(
              padding: const EdgeInsets.all(4),
              child: CustomMaterialIndicator(
                displacement: 20,
                withRotation: false,
                backgroundColor: Colors.transparent,
                onRefresh: () async {
                  Future.delayed(
                      Durations.short4, () => ref.read(threadsLoader).next());
                  return Future.value();
                },
                indicatorBuilder: (context, controller) {
                  return Opacity(
                    opacity: (controller.value / 0.5).clamp(0.0, 1.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: colorScheme.surfaceVariant,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: colorScheme.outline.withOpacity(0.4))),
                          child: SizedBox.square(
                              dimension: 40,
                              child: RotatedBox(
                                  quarterTurns:
                                      Settings.nextThreadDirection.val ==
                                              NextDirection.newer
                                          ? 0
                                          : 2,
                                  child: const Icon(Icons.double_arrow))),
                        ),
                        OverflowBox(
                          maxWidth: constraints.maxWidth * 0.8,
                          maxHeight: 128,
                          child: const Align(
                            alignment: Alignment.bottomCenter,
                            child: PostNext(true),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: ScrollablePositionedList.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  initialScrollIndex: loader.getIndex(scrollControl.lastId),
                  initialAlignment: scrollControl.lastOffset,
                  itemScrollController: scrollControl.itemScrollController,
                  itemPositionsListener: scrollControl.itemPositionsListener,
                  itemCount: posts.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= posts.length) {
                      return const SizedBox(height: 80);
                    }
                    var post = posts[index];
                    return PostTile(key: ValueKey(post.post.messageId), post);
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: Adaptive.useTwoPaneUI
                    ? EdgeInsets.only(
                        right: Adaptive.isDesktop ? 100 : 130, bottom: 48)
                    : const EdgeInsets.only(right: 74, bottom: 52),
                child: Visibility(
                    visible: Settings.nextTitle.val,
                    child: const PostNext(false)),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class PostProgress extends HookConsumerWidget {
  const PostProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var posts = ref.watch(postsProvider);
    var loader = ref.read(postsLoader);
    useListenable(loader.progress);
    return AnimatedOpacity(
      opacity: posts.isEmpty ||
              loader.progress.value == 0 ||
              loader.progress.value == posts.length
          ? 0
          : 1,
      duration: Durations.long1,
      child: TweenAnimationBuilder<double>(
          key: ValueKey(posts.firstOrNull?.post.threadId),
          duration: Durations.short4,
          tween: Tween<double>(
            begin: 0,
            end: posts.isEmpty ? 0 : loader.progress.value / posts.length,
          ),
          builder: (context, value, _) {
            return LinearProgressIndicator(
              value: value,
              borderRadius: BorderRadius.circular(4),
            );
          }),
    );
  }
}

class PostNext extends HookConsumerWidget {
  const PostNext(this.showNoMore, {super.key});

  final bool showNoMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var theme = Theme.of(context);

    ref.watch(selectedThreadProvider);
    var loader = ref.read(postsLoader);
    var next = ref.read(threadsLoader).getNext();
    var text = next == null ? 'No more' : next.thread.subject;

    useListenable(loader.unread);
    useListenable(Settings.nextThreadDirection);

    return AnimatedSwitcher(
      duration: Durations.short4,
      child: (!showNoMore && next == null) || loader.unread.value > 0
          ? const SizedBox.shrink()
          : Card(
              key: ValueKey(text),
              elevation: 2,
              color: colorScheme.surfaceVariant,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ),
    );
  }
}

class PostTile extends HookConsumerWidget {
  const PostTile(this.data, {super.key});

  final PostData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var theme = Theme.of(context).extension<NGroupTheme>()!;

    var postId = data.post.messageId;
    ref.watch(postChangeProvider(postId));
    var selected = ref.read(selectedPostProvider) == postId;
    var state = data.state;

    var filters = ref.read(filterProvider);
    var hide = (state.inside &&
            filters.filterPost(data.parent!) &&
            !(selected && CaptureView.of(context))) ||
        state.load == PostLoadState.waiting ||
        !filters.filterPost(data);

    useListenable(Listenable.merge(
        [filters, ...filters.filters.where((e) => e.useInPost)]));

    return AnimatedCrossFade(
      duration: Durations.short4,
      sizeCurve: Curves.easeOutCirc,
      crossFadeState:
          hide ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: const SizedBox.shrink(),
      secondChild: Padding(
        padding: const EdgeInsets.all(4),
        child: GestureDetector(
          onTap: () => ref.read(postsLoader).select(data),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                  style: selected && !CaptureView.of(context)
                      ? BorderStyle.solid
                      : BorderStyle.none,
                  color: colorScheme.outline,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignCenter),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: colorScheme.tertiaryContainer,
                  elevation: 1,
                  margin: const EdgeInsets.all(0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              WidgetSpan(child: PostState(data)),
                              TextSpan(
                                  text: '${data.post.from.sender} ',
                                  style: TextStyle(color: theme.sender)),
                              const WidgetSpan(child: SizedBox(width: 4)),
                              TextSpan(
                                text: data.post.dateTime.toLocal().string,
                                style: TextStyle(
                                    color: colorScheme.onTertiaryContainer),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textScaler: TextScaler.linear(
                              Settings.contentScale.val / 100),
                        ),
                        const Spacer(),
                        Text.rich(
                          TextSpan(text: '#${data.index + 1}'),
                          textScaler: TextScaler.linear(
                              Settings.contentScale.val / 100),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 1,
                  margin: const EdgeInsets.all(0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: PostBody(data),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PostState extends ConsumerWidget {
  const PostState(this.data, {super.key});

  final PostData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context).extension<NGroupTheme>()!;
    var state = data.state;

    Widget widget = const SizedBox.shrink();
    if (CaptureView.of(context)) return widget;

    if (state.isRead) {
      widget = Padding(
        padding: const EdgeInsets.only(right: 4, top: 2, bottom: 1),
        child: Icon(Icons.check,
            size: 16, color: state.isNew ? theme.isNew! : theme.isRead!),
      );
    } else if (state.isNew) {
      widget = Padding(
        padding: const EdgeInsets.only(right: 4, top: 2, bottom: 3),
        child: Icon(Icons.circle, size: 12, color: theme.isNew!),
      );
    }
    return widget;
  }
}

class PostBody extends ConsumerWidget {
  const PostBody(this.data, {super.key});

  final PostData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var body = data.body;
    var state = data.state;
    var filters = ref.read(filterProvider);
    var quote = ref.read(postsLoader).getQuoteData(data);

    var quoteBody = [
      if (quote != null) PostQuote(quote),
      if (body != null && body.text.isNotEmpty) PostBodyText(data, false),
    ];

    var list = [
      if (body == null)
        const Center(
            child: SizedBox.square(
                dimension: 50, child: CircularProgressIndicator()))
      else ...[
        if (quoteBody.isNotEmpty)
          Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: quoteBody),
        if (body.links.any((e) => e.enabled)) PostLinkPreviews(data),
        if (body.images.isNotEmpty) PostImages(data),
        if (body.files.isNotEmpty) PostFiles(data),
        if (state.reply.where((e) => e.state.inside).any((e) =>
            e.state.load == PostLoadState.loading ||
            (e.body != null && filters.filterPost(e))))
          PostShortReply(data),
      ],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list
          .expand((e) sync* {
            yield const Divider();
            yield e;
          })
          .skip(1)
          .toList(),
    );
  }
}

class PostQuote extends StatelessWidget {
  const PostQuote(this.data, {super.key});

  final PostData data;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).extension<NGroupTheme>()!;
    var quote = data.body?.text.noLinebreak ?? '';
    if (quote.isEmpty) quote = 'No content.';
    return Card(
      color: theme.quote,
      shadowColor: Color.lerp(theme.quote, Colors.black, 0.8),
      elevation: 1,
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(' ${data.post.from.sender} ',
              style: TextStyle(color: theme.sender!.withOpacity(0.8))),
          Flexible(
            child: Card(
              margin: const EdgeInsets.all(1),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: Text(' $quote ',
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}

class PostShortReply extends ConsumerWidget {
  const PostShortReply(this.data, {super.key});

  final PostData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var state = data.state;
    var filters = ref.read(filterProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...state.reply.where((e) => e.state.inside && e.body != null).map(
          (e) {
            var selected = ref.read(selectedPostProvider) == e.post.messageId;
            return AnimatedCrossFade(
              duration: Durations.short4,
              sizeCurve: Curves.easeOutCirc,
              crossFadeState: !filters.filterPost(e)
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: const SizedBox.shrink(),
              secondChild: GestureDetector(
                onTap: () => ref.read(postsLoader).select(e),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(
                        style: selected && !CaptureView.of(context)
                            ? BorderStyle.solid
                            : BorderStyle.none,
                        color: colorScheme.outline,
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignInside),
                  ),
                  child: PostBodyText(e, true),
                ),
              ),
            );
          },
        ),
        if (state.reply.any(
            (e) => e.state.inside && e.state.load == PostLoadState.loading))
          const Center(
            child: SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2)),
          ),
      ],
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  const CustomScrollBehavior();
  @override
  Widget buildScrollbar(context, child, details) => child;
}

class PostBodyText extends HookConsumerWidget {
  const PostBodyText(this.data, this.short, {super.key});

  final PostData data;
  final bool short;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var theme = Theme.of(context).extension<NGroupTheme>()!;
    var filters = ref.read(filterProvider);

    final more = useState(false);
    final clearSelection = useState(0);

    var text = data.body?.text ?? '';
    if (short) text = text.noLinebreak;
    text += ' ';
    var hide = Settings.hideText.val;

    var span = TextSpan(children: [
      if (data.state.inside && filters.filterPost(data.parent!)) ...[
        WidgetSpan(child: PostState(data)),
        TextSpan(
            text: '${data.post.from.sender} ',
            style: TextStyle(color: theme.sender)),
      ],
      if (data.state.error)
        WidgetSpan(
            child: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(Icons.error, size: 18, color: colorScheme.error),
        )),
      LinkifySpan(
          text: text,
          style: data.state.error ? TextStyle(color: colorScheme.error) : null,
          linkStyle: const TextStyle(
            color: Colors.blueAccent,
            decoration: TextDecoration.underline,
          ),
          onOpen: (link) => launchUrlString(link.url))
    ]);

    return VisibilityDetector(
      key: Key('${data.post.messageId} body'),
      onVisibilityChanged: (info) {
        if (context.mounted) ref.read(postsLoader).setVisible(data, info);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tp = TextPainter(
              text: TextSpan(text: text),
              textDirection: Directionality.of(context));
          tp.layout(maxWidth: constraints.maxWidth);
          final length = tp.computeLineMetrics().length;
          return GestureDetector(
            onLongPress: !Adaptive.isDesktop
                ? null
                : () => ref.read(postsLoader).toggleSelectable(data),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!Adaptive.isDesktop)
                  SelectionArea(
                    key: ValueKey('${clearSelection.value}'),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(postsLoader).select(data);
                        clearSelection.value++;
                      },
                      child: Text.rich(
                        span,
                        maxLines:
                            more.value || CaptureView.of(context) ? null : hide,
                        textScaler:
                            TextScaler.linear(Settings.contentScale.val / 100),
                      ),
                    ),
                  )
                else if (data.state.selectable)
                  ScrollConfiguration(
                    behavior: const CustomScrollBehavior().copyWith(
                        scrollbars: false,
                        physics: const NeverScrollableScrollPhysics()),
                    child: SelectableText.rich(
                      span,
                      maxLines: short ||
                              length <= hide ||
                              more.value ||
                              CaptureView.of(context)
                          ? null
                          : hide,
                      onTap: () => ref.read(postsLoader).select(data),
                      contextMenuBuilder: (_, state) =>
                          AdaptiveTextSelectionToolbar.buttonItems(
                              anchors: state.contextMenuAnchors,
                              buttonItems: state.contextMenuButtonItems),
                      textScaler:
                          TextScaler.linear(Settings.contentScale.val / 100),
                    ),
                  )
                else
                  Text.rich(
                    span,
                    maxLines:
                        more.value || CaptureView.of(context) ? null : hide,
                    textScaler:
                        TextScaler.linear(Settings.contentScale.val / 100),
                  ),
                if (!more.value && length > hide && !CaptureView.of(context))
                  Text.rich(
                    TextSpan(
                      text: '\n${length - hide} lines is hidden. ',
                      style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                            text: 'Show more',
                            style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => more.value = true),
                        const TextSpan(text: ' ')
                      ],
                    ),
                    textScaler:
                        TextScaler.linear(Settings.contentScale.val / 100),
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}

class PostFiles extends ConsumerWidget {
  const PostFiles(this.data, {super.key});

  final PostData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    return VisibilityDetector(
      key: Key('${data.post.messageId} file'),
      onVisibilityChanged: (info) {
        if (context.mounted) ref.read(postsLoader).setVisible(data, info);
      },
      child: Center(
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            ...data.body!.files.map((e) => ActionChip(
                  label: Text(e.filename),
                  avatar: const Icon(Icons.attach_file),
                  elevation: 1,
                  pressElevation: 2,
                  side:
                      BorderSide(color: colorScheme.outline.withOpacity(0.12)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  onPressed: () => Adaptive.saveBinary(
                      e.data!, 'Save attachment', e.filename, null),
                ))
          ],
        ),
      ),
    );
  }
}

class PostImages extends ConsumerWidget {
  const PostImages(this.data, {super.key});

  final PostData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    return VisibilityDetector(
      key: Key('${data.post.messageId} image'),
      onVisibilityChanged: (info) {
        if (context.mounted) ref.read(postsLoader).setVisible(data, info);
      },
      child: Center(
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            ...data.body!.images.map(
              (e) => Card(
                shape: RoundedRectangleBorder(
                    side:
                        BorderSide(color: colorScheme.outline.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(8)),
                child: SizedBox(
                  height: Settings.smallPreview.val ? 100 : null,
                  child: GalleryItem(e.id, 'post-image'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostLinkPreviews extends StatelessWidget {
  const PostLinkPreviews(this.data, {super.key});

  final PostData data;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var links = data.body!.links.where((e) => e.enabled).toList();
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: links.length * 300),
        child: MasonryGridView.extent(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          maxCrossAxisExtent: 300,
          physics: const ClampingScrollPhysics(),
          itemCount: links.length,
          itemBuilder: (_, index) {
            var e = links[index];
            return Card(
              color: colorScheme.surfaceVariant,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(8)),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return SizedBox(
                    width: 300,
                    height: e.image != null ? 200 : null,
                    child: InkWell(
                      onTap: () => launchUrlString(e.url),
                      child: !e.ready
                          ? const SizedBox(
                              height: 200,
                              child: Center(
                                child: SizedBox.square(
                                    dimension: 50,
                                    child: CircularProgressIndicator()),
                              ),
                            )
                          : Stack(
                              fit: StackFit.loose,
                              children: [
                                if (e.image != null)
                                  Center(
                                    child: Ink.image(
                                      image: e.image!,
                                      fit: BoxFit.contain,
                                      onImageError: (_, __) =>
                                          setState(() => e.image = null),
                                    ),
                                  ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Ink(
                                      decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer
                                              .withOpacity(0.8)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          e.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    if (e.image != null) const Spacer(),
                                    Ink(
                                      decoration: BoxDecoration(
                                          color: colorScheme.tertiaryContainer
                                              .withOpacity(0.8)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          e.description,
                                          maxLines: e.image == null ? null : 2,
                                          overflow: e.image == null
                                              ? null
                                              : TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
