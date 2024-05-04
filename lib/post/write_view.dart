import 'dart:math';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/adaptive.dart';
import '../settings/settings.dart';
import 'write_controller.dart';

class WriteView extends HookConsumerWidget {
  const WriteView({super.key});

  static var path = 'write';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var controller = ref.read(writeController);
    useListenable(controller.data);
    return SingleChildScrollView(
      controller: ScrollController(),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(Settings.contentScale.val / 100)),
        child: AdaptivePageView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const WriteIdentity(),
              const WriteContent(),
              const WriteSignature(),
              if (controller.data.value != null) const WriteQuote(),
              const WriteAttachment(),
              const SizedBox(height: 48)
            ],
          ),
        ),
      ),
    );
  }
}

class WriteIdentity extends HookConsumerWidget {
  const WriteIdentity({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var controller = ref.read(writeController);
    useListenable(controller.identity);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton(
              isExpanded: true,
              value: controller.identity.value,
              items: [
                const DropdownMenuItem(
                  value: -1,
                  child: Text('Enter Identity'),
                ),
                ...Settings.identities.val.asMap().entries.map((e) =>
                    DropdownMenuItem(
                        value: e.key,
                        child:
                            Text('${e.value['name']} <${e.value['email']}>'))),
              ],
              onChanged: (int? newValue) {
                controller.identity.value = newValue ?? -1;
              },
            ),
            if (controller.identity.value == -1) ...[
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                controller: controller.name,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                controller: controller.email,
              ),
            ],
            TextField(
              decoration: const InputDecoration(labelText: 'Subject'),
              controller: controller.subject,
            ),
          ],
        ),
      ),
    );
  }
}

class WriteContent extends HookConsumerWidget {
  const WriteContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var controller = ref.read(writeController);
    useListenable(controller.body);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            TextField(
              maxLines: null,
              decoration: const InputDecoration(labelText: 'Content'),
              controller: controller.body,
            ),
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: IconButton(
                splashRadius: 20,
                icon: const Icon(Icons.clear),
                onPressed:
                    controller.body.text.isEmpty ? null : controller.body.clear,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WriteSignature extends HookConsumerWidget {
  const WriteSignature({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var controller = ref.read(writeController);
    useListenable(controller.enableSignature);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            TextField(
              maxLines: null,
              decoration: const InputDecoration(labelText: 'Signature'),
              controller: controller.signature,
            ),
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: Checkbox(
                  value: controller.enableSignature.value,
                  onChanged: (v) => controller.enableSignature.value = v!),
            ),
          ],
        ),
      ),
    );
  }
}

class WriteQuote extends HookConsumerWidget {
  const WriteQuote({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var controller = ref.read(writeController);

    final all = useState(false);
    useListenable(controller.enableQuote);

    void quoteListener() => all.value = true;
    useEffect(() {
      controller.quote.addListener(quoteListener);
      return () => controller.quote.removeListener(quoteListener);
    });
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  maxLines: null,
                  decoration: const InputDecoration(labelText: 'Quote'),
                  controller: controller.quote,
                ),
                if (!all.value && controller.needChop())
                  RichText(
                    text: TextSpan(
                      text:
                          '${controller.charChopped()} characters is chopped. ',
                      style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                            text: 'Quote all',
                            style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => controller.quoteAll()),
                        const TextSpan(text: ' ')
                      ],
                    ),
                    textScaler:
                        TextScaler.linear(Settings.contentScale.val / 100),
                  )
              ],
            ),
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: Checkbox(
                  value: controller.enableQuote.value,
                  onChanged: (v) => controller.enableQuote.value = v!),
            ),
          ],
        ),
      ),
    );
  }
}

class WriteAttachment extends HookConsumerWidget {
  const WriteAttachment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var controller = ref.read(writeController);
    var selected = controller.selectedFile.value;

    final scale = useState(WriteController.scaleList.length - 1);
    final original = useState(true);
    final hqResize = useState(false);

    useListenable(controller.files);
    useListenable(controller.selectedFile);
    useListenable(controller.resizing);
    useValueChanged(selected, (_, void __) {
      scale.value = controller.imageData[selected]?.scale ??
          WriteController.scaleList.length - 1;
      original.value = controller.imageData[selected]?.original ?? true;
      hqResize.value = controller.imageData[selected]?.hqResize ?? false;
    });
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: controller.files.value
                        .map((e) => WriteFile(e))
                        .toList(),
                  ),
                ),
                if (controller.files.value.isNotEmpty) const Divider(),
                if (selected != null)
                  MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.noScaling),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        ...WriteController.scaleList
                            .mapIndexed((i, e) => ChoiceChip(
                                  label:
                                      Text('${(e * 100).toStringAsFixed(0)}%'),
                                  padding: const EdgeInsets.all(0),
                                  selected: !original.value && scale.value == i,
                                  onSelected: (v) {
                                    if (!v) return;
                                    if (controller.resizing.value) return;
                                    if (original.value || scale.value != i) {
                                      scale.value = i;
                                      original.value = false;
                                      controller.setImageScale(
                                          selected, i, false, hqResize.value);
                                    }
                                  },
                                )),
                        ChoiceChip(
                          label: const Text('Original'),
                          padding: const EdgeInsets.all(0),
                          selected: original.value,
                          onSelected: (v) {
                            if (!v) return;
                            if (controller.resizing.value) return;
                            if (original.value != v) {
                              original.value = v;
                              controller.setImageScale(
                                  selected, scale.value, true, hqResize.value);
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('HQ Resize'),
                          padding: const EdgeInsets.all(0),
                          selected: hqResize.value,
                          onSelected: (v) {
                            if (controller.resizing.value) return;
                            hqResize.value = v;
                            controller.setImageScale(
                                selected, scale.value, original.value, v);
                          },
                        ),
                        ActionChip(
                          label: const Text('Remove'),
                          padding: const EdgeInsets.all(0),
                          onPressed: () {
                            if (controller.resizing.value) return;
                            controller.removeFile(selected);
                          },
                        )
                      ],
                    ),
                  ),
              ],
            ),
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: IconButton(
                splashRadius: 20,
                icon: const Icon(Icons.attach_file),
                onPressed: controller.addFile,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WriteFile extends HookConsumerWidget {
  const WriteFile(this.file, {super.key});

  final PlatformFile file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var controller = ref.read(writeController);

    var data = controller.imageData[file];
    var scale = WriteController
        .scaleList[data?.scale ?? WriteController.scaleList.length - 1];
    var width = data?.info?.width ?? 0;
    var height = data?.info?.height ?? 0;
    var size = data?.bytes?.lengthInBytes ?? 0;

    var widthText = (width * scale).toStringAsFixed(0);
    var heightText = (height * scale).toStringAsFixed(0);
    var sizeText = size > (1024 * 1024)
        ? '${(size / (1024 * 1024)).toStringAsFixed(2)}M'
        : size > 1024
            ? '${(size / 1024).toStringAsFixed(2)}k'
            : size;

    useListenable(controller.resizing);
    return Container(
      height: 100,
      constraints: BoxConstraints(maxWidth: max(100, width * 100 / height)),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(
            style: controller.selectedFile.value == file
                ? BorderStyle.solid
                : BorderStyle.none,
            color: colorScheme.primary.withOpacity(0.8),
            width: 3,
            strokeAlign: BorderSide.strokeAlignOutside),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Material(
          child: IgnorePointer(
            ignoring: controller.resizing.value,
            child: InkWell(
              onTap: () => controller.selectedFile.value = file,
              child: Stack(
                fit: StackFit.loose,
                children: [
                  Center(
                    child: Ink.image(
                      image: MemoryImage(file.bytes!),
                      fit: BoxFit.contain,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Ink(
                          decoration: BoxDecoration(
                              color: colorScheme.tertiaryContainer
                                  .withOpacity(0.6)),
                          child: controller.resizing.value &&
                                  controller.selectedFile.value == file
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(4),
                                    child: SizedBox.square(
                                        dimension: 30,
                                        child: CircularProgressIndicator()),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('$widthText x $heightText'),
                                    Text('$sizeText'),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
