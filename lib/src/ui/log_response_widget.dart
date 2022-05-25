import 'package:dio_logs_manager/src/data/models/net_options.dart';
import 'package:dio_logs_manager/src/ui/log_request_widget.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../utils/copy_clipboard.dart';
import '../utils/json_utils.dart';
import 'components/json_view.dart';
import 'components/json_viewer.dart';

///LogResponseWidget Page where [ResOptions] info is shown
class LogResponseWidget extends StatefulWidget {
  final NetOptions netOptions;

  const LogResponseWidget(this.netOptions, {Key? key}) : super(key: key);

  @override
  LogResponseWidgetState createState() => LogResponseWidgetState();
}

class LogResponseWidgetState extends State<LogResponseWidget>
    with AutomaticKeepAliveClientMixin {
  bool isShowAll = false;
  double fontSize = 14;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final response = widget.netOptions.resOptions;
    final responseData = response?.data ?? 'no response';
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            // const SizedBox(width: 10),
            // Text(isShowAll ? 'shrink all' : 'expand all'),
            // Switch(
            //   value: isShowAll,
            //   onChanged: (check) {
            //     isShowAll = check;

            //     setState(() {});
            //   },
            // ),
            Expanded(
              child: Slider(
                value: fontSize,
                max: 30,
                min: 1,
                onChanged: (v) {
                  fontSize = v;
                  setState(() {});
                },
              ),
            ),
            const Text(
              'Tip: long press a key to copy the value to the clipboard',
              style: TextStyle(
                fontSize: 10,
                color: Colors.red,
              ),
            ),
          ],
        ),
        LogsParams(
          label: 'Headers',
          params: response?.headers,
          fontSize: fontSize,
        ),
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildResponse(context, responseData),
              ],
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildResponse(BuildContext context, dynamic data) {
    if (data is ResponseBody) {
      //Para los Stream AKA descarga de ficheros
      return const Text("Content type was Stream.");
    }
    return buildJsonView(context, 'Response.data', data, fontSize: fontSize);
  }

  @override
  bool get wantKeepAlive => true;
}
