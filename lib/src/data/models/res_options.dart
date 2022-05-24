// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';

class ResOptions {
  int? id;
  dynamic data;
  int? statusCode;
  DateTime? responseTime; //ms
  int? duration; //ms
  Map<String, List<String>>? headers;
  ResOptions({
    this.id,
    this.data,
    this.statusCode,
    this.responseTime,
    this.duration,
    this.headers,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ResOptions &&
        other.id == id &&
        other.data == data &&
        other.statusCode == statusCode &&
        other.responseTime == responseTime &&
        other.duration == duration &&
        mapEquals(other.headers, headers);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        data.hashCode ^
        statusCode.hashCode ^
        responseTime.hashCode ^
        duration.hashCode ^
        headers.hashCode;
  }
}
