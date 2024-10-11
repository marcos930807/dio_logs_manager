import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_logs_manager/src/data/models/net_options.dart';
import 'package:dio_logs_manager/src/ui/components/json_viewer.dart';
import 'package:dio_logs_manager/src/utils/copy_clipboard.dart';
import 'package:dio_logs_manager/src/utils/time_utils.dart';
import 'package:flutter/material.dart';

import '../utils/json_utils.dart';

///LogRequestWidget Page where [ReqOptions] info is shown
class LogRequestWidget extends StatefulWidget {
  final NetOptions netOptions;

  const LogRequestWidget(this.netOptions, {Key? key}) : super(key: key);

  @override
  LogRequestWidgetState createState() => LogRequestWidgetState();
}

class LogRequestWidgetState extends State<LogRequestWidget>
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
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      copyClipboard(
                          context,
                          'url:${reqOpt.url}\nmethod:${reqOpt.method}\nrequestTime:$requestTime\nresponseTime:$responseTime\n'
                          'duration:${resOpt?.duration ?? 0}ms\n${dataFormat(reqOpt.data)}'
                          '\nparams:${toJson(reqOpt.params)}\nheader:${reqOpt.headers}');
                    },
                    child: const Text('Copy all'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Expanded(
                    child: Text(
                      'Tip: press a key or long press Object to copy the value to the clipboard.',
                      style: TextStyle(fontSize: 10, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            _LogRequestGeneralInfo(
              netOptions: widget.netOptions,
            ),
            LogsParams(
              params: widget.netOptions.reqOptions?.headers,
              label: "Headers",
            ),
            _LogsRequestBody(data: reqOpt.data),
            LogsParams(
              params: reqOpt.params,
              label: "Params",
            ),
          ],
        ),
      ),
    );
  }

  Text _getDefText(String str) {
    return Text(
      str,
      style: const TextStyle(fontSize: 15),
    );
  }

  @override
  bool get wantKeepAlive => true;

  String dataFormat(dynamic data) {
    if (data is FormData) {
      var formDataMap = {}
        ..addEntries(data.fields)
        ..addEntries(data.files);
      return 'formdata:${map2Json(formDataMap)}';
    } else {
      return 'body:${toJson(data)}';
    }
  }
}

Widget _buildKeyValue(BuildContext context, String k, dynamic v) {
  return Row(
    children: [
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: () {
          copyClipboard(context, v);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            '$k: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      Flexible(child: Text('${v is String ? v : v?.toString()}'))
    ],
  );
}

Widget buildJsonView(BuildContext context, String key, dynamic data,
    {double fontSize = 14}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: () {
          copyClipboard(context, toJson(data));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            '$key: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      JsonViewer(
        data,
        fontSize: fontSize,
      ),
    ],
  );
}

class _LogRequestGeneralInfo extends StatelessWidget {
  const _LogRequestGeneralInfo({
    Key? key,
    required this.netOptions,
  }) : super(key: key);
  final NetOptions netOptions;

  @override
  Widget build(BuildContext context) {
    if (netOptions.reqOptions == null) return const SizedBox();
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildKeyValue(context, 'Url ', netOptions.reqOptions!.url),
            _buildKeyValue(context, 'Method ', netOptions.reqOptions!.method),
            _buildKeyValue(context, 'RequestTime ',
                getTimeStr(netOptions.reqOptions!.requestTime!)),
            _buildKeyValue(
                context,
                'ResponseTime ',
                getTimeStr(netOptions.resOptions?.responseTime ??
                    netOptions.reqOptions!.requestTime!)),
            _buildKeyValue(context, 'Duration ',
                '${netOptions.resOptions?.duration ?? 0}ms'),
          ],
        ),
      ),
    );
  }
}

class _LogsRequestBody extends StatelessWidget {
  const _LogsRequestBody({
    Key? key,
    required this.data,
  }) : super(key: key);
  final dynamic data;
  @override
  Widget build(BuildContext context) {
    if (data == null) return const SizedBox();
    Widget w = const SizedBox();
    if (data is Map) {
      w = buildJsonView(context, 'Body', data);
    } else if (data is FormData) {
      Map? formDataMap;
      formDataMap = {}
        ..addEntries(data.fields)
        ..addEntries(data.files);
      return Text('formdata:${map2Json(formDataMap)}');
    } else if (data is String) {
      try {
        var decodedMap = json.decode(data);
        return buildJsonView(context, 'Body', decodedMap);
      } catch (e) {
        return Text('Body: $data');
      }
    } else {
      return Text('Body: $data');
    }
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: w,
      ),
    );
  }
}

class LogsParams extends StatelessWidget {
  const LogsParams(
      {Key? key,
      required this.label,
      required this.params,
      this.fontSize = 14.0})
      : super(key: key);
  final String label;
  final Map<String, dynamic>? params;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    if (params == null) return const SizedBox();
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildJsonView(context, label, params, fontSize: fontSize),
          ],
        ),
      ),
    );
  }
}
