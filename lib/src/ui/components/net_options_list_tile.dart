import 'package:dio_logs_manager/src/data/models/net_options.dart';
import 'package:dio_logs_manager/src/ui/log_widget.dart';
import 'package:dio_logs_manager/src/utils/time_utils.dart';
import 'package:flutter/material.dart';

class NetOptionsListTile extends StatelessWidget {
  const NetOptionsListTile({
    Key? key,
    required this.item,
  }) : super(key: key);
  final NetOptions item;
  @override
  Widget build(BuildContext context) {
    var resOpt = item.resOptions;
    var reqOpt = item.reqOptions!;

    var requestTime = getTimeStr1(reqOpt.requestTime!);

    Color? textColor = (item.errOptions != null)
        ? Colors.red
        : Theme.of(context).textTheme.bodyLarge!.color;

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 0,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return LogWidget(item);
          }));
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (item.resOptions == null && item.errOptions == null) ...[
                const LinearProgressIndicator()
              ],
              Row(
                children: [
                  Icon(
                    Icons.link_rounded,
                    size: 15,
                    color: textColor,
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  Expanded(
                    child: Text(
                      'Url: ${reqOpt.url}',
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 2),
              Row(
                children: [
                  _buildStatusIcon(item),
                  Expanded(
                    child: Text(
                      'Status: ${resOpt?.statusCode}',
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 2),
              if (item.errOptions != null) ...[
                Text(
                  'Error: ${item.errOptions?.errorType}',
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
              ],
              const Divider(height: 2),
              Text(
                'RequestTime: $requestTime    Duration: ${resOpt?.duration ?? 0}ms',
                style: TextStyle(
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(NetOptions item) {
    var resOpt = item.resOptions;
    if (item.errOptions != null) {
      return const Padding(
        padding: EdgeInsets.only(right: 2),
        child: Icon(
          Icons.error_outline,
          size: 15,
          color: Colors.red,
        ),
      );
    } else if (resOpt == null || resOpt.statusCode == null) {
      return const SizedBox();
    } else if (resOpt.statusCode! >= 200 && resOpt.statusCode! < 210) {
      return const Padding(
        padding: EdgeInsets.only(right: 2),
        child: Icon(
          Icons.check_circle_outline,
          size: 15,
          color: Colors.green,
        ),
      );
    } else if (resOpt.statusCode! == 404) {
      return const Padding(
        padding: EdgeInsets.only(right: 2),
        child: Icon(
          Icons.not_interested,
          size: 15,
          color: Colors.red,
        ),
      );
    } else if (resOpt.statusCode! > 500) {
      return const Padding(
        padding: EdgeInsets.only(right: 2),
        child: Icon(
          Icons.error_outline,
          size: 15,
          color: Colors.red,
        ),
      );
    }
    return const SizedBox();
  }
}
