import 'dart:collection';

import 'package:dio_logs_manager/src/data/models/net_options.dart';
import 'package:flutter/material.dart';

import 'models/err_options.dart';
import 'models/req_options.dart';
import 'models/res_options.dart';

/// MemoryLogs Pool
class LogPoolManager {
  ///
  LinkedHashMap<String, NetOptions> get logMap => logMapNotifier.value;

  late ValueNotifier<LinkedHashMap<String, NetOptions>> logMapNotifier;
  late List<String> keys;

  /// max count logs
  int maxCount = 50;
  static LogPoolManager? _instance;

  LogPoolManager._singleton() {
    logMapNotifier = ValueNotifier(LinkedHashMap());
    keys = <String>[];
  }

  static LogPoolManager? getInstance() {
    _instance ??= LogPoolManager._singleton();
    return _instance;
  }

  //Update Error
  void onError(ErrOptions err) {
    var key = err.id.toString();
    if (logMap.containsKey(key)) {
      logMap.update(key, (value) {
        value.errOptions = err;
        return value;
      });
      logMapNotifier.notifyListeners();
    }
  }

  /// Add new [NetOptions] to Map
  ///
  void onRequest(ReqOptions options) {
    if (logMap.length >= maxCount) {
      logMap.remove(keys.last);
      keys.removeLast();
    }
    var key = options.id.toString();
    keys.insert(0, key);
    logMap.putIfAbsent(key, () => NetOptions(reqOptions: options));
    logMapNotifier.notifyListeners();
  }

  //Update Response
  void onResponse(ResOptions response) {
    var key = response.id.toString();
    if (logMap.containsKey(key)) {
      logMap.update(key, (value) {
        response.duration = response.responseTime!.millisecondsSinceEpoch -
            value.reqOptions!.requestTime!.millisecondsSinceEpoch;
        value.resOptions = response;
        return value;
      });
      logMapNotifier.notifyListeners();
    }
  }

  ///Reset de Pool
  void clear() {
    logMap.clear();
    keys.clear();
  }
}
