import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/article.dart';
import 'package:trade_hart/model/article_color.dart';
import 'package:trade_hart/model/location_provider.dart';
import 'package:trade_hart/model/price_filter_provider.dart';
import 'package:trade_hart/model/search_filter_provider.dart';
import 'package:trade_hart/model/service.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/article_view.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/home_add_to_favorite.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/service_view.dart';
import 'package:trade_hart/views/main_page_components/pages/article_details_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_detail_page.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class ArticlesFeed extends StatefulWidget {
  const ArticlesFeed({super.key});

  @override
  State<ArticlesFeed> createState() => _ArticlesFeedState();
}

class _ArticlesFeedState extends State<ArticlesFeed> {
  Future<void> addToWishlist(String articleID) async {
    try {
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        var data = userSnapshot.data() as Map<String, dynamic>;
        List<String> wishlist = List.from(data['wishlist'] ?? []);

        // Vérifier si l'article est déjà présent dans la wishlist
        if (!wishlist.contains(articleID)) {
          // Utiliser FieldValue.arrayUnion pour ajouter l'article à la wishlist
          await userRef.update({
            'wishlist': FieldValue.arrayUnion([articleID])
          });

          const snackBar = SnackBar(
            content: Text("Article ajouté dans la Wish List"),
            backgroundColor: Colors.green,
          );

          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          const snackBar = SnackBar(
            content: Text("Cette article est déjà dans votre Wish List"),
            backgroundColor: Colors.red,
          );

          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    } catch (error) {
      const snackBar = SnackBar(
        content: Text(
            "Une erreur s'est produite, impossible de poursuivre cette action."),
        backgroundColor: Colors.red,
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PriceFilterProvider>(
      builder: (context, value, child) {
        return Consumer<SearchFilterProvider>(
          builder: (context, value, child) => StreamBuilder(
              stream: (context.read<SearchFilterProvider>().articlesFilters.isEmpty
                  ? (context.read<PriceFilterProvider>().isArticlesFiltered &&
                          context.read<PriceFilterProvider>().minArticlePrice >=
                              0 &&
                          context.read<PriceFilterProvider>().maxArticlePrice >
                              context
                                  .read<PriceFilterProvider>()
                                  .minArticlePrice
                      ? FirebaseFirestore.instance
                          .collection('Articles')
                          .where('price',
                              isLessThanOrEqualTo: context
                                  .read<PriceFilterProvider>()
                                  .maxArticlePrice)
                          .where('price',
                              isGreaterThanOrEqualTo: context
                                  .read<PriceFilterProvider>()
                                  .minArticlePrice)
                          .orderBy('total points')
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection('Articles')
                          .orderBy('total points')
                          .snapshots())
                  : (context.read<PriceFilterProvider>().isArticlesFiltered &&
                          context.read<PriceFilterProvider>().minArticlePrice >
                              0 &&
                          context.read<PriceFilterProvider>().maxArticlePrice >
                              context
                                  .read<PriceFilterProvider>()
                                  .minArticlePrice
                      ? FirebaseFirestore.instance
                          .collection('Articles')
                          .where('price',
                              isLessThanOrEqualTo: context
                                  .read<PriceFilterProvider>()
                                  .maxArticlePrice)
                          .where('price',
                              isGreaterThanOrEqualTo: context
                                  .read<PriceFilterProvider>()
                                  .minArticlePrice)
                          .where('category',
                              arrayContainsAny: context.read<SearchFilterProvider>().articlesFilters)
                          .orderBy('total points')
                          .snapshots()
                      : FirebaseFirestore.instance.collection('Articles').where('category', arrayContainsAny: context.read<SearchFilterProvider>().articlesFilters).orderBy('total points').snapshots())),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                return GridView.builder(
                  cacheExtent: 2800,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: manageWidth(context, 10),
                    childAspectRatio: 0.6,
                  ),
                  itemCount: snapshot.data!.docs.isEmpty
                      ? 1
                      : snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: AppBarTitleText(
                              title: "Aucun article disponible", size: 17));
                    }
                    Map<String, dynamic> articleData =
                        snapshot.data!.docs[index].data();

                    List<NetworkArticleColor> colors = [];

                    for (var element in articleData['colors']) {
                      colors.add(NetworkArticleColor(
                          color: element['name'],
                          imageUrl: element['image url'],
                          amount: element['amount'],
                          sizes: element['sizes']));
                    }
                    var article = Article(
                        id: snapshot.data!.docs[index].id,
                        name: articleData['name'],
                        price: articleData['price'] * 1.0,
                        categories: articleData['category'],
                        sellerId: articleData['sellerId'],
                        amount: articleData['amount'],
                        description: articleData['description'],
                        averageRate: articleData['average rate'] * 1.0,
                        totalPoints: articleData['total points'] * 1.0,
                        ratesNumber: articleData['rates number'],
                        date: (articleData['date'] as Timestamp).toDate(),
                        status: articleData['status'],
                        sellerName: articleData['seller name'],
                        deliveryInformations:
                            articleData['delivery informations'],
                        images: articleData['images'],
                        colors: colors);

                    return Stack(
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ArticleDetailsPage(
                                    articleId: article.id);
                              }));
                            },
                            child: ArticleView(article: article)),
                        Padding(
                          padding:
                              EdgeInsets.only(top: manageHeight(context, 95)),
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const HomeAddToFavorite(
                                    color: Colors.grey,
                                  );
                                }
                                var data = snapshot.data!.data();
                                var favourites = [];
                                if ((data!["wishlist"]) != null) {
                                  favourites = data["wishlist"];
                                  return GestureDetector(
                                    child: HomeAddToFavorite(
                                      color: favourites.contains(article.id)
                                          ? const Color.fromARGB(
                                              164, 253, 120, 162)
                                          : Colors.blueGrey,
                                    ),
                                    onTap: () {
                                      addToWishlist(article.id!);
                                    },
                                  );
                                }

                                return GestureDetector(
                                  child: HomeAddToFavorite(
                                    color: favourites.contains(article.id)
                                        ? const Color.fromARGB(
                                            164, 253, 120, 162)
                                        : Colors.blueGrey,
                                  ),
                                  onTap: () {
                                    addToWishlist(article.id!);
                                  },
                                );
                              }),
                        )
                      ],
                    );
                  },
                );
              }),
        );
      },
    );
  }
}

class ServicesFeed extends StatefulWidget {
  const ServicesFeed({super.key});

  @override
  State<ServicesFeed> createState() => _ServicesFeedState();
}

class _ServicesFeedState extends State<ServicesFeed> {
  @override
  Widget build(BuildContext context) {
    Future<void> addToWishlist(String articleID) async {
      try {
        DocumentReference userRef = FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid);
        DocumentSnapshot userSnapshot = await userRef.get();

        if (userSnapshot.exists) {
          var data = userSnapshot.data() as Map<String, dynamic>;
          List<String> wishlist = List.from(data['wishlist'] ?? []);

          // Vérifier si l'article est déjà présent dans la wishlist
          if (!wishlist.contains(articleID)) {
            // Utiliser FieldValue.arrayUnion pour ajouter l'article à la wishlist
            await userRef.update({
              'wishlist': FieldValue.arrayUnion([articleID])
            });

            const snackBar = SnackBar(
              content: Text("Service ajouté dans la Wish List"),
              backgroundColor: Colors.green,
            );

            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else {
            const snackBar = SnackBar(
              content: Text("Ce service est déjà dans votre Wish List"),
              backgroundColor: Colors.red,
            );

            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        }
      } catch (error) {
        const snackBar = SnackBar(
          content: Text(
              "Une erreur s'est produite, impossible de poursuivre cette action."),
          backgroundColor: Colors.red,
        );

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    return Consumer<PriceFilterProvider>(
      builder: (context, v, child) {
        return Consumer<LocationProvider>(
          builder: (context, locationProvider, child) {
            if (locationProvider.isLocationFiltered &&
                locationProvider.center != null) {
              return Consumer<SearchFilterProvider>(
                  builder: (context, value, child) => StreamBuilder<
                          List<DocumentSnapshot>>(
                      stream: value.servicesFilters.isEmpty
                          ? (v.isServicesFiltered && v.minServicePrice >= 0 && v.maxServicePrice > v.minServicePrice
                              ? GeoFlutterFire()
                                  .collection(
                                      collectionRef: FirebaseFirestore.instance
                                          .collection('Services')
                                          .where('price',
                                              isGreaterThanOrEqualTo:
                                                  v.minServicePrice,
                                              isLessThanOrEqualTo:
                                                  v.maxServicePrice))
                                  .within(
                                      center: locationProvider.center!,
                                      radius: locationProvider.radius,
                                      field: "gelocation")
                              : GeoFlutterFire().collection(collectionRef: FirebaseFirestore.instance.collection('Services')).within(
                                  center: locationProvider.center!,
                                  radius: locationProvider.radius,
                                  field: "gelocation"))
                          : (v.isServicesFiltered &&
                                  v.minServicePrice >= 0 &&
                                  v.maxServicePrice > v.minServicePrice
                              ? GeoFlutterFire().collection(collectionRef: FirebaseFirestore.instance.collection('Services').where('categories', arrayContainsAny: value.servicesFilters).where('price', isGreaterThanOrEqualTo: v.minServicePrice, isLessThanOrEqualTo: v.maxServicePrice)).within(
                                  center: locationProvider.center!,
                                  radius: locationProvider.radius,
                                  field: "gelocation")
                              : GeoFlutterFire()
                                  .collection(collectionRef: FirebaseFirestore.instance.collection('Services').where('categories', arrayContainsAny: value.servicesFilters))
                                  .within(center: locationProvider.center!, radius: locationProvider.radius, field: "gelocation")),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          const SizedBox();
                        }

                        return GridView.builder(
                          cacheExtent: 2800,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: manageWidth(context, 10),
                            childAspectRatio: 0.6,
                          ),
                          itemCount: snapshot.data!.isEmpty
                              ? 1
                              : snapshot.data!.length,
                          itemBuilder: (context, index) {
                            if (snapshot.data!.isEmpty) {
                              return Center(
                                  child: AppBarTitleText(
                                      title: "Aucun service disponible",
                                      size: manageWidth(context, 17)));
                            }
                            Map<String, dynamic> serviceData =
                                snapshot.data![index].data()
                                    as Map<String, dynamic>;

                            var service = Service(
                                location: serviceData['location'],
                                id: snapshot.data![index].id,
                                name: serviceData['name'],
                                price: serviceData['price'] * 1.0,
                                categories: serviceData['categories'],
                                sellerId: serviceData['sellerId'],
                                duration: serviceData['duration'],
                                description: serviceData['description'],
                                averageRate: serviceData['average rate'] * 1.0,
                                date:
                                    (serviceData['date'] as Timestamp).toDate(),
                                images: serviceData['images'],
                                ratesNumber: serviceData['rates number'],
                                sellerName: serviceData['seller name'],
                                status: serviceData['status'],
                                totalPoints: serviceData['total points'] * 1.0,
                                creneauReservationStatus:
                                    serviceData["creneau reservation status"],
                                crenaux: serviceData["crenaux"]);

                            return Stack(
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return ServiceDetailPage(
                                            serviceId: service.id);
                                      }));
                                    },
                                    child: ServiceView(
                                      service: service,
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        top: manageHeight(context, 95)),
                                    child: GestureDetector(
                                        child: StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('Users')
                                                .doc(FirebaseAuth
                                                    .instance.currentUser!.uid)
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const HomeAddToFavorite(
                                                  color: Colors.grey,
                                                );
                                              }
                                              var data = snapshot.data!.data();
                                              var favourites =
                                                  (data!["wishlist"]) ?? [];
                                              return GestureDetector(
                                                child: HomeAddToFavorite(
                                                  color: (favourites as List)
                                                          .contains(service.id)
                                                      ? const Color.fromARGB(
                                                          164, 253, 120, 162)
                                                      : Colors.blueGrey,
                                                ),
                                                onTap: () {
                                                  addToWishlist(service.id!);
                                                },
                                              );
                                            })))
                              ],
                            );
                          },
                        );
                      }));
            }
            return Consumer<SearchFilterProvider>(
                builder: (context, value, child) => StreamBuilder(
                    stream: value.servicesFilters.isEmpty
                        ? (v.isServicesFiltered &&
                                v.minServicePrice >= 0 &&
                                v.maxServicePrice > v.minServicePrice
                            ? FirebaseFirestore.instance
                                .collection('Services')
                                .where('price',
                                    isGreaterThanOrEqualTo: v.minServicePrice,
                                    isLessThanOrEqualTo: v.maxServicePrice)
                                .orderBy('total points')
                                .snapshots()
                            : FirebaseFirestore.instance
                                .collection('Services')
                                .orderBy('total points')
                                .snapshots())
                        : (v.isServicesFiltered &&
                                v.minServicePrice >= 0 &&
                                v.maxServicePrice > v.minServicePrice
                            ? FirebaseFirestore.instance
                                .collection('Services')
                                .where('categories',
                                    arrayContainsAny: value.servicesFilters)
                                .where('price',
                                    isGreaterThanOrEqualTo: v.minServicePrice,
                                    isLessThanOrEqualTo: v.maxServicePrice)
                                .orderBy('total points')
                                .snapshots()
                            : FirebaseFirestore.instance
                                .collection('Services')
                                .where('categories',
                                    arrayContainsAny: value.servicesFilters)
                                .orderBy('total points')
                                .snapshots()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      }

                      return GridView.builder(
                        cacheExtent: 2800,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: manageWidth(context, 10),
                          childAspectRatio: 0.6,
                        ),
                        itemCount: snapshot.data!.docs.isEmpty
                            ? 1
                            : snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          if (snapshot.data!.docs.isEmpty) {
                            return Center(
                                child: AppBarTitleText(
                                    title: "Aucun service disponible",
                                    size: manageWidth(context, 17)));
                          }
                          Map<String, dynamic> serviceData =
                              snapshot.data!.docs[index].data();

                          var service = Service(
                              location: serviceData['location'],
                              id: snapshot.data!.docs[index].id,
                              name: serviceData['name'],
                              price: serviceData['price'] * 1.0,
                              categories: serviceData['categories'],
                              sellerId: serviceData['sellerId'],
                              duration: serviceData['duration'],
                              description: serviceData['description'],
                              averageRate: serviceData['average rate'] * 1.0,
                              date: (serviceData['date'] as Timestamp).toDate(),
                              images: serviceData['images'],
                              ratesNumber: serviceData['rates number'],
                              sellerName: serviceData['seller name'],
                              status: serviceData['status'],
                              totalPoints: serviceData['total points'] * 1.0,
                              creneauReservationStatus:
                                  serviceData["creneau reservation status"],
                              crenaux: serviceData["crenaux"]);

                          return Stack(
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return ServiceDetailPage(
                                          serviceId: service.id);
                                    }));
                                  },
                                  child: ServiceView(
                                    service: service,
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: manageHeight(context, 95)),
                                  child: GestureDetector(
                                      child: StreamBuilder(
                                          stream: FirebaseFirestore.instance
                                              .collection('Users')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const HomeAddToFavorite(
                                                color: Colors.grey,
                                              );
                                            }
                                            var data = snapshot.data!.data();
                                            var favourites =
                                                (data!["wishlist"]) ?? [];
                                            return GestureDetector(
                                              child: HomeAddToFavorite(
                                                color: (favourites as List)
                                                        .contains(service.id)
                                                    ? const Color.fromARGB(
                                                        164, 253, 120, 162)
                                                    : Colors.blueGrey,
                                              ),
                                              onTap: () {
                                                addToWishlist(service.id!);
                                              },
                                            );
                                          })))
                            ],
                          );
                        },
                      );
                    }));
          },
        );
      },
    );
  }
}

List<Widget> feed = const [ArticlesFeed(), ServicesFeed()];
