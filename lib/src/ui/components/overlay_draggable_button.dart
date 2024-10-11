import 'package:dio_logs_manager/src/ui/logs_page.dart';
import 'package:flutter/material.dart';

OverlayEntry? itemEntry;

///Show [DrawableButtonWidget] which open [LogsPage]
showDebugBtn(BuildContext context,
    {Widget? button, Color? btnColor, bool useRootNavigator = false}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    dismissDebugBtn();
    itemEntry = OverlayEntry(
        builder: (BuildContext context) =>
            button ??
            DrawableButtonWidget(
              btnColor: btnColor,
              onTap: () {
                Navigator.of(context, rootNavigator: useRootNavigator).push(
                  MaterialPageRoute(
                    builder: (context) => const LogsPage(),
                  ),
                );
              },
            ));

    Overlay.of(context).insert(itemEntry!);
  });
}

///Close the [OverlayEntry] for [DrawableButtonWidget]
dismissDebugBtn() {
  itemEntry?.remove();
  itemEntry = null;
}

///Determine if [OverlayEntry] is shown
bool debugBtnIsShow() {
  return !(itemEntry == null);
}

///Widget to show a circular drawable button
class DrawableButtonWidget extends StatefulWidget {
  final String title;
  final GestureTapCallback? onTap;
  final double btnSize;
  final Color? btnColor;

  const DrawableButtonWidget({
    Key? key,
    this.title = 'http log',
    this.onTap,
    this.btnSize = 66,
    this.btnColor,
  }) : super(key: key);

  @override
  DrawableButtonWidgetState createState() => DrawableButtonWidgetState();
}

class DrawableButtonWidgetState extends State<DrawableButtonWidget> {
  double left = 30;
  double top = 100;
  late double screenWidth;
  late double screenHeight;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    Widget w;
    Color primaryColor = widget.btnColor ?? Theme.of(context).primaryColor;
    primaryColor = primaryColor.withOpacity(0.6);
    w = GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: _dragUpdate,
      child: Container(
        width: widget.btnSize,
        height: widget.btnSize,
        color: primaryColor,
        child: Center(
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.normal,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );

    ///圆形
    w = ClipRRect(
      borderRadius: BorderRadius.circular(widget.btnSize / 2),
      child: w,
    );

    ///计算偏移量限制
    if (left < 1) {
      left = 1;
    }
    if (left > screenWidth - widget.btnSize) {
      left = screenWidth - widget.btnSize;
    }

    if (top < 1) {
      top = 1;
    }
    if (top > screenHeight - widget.btnSize) {
      top = screenHeight - widget.btnSize;
    }
    w = Container(
      alignment: Alignment.topLeft,
      margin: EdgeInsets.only(left: left, top: top),
      child: w,
    );
    return w;
  }

  _dragUpdate(DragUpdateDetails detail) {
    Offset offset = detail.delta;
    left = left + offset.dx;
    top = top + offset.dy;
    setState(() {});
  }
}
