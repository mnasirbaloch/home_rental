import 'package:homerental/models/user_model.dart';

class ReviewModel {
  final String? id;
  final String? review;
  final String? idRent;

  final UserModel? user;
  final double? rating;
  final int? flag;
  final int? status;
  final String? dateCreated;
  final String? dateUpdated;

  ReviewModel(
      {this.id,
      this.review,
      this.rating = 0.0,
      this.user,
      this.idRent,
      this.dateCreated,
      this.dateUpdated,
      this.flag = 1,
      this.status = 1});

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
        id: map['id_comment'],
        review: map['description'],
        rating: double.parse(map['rating'] ?? "0.0"),
        idRent: map['id_rent'],
        user: map['user'] != null ? UserModel.fromJson(map['user']) : null,
        dateCreated: map['date_created'],
        dateUpdated: map['date_updated'],
        flag: int.parse(map['flag'] ?? "1"),
        status: int.parse(map['status'] ?? "1"));
  }

  Map<String, dynamic> toJson() {
    return {
      "id_comment": id,
      "description": "$review",
      "rating": "$rating",
      "date_created": dateCreated,
      "date_updated": dateUpdated,
      "user": user != null ? user!.toJson() : null,
      "id_rent": "$idRent",
      "flag": "$flag",
      "status": "$status"
    };
  }
}
