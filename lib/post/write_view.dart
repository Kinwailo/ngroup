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
    var colorScheme = Theme.of(context).colorScheme;
    var controller = ref.read(writeController);

    final all = useState(false);
    useListenable(controller.data);

    void quoteListener() => all.value = true;
    useEffect(() {
      controller.quote.addListener(quoteListener);
      return () => controller.quote.removeListener(quoteListener);
    });

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
              HookBuilder(builder: (context) {
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
                            ...Settings.identities.val.asMap().entries.map(
                                (e) => DropdownMenuItem(
                                    value: e.key,
                                    child: Text(
                                        '${e.value['name']} <${e.value['email']}>'))),
                          ],
                          onChanged: (int? newValue) {
                            controller.identity.value = newValue ?? -1;
                          },
                        ),
                        if (controller.identity.value == -1) ...[
                          TextField(
                            decoration:
                                const InputDecoration(labelText: 'Name'),
                            controller: controller.name,
                          ),
                          TextField(
                            decoration:
                                const InputDecoration(labelText: 'Email'),
                            controller: controller.email,
                          ),
                        ],
                        TextField(
                          decoration:
                              const InputDecoration(labelText: 'Subject'),
                          controller: controller.subject,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Stack(
                    children: [
                      TextField(
                        maxLines: null,
                        decoration: const InputDecoration(labelText: 'Content'),
                        controller: controller.body,
                      ),
                      HookBuilder(builder: (context) {
                        useListenable(controller.body);
                        return Align(
                          alignment: AlignmentDirectional.topEnd,
                          child: IconButton(
                            splashRadius: 20,
                            icon: const Icon(Icons.clear),
                            onPressed: controller.body.text.isEmpty
                                ? null
                                : controller.body.clear,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Stack(
                    children: [
                      TextField(
                        maxLines: null,
                        decoration:
                            const InputDecoration(labelText: 'Signature'),
                        controller: controller.signature,
                      ),
                      HookBuilder(builder: (context) {
                        useListenable(controller.enableSignature);
                        return Align(
                          alignment: AlignmentDirectional.topEnd,
                          child: Checkbox(
                              value: controller.enableSignature.value,
                              onChanged: (v) =>
                                  controller.enableSignature.value = v!),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              if (controller.data.value != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              maxLines: null,
                              decoration:
                                  const InputDecoration(labelText: 'Quote'),
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
                                          ..onTap =
                                              () => controller.quoteAll()),
                                    const TextSpan(text: ' ')
                                  ],
                                ),
                                textScaler: TextScaler.linear(
                                    Settings.contentScale.val / 100),
                              )
                          ],
                        ),
                        HookBuilder(builder: (context) {
                          useListenable(controller.enableQuote);
                          return Align(
                            alignment: AlignmentDirectional.topEnd,
                            child: Checkbox(
                                value: controller.enableQuote.value,
                                onChanged: (v) =>
                                    controller.enableQuote.value = v!),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              HookBuilder(builder: (context) {
                useListenable(controller.files);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Stack(
                      children: [
                        Center(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              ...controller.files.value.map(
                                (e) => SizedBox(
                                  height: 100,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    child: InkWell(
                                      onTap: () => controller.removeFile(e),
                                      child: Image(
                                        image: MemoryImage(e.bytes!),
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.medium,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
              }),
              const SizedBox(height: 48)
            ],
          ),
        ),
      ),
    );
  }
}
