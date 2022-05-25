import 'dart:collection';

import 'package:dio_logs_manager/src/data/logs_pool.dart';
import 'package:dio_logs_manager/src/data/models/net_options.dart';
import 'package:dio_logs_manager/src/ui/components/net_options_list_tile.dart';
import 'package:flutter/material.dart';

import 'components/overlay_draggable_button.dart';

///Main Page where [NetOptions] are listed
class LogsPage extends StatefulWidget {
  const LogsPage({Key? key}) : super(key: key);

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final keys = LogPoolManager.getInstance()!.keys;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Logs"),
        backgroundColor: theme.scaffoldBackgroundColor,
        titleTextStyle: theme.textTheme.headlineSmall,
        iconTheme: theme.iconTheme,
        elevation: 1.0,
        actions: [
          InkWell(
            onTap: () {
              if (debugBtnIsShow()) {
                dismissDebugBtn();
              } else {
                showDebugBtn(context);
              }
              setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                child: Text(
                  debugBtnIsShow() ? 'close overlay' : 'open overlay',
                  style: theme.textTheme.caption!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              LogPoolManager.getInstance()!.clear();
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                child: Text(
                  'clear',
                  style: theme.textTheme.caption!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<LinkedHashMap<String, NetOptions>>(
        valueListenable: LogPoolManager.getInstance()!.logMapNotifier,
        builder: (context, map, child) {
          return map.isEmpty
              ? const Center(
                  child: Text('No request log'),
                )
              : ListView.builder(
                  reverse: false,
                  itemCount: map.length,
                  itemBuilder: (BuildContext context, int index) {
                    return NetOptionsListTile(
                      key: ValueKey(keys[index]),
                      item: map[keys[index]]!,
                    );
                  },
                );
        },
      ),
    );
  }
}
