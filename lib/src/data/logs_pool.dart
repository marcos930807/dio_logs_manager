import 'dart:collection';

import 'package:dio_logs_manager/src/data/models/net_options.dart';

import 'linked_hash_map_notifier.dart';
import 'models/err_options.dart';
import 'models/req_options.dart';
import 'models/res_options.dart';

/// MemoryLogs Pool
class LogPoolManager {
  late LinkedHashMapNotifier<String, NetOptions> logMapNotifier;
  late List<String> keys;

  /// max count logs
  int maxCount = 50;
  static LogPoolManager? _instance;

  LogPoolManager._singleton() {
    logMapNotifier = LinkedHashMapNotifier(LinkedHashMap<String, NetOptions>());
    keys = <String>[];
  }

  static LogPoolManager? getInstance() {
    _instance ??= LogPoolManager._singleton();
    return _instance;
  }

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
    if (logMapNotifier.length >= maxCount) {
      logMapNotifier.remove(keys.last);
      keys.removeLast();
    }
    var key = options.id.toString();
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
