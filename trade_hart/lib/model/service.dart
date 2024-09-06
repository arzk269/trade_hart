// class Service {
//   String name;
//   String provider;
//   String description;
//   double price;
//   int rate;
//   int nbRate;
//   String imagePath;

//   Service(
//       {required this.name,
//       required this.provider,
//       required this.description,
//       required this.price,
//       required this.rate,
//       required this.nbRate,
//       required this.imagePath});
// }
class Service {
  String? id;
  String name;
  double price;
  List<dynamic> categories;
  String sellerId;
  String duration;
  String description;
  double averageRate;
  double totalPoints;
  int ratesNumber;
  DateTime date;
  bool status;
  String sellerName;
  List<dynamic> images;
  List<dynamic>? crenaux;
  bool creneauReservationStatus;
  String location;
  Service(
      {this.id,
      required this.name,
      required this.price,
      required this.categories,
      required this.sellerId,
      required this.duration,
      required this.description,
      required this.averageRate,
      this.crenaux,
      required this.date,
      required this.images,
      required this.ratesNumber,
      required this.sellerName,
      required this.status,
      required this.totalPoints,
      required this.creneauReservationStatus,
      required this.location});
}
