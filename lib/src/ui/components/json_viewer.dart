import 'dart:convert';

import 'package:dio_logs_manager/src/utils/copy_clipboard.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../utils/json_utils.dart';

class JsonViewer extends StatefulWidget {
  final Object jsonObj;
  final double fontSize;
  const JsonViewer(
    this.jsonObj, {
    Key? key,
    this.fontSize = 14,
  }) : super(key: key);
  @override
  JsonViewerState createState() => JsonViewerState();
}

class JsonViewerState extends State<JsonViewer> {
  @override
  Widget build(BuildContext context) {
    Object content = widget.jsonObj;
    if (content is List) {
      return JsonArrayViewer(
        content,
        isRoot: true,
        fontSize: widget.fontSize,
      );
    } else if (content is Map<String, dynamic>) {
      return JsonObjectViewer(
        content,
        isRoot: true,
        fontSize: widget.fontSize,
      );
    } else if (content is String) {
      try {
        final jsonMap = json.decode(content) as Map<String, dynamic>;
        return JsonObjectViewer(jsonMap, isRoot: true);
      } catch (e) {
        const je = JsonEncoder.withIndent('  ');
        final jsonStr = je.convert(content);
        return Text(jsonStr);
      }
    }
    return const SizedBox(
      child: Text("Unknown json format!"),
    );
  }
}

class JsonObjectViewer extends StatefulWidget {
  final Map<String, dynamic> jsonObj;
  final String? jsonKey;
  final bool isRoot;
  final double fontSize;

  const JsonObjectViewer(
    this.jsonObj, {
    Key? key,
    this.jsonKey,
    this.isRoot = false,
    this.fontSize = 14,
  }) : super(key: key);

  @override
  JsonObjectViewerState createState() => JsonObjectViewerState();
}

class JsonObjectViewerState extends State<JsonObjectViewer> {
  Map<String, bool> openFlag = {};

  @override
  void initState() {
    super.initState();
    if (widget.isRoot) {
      //Esto es para que el Root salga expandido
      openFlag.putIfAbsent(widget.jsonKey ?? "", () => true);
    }
  }

  bool _isOpen(String key) {
    return openFlag[key.toString()] ?? false;
    // if (widget.isShowAll!) {
    //   return showMap[key.toString()] ?? true;
    // } else {
    //   return showMap[key.toString()] ?? false;
    // }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRoot) {
      return Container(
        padding: const EdgeInsets.only(left: 14.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _getList(widget.jsonObj)),
      );
    } else {
      //Rut Object
      Map<String, Object> rootMap = {widget.jsonKey ?? "": widget.jsonObj};
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _getList(rootMap),
      );
    }
  }

  List<Widget> _getList(Map<String, dynamic> jsonObj) {
    List<Widget> list = [];
    for (MapEntry entry in jsonObj.entries) {
      bool ex = isExtensible(entry.value);
      bool ink = isInkWell(entry.value);
      if (ex) {
        //List or Object
        list.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _wrapFlex(entry.key, const Text("")),
            if (entry.key != null && entry.key != "") ...[
              if (ink)
                InkWell(
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        openFlag[entry.key] = !(openFlag[entry.key] ?? false);
                      });
                    })
              else
                Text(entry.key,
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.bold,
                    )),
              Text(
                ':',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: widget.fontSize,
                ),
              ),
              const SizedBox(width: 3),
            ],
            ValueWidget(
              key: ValueKey(entry.key),
              content: entry.value,
              fontSize: widget.fontSize,
              onTap: (Key? key) {
                if (key is ValueKey) {
                  setState(() {
                    openFlag[key.value] = !(openFlag[key.value] ?? false);
                  });
                }
              },
            )
          ],
        ));
        list.add(const SizedBox(height: 4));
        if (openFlag[entry.key] ?? false) {
          list.add(getContentWidget(entry.value));
        }
      } else {
        //Primitive Type
        list.add(
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: RichText(
              text: TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    // open desired screen
                    copyClipboard(context, entry.value?.toString());
                  },
                text: entry.key,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  color: Theme.of(context).textTheme.bodyText1?.color,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: ': ',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1?.color,
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.normal),
                  ),
                  ValueTextSpan(
                    value: entry.value,
                    textStyle: TextStyle(
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).textTheme.bodyText1?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    return list;
  }

  Widget getContentWidget(dynamic content) {
    if (content is List) {
      return JsonArrayViewer(
        content,
        isRoot: false,
        fontSize: widget.fontSize,
      );
    } else {
      return JsonObjectViewer(
        content,
        isRoot: false,
        fontSize: widget.fontSize,
      );
    }
  }

  static isInkWell(dynamic content) {
    if (content == null) {
      return false;
    } else if (content is int) {
      return false;
    } else if (content is String) {
      return false;
    } else if (content is bool) {
      return false;
    } else if (content is double) {
      return false;
    } else if (content is List) {
      if (content.isEmpty) {
        return false;
      } else {
        return true;
      }
    }
    return true;
  }

  static isExtensible(dynamic content) {
    if (content == null) {
      return false;
    } else if (content is int) {
      return false;
    } else if (content is String) {
      return false;
    } else if (content is bool) {
      return false;
    } else if (content is double) {
      return false;
    }
    return true;
  }

  static getTypeName(dynamic content) {
    if (content is int) {
      return 'int';
    } else if (content is String) {
      return 'String';
    } else if (content is bool) {
      return 'bool';
    } else if (content is double) {
      return 'double';
    } else if (content is List) {
      return 'List';
    }
    return 'Object';
  }

  Widget _wrapFlex(String key, Widget keyW) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // if (key == 0) {
        //   _flexAll(!_isShow(key));
        //   setState(() {});
        // }
        _flexSwitch(key.toString());
      },
      child: Row(
        children: <Widget>[
          Transform.rotate(
            angle: _isOpen(key) ? 0 : 3.14 * 1.5,
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

  void _flexSwitch(String key) {
    openFlag.putIfAbsent(key, () => false);
    openFlag[key] = !openFlag[key]!;
    setState(() {});
  }

  void _flexAll(bool flex) {
    openFlag.forEach((k, v) {
      openFlag[k] = flex;
    });
  }
}

class JsonArrayViewer extends StatefulWidget {
  final List<dynamic> jsonArray;

  final bool isRoot;
  final double fontSize;
  const JsonArrayViewer(this.jsonArray,
      {Key? key, this.isRoot = false, this.fontSize = 14})
      : super(key: key);

  @override
  JsonArrayViewerState createState() => JsonArrayViewerState();
}

class JsonArrayViewerState extends State<JsonArrayViewer> {
  late List<bool> openFlag;

  bool _isOpen(int index) {
    return openFlag[index];
    // if (widget.isShowAll!) {
    //   return showMap[key.toString()] ?? true;
    // } else {
    //   return showMap[key.toString()] ?? false;
    // }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRoot) {
      return Container(
          padding: const EdgeInsets.only(left: 14.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _getList()));
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: _getList());
  }

  @override
  void initState() {
    super.initState();
    openFlag = List.filled(widget.jsonArray.length, false);
  }

  _getList() {
    List<Widget> list = [];
    int i = 0;
    for (dynamic content in widget.jsonArray) {
      bool ex = JsonObjectViewerState.isExtensible(content);
      bool ink = JsonObjectViewerState.isInkWell(content);
      if (ex) {
        list.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _wrapFlex(i, const Text("")),
            (ink)
                ? getInkWell(i)
                : Text('[$i]',
                    style: TextStyle(
                        color:
                            content == null ? Colors.grey : Colors.purple[900],
                        fontSize: widget.fontSize)),
            Text(
              ':',
              style: TextStyle(
                color: Colors.grey,
                fontSize: widget.fontSize,
              ),
            ),
            const SizedBox(width: 3),
            ValueWidget(
              key: ValueKey(i),
              content: content,
              fontSize: widget.fontSize,
              onTap: (Key? key) {
                if (key is ValueKey) {
                  final index = key.value as int;
                  setState(() {
                    openFlag[index] = !(openFlag[index]);
                  });
                }
              },
            ),
          ],
        ));
        list.add(const SizedBox(height: 4));
        if (openFlag[i]) {
          list.add(getContentWidget(content));
        }
      } else {
        //Primitive
        list.add(
          RichText(
            text: TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    // open desired screen
                    copyClipboard(context, content?.toString());
                  },
                text: '[$i]',
                style: TextStyle(
                  fontSize: widget.fontSize,
                  color: Theme.of(context).textTheme.bodyText1?.color,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: ': ',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1?.color,
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.normal),
                  ),
                  ValueTextSpan(
                    value: content,
                    textStyle: TextStyle(
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).textTheme.bodyText1?.color,
                    ),
                  ),
                ]),
          ),
        );
      }

      i++;
    }
    return list;
  }

  Widget getContentWidget(dynamic content) {
    if (content is List) {
      return JsonArrayViewer(
        content,
        isRoot: false,
        fontSize: widget.fontSize,
      );
    } else {
      return JsonObjectViewer(
        content,
        isRoot: false,
        fontSize: widget.fontSize,
      );
    }
  }

  getInkWell(int index) {
    return InkWell(
        child: Text('[$index]', style: const TextStyle(color: Colors.grey)),
        onTap: () {
          setState(() {
            openFlag[index] = !(openFlag[index]);
          });
        });
  }

  Widget _wrapFlex(int index, Widget keyW) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // if (key == 0) {
        //   _flexAll(!_isShow(key));
        //   setState(() {});
        // }
        _flexSwitch(index);
      },
      child: Row(
        children: <Widget>[
          Transform.rotate(
            angle: _isOpen(index) ? 0 : 3.14 * 1.5,
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

  void _flexSwitch(int index) {
    openFlag[index] = !openFlag[index];
    setState(() {});
  }

  void _flexAll(bool flex) {
    //TODO test this
    for (var element in openFlag) {
      element = !element;
    }
  }
}

class ValueTextSpan extends TextSpan {
  const ValueTextSpan({
    Key? key,
    required this.textStyle,
    required this.value,
  });

  final dynamic value;
  final TextStyle textStyle;

  @override
  String? get text => value is String ? '"$value"' : value?.toString();

  @override
  TextStyle? get style => textStyle;
}

class ValueWidget extends StatelessWidget {
  const ValueWidget({
    Key? key,
    required this.content,
    this.fontSize = 14,
    this.onTap,
  }) : super(key: key);
  final double fontSize;
  final dynamic content;
  final void Function(Key?)? onTap;
  @override
  Widget build(BuildContext context) {
    if (content == null) {
      return Expanded(
          child: Text(
        'undefined',
        style: TextStyle(color: Colors.grey, fontSize: fontSize),
      ));
    } else if (content is int) {
      return Expanded(
          child: Text(
        content.toString(),
        style: TextStyle(color: Colors.teal, fontSize: fontSize),
      ));
    } else if (content is String) {
      return Expanded(
          child: Text(
        '"$content"',
        style: TextStyle(color: Colors.redAccent, fontSize: fontSize),
      ));
    } else if (content is bool) {
      return Expanded(
          child: Text(
        content.toString(),
        style: TextStyle(color: Colors.purple, fontSize: fontSize),
      ));
    } else if (content is double) {
      return Expanded(
          child: Text(
        content.toString(),
        style: TextStyle(color: Colors.teal, fontSize: fontSize),
      ));
    } else if (content is List) {
      if (content.isEmpty) {
        return Expanded(
          child: Text(
            'Array[0]',
            style: TextStyle(color: Colors.grey, fontSize: fontSize),
          ),
        );
      } else {
        return Expanded(
          child: InkWell(
              onTap: () {
                onTap?.call(key);
              },
              onLongPress: () {
                copyClipboard(context, toJson(content));
              },
              child: Text(
                'Array<${JsonObjectViewerState.getTypeName(content[0])}>[${content.length}]',
                style: TextStyle(color: Colors.grey, fontSize: fontSize),
              )),
        );
      }
    }
    return InkWell(
        onTap: () {
          onTap?.call(key);
        },
        onLongPress: () {
          if (content is Map) {
            copyClipboard(context, toJson(content));
          }
        },
        child: Text(
          'Object',
          style: TextStyle(color: Colors.grey, fontSize: fontSize),
        ));
  }
}
