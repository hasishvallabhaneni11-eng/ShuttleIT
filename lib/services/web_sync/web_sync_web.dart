import 'dart:html' as html;

void notifyWebSync(String key, String value) {
  try {
    html.window.localStorage[key] = value;
  } catch (_) {}
}

void listenWebSync(void Function(String key, String? value) onSync) {
  try {
    html.window.onStorage.listen((event) {
      if (event.key != null) {
        onSync(event.key!, event.newValue);
      }
    });
  } catch (_) {}
}

String? getWebSync(String key) {
  try {
    return html.window.localStorage[key];
  } catch (_) {
    return null;
  }
}
