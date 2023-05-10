import 'package:homerental/models/rental_model.dart';
import 'package:homerental/models/user_model.dart';

class NotifModel {
  final String? id;
  final String? title;
  final String? description;
  final String? idRent;
  final String? idUser;

  final UserModel? user;
  final RentalModel? rent;

  final String? isFrom;
  final int? flag;
  final int? status;
  final String? dateCreated;
  final String? dateUpdated;

  NotifModel(
      {this.id,
      this.title,
      this.description,
      this.idUser,
      this.isFrom,
      this.user,
      this.rent,
      this.idRent,
      this.dateCreated,
      this.dateUpdated,
      this.flag = 1,
      this.status = 1});

  factory NotifModel.fromMap(Map<String, dynamic> map) {
    return NotifModel(
        id: map['id_notif'],
        title: map['title'],
        description: map['description'],
        idUser: map['id_user'],
        idRent: map['id_rent'],
        isFrom: map['is_from'],
        user: map['user'] != null ? UserModel.fromJson(map['user']) : null,
        rent: map['rent'] != null ? RentalModel.fromMap(map['rent']) : null,
        dateCreated: map['date_created'],
        dateUpdated: map['date_updated'],
        flag: int.parse(map['flag'] ?? "1"),
        status: int.parse(map['status'] ?? "1"));
  }

  Map<String, dynamic> toJson() {
    return {
      "id_description": id,
      "title": "$title",
      "description": "$description",
      "is_from": "$isFrom",
      "date_created": dateCreated,
      "date_updated": dateUpdated,
      "user": user != null ? user!.toJson() : null,
      "rent": rent != null ? rent!.toJson() : null,
      "id_user": "$idUser",
      "id_rent": "$idRent",
      "flag": "$flag",
      "status": "$status"
    };
  }
}
