import 'err_options.dart';
import 'req_options.dart';
import 'res_options.dart';

class NetOptions {
  ReqOptions? reqOptions;
  ResOptions? resOptions;
  ErrOptions? errOptions;
  NetOptions({
    this.reqOptions,
    this.resOptions,
    this.errOptions,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NetOptions &&
        other.reqOptions == reqOptions &&
        other.resOptions == resOptions &&
        other.errOptions == errOptions;
  }

  @override
  int get hashCode =>
      reqOptions.hashCode ^ resOptions.hashCode ^ errOptions.hashCode;
}
