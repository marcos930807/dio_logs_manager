import 'package:flutter/material.dart';

import '../data/models/net_options.dart';

class LogErrorWidget extends StatefulWidget {
  final NetOptions netOptions;

  const LogErrorWidget(this.netOptions);

  @override
  _LogErrorWidgetState createState() => _LogErrorWidgetState();
}

class _LogErrorWidgetState extends State<LogErrorWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      height: double.infinity,
      child: Center(
        child: Text(widget.netOptions.errOptions?.errorMsg ?? 'no error'),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
