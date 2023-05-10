import 'package:homerental/models/user_model.dart';

class RentalModel {
  final String? id;
  final String? title;
  final String? description;

  final String? image;
  final String? image2;
  final String? image3;
  final String? image4;
  final String? image5;
  final String? image6;

  final String? idCategory;
  final String? owner;

  final String? address;
  final String? latitude;

  final List<dynamic>? facilities;
  final List<dynamic>? menus;
  final List<dynamic>? reviews;

  final int? isLiked;
  final int? price;
  final String? unitPrice;

  final int? beds;
  final int? baths;
  final int? sqft;

  final String? subscribeFcm;
  final int? totalRent; //total booking
  final int? totalLike; //bookmark
  final int? totalRating; //total review
  final double? rating;
  final double? distance;

  final int? flag;
  final int? status;
  final UserModel? user;

  final String? dateCreated;
  final String? dateUpdated;

  RentalModel(
      {this.id,
      this.title,
      this.description,
      this.image,
      this.image2,
      this.image3,
      this.image4,
      this.image5,
      this.image6,
      this.idCategory,
      this.owner,
      this.address,
      this.latitude,
      this.subscribeFcm,
      this.facilities,
      this.menus,
      this.reviews,
      this.isLiked = 0,
      this.beds = 0,
      this.baths = 0,
      this.sqft = 0,
      this.price,
      this.unitPrice,
      this.totalRent = 0,
      this.totalLike = 0,
      this.totalRating = 0,
      this.rating = 0.0,
      this.distance = 0.0,
      this.user,
      this.flag = 1,
      this.status = 1,
      this.dateCreated,
      this.dateUpdated});

  factory RentalModel.fromMap(Map<String, dynamic> map) {
    return RentalModel(
        id: map['id_rent'],
        title: map['title'],
        description: map['description'],
        image: map['image'],
        image2: map['image2'],
        image3: map['image3'],
        image4: map['image4'],
        image5: map['image5'],
        image6: map['image6'],
        idCategory: map['id_category'],
        owner: map['owner'],
        address: map['address'],
        latitude: map['latitude'],
        subscribeFcm: map['subscribe_fcm'],
        facilities: map['facilities'],
        menus: map['menus'],
        reviews: map['reviews'],
        beds: int.parse(map['beds'] ?? "0"),
        baths: int.parse(map['baths'] ?? "0"),
        sqft: int.parse(map['sqft'] ?? "0"),
        price: int.parse(map['price'] ?? "1"),
        isLiked: int.parse(map['is_liked'] ?? "0"),
        unitPrice: map['unit_price'],
        rating: double.parse(map['rating'] ?? "0"),
        distance: map['distance'] ?? 0,
        totalRent: int.parse(map['total_rent'] ?? "0"),
        totalLike: int.parse(map['total_liked'] ?? "0"),
        totalRating: int.parse(map['total_rating'] ?? "0"),
        user: map['users'] == null ? null : UserModel.fromJson(map['users']),
        dateCreated: map['date_created'],
        dateUpdated: map['date_updated'],
        flag: int.parse(map['flag'] ?? "1"),
        status: int.parse(map['status'] ?? "1"));
  }

  Map<String, dynamic> toJson() {
    return {
      "id_rent": id,
      "title": title,
      "description": description,
      "image": image,
      "image2": image2,
      "image3": image3,
      "image4": image4,
      "image5": image5,
      "image6": image6,
      "id_category": idCategory,
      "owner": owner,
      "address": address,
      "latitude": latitude,
      "facilities": facilities,
      "menus": menus,
      "reviews": reviews,
      "subscribe_fcm": subscribeFcm,
      "beds": "$beds",
      "baths": "$baths",
      "sqft": "$sqft",
      "price": "$price",
      "is_liked": "$isLiked",
      "unit_price": "$unitPrice",
      "rating": "$rating",
      "distance": "$distance",
      "total_rent": "$totalRent",
      "total_liked": "$totalLike",
      "total_rating": "$totalRating",
      "user": user!.toJson(),
      "date_created": "$dateCreated",
      "date_updated": "$dateUpdated",
      "flag": "$flag",
      "status": "$status"
    };
  }
}
