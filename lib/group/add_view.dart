import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ngroup/nntp/nntp_service.dart';

import '../core/adaptive.dart';
import '../database/models.dart';
import '../home/home_view.dart';
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

    var address = useTextEditingController();
    var port = useTextEditingController();
    var secure = useState(false);
    var user = useTextEditingController();
    var password = useTextEditingController();

    var charset = useTextEditingController();
    charset.addListener(() => selectionController.charset = charset.text);

    void setServerInfo() {
      var server = selectionController.server;
      server.address = address.text;
      server.port = int.tryParse(port.text) ?? -1;
      server.user = user.text.isEmpty ? null : user.text;
      server.password = password.text.isEmpty ? null : password.text;
    }

    void getServerInfo() {
      if (selectedServer == -1) {
        address.text = '';
        port.text = '';
        user.text = '';
        password.text = '';
        secure.value = false;
      } else {
        var server =
            servers.requireValue.where((e) => e.id == selectedServer).first;
        address.text = server.address;
        port.text = server.port < 0 ? '' : '${server.port}';
        user.text = server.user ?? '';
        password.text = server.password ?? '';
        secure.value = server.secure;
      }
    }

    String getServerTitle(Server server) {
      var port = server.port >= 0
          ? server.port
          : server.secure
              ? NNTPService.securePort
              : NNTPService.defaultPort;
      return '${server.address}:$port';
    }

    address.addListener(setServerInfo);
    port.addListener(setServerInfo);
    user.addListener(setServerInfo);
    password.addListener(setServerInfo);

    useEffect(() {
      getServerInfo();
      return null;
    }, []);
    useValueChanged(selectedServer, (_, __) => getServerInfo());
    useListenable(user);

    return SingleChildScrollView(
      child: Column(
        children: [
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
                    value: server.id, child: Text(getServerTitle(server)))),
              ],
              onChanged: (v) =>
                  ref.read(selectedServerProvider.notifier).state = v ?? -1,
            ),
          ),
          TextField(
            focusNode: selectionController.addressFocusNode,
            decoration: const InputDecoration(labelText: 'Address'),
            controller: address,
            enabled: selectedServer == -1,
          ),
          TextField(
            focusNode: selectionController.portFocusNode,
            decoration: InputDecoration(
                labelText: 'Port',
                hintText: port.text.isNotEmpty
                    ? null
                    : 'Default: ${secure.value ? '563' : '119'}',
                floatingLabelBehavior: FloatingLabelBehavior.always),
            controller: port,
            keyboardType: const TextInputType.numberWithOptions(),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            enabled: selectedServer == -1,
          ),
          CheckboxListTile(
            title: const Text('Secure Connection'),
            value: secure.value,
            onChanged: selectedServer != -1
                ? null
                : (v) => selectionController.server.secure = secure.value = v!,
            visualDensity: VisualDensity.compact,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          TextField(
            focusNode: selectionController.userFocusNode,
            decoration: const InputDecoration(
                labelText: 'User',
                hintText: 'Anonymous',
                floatingLabelBehavior: FloatingLabelBehavior.always),
            controller: user,
            enabled: selectedServer == -1,
          ),
          if (user.text.isNotEmpty)
            TextField(
              focusNode: selectionController.passwordFocusNode,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              controller: password,
              enabled: selectedServer == -1,
            ),
          TextField(
            focusNode: selectionController.charsetFocusNode,
            decoration: const InputDecoration(labelText: 'Charset'),
            controller: charset,
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
    var selectionController = ref.read(selectionProvider.notifier);

    var scrollController = useScrollController();
    var filter = useTextEditingController();
    selection = Map.fromEntries(
        selection.entries.where((e) => e.key.name.contains(filter.text)));
    useListenable(filter);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 72),
          child: ListView.builder(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            itemCount: selection.length,
            itemBuilder: (_, index) {
              var key = selection.keys.elementAt(index);
              return InkWell(
                onTap: () => selectionController.toggle(key),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    children: [
                      Text(
                        '${key.display} (${key.last - key.first + 1})',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Checkbox(
                        value: selection[key],
                        onChanged: (bool? value) =>
                            selectionController.toggle(key),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: TextField(
                  focusNode: selectionController.filterFocusNode,
                  controller: filter,
                  decoration: const InputDecoration(labelText: 'Filter')),
            )),
      ],
    );
  }
}
