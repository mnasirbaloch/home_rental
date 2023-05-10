class LikedModel {
  final String? id;
  final String? idUser;
  final String? idRent;
  final String? idCategory;

  final int isLiked;
  final int flag;
  final int status;
  final String? dateCreated;
  final String? dateUpdated;

  //'id_category', 'id_post', 'id_user', 'is_liked', 'flag', 'status', 'date_created', 'date_updated'

  LikedModel(
      {this.id,
      this.idUser,
      this.idRent,
      this.idCategory,
      this.isLiked = 0,
      this.flag = 1,
      this.status = 0,
      this.dateCreated,
      this.dateUpdated});

  factory LikedModel.fromJson(Map<String, dynamic> map) {
    return LikedModel(
      id: map['id_liked'],
      idUser: map['id_user'],
      idRent: map['id_rent'],
      idCategory: map['id_category'],
      isLiked: int.parse(map['is_liked'] ?? "0"),
      flag: int.parse(map['flag']),
      status: int.parse(map['status']),
      dateCreated: map['date_created'],
      dateUpdated: map['date_updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_follow": id,
      "id_user": idUser,
      "id_rent": idRent,
      "id_category": "$idCategory",
      "isLiked": "$isLiked",
      "flag": "$flag",
      "status": "$status",
      "date_created": dateCreated,
      "date_updated": dateUpdated
    };
  }
}
