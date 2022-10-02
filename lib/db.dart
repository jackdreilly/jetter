import 'dart:convert';
import 'dart:html';

mixin Database {
  dynamic get(String key);
  set(String key, dynamic value);

  clear();
}
Database db() => DBImpl();

typedef JsonMap = Map<String, dynamic>;

class DBImpl with Database {
  final JsonMap records = jsonDecode(window.localStorage['db'] ?? '{}');
  @override
  dynamic get(String key) => records[key];
  @override
  set(String key, dynamic value) {
    records[key] = value;
    dump;
  }

  get dump {
    window.localStorage['db'] = jsonEncode(records);
  }

  @override
  clear() {
    records.clear();
    dump;
  }
}
