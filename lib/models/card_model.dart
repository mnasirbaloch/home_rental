class CardModel {
  final String? id;
  final String? name;
  final String? no;
  final String? provider;

  final String? exp;
  final int? status;

  CardModel(
      {this.id, this.name, this.no, this.provider, this.exp, this.status = 1});

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
        id: map['id_card'],
        name: map['nm'],
        no: map['no'],
        provider: map['provider'],
        exp: map['expired_date'],
        status: int.parse(map['status'] ?? "1"));
  }

  Map<String, dynamic> toJson() {
    return {
      "id_card": id,
      "no": "$no",
      "m,": "$name",
      "provider": "$provider",
      "exp": "$exp",
      "status": "$status"
    };
  }
}
