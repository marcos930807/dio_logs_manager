import 'dart:collection';

import 'package:dio_logs_manager/src/data/models/net_options.dart';

import 'linked_hash_map_notifier.dart';
import 'models/err_options.dart';
import 'models/req_options.dart';
import 'models/res_options.dart';

/// MemoryLogs Pool
class LogPoolManager {
  final LinkedHashMapNotifier<String, NetOptions> logMapNotifier =
      LinkedHashMapNotifier(LinkedHashMap<String, NetOptions>());

  /// Keys of [logMapNotifier], newest first. Kept in sync with the map so the
  /// oldest entry can be evicted once [maxCount] is reached.
  final List<String> keys = <String>[];

  /// max count logs
  int maxCount = 50;
  static LogPoolManager? _instance;

  LogPoolManager._singleton();

  static LogPoolManager getInstance() =>
      _instance ??= LogPoolManager._singleton();

  //Update Error
  void onError(ErrOptions err) {
    var key = err.id.toString();
    if (logMapNotifier.containsKey(key)) {
      logMapNotifier.update(key, (value) {
        value.errOptions = err;
        return value;
      });
    }
  }

  /// Add new [NetOptions] to Map
  ///
  void onRequest(ReqOptions options) {
    var key = options.id.toString();
    // Bail out on a key we already track. Inserting it again would push a
    // duplicate into [keys] while the map ignores it, drifting the two apart
    // until eviction starts dropping the wrong entries.
    if (logMapNotifier.containsKey(key)) return;

    while (logMapNotifier.length >= maxCount && keys.isNotEmpty) {
      logMapNotifier.remove(keys.removeLast());
    }
    keys.insert(0, key);
    logMapNotifier.putIfAbsent(key, () => NetOptions(reqOptions: options));
  }

  //Update Response
  void onResponse(ResOptions response) {
    var key = response.id.toString();
    if (logMapNotifier.containsKey(key)) {
      logMapNotifier.update(key, (value) {
        response.duration = response.responseTime!.millisecondsSinceEpoch -
            value.reqOptions!.requestTime!.millisecondsSinceEpoch;
        value.resOptions = response;
        return value;
      });
    }
  }

  ///Reset de Pool
  void clear() {
    logMapNotifier.clear();
    keys.clear();
  }
}
