class ErrOptions {
  int? id;
  String? errorMsg;
  String errorType;
  ErrOptions({
    this.id,
    this.errorMsg,
    required this.errorType,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ErrOptions && other.id == id && other.errorMsg == errorMsg;
  }

  @override
  int get hashCode => id.hashCode ^ errorMsg.hashCode;
}
