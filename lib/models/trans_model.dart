import 'package:homerental/models/rental_model.dart';
import 'package:homerental/models/user_model.dart';

class TransModel {
  final String? id;
  final String? no;
  final String? duration;

  final String? idRent;
  final String? idUser;
  final int? total;
  final String? currency;
  final String? unitPrice;

  final String? payment;
  final String? descPayment;

  final UserModel? user;
  final RentalModel? rent;

  final int? flag;
  final int? status;
  final String? dateCreated;
  final String? dateUpdated;

  TransModel(
      {this.id,
      this.no,
      this.duration,
      this.idUser,
      this.idRent,
      this.rent,
      this.user,
      this.currency,
      this.unitPrice,
      this.payment,
      this.descPayment,
      this.dateCreated,
      this.dateUpdated,
      this.total = 0,
      this.flag = 1,
      this.status = 1});

  factory TransModel.fromMap(Map<String, dynamic> map) {
    return TransModel(
        id: map['id_trans'],
        no: map['no_trans'],
        duration: map['duration'],
        idUser: map['id_user'],
        idRent: map['id_rent'],
        user: map['user'] != null ? UserModel.fromJson(map['user']) : null,
        rent: map['rent'] != null ? RentalModel.fromMap(map['rent']) : null,
        currency: map['currency'],
        unitPrice: map['unit_price'],
        payment: map['payment'],
        descPayment: map['desc_payment'],
        total: int.parse(map['total'] ?? "0"),
        dateCreated: map['date_created'],
        dateUpdated: map['date_updated'],
        flag: int.parse(map['flag'] ?? "1"),
        status: int.parse(map['status'] ?? "1"));
  }

  Map<String, dynamic> toJson() {
    return {
      "id_trans": id,
      "no_trans": no,
      "duration": "$duration",
      "id_user": idUser,
      "id_rent": idRent,
      "user": user != null ? user!.toJson() : null,
      "rent": rent != null ? rent!.toJson() : null,
      "currency": "$currency",
      "unit_price": "$unitPrice",
      "payment": "$payment",
      "desc_payment": "$descPayment",
      "total": "$total",
      "date_created": "$dateCreated",
      "date_updated": "$dateUpdated",
      "flag": "$flag",
      "status": "$status"
    };
  }
}
