import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/filters.dart';
import 'package:trade_hart/model/location_provider.dart';
import 'package:trade_hart/model/price_filter_provider.dart';
import 'package:trade_hart/model/search_filter_provider.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/views/main_page_components/app_bar_view.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/search_view_components/filter_button.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/selection_button.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/selection_divider.dart';
import 'package:trade_hart/views/main_page_components/pages/article_details_page.dart';
import 'package:trade_hart/views/main_page_components/pages/filters_page.dart';
import 'package:trade_hart/views/main_page_components/pages/history_page.dart';
import 'package:trade_hart/views/main_page_components/pages/seller_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_detail_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_provider_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController controller = TextEditingController();
  String search = "";
  int groupValue = 0;
  bool eshopSelection = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarView(title: "TradeHart").appBarsetter(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(
                    manageWidth(context, 10),
                    manageHeight(context, 3),
                    manageWidth(context, 0),
                    manageHeight(context, 0),
                  ),
                  width: manageWidth(context, 275),
                  height: manageHeight(context, 52),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(manageHeight(context, 27.5)),
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.23),
                        spreadRadius: manageWidth(context, 1.5),
                        blurRadius: manageWidth(context, 8),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: manageWidth(context, 15)),
                      Icon(
                        Icons.search,
                        size: manageWidth(context, 20),
                      ),
                      SizedBox(
                        width: manageWidth(context, 190),
                        height: manageHeight(context, 50),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              search = controller.text;
                            });
                          },
                          autofocus: true,
                          controller: controller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search...',
                            contentPadding: EdgeInsets.fromLTRB(
                              manageWidth(context, 15.50),
                              manageHeight(context, 15.50),
                              manageWidth(context, 15.50),
                              manageHeight(context, 15.50),
                            ),
                            hintStyle: TextStyle(
                                color: const Color.fromARGB(255, 128, 128, 128),
                                fontSize: manageWidth(context, 16),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => const HistoryPage())));
                          },
                          icon: Icon(
                            Icons.history_sharp,
                            size: manageWidth(context, 20),
                          ))
                    ],
                  ),
                ),
                GestureDetector(
                  child: const FilterButton(),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FilterPage(
                              categories: eshopSelection
                                  ? articlesFilters
                                  : serviceFilters))),
                )
              ],
            ),

            //Selection
            SizedBox(height: manageHeight(context, 13)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SelectionButton(
                  selection: "e-shop",
                  changeSelection: () {
                    setState(() {
                      eshopSelection = true;
                    });
                  },
                  buttonColor:
                      eshopSelection ? AppColors.mainColor : Colors.white,
                  textColor:
                      eshopSelection ? Colors.white : AppColors.mainColor,
                ),
                const SelectionDivider(),
                SelectionButton(
                  selection: "services",
                  changeSelection: () {
                    setState(() {
                      eshopSelection = false;
                    });
                  },
                  buttonColor:
                      eshopSelection ? Colors.white : AppColors.mainColor,
                  textColor:
                      eshopSelection ? AppColors.mainColor : Colors.white,
                ),
              ],
            ),
            SizedBox(height: manageHeight(context, 10)),
            Row(
              children: [
                SizedBox(width: manageWidth(context, 10)),
                Radio(
                  value: 0,
                  groupValue: groupValue,
                  onChanged: (value) {
                    setState(() {
                      groupValue = value!;
                    });
                  },
                ),
                Text(
                  eshopSelection ? "Articles" : "Services",
                  style: GoogleFonts.poppins(
                    fontSize: manageWidth(context, 16),
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: manageWidth(context, 60)),
                Radio(
                  value: 1,
                  groupValue: groupValue,
                  onChanged: (value) {
                    setState(() {
                      groupValue = value!;
                    });
                  },
                ),
                Text(
                  eshopSelection ? "Boutiques" : "Prestataires",
                  style: GoogleFonts.poppins(
                    fontSize: manageWidth(context, 16),
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Consumer<SearchFilterProvider>(
              builder: (context, value, child) => Container(
                margin: EdgeInsets.only(left: manageWidth(context, 10)),
                height: eshopSelection
                    ? value.articlesFilters.isEmpty
                        ? manageHeight(context, 1)
                        : manageHeight(context, 45)
                    : value.servicesFilters.isEmpty
                        ? manageHeight(context, 1)
                        : manageHeight(context, 45),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: (eshopSelection && value.articlesFilters.isEmpty) ||
                          (!eshopSelection && value.servicesFilters.isEmpty)
                      ? [const SizedBox()]
                      : eshopSelection
                          ? value.articlesFilters
                              .map((e) => Container(
                                    padding: EdgeInsets.only(
                                      left: manageWidth(context, 10),
                                      right: manageWidth(context, 10),
                                    ),
                                    margin: EdgeInsets.fromLTRB(
                                      manageWidth(context, 5),
                                      manageHeight(context, 5),
                                      manageWidth(context, 5),
                                      manageHeight(context, 5),
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 180, 92, 159),
                                        width: manageWidth(context, 1.0),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          manageHeight(context, 15)),
                                    ),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              value
                                                  .removeFromArticlesFilters(e);
                                            },
                                            child: Icon(
                                              CupertinoIcons.clear,
                                              size: manageWidth(context, 18),
                                              color: const Color.fromARGB(
                                                  255, 180, 92, 159),
                                            ),
                                          ),
                                          SizedBox(
                                              width: manageWidth(context, 3)),
                                          Text(
                                            e,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w400,
                                              fontSize:
                                                  manageWidth(context, 15),
                                              color: const Color.fromARGB(
                                                  255, 180, 92, 159),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList()
                          : value.servicesFilters
                              .map((e) => Container(
                                    padding: EdgeInsets.only(
                                      left: manageWidth(context, 10),
                                      right: manageWidth(context, 10),
                                    ),
                                    margin: EdgeInsets.fromLTRB(
                                      manageWidth(context, 5),
                                      manageHeight(context, 5),
                                      manageWidth(context, 5),
                                      manageHeight(context, 5),
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 180, 92, 159),
                                        width: manageWidth(context, 1.0),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          manageHeight(context, 15)),
                                    ),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              value
                                                  .removeFromServicesFilters(e);
                                            },
                                            child: Icon(
                                              CupertinoIcons.clear,
                                              size: manageWidth(context, 18),
                                              color: const Color.fromARGB(
                                                  255, 180, 92, 159),
                                            ),
                                          ),
                                          SizedBox(
                                              width: manageWidth(context, 3)),
                                          Text(
                                            e,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w400,
                                              fontSize:
                                                  manageWidth(context, 15),
                                              color: const Color.fromARGB(
                                                  255, 180, 92, 159),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                ),
              ),
            ),
            SizedBox(height: manageHeight(context, 10)),

            Consumer<LocationProvider>(
              builder: (context, locationProvider, child) {
                if (!eshopSelection &&
                    locationProvider.isLocationFiltered &&
                    locationProvider.center != null) {
                  return Consumer<PriceFilterProvider>(
                    builder: (context, v, child) {
                      return Consumer<SearchFilterProvider>(
                        builder: (context, value, child) {
                          return StreamBuilder<List<DocumentSnapshot>>(
                              stream: groupValue == 0
                                  ? (value.servicesFilters.isEmpty
                                      ? (v.isServicesFiltered &&
                                              v.minServicePrice >= 0 &&
                                              v.maxServicePrice >=
                                                  v.minServicePrice
                                          ? GeoFlutterFire().collection(collectionRef: FirebaseFirestore.instance.collection('Services').where('price', isLessThanOrEqualTo: v.maxServicePrice, isGreaterThanOrEqualTo: v.minServicePrice)).within(
                                              center: locationProvider.center!,
                                              radius: locationProvider.radius,
                                              field: "gelocation")
                                          : GeoFlutterFire().collection(collectionRef: FirebaseFirestore.instance.collection('Services')).within(
                                              center: locationProvider.center!,
                                              radius: locationProvider.radius,
                                              field: "gelocation"))
                                      : (v.isServicesFiltered &&
                                              v.minServicePrice >= 0 &&
                                              v.maxServicePrice >=
                                                  v.minServicePrice
                                          ? GeoFlutterFire().collection(collectionRef: FirebaseFirestore.instance.collection('Services').where('categories', arrayContainsAny: value.servicesFilters).where('price', isLessThanOrEqualTo: v.maxServicePrice, isGreaterThanOrEqualTo: v.minServicePrice)).within(
                                              center: locationProvider.center!,
                                              radius: locationProvider.radius,
                                              field: "gelocation")
                                          : GeoFlutterFire().collection(collectionRef: FirebaseFirestore.instance.collection('Services').where('categories', arrayContainsAny: value.servicesFilters)).within(
                                              center: locationProvider.center!,
                                              radius: locationProvider.radius,
                                              field: "gelocation")))
                                  : GeoFlutterFire().collection(collectionRef: FirebaseFirestore.instance.collection('Users').where('user type', isEqualTo: 'provider')).within(
                                      center: locationProvider.center!,
                                      radius: locationProvider.radius,
                                      field: "gelocation"),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox();
                                }

                                var data = groupValue == 1
                                    ? snapshot.data!
                                        .where((element) => ((element.data()
                                                    as Map<String, dynamic>)["service"]
                                                ["name"] as String)
                                            .toLowerCase()
                                            .trim()
                                            .startsWith(
                                                search.toLowerCase().trim()))
                                        .toList()
                                    : snapshot.data!
                                        .where((element) => ((element.data()
                                                    as Map<String, dynamic>)["name"]
                                                as String)
                                            .toLowerCase()
                                            .trim()
                                            .startsWith(search.toLowerCase().trim()))
                                        .toList();

                                if (data.isEmpty || !snapshot.hasData) {
                                  return StreamBuilder<List<DocumentSnapshot>>(
                                      stream: groupValue == 0
                                          ? (value.servicesFilters.isEmpty
                                              ? (v.isServicesFiltered && v.minServicePrice >= 0 && v.maxServicePrice >= v.minServicePrice
                                                  ? GeoFlutterFire().collection(collectionRef: FirebaseFirestore.instance.collection('Services').where('categories', arrayContainsAny: retrieveSubfilters(serviceHashtags, search)).where('categories', arrayContainsAny: retrieveSubfilters(serviceHashtags, search)).where('price', isLessThanOrEqualTo: v.maxServicePrice, isGreaterThanOrEqualTo: v.minServicePrice)).within(
                                                      center: locationProvider
                                                          .center!,
                                                      radius: locationProvider
                                                          .radius,
                                                      field: "gelocation")
                                                  : GeoFlutterFire().collection(collectionRef: FirebaseFirestore.instance.collection('Services').where('categories', arrayContainsAny: retrieveSubfilters(serviceHashtags, search))).within(
                                                      center: locationProvider
                                                          .center!,
                                                      radius: locationProvider
                                                          .radius,
                                                      field: "gelocation"))
                                              : (v.isServicesFiltered &&
                                                      v.minServicePrice >= 0 &&
                                                      v.maxServicePrice >=
                                                          v.minServicePrice
                                                  ? GeoFlutterFire().collection(collectionRef: FirebaseFirestore.instance.collection('Services').where('categories', arrayContainsAny: retrieveSubfilters(serviceHashtags, search)).where('categories', arrayContainsAny: value.servicesFilters).where('price', isLessThanOrEqualTo: v.maxServicePrice, isGreaterThanOrEqualTo: v.minServicePrice)).within(
                                                      center: locationProvider.center!,
                                                      radius: locationProvider.radius,
                                                      field: "gelocation")
                                                  : GeoFlutterFire().collection(collectionRef: FirebaseFirestore.instance.collection('Services').where('categories', arrayContainsAny: retrieveSubfilters(serviceHashtags, search)).where('categories', arrayContainsAny: value.servicesFilters)).within(center: locationProvider.center!, radius: locationProvider.radius, field: "gelocation")))
                                          : GeoFlutterFire().collection(collectionRef: FirebaseFirestore.instance.collection('Users').where('user type', isEqualTo: 'provider')).within(center: locationProvider.center!, radius: locationProvider.radius, field: "gelocation"),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const SizedBox();
                                        }
                                        if (!snapshot.hasData) {
                                          return const Text(
                                              "Aucun résultat de recherche");
                                        }

                                        var data = snapshot.data;

                                        if (data!.isEmpty) {
                                          return const Text(
                                              "Aucun résultat de recherche");
                                        }

                                        return Container(
                                          height: manageHeight(context, 465),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.96,
                                          margin: EdgeInsets.fromLTRB(
                                            manageWidth(context, 7.5),
                                            manageHeight(context, 0),
                                            manageWidth(context, 7.5),
                                            manageHeight(context, 0),
                                          ),
                                          padding: EdgeInsets.fromLTRB(
                                            manageWidth(context, 5),
                                            manageHeight(context, 5),
                                            manageWidth(context, 5),
                                            manageHeight(context, 8),
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: manageWidth(context, 0.1),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                                manageHeight(context, 15)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                                spreadRadius:
                                                    manageWidth(context, 1.5),
                                                blurRadius:
                                                    manageWidth(context, 5),
                                                offset: Offset(0,
                                                    manageHeight(context, 2)),
                                              ),
                                            ],
                                          ),
                                          child: !snapshot.hasData
                                              ? const Center(
                                                  child: Text(
                                                      "Aucune donnée relative à votre recherche n'a été trouvée"))
                                              : ListView(
                                                  children: data.map((e) {
                                                    Map<String, dynamic>
                                                        donnee = e.data()
                                                            as Map<String,
                                                                dynamic>;
                                                    return Column(
                                                      children: [
                                                        SizedBox(
                                                          height: manageHeight(
                                                              context, 20),
                                                        ),
                                                        ListTile(
                                                          onTap: groupValue ==
                                                                      0 &&
                                                                  eshopSelection
                                                              ? () {
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'Users')
                                                                      .doc(FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .uid)
                                                                      .collection(
                                                                          'History')
                                                                      .add({
                                                                    "name": donnee[
                                                                        "name"],
                                                                    'id': e.id,
                                                                    'type':
                                                                        'article',
                                                                    'time':
                                                                        Timestamp
                                                                            .now()
                                                                  });
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              ArticleDetailsPage(articleId: e.id)));
                                                                }
                                                              : groupValue ==
                                                                          1 &&
                                                                      eshopSelection
                                                                  ? () {
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'Users')
                                                                          .doc(FirebaseAuth
                                                                              .instance
                                                                              .currentUser!
                                                                              .uid)
                                                                          .collection(
                                                                              'History')
                                                                          .add({
                                                                        "name": donnee["shop"]
                                                                            [
                                                                            "name"],
                                                                        'id': e
                                                                            .id,
                                                                        'type':
                                                                            'seller',
                                                                        'time':
                                                                            Timestamp.now()
                                                                      });
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => SellerPage(sellerId: e.id)));
                                                                    }
                                                                  : groupValue ==
                                                                              0 &&
                                                                          !eshopSelection
                                                                      ? () {
                                                                          FirebaseFirestore
                                                                              .instance
                                                                              .collection(
                                                                                  'Users')
                                                                              .doc(FirebaseAuth
                                                                                  .instance.currentUser!.uid)
                                                                              .collection(
                                                                                  'History')
                                                                              .add({
                                                                            "name":
                                                                                donnee["name"],
                                                                            'id':
                                                                                e.id,
                                                                            'type':
                                                                                'service',
                                                                            'time':
                                                                                Timestamp.now()
                                                                          });
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => ServiceDetailPage(serviceId: e.id)));
                                                                        }
                                                                      : () {
                                                                          FirebaseFirestore
                                                                              .instance
                                                                              .collection('Users')
                                                                              .doc(FirebaseAuth.instance.currentUser!.uid)
                                                                              .collection('History')
                                                                              .add({
                                                                            "name":
                                                                                donnee["service"]["name"],
                                                                            'id':
                                                                                e.id,
                                                                            'type':
                                                                                'provider',
                                                                            'time':
                                                                                Timestamp.now()
                                                                          });
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => ServiceProviderPage(id: e.id)));
                                                                        },
                                                          title: Text(
                                                            groupValue == 0
                                                                ? donnee["name"]
                                                                : donnee[
                                                                        "service"]
                                                                    ["name"],
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts.poppins(
                                                                fontSize:
                                                                    manageWidth(
                                                                        context,
                                                                        16),
                                                                color: Colors
                                                                    .grey
                                                                    .shade800,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                          leading: Container(
                                                            height: manageHeight(
                                                                context,
                                                                groupValue == 0
                                                                    ? 70
                                                                    : 60),
                                                            width: manageWidth(
                                                                context,
                                                                groupValue == 0
                                                                    ? 70
                                                                    : 60),
                                                            decoration:
                                                                BoxDecoration(
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.2),
                                                                  spreadRadius:
                                                                      manageWidth(
                                                                          context,
                                                                          1.5),
                                                                  blurRadius:
                                                                      manageWidth(
                                                                          context,
                                                                          5),
                                                                  offset: Offset(
                                                                      0,
                                                                      manageHeight(
                                                                          context,
                                                                          1.5)),
                                                                ),
                                                              ],
                                                              color: Colors.grey
                                                                  .shade200,
                                                              borderRadius: BorderRadius
                                                                  .circular(manageHeight(
                                                                      context,
                                                                      groupValue ==
                                                                              0
                                                                          ? 70
                                                                          : 60)),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius
                                                                  .circular(manageHeight(
                                                                      context,
                                                                      groupValue ==
                                                                              1
                                                                          ? 35
                                                                          : 10)),
                                                              child:
                                                                  Image.network(
                                                                groupValue == 0
                                                                    ? donnee["images"]
                                                                            [0][
                                                                        "image url"]
                                                                    : donnee[
                                                                            "images"]
                                                                        [
                                                                        "profil image"],
                                                                fit: BoxFit
                                                                    .cover,
                                                                errorBuilder: (context,
                                                                        error,
                                                                        stackTrace) =>
                                                                    SizedBox(
                                                                        height: manageHeight(
                                                                            context,
                                                                            150),
                                                                        width: manageWidth(
                                                                            context,
                                                                            165),
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Icon(
                                                                              CupertinoIcons.exclamationmark_triangle_fill,
                                                                              size: manageWidth(context, 15),
                                                                            ),
                                                                          ],
                                                                        )),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }).toList(),
                                                ),
                                        );
                                      });
                                }

                                return Container(
                                  height: manageHeight(context, 465),
                                  width:
                                      MediaQuery.of(context).size.width * 0.96,
                                  margin: EdgeInsets.fromLTRB(
                                    manageWidth(context, 7.5),
                                    manageHeight(context, 0),
                                    manageWidth(context, 7.5),
                                    manageHeight(context, 0),
                                  ),
                                  padding: EdgeInsets.fromLTRB(
                                    manageWidth(context, 5),
                                    manageHeight(context, 5),
                                    manageWidth(context, 5),
                                    manageHeight(context, 8),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: manageWidth(context, 0.1),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        manageHeight(context, 15)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: manageWidth(context, 1.5),
                                        blurRadius: manageWidth(context, 5),
                                        offset:
                                            Offset(0, manageHeight(context, 2)),
                                      ),
                                    ],
                                  ),
                                  child: !snapshot.hasData
                                      ? const Center(
                                          child: Text(
                                              "Aucune donnée relative à votre recherche n'a été trouvée"))
                                      : ListView(
                                          children: data.map((e) {
                                            Map<String, dynamic> donnee = e
                                                .data() as Map<String, dynamic>;
                                            return Column(
                                              children: [
                                                SizedBox(
                                                  height:
                                                      manageHeight(context, 20),
                                                ),
                                                ListTile(
                                                  onTap: groupValue == 0 &&
                                                          eshopSelection
                                                      ? () {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'Users')
                                                              .doc(FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid)
                                                              .collection(
                                                                  'History')
                                                              .add({
                                                            "name":
                                                                donnee["name"],
                                                            'id': e.id,
                                                            'type': 'article',
                                                            'time':
                                                                Timestamp.now()
                                                          });
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      ArticleDetailsPage(
                                                                          articleId:
                                                                              e.id)));
                                                        }
                                                      : groupValue == 1 &&
                                                              eshopSelection
                                                          ? () {
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Users')
                                                                  .doc(FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid)
                                                                  .collection(
                                                                      'History')
                                                                  .add({
                                                                "name": donnee[
                                                                        "shop"]
                                                                    ["name"],
                                                                'id': e.id,
                                                                'type':
                                                                    'seller',
                                                                'time':
                                                                    Timestamp
                                                                        .now()
                                                              });
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          SellerPage(
                                                                              sellerId: e.id)));
                                                            }
                                                          : groupValue == 0 &&
                                                                  !eshopSelection
                                                              ? () {
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'Users')
                                                                      .doc(FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .uid)
                                                                      .collection(
                                                                          'History')
                                                                      .add({
                                                                    "name": donnee[
                                                                        "name"],
                                                                    'id': e.id,
                                                                    'type':
                                                                        'service',
                                                                    'time':
                                                                        Timestamp
                                                                            .now()
                                                                  });
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              ServiceDetailPage(serviceId: e.id)));
                                                                }
                                                              : () {
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'Users')
                                                                      .doc(FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .uid)
                                                                      .collection(
                                                                          'History')
                                                                      .add({
                                                                    "name": donnee[
                                                                            "service"]
                                                                        [
                                                                        "name"],
                                                                    'id': e.id,
                                                                    'type':
                                                                        'provider',
                                                                    'time':
                                                                        Timestamp
                                                                            .now()
                                                                  });
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              ServiceProviderPage(id: e.id)));
                                                                },
                                                  title: Text(
                                                    groupValue == 0
                                                        ? donnee["name"]
                                                        : donnee["service"]
                                                            ["name"],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.poppins(
                                                        fontSize: manageWidth(
                                                            context, 16),
                                                        color: Colors
                                                            .grey.shade800,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  leading: Container(
                                                    height: manageHeight(
                                                        context,
                                                        groupValue == 0
                                                            ? 70
                                                            : 60),
                                                    width: manageWidth(
                                                        context,
                                                        groupValue == 0
                                                            ? 70
                                                            : 60),
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.2),
                                                          spreadRadius:
                                                              manageWidth(
                                                                  context, 1.5),
                                                          blurRadius:
                                                              manageWidth(
                                                                  context, 5),
                                                          offset: Offset(
                                                              0,
                                                              manageHeight(
                                                                  context,
                                                                  1.5)),
                                                        ),
                                                      ],
                                                      color:
                                                          Colors.grey.shade200,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              manageHeight(
                                                                  context,
                                                                  groupValue ==
                                                                          0
                                                                      ? 70
                                                                      : 60)),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              manageHeight(
                                                                  context,
                                                                  groupValue ==
                                                                          1
                                                                      ? 35
                                                                      : 10)),
                                                      child: Image.network(
                                                        groupValue == 0
                                                            ? donnee["images"]
                                                                [0]["image url"]
                                                            : donnee["images"][
                                                                "profil image"],
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                                error,
                                                                stackTrace) =>
                                                            SizedBox(
                                                                height:
                                                                    manageHeight(
                                                                        context,
                                                                        150),
                                                                width:
                                                                    manageWidth(
                                                                        context,
                                                                        165),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                      CupertinoIcons
                                                                          .exclamationmark_triangle_fill,
                                                                      size: manageWidth(
                                                                          context,
                                                                          15),
                                                                    ),
                                                                  ],
                                                                )),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                );
                              });
                        },
                      );
                    },
                  );
                }
                return Consumer<PriceFilterProvider>(
                  builder: (context, v, child) {
                    return Consumer<SearchFilterProvider>(
                      builder: (context, value, child) {
                        return StreamBuilder(
                            stream: groupValue == 1 && eshopSelection
                                ? FirebaseFirestore.instance
                                    .collection('Users')
                                    .where('user type', isEqualTo: 'seller')
                                    .orderBy('shop.name to lower case')
                                    .startAt([search.toLowerCase()]).snapshots()
                                : groupValue == 0 && eshopSelection
                                    ? value.articlesFilters.isEmpty
                                        ? (v.isArticlesFiltered && v.minArticlePrice >= 0 && v.maxArticlePrice > v.minArticlePrice
                                            ? FirebaseFirestore.instance
                                                .collection('Articles')
                                                .where('price',
                                                    isLessThanOrEqualTo:
                                                        v.maxArticlePrice,
                                                    isGreaterThanOrEqualTo:
                                                        v.minArticlePrice)
                                                .orderBy('name to lower case')
                                                .startAt(
                                                    [search.toLowerCase()]).snapshots()
                                            : FirebaseFirestore.instance
                                                .collection('Articles')
                                                .orderBy('name to lower case')
                                                .startAt(
                                                    [search.toLowerCase()]).snapshots())
                                        : (v.isArticlesFiltered &&
                                                v.minArticlePrice >= 0 &&
                                                v.maxArticlePrice >
                                                    v.minArticlePrice
                                            ? FirebaseFirestore.instance
                                                .collection('Articles')
                                                .where('price',
                                                    isLessThanOrEqualTo:
                                                        v.maxArticlePrice,
                                                    isGreaterThanOrEqualTo: v.minArticlePrice)
                                                .where('category', arrayContainsAny: value.articlesFilters)
                                                .orderBy('name to lower case')
                                                .startAt([search.toLowerCase()]).snapshots()
                                            : FirebaseFirestore.instance.collection('Articles').where('category', arrayContainsAny: value.articlesFilters).orderBy('name to lower case').startAt([search.toLowerCase()]).snapshots())
                                    : groupValue == 0 && !eshopSelection
                                        ? value.servicesFilters.isEmpty
                                            ? (v.isServicesFiltered && v.minServicePrice >= 0 && v.maxServicePrice >= v.minServicePrice ? FirebaseFirestore.instance.collection('Services').where('price', isLessThanOrEqualTo: v.maxServicePrice, isGreaterThanOrEqualTo: v.minServicePrice).orderBy('name to lower case').startAt([search.toLowerCase()]).snapshots() : FirebaseFirestore.instance.collection('Services').orderBy('name to lower case').startAt([search.toLowerCase()]).snapshots())
                                            : (v.isServicesFiltered && v.minServicePrice >= 0 && v.maxServicePrice >= v.minServicePrice ? FirebaseFirestore.instance.collection('Services').where('categories', arrayContainsAny: value.servicesFilters).where('price', isLessThanOrEqualTo: v.maxServicePrice, isGreaterThanOrEqualTo: v.minServicePrice).orderBy('name to lower case').startAt([search.toLowerCase()]).snapshots() : FirebaseFirestore.instance.collection('Services').where('categories', arrayContainsAny: value.servicesFilters).orderBy('name to lower case').startAt([search.toLowerCase()]).snapshots())
                                        : FirebaseFirestore.instance.collection('Users').where('user type', isEqualTo: 'provider').orderBy('service.name to lower case').startAt([search.toLowerCase()]).snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox();
                              }

                              var data = snapshot.data!.docs;

                              if (data.isEmpty || !snapshot.hasData) {
                                return StreamBuilder(
                                    stream: groupValue == 1 && eshopSelection
                                        ? FirebaseFirestore.instance
                                            .collection('Users')
                                            .where('user type',
                                                isEqualTo: 'seller')
                                            .orderBy('shop.name to lower case')
                                            .startAt(
                                                [search.toLowerCase()]).snapshots()
                                        : groupValue == 0 && eshopSelection
                                            ? value.articlesFilters.isEmpty
                                                ? (v.isArticlesFiltered && v.minArticlePrice >= 0 && v.maxArticlePrice > v.minArticlePrice
                                                    ? FirebaseFirestore.instance
                                                        .collection('Articles')
                                                        .where('price',
                                                            isLessThanOrEqualTo: v
                                                                .maxArticlePrice,
                                                            isGreaterThanOrEqualTo: v
                                                                .minArticlePrice)
                                                        .orderBy(
                                                            'name to lower case')
                                                        .where('category',
                                                            arrayContainsAny: retrieveSubfilters(
                                                                articleHashtags, search))
                                                        .snapshots()
                                                    : FirebaseFirestore.instance
                                                        .collection('Articles')
                                                        .orderBy(
                                                            'name to lower case')
                                                        .where('category',
                                                            arrayContainsAny:
                                                                retrieveSubfilters(
                                                                    articleHashtags, search))
                                                        .snapshots())
                                                : (v.isArticlesFiltered && v.minArticlePrice >= 0 && v.maxArticlePrice > v.minArticlePrice
                                                    ? FirebaseFirestore.instance
                                                        .collection('Articles')
                                                        .where('price', isLessThanOrEqualTo: v.maxArticlePrice, isGreaterThanOrEqualTo: v.minArticlePrice)
                                                        .where('category', arrayContainsAny: value.articlesFilters)
                                                        .orderBy('name to lower case')
                                                        .where('category', arrayContainsAny: retrieveSubfilters(articleHashtags, search))
                                                        .snapshots()
                                                    : FirebaseFirestore.instance.collection('Articles').where('category', arrayContainsAny: value.articlesFilters).orderBy('name to lower case').where('category', arrayContainsAny: retrieveSubfilters(articleHashtags, search)).snapshots())
                                            : groupValue == 0 && !eshopSelection
                                                ? value.servicesFilters.isEmpty
                                                    ? (v.isServicesFiltered && v.minServicePrice >= 0 && v.maxServicePrice >= v.minServicePrice ? FirebaseFirestore.instance.collection('Services').where('price', isLessThanOrEqualTo: v.maxServicePrice, isGreaterThanOrEqualTo: v.minServicePrice).orderBy('name to lower case').startAt([search.toLowerCase()]).snapshots() : FirebaseFirestore.instance.collection('Services').orderBy('name to lower case').startAt([search.toLowerCase()]).snapshots())
                                                    : (v.isServicesFiltered && v.minServicePrice >= 0 && v.maxServicePrice >= v.minServicePrice ? FirebaseFirestore.instance.collection('Services').where('categories', arrayContainsAny: value.servicesFilters).where('price', isLessThanOrEqualTo: v.maxServicePrice, isGreaterThanOrEqualTo: v.minServicePrice).orderBy('name to lower case').startAt([search.toLowerCase()]).snapshots() : FirebaseFirestore.instance.collection('Services').where('categories', arrayContainsAny: value.servicesFilters).orderBy('name to lower case').startAt([search.toLowerCase()]).snapshots())
                                                : FirebaseFirestore.instance.collection('Users').where('user type', isEqualTo: 'provider').orderBy('service.name to lower case').where('category', arrayContainsAny: retrieveSubfilters(articleHashtags, search)).snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const SizedBox();
                                      }

                                      var data = snapshot.data!.docs;

                                      if (data.isEmpty || !snapshot.hasData) {
                                        return const Text(
                                            "Aucun résultat de recherche");
                                      }

                                      return Container(
                                        height: manageHeight(context, 465),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.96,
                                        margin: EdgeInsets.fromLTRB(
                                          manageWidth(context, 7.5),
                                          manageHeight(context, 0),
                                          manageWidth(context, 7.5),
                                          manageHeight(context, 0),
                                        ),
                                        padding: EdgeInsets.fromLTRB(
                                          manageWidth(context, 5),
                                          manageHeight(context, 5),
                                          manageWidth(context, 5),
                                          manageHeight(context, 8),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: manageWidth(context, 0.1),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              manageHeight(context, 15)),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.3),
                                              spreadRadius:
                                                  manageWidth(context, 1.5),
                                              blurRadius:
                                                  manageWidth(context, 5),
                                              offset: Offset(
                                                  0, manageHeight(context, 2)),
                                            ),
                                          ],
                                        ),
                                        child: !snapshot.hasData
                                            ? const Center(
                                                child: Text(
                                                    "Aucune donnée relative à votre recherche n'a été trouvée"))
                                            : ListView(
                                                children: data.map((e) {
                                                  var donnee = e.data();
                                                  return Column(
                                                    children: [
                                                      SizedBox(
                                                        height: manageHeight(
                                                            context, 20),
                                                      ),
                                                      ListTile(
                                                        onTap: groupValue ==
                                                                    0 &&
                                                                eshopSelection
                                                            ? () {
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'Users')
                                                                    .doc(FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid)
                                                                    .collection(
                                                                        'History')
                                                                    .add({
                                                                  "name": donnee[
                                                                      "name"],
                                                                  'id': e.id,
                                                                  'type':
                                                                      'article',
                                                                  'time':
                                                                      Timestamp
                                                                          .now()
                                                                });
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                ArticleDetailsPage(articleId: e.id)));
                                                              }
                                                            : groupValue == 1 &&
                                                                    eshopSelection
                                                                ? () {
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'Users')
                                                                        .doc(FirebaseAuth
                                                                            .instance
                                                                            .currentUser!
                                                                            .uid)
                                                                        .collection(
                                                                            'History')
                                                                        .add({
                                                                      "name": donnee[
                                                                              "shop"]
                                                                          [
                                                                          "name"],
                                                                      'id':
                                                                          e.id,
                                                                      'type':
                                                                          'seller',
                                                                      'time': Timestamp
                                                                          .now()
                                                                    });
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                SellerPage(sellerId: e.id)));
                                                                  }
                                                                : groupValue ==
                                                                            0 &&
                                                                        !eshopSelection
                                                                    ? () {
                                                                        FirebaseFirestore
                                                                            .instance
                                                                            .collection(
                                                                                'Users')
                                                                            .doc(FirebaseAuth
                                                                                .instance.currentUser!.uid)
                                                                            .collection(
                                                                                'History')
                                                                            .add({
                                                                          "name":
                                                                              donnee["name"],
                                                                          'id':
                                                                              e.id,
                                                                          'type':
                                                                              'service',
                                                                          'time':
                                                                              Timestamp.now()
                                                                        });
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => ServiceDetailPage(serviceId: e.id)));
                                                                      }
                                                                    : () {
                                                                        FirebaseFirestore
                                                                            .instance
                                                                            .collection('Users')
                                                                            .doc(FirebaseAuth.instance.currentUser!.uid)
                                                                            .collection('History')
                                                                            .add({
                                                                          "name":
                                                                              donnee["service"]["name"],
                                                                          'id':
                                                                              e.id,
                                                                          'type':
                                                                              'provider',
                                                                          'time':
                                                                              Timestamp.now()
                                                                        });
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => ServiceProviderPage(id: e.id)));
                                                                      },
                                                        title: Text(
                                                          groupValue == 0
                                                              ? donnee["name"]
                                                              : groupValue ==
                                                                          1 &&
                                                                      eshopSelection
                                                                  ? donnee[
                                                                          "shop"]
                                                                      ["name"]
                                                                  : donnee[
                                                                          "service"]
                                                                      ["name"],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts.poppins(
                                                              fontSize:
                                                                  manageWidth(
                                                                      context,
                                                                      16),
                                                              color: Colors.grey
                                                                  .shade800,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                        leading: Container(
                                                          height: manageHeight(
                                                              context,
                                                              groupValue == 0
                                                                  ? 70
                                                                  : 60),
                                                          width: manageWidth(
                                                              context,
                                                              groupValue == 0
                                                                  ? 70
                                                                  : 60),
                                                          decoration:
                                                              BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.2),
                                                                spreadRadius:
                                                                    manageWidth(
                                                                        context,
                                                                        1.5),
                                                                blurRadius:
                                                                    manageWidth(
                                                                        context,
                                                                        5),
                                                                offset: Offset(
                                                                    0,
                                                                    manageHeight(
                                                                        context,
                                                                        1.5)),
                                                              ),
                                                            ],
                                                            color: Colors
                                                                .grey.shade200,
                                                            borderRadius: BorderRadius
                                                                .circular(manageHeight(
                                                                    context,
                                                                    groupValue ==
                                                                            0
                                                                        ? 70
                                                                        : 60)),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius
                                                                .circular(manageHeight(
                                                                    context,
                                                                    groupValue ==
                                                                            1
                                                                        ? 35
                                                                        : 10)),
                                                            child:
                                                                Image.network(
                                                              groupValue == 0
                                                                  ? donnee["images"]
                                                                          [0][
                                                                      "image url"]
                                                                  : groupValue ==
                                                                              1 &&
                                                                          eshopSelection
                                                                      ? donnee[
                                                                              "shop"]
                                                                          [
                                                                          "cover image"]
                                                                      : donnee[
                                                                              "images"]
                                                                          [
                                                                          "profil image"],
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (context,
                                                                      error,
                                                                      stackTrace) =>
                                                                  SizedBox(
                                                                      child:
                                                                          Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    CupertinoIcons
                                                                        .exclamationmark_triangle_fill,
                                                                    size: manageWidth(
                                                                        context,
                                                                        20),
                                                                  ),
                                                                ],
                                                              )),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                      );
                                    });
                              }

                              return Container(
                                height: manageHeight(context, 465),
                                width: MediaQuery.of(context).size.width * 0.96,
                                margin: EdgeInsets.fromLTRB(
                                  manageWidth(context, 7.5),
                                  manageHeight(context, 0),
                                  manageWidth(context, 7.5),
                                  manageHeight(context, 0),
                                ),
                                padding: EdgeInsets.fromLTRB(
                                  manageWidth(context, 5),
                                  manageHeight(context, 5),
                                  manageWidth(context, 5),
                                  manageHeight(context, 8),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: manageWidth(context, 0.1),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      manageHeight(context, 15)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: manageWidth(context, 1.5),
                                      blurRadius: manageWidth(context, 5),
                                      offset:
                                          Offset(0, manageHeight(context, 2)),
                                    ),
                                  ],
                                ),
                                child: !snapshot.hasData
                                    ? const Center(
                                        child: Text(
                                            "Aucune donnée relative à votre recherche n'a été trouvée"))
                                    : ListView(
                                        children: data.map((e) {
                                          var donnee = e.data();
                                          return Column(
                                            children: [
                                              SizedBox(
                                                height:
                                                    manageHeight(context, 20),
                                              ),
                                              ListTile(
                                                onTap: groupValue == 0 &&
                                                        eshopSelection
                                                    ? () {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('Users')
                                                            .doc(FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid)
                                                            .collection(
                                                                'History')
                                                            .add({
                                                          "name":
                                                              donnee["name"],
                                                          'id': e.id,
                                                          'type': 'article',
                                                          'time':
                                                              Timestamp.now()
                                                        });
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    ArticleDetailsPage(
                                                                        articleId:
                                                                            e.id)));
                                                      }
                                                    : groupValue == 1 &&
                                                            eshopSelection
                                                        ? () {
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Users')
                                                                .doc(FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid)
                                                                .collection(
                                                                    'History')
                                                                .add({
                                                              "name":
                                                                  donnee["shop"]
                                                                      ["name"],
                                                              'id': e.id,
                                                              'type': 'seller',
                                                              'time': Timestamp
                                                                  .now()
                                                            });
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        SellerPage(
                                                                            sellerId:
                                                                                e.id)));
                                                          }
                                                        : groupValue == 0 &&
                                                                !eshopSelection
                                                            ? () {
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'Users')
                                                                    .doc(FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid)
                                                                    .collection(
                                                                        'History')
                                                                    .add({
                                                                  "name": donnee[
                                                                      "name"],
                                                                  'id': e.id,
                                                                  'type':
                                                                      'service',
                                                                  'time':
                                                                      Timestamp
                                                                          .now()
                                                                });
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                ServiceDetailPage(serviceId: e.id)));
                                                              }
                                                            : () {
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'Users')
                                                                    .doc(FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid)
                                                                    .collection(
                                                                        'History')
                                                                    .add({
                                                                  "name": donnee[
                                                                          "service"]
                                                                      ["name"],
                                                                  'id': e.id,
                                                                  'type':
                                                                      'provider',
                                                                  'time':
                                                                      Timestamp
                                                                          .now()
                                                                });
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                ServiceProviderPage(id: e.id)));
                                                              },
                                                title: Text(
                                                  groupValue == 0
                                                      ? donnee["name"]
                                                      : groupValue == 1 &&
                                                              eshopSelection
                                                          ? donnee["shop"]
                                                              ["name"]
                                                          : donnee["service"]
                                                              ["name"],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: manageWidth(
                                                          context, 16),
                                                      color:
                                                          Colors.grey.shade800,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                leading: Container(
                                                  height: manageHeight(
                                                      context,
                                                      groupValue == 0
                                                          ? 70
                                                          : 60),
                                                  width: manageWidth(
                                                      context,
                                                      groupValue == 0
                                                          ? 70
                                                          : 60),
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.2),
                                                        spreadRadius:
                                                            manageWidth(
                                                                context, 1.5),
                                                        blurRadius: manageWidth(
                                                            context, 5),
                                                        offset: Offset(
                                                            0,
                                                            manageHeight(
                                                                context, 1.5)),
                                                      ),
                                                    ],
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            manageHeight(
                                                                context,
                                                                groupValue == 0
                                                                    ? 70
                                                                    : 60)),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            manageHeight(
                                                                context,
                                                                groupValue == 1
                                                                    ? 35
                                                                    : 10)),
                                                    child: Image.network(
                                                      groupValue == 0
                                                          ? donnee["images"][0]
                                                              ["image url"]
                                                          : groupValue == 1 &&
                                                                  eshopSelection
                                                              ? donnee["shop"][
                                                                  "cover image"]
                                                              : donnee["images"]
                                                                  [
                                                                  "profil image"],
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          SizedBox(
                                                              child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            CupertinoIcons
                                                                .exclamationmark_triangle_fill,
                                                            size: manageWidth(
                                                                context, 20),
                                                          ),
                                                        ],
                                                      )),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                              );
                            });
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
