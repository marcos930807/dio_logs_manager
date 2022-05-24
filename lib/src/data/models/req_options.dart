// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';

class ReqOptions {
  int? id;
  String? url;
  String? method;
  String? contentType;
  DateTime? requestTime;
  Map<String, dynamic>? params;
  dynamic data;
  Map<String, dynamic>? headers;
  ReqOptions({
    this.id,
    this.url,
    this.method,
    this.contentType,
    this.requestTime,
    this.headers,
    this.params,
    this.data,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReqOptions &&
        other.id == id &&
        other.url == url &&
        other.method == method &&
        other.contentType == contentType &&
        other.requestTime == requestTime &&
        mapEquals(other.params, params) &&
        other.data == data &&
        mapEquals(other.headers, headers);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        url.hashCode ^
        method.hashCode ^
        contentType.hashCode ^
        requestTime.hashCode ^
        params.hashCode ^
        data.hashCode ^
        headers.hashCode;
  }
}
