import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Publishes a JSON result on `window` so automated checks can read it.
void publishResult(String name, Object? result) {
  globalContext.setProperty(name.toJS, jsonEncode(result).toJS);
}

/// True when the page URL asks [spike] to run automatically.
bool autoRun(String spike) {
  final q = Uri.base.queryParameters;
  return q['spike'] == spike && q['auto'] == '1';
}
