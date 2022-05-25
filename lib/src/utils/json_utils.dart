import 'dart:convert';

toJson(dynamic data) {
  const je = JsonEncoder.withIndent('  ');
  return je.convert(data);
}

String map2Json(Map? map) {
  if (map == null) {
    return '';
  }
  StringBuffer sb = StringBuffer();
  sb.writeln('{');
  map.forEach((key, value) => sb.writeln('$key:$value'));
  sb.write('}');
  return sb.toString();
}
