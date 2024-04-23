import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/adaptive.dart';
import '../home/home_view.dart';
import '../nntp/nntp_service.dart';
import 'add_controller.dart';

class AddPage extends StatelessWidget {
  const AddPage({super.key});

  static void show(BuildContext context) {
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (_) => const AddPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const HomeIcon(),
        title: const Text('Add new group'),
      ),
      body: const AddView(),
    );
  }
}

class AddView extends ConsumerWidget {
  const AddView({super.key});

  static var path = 'add';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var step = ref.watch(stepProvider);
    var stepController = ref.read(stepProvider.notifier);
    ref.watch(selectionProvider);

    return AdaptivePageView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 90,
            child: PrimaryScrollController(
              controller: ScrollController(),
              child: Stepper(
                type: StepperType.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                currentStep: step,
                controlsBuilder: (_, __) {
                  return Container();
                },
                steps: ['Server', 'Connect', 'Subscribe']
                    .asMap()
                    .entries
                    .map(
                      (e) => Step(
                        title: Text(e.value),
                        content: Container(),
                        isActive: stepController.isStepActive(e.key),
                        state: stepController.stepState(e.key),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: const [AddStep1(), AddStep2(), AddStep3()][step],
          ),
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: stepController.onCancel,
                    child: Text(stepController.cancelLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: stepController.onNext,
                    child: Text(stepController.nextLabel),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class AddStep1 extends HookConsumerWidget {
  const AddStep1({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var servers = ref.watch(serversProvider);
    var selectedServer = ref.watch(selectedServerProvider);
    var selectionController = ref.read(selectionProvider.notifier);

    var address = useTextEditingController(text: selectionController.address);
    address.addListener(() => selectionController.address = address.text);

    var port =
        useTextEditingController(text: selectionController.port.toString());
    port.addListener(() => selectionController.port =
        int.tryParse(port.text) ?? NNTPService.defaultPort);

    useValueChanged(selectedServer, (_, void __) {
      if (selectedServer == -1) {
        address.text = '';
        port.text = NNTPService.defaultPort.toString();
      } else {
        var server =
            servers.requireValue.where((e) => e.id == selectedServer).first;
        address.text = server.address;
        port.text = server.port.toString();
      }
    });

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          servers.when(
            loading: () => const Text('Loading server list...'),
            error: (e, st) => Text('Error: ${e.toString()}'),
            data: (data) => DropdownButton(
              isExpanded: true,
              value: selectedServer,
              items: [
                const DropdownMenuItem(
                    value: -1, child: Text("Add new server")),
                ...data.map((server) => DropdownMenuItem(
                    value: server.id,
                    child: Text('${server.address}:${server.port}'))),
              ],
              onChanged: (int? newValue) {
                ref.read(selectedServerProvider.notifier).state =
                    newValue ?? -1;
              },
            ),
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Address'),
            controller: address,
            enabled: selectedServer == -1,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Port'),
            controller: port,
            enabled: selectedServer == -1,
          ),
        ],
      ),
    );
  }
}

class AddStep2 extends ConsumerWidget {
  const AddStep2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var selection = ref.watch(selectionProvider);
    var theme = Theme.of(context);

    return Column(
      children: <Widget>[
        SizedBox(
          width: 60,
          height: 60,
          child: selection.when(
            loading: () => const CircularProgressIndicator(value: null),
            error: (_, __) => CircularProgressIndicator(
              value: 100,
              color: theme.colorScheme.error,
            ),
            data: (_) => const CircularProgressIndicator(value: 100),
          ),
        ),
        const SizedBox(height: 8),
        selection.when(
          loading: () => const Text('Connecting to server...'),
          error: (e, __) => Text('Cannot connect to server, ${e.toString()}',
              style: TextStyle(color: theme.colorScheme.error)),
          data: (_) => Text(
              'Connected to server, ${selection.requireValue.length} groups found on server.'),
        ),
      ],
    );
  }
}

class AddStep3 extends HookConsumerWidget {
  const AddStep3({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var selection = ref.watch(selectionProvider).requireValue;

    var scrollController = useScrollController();
    var filter = useTextEditingController();
    useListenable(filter);

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(top: 68, left: 8),
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          itemCount: selection.length,
          itemBuilder: (_, index) {
            var key = selection.keys.elementAt(index);
            return Visibility(
              visible: key['name'].toString().contains(filter.text),
              child: InkWell(
                onTap: () => ref.read(selectionProvider.notifier).toggle(key),
                child: Row(
                  children: [
                    Text(
                      '${key['name']} (${key['last'] - key['first'] + 1})',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Checkbox(
                      value: selection[key],
                      onChanged: (bool? value) =>
                          ref.read(selectionProvider.notifier).toggle(key),
                    )
                  ],
                ),
              ),
            );
          },
        ),
        Container(
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: TextField(
                  controller: filter,
                  decoration: const InputDecoration(labelText: 'Filter')),
            )),
      ],
    );
  }
}
