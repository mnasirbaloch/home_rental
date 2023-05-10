class MenuModel {
  final String? id;
  final String? title;
  final String? description;
  final String? image;
  final String? unitPrice;

  final String? idOffice;
  final int? price;
  final int? flag;
  final int? status;

  MenuModel(
      {this.id,
      this.title,
      this.description,
      this.image,
      this.unitPrice,
      this.idOffice,
      this.price = 0,
      this.flag = 1,
      this.status = 1});

  // title, description, image, total_interest, total_post, total_like, total_trivia, flag,
  //status, date_created, date_updated

  factory MenuModel.fromMap(Map<String, dynamic> map) {
    return MenuModel(
        id: map['id_menu'],
        title: map['title'],
        description: map['description'],
        image: map['image'],
        unitPrice: map['unit_price'],
        idOffice: map['id_office'],
        price: int.parse(map['price'] ?? "0"),
        flag: int.parse(map['flag'] ?? "1"),
        status: int.parse(map['status'] ?? "1"));
  }

  Map<String, dynamic> toJson() {
    return {
      "id_menu": id,
      "title": title,
      "description": description,
      "image": image,
      "unit_price": unitPrice,
      "price": "$price",
      "id_office": "$idOffice",
      "flag": "$flag",
      "status": "$status"
    };
  }
}
