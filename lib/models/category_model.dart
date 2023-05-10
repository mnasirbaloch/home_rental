// ignore_for_file: prefer_null_aware_operators

import 'package:homerental/models/user_model.dart';

class CategoryModel {
  final String? id;
  final String? title;
  final String? description;
  final String? image;
  final String? subscribeFcm;
  final int? totalRent;
  final int? totalLike;
  final int? flag;
  final int? status;
  final List<UserModel>? users;

  CategoryModel(
      {this.id,
      this.title,
      this.description,
      this.image,
      this.subscribeFcm,
      this.totalRent = 0,
      this.totalLike = 0,
      this.users,
      this.flag = 1,
      this.status = 1});

  // title, description, image, total_interest, total_post, total_like, total_trivia, flag,
  //status, date_created, date_updated

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
        id: map['id_category'],
        title: map['title'],
        description: map['description'],
        image: map['image'],
        subscribeFcm: map['subscribe_fcm'],
        totalRent: int.parse(map['total_rent'] ?? "0"),
        totalLike: int.parse(map['total_like'] ?? "0"),
        users: map['users'] == null
            ? null
            : map['users'].map<UserModel>((json) {
                return UserModel.fromJson(json);
              }).toList(),
        flag: int.parse(map['flag'] ?? "1"),
        status: int.parse(map['status'] ?? "1"));
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> dtusers = [];
    if (users != null) {
      dtusers = users!.map<Map<String, dynamic>>((UserModel user) {
        return user.toJson();
      }).toList();
    }

    return {
      "id_category": id,
      "title": title,
      "description": description,
      "image": image,
      "subscribe_fcm": subscribeFcm,
      "total_rent": "$totalRent",
      "total_like": "$totalLike",
      "users": dtusers,
      "flag": "$flag",
      "status": "$status"
    };
  }
}
