import 'package:flutter/material.dart';

class ProgressDialog {
  ProgressDialog(this.context);

  final BuildContext context;

  final message = ValueNotifier('');
  final prepare = ValueNotifier(true);
  final progress = ValueNotifier(0);
  final max = ValueNotifier(0);
  final completed = ValueNotifier(false);
  final error = ValueNotifier(false);

  var _closed = true;
  bool get closed => _closed;
  void Function()? onClosed;
  NavigatorState? navigatorState;

  void step(int step) {
    progress.value += step;
  }

  void close() {
    _closed = true;
    navigatorState?.pop();
    onClosed?.call();
  }

  void show() {
    var theme = Theme.of(context);
    navigatorState = Navigator.of(context, rootNavigator: true);
    _closed = false;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => PopScope(
        canPop: false,
        child: ListenableBuilder(
            listenable:
                Listenable.merge([completed, error, prepare, progress, max]),
            builder: (_, __) {
              if (completed.value) {
                Future.delayed(
                    const Duration(milliseconds: 1000), () => close());
              }
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        switch ((completed.value, error.value)) {
                          (true, _) => const Icon(Icons.check_circle,
                              size: 48, color: Colors.blueAccent),
                          (_, true) => const Icon(Icons.error,
                              size: 48, color: Colors.redAccent),
                          _ => SizedBox(
                              width: 48,
                              height: 48,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.blueGrey,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color?>(
                                          Colors.blueAccent),
                                  value: prepare.value
                                      ? null
                                      : progress.value / max.value,
                                ),
                              ),
                            ),
                        },
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              top: 8.0,
                              bottom: 8.0,
                            ),
                            child: ListenableBuilder(
                              listenable: message,
                              builder: (_, __) {
                                return Text(
                                  message.value,
                                  textAlign: TextAlign.center,
                                  // maxLines: 1,
                                  // overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize:
                                        theme.textTheme.bodyMedium!.fontSize!,
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: FontWeight.normal,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (error.value)
                      TextButton(
                          onPressed: () => close(), child: const Text('Ok'))
                  ],
                ),
              );
            }),
      ),
    );
  }
}
