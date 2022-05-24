// ignore_for_file: public_member_api_docs, sort_constructors_first
class ErrOptions {
  int? id;
  String? errorMsg;
  ErrOptions({
    this.id,
    this.errorMsg,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ErrOptions && other.id == id && other.errorMsg == errorMsg;
  }

  @override
  int get hashCode => id.hashCode ^ errorMsg.hashCode;
}
