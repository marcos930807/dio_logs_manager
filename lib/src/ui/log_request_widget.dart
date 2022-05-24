import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_logs_manager/src/data/models/net_options.dart';
import 'package:dio_logs_manager/src/utils/copy_clipboard.dart';
import 'package:dio_logs_manager/src/utils/time_utils.dart';
import 'package:flutter/material.dart';

import '../utils/json_utils.dart';
import 'components/json_view.dart';

class LogRequestWidget extends StatefulWidget {
  final NetOptions netOptions;

  const LogRequestWidget(this.netOptions);

  @override
  _LogRequestWidgetState createState() => _LogRequestWidgetState();
}

class _LogRequestWidgetState extends State<LogRequestWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final reqOpt = widget.netOptions.reqOptions!;
    final resOpt = widget.netOptions.resOptions;
    final requestTime = getTimeStr(reqOpt.requestTime!);
    final responseTime =
        getTimeStr(resOpt?.responseTime ?? reqOpt.requestTime!);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Tip: long press a key to copy the value to the clipboard',
              style: TextStyle(fontSize: 10, color: Colors.red),
            ),
            ElevatedButton(
              onPressed: () {
                copyClipboard(
                    context,
                    'url:${reqOpt.url}\nmethod:${reqOpt.method}\nrequestTime:$requestTime\nresponseTime:$responseTime\n'
                    'duration:${resOpt?.duration ?? 0}ms\n${dataFormat(reqOpt.data)}'
                    '\nparams:${toJson(reqOpt.params)}\nheader:${reqOpt.headers}');
              },
              child: const Text('Copy all'),
            ),
            _buildKeyValue('Url ', reqOpt.url),
            _buildKeyValue('Method ', reqOpt.method),
            _buildKeyValue('RequestTime ', requestTime),
            _buildKeyValue('ResponseTime ', responseTime),
            _buildKeyValue('Duration ', '${resOpt?.duration ?? 0}ms'),
            _buildParam(reqOpt.data),
            _buildJsonView('Params ', reqOpt.params),
            _buildJsonView('Header ', reqOpt.headers),
          ],
        ),
      ),
    );
  }

  Widget _buildJsonView(key, json) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onLongPress: () {
            copyClipboard(context, toJson(json));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: _getDefText('$key:'),
          ),
        ),
        JsonView(json: json),
      ],
    );
  }

  Widget _buildKeyValue(k, v) {
    Widget w = _getDefText('$k: ${v is String ? v : v?.toString()}');
    if (k != null) {
      w = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: () {
          copyClipboard(context, v);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: w,
        ),
      );
    }
    return w;
  }

  Text _getDefText(String str) {
    return Text(
      str,
      style: const TextStyle(fontSize: 15),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Map? formDataMap;
  Widget _buildParam(dynamic data) {
    if (data is Map) {
      return _buildJsonView('body', data);
    } else if (data is FormData) {
      formDataMap = Map()
        ..addEntries(data.fields)
        ..addEntries(data.files);
      return _getDefText('formdata:${map2Json(formDataMap)}');
    } else if (data is String) {
      try {
        var decodedMap = json.decode(data);
        return _buildJsonView('body', decodedMap);
      } catch (e) {
        return Text('body: $data');
      }
    } else {
      return const SizedBox();
    }
  }

  String dataFormat(dynamic data) {
    if (data is FormData) {
      return 'formdata:${map2Json(formDataMap)}';
    } else {
      return 'body:${toJson(data)}';
    }
  }
}
