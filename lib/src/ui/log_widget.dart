import 'package:dio_logs_manager/src/data/models/net_options.dart';
import 'package:dio_logs_manager/src/ui/log_request_widget.dart';
import 'package:flutter/material.dart';

import 'log_error_widget.dart';
import 'log_response_widget.dart';

class LogWidget extends StatefulWidget {
  final NetOptions netOptions;

  const LogWidget(this.netOptions, {Key? key}) : super(key: key);

  @override
  LogWidgetState createState() => LogWidgetState();
}

class LogWidgetState extends State<LogWidget>
    with SingleTickerProviderStateMixin {
  PageController? _pageController;

  int currentIndex = 0;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.netOptions.reqOptions!.url!,
          style: const TextStyle(fontSize: 11),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 1.0,
        titleTextStyle: theme.textTheme.headlineSmall,
        iconTheme: theme.iconTheme,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: 3,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return LogRequestWidget(widget.netOptions);
          } else if (index == 1) {
            return LogResponseWidget(widget.netOptions);
          } else {
            return LogErrorWidget(widget.netOptions);
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _bottomTap,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.cloud_upload_outlined), label: 'Request'),
          BottomNavigationBarItem(
              icon: Icon(Icons.cloud_download_outlined), label: 'Response'),
          BottomNavigationBarItem(
              icon: Icon(Icons.error_outline), label: 'Error'),
        ],
      ),
    );
  }

  void _onPageChanged(int value) {
    if (mounted) {
      setState(() {
        currentIndex = value;
      });
    }
  }

  void _bottomTap(int value) {
    _pageController!.animateToPage(value,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }
}
