import 'dart:convert';

import 'package:flutter/material.dart';

class JsonView extends StatefulWidget {
  final dynamic json;

  final bool? isShowAll;

  final double fontSize;
  const JsonView({
    Key? key,
    this.json,
    this.isShowAll = false,
    this.fontSize = 14,
  }) : super(key: key);

  @override
  JsonViewState createState() => JsonViewState();
}

class JsonViewState extends State<JsonView> {
  Map<String, bool?> showMap = {};

  int currentIndex = 0;

  @override
  void didUpdateWidget(JsonView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isShowAll != widget.isShowAll) {
      _flexAll(widget.isShowAll);
    }
  }

  @override
  Widget build(BuildContext context) {
    currentIndex = 0;
    Widget w;
    final JsonType type = getType(widget.json);
    if (type == JsonType.object) {
      w = _buildObject(widget.json as Map<String, Object?>);
    } else if (type == JsonType.array) {
      final List? list = widget.json as List?;
      w = _buildArray(list, '');
    } else {
      try {
        final jsonMap =
            json.decode(widget.json as String) as Map<String, dynamic>;
        w = _buildObject(jsonMap);
      } catch (e) {
        const je = JsonEncoder.withIndent('  ');
        final json = je.convert(widget.json);
        return _getDefText(json);
      }
    }
    return w;
  }

  Widget _buildObject(Map<String, dynamic>? json, {String? key}) {
    final List<Widget> listW = [];

    currentIndex++;
    Widget keyW;
    if (_isShow(currentIndex)) {
      keyW = _getDefText(key == null ? '{' : '$key:{');
    } else {
      keyW = _getDefText(key == null ? '{...}' : '$key:{...}');
    }
    listW.add(_wrapFlex(currentIndex, keyW));

    if (_isShow(currentIndex)) {
      final List<Widget> listObj = [];
      json!.forEach((k, dynamic v) {
        Widget w;
        final JsonType type = getType(v);
        if (type == JsonType.object) {
          w = _buildObject(v as Map<String, dynamic>, key: k);
        } else if (type == JsonType.array) {
          final List list = v as List;
          w = _buildArray(list, k);
        } else {
          w = _buildKeyValue(v, k: k);
        }
        listObj.add(w);
      });

      listObj.add(_getDefText('},'));

      listW.add(
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: listObj,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listW,
    );
  }

  Widget _buildArray(List? listJ, String key) {
    final List<Widget> listW = [];
    currentIndex++;
    Widget keyW;
    if (key.isEmpty) {
      keyW = _getDefText('[');
    } else if (_isShow(currentIndex)) {
      keyW = _getDefText('$key:[');
    } else {
      keyW = _getDefText('$key:[...]');
    }

    listW.add(
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: () {
          _copy(listJ.toString());
        },
        child: _wrapFlex(currentIndex, keyW),
      ),
    );

    if (_isShow(currentIndex)) {
      final List<Widget> listArr = [];
      for (final val in listJ!) {
        final type = getType(val);
        Widget w;
        if (type == JsonType.object) {
          w = _buildObject(val as Map<String, dynamic>);
        } else {
          w = _buildKeyValue(val);
        }
        listArr.add(w);
      }
      listArr.add(_getDefText(']'));

      listW.add(
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: listArr,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listW,
    );
  }

  Widget _wrapFlex(int key, Widget keyW) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (key == 0) {
          _flexAll(!_isShow(key));
          setState(() {});
        }
        _flexSwitch(key.toString());
      },
      child: Row(
        children: <Widget>[
          Transform.rotate(
            angle: _isShow(key) ? 0 : 3.14 * 1.5,
            child: const Icon(
              Icons.expand_more,
              size: 12,
            ),
          ),
          keyW,
        ],
      ),
    );
  }

  Widget _buildKeyValue(dynamic v, {dynamic k}) {
    Widget w = _getDefText(
      '${k ?? ''}:${v is String ? '"$v"' : v?.toString()},',
    );
    if (k != null) {
      w = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: () {
          _copy(v);
        },
        child: w,
      );
    }
    return w;
  }

  bool _isShow(int key) {
    if (key == 1) return true;
    if (widget.isShowAll!) {
      return showMap[key.toString()] ?? true;
    } else {
      return showMap[key.toString()] ?? false;
    }
  }

  void _flexSwitch(String key) {
    showMap.putIfAbsent(key, () => false);
    showMap[key] = !showMap[key]!;
    setState(() {});
  }

  void _flexAll(bool? flex) {
    showMap.forEach((k, v) {
      showMap[k] = flex;
    });
  }

  JsonType getType(dynamic data) {
    if (data is List) {
      return JsonType.array;
    } else if (data is Map<String, dynamic>) {
      return JsonType.object;
    }
    return JsonType.str;
  }

  Text _getDefText(String str) {
    return Text(
      str,
      style: TextStyle(fontSize: widget.fontSize),
    );
  }

  void _copy(dynamic value) {
    // copyClipboard(context, value);
  }
}

enum JsonType {
  object,
  array,
  str,
}
