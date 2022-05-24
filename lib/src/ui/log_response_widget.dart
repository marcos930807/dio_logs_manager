import 'package:dio_logs_manager/src/data/models/net_options.dart';
import 'package:flutter/material.dart';

import '../utils/copy_clipboard.dart';
import '../utils/json_utils.dart';
import 'components/json_view.dart';

class LogResponseWidget extends StatefulWidget {
  final NetOptions netOptions;

  const LogResponseWidget(this.netOptions);

  @override
  _LogResponseWidgetState createState() => _LogResponseWidgetState();
}

class _LogResponseWidgetState extends State<LogResponseWidget>
    with AutomaticKeepAliveClientMixin {
  bool isShowAll = false;
  double fontSize = 14;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final response = widget.netOptions.resOptions;
    final json = response?.data ?? 'no response';
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            const SizedBox(width: 10),
            Text(isShowAll ? 'shrink all' : 'expand all'),
            Switch(
              value: isShowAll,
              onChanged: (check) {
                isShowAll = check;

                setState(() {});
              },
            ),
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
          ],
        ),
        const Text(
          'Tip: long press a key to copy the value to the clipboard',
          style: TextStyle(
            fontSize: 10,
            color: Colors.red,
          ),
        ),
        _buildJsonView('Headers:', response?.headers),
        _buildJsonView('Response.data:', json),
      ],
    ));
  }

  Widget _buildJsonView(key, json) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ElevatedButton(
          onPressed: () {
            copyClipboard(context, toJson(json));
          },
          child: const Text('Copy json'),
        ),
        Text(
          '$key',
          style: TextStyle(
            fontSize: fontSize,
          ),
        ),
        JsonView(
          json: json,
          isShowAll: isShowAll,
          fontSize: fontSize,
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
