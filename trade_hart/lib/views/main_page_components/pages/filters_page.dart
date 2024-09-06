// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/filters.dart';
import 'package:trade_hart/model/location_provider.dart';
import 'package:trade_hart/model/price_filter_provider.dart';
import 'package:trade_hart/model/search_filter_provider.dart';
import 'package:trade_hart/model/setting.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/main_back_button.dart';
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';
import 'package:trade_hart/views/main_page_components/pages/sub_filter_page.dart';
import 'package:trade_hart/views/main_page_components/profile_page_components/setting_view.dart';

class FilterPage extends StatefulWidget {
  final Map<Setting, List<String>> categories;
  const FilterPage({super.key, required this.categories});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  var adressLocationController = TextEditingController();
  getLocation() async {
    try {
      var location = Location();
      await location.requestPermission();
      var locationData = await location.getLocation();
      print("${locationData.latitude}  ${locationData.longitude}");
    } on PlatformException catch (e) {
      print("Nous avons une erreur ${e.message}");
    }
  }

  var minController = TextEditingController();
  var maxController = TextEditingController();

  @override
  void initState() {
    getLocation();
    if (widget.categories == articlesFilters) {
      maxController.text =
          context.read<PriceFilterProvider>().maxArticlePrice > 0
              ? context.read<PriceFilterProvider>().maxArticlePrice.toString()
              : "";
      minController.text =
          context.read<PriceFilterProvider>().minArticlePrice > 0
              ? context.read<PriceFilterProvider>().minArticlePrice.toString()
              : "";
    } else {
      maxController.text =
          context.read<PriceFilterProvider>().maxServicePrice > 0
              ? context.read<PriceFilterProvider>().maxServicePrice.toString()
              : "";
      minController.text =
          context.read<PriceFilterProvider>().minServicePrice > 0
              ? context.read<PriceFilterProvider>().minServicePrice.toString()
              : "";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const MainBackButton(),
        title: AppBarTitleText(
          title: "Catégories",
          size: manageWidth(context, 23),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Consumer<PriceFilterProvider>(
              builder: (context, value, child) => Row(
                children: [
                  Checkbox(
                      value: widget.categories == articlesFilters
                          ? value.isArticlesFiltered
                          : value.isServicesFiltered,
                      onChanged: (status) {
                        if (widget.categories == articlesFilters) {
                          value.changeArticleFilteredStatus();
                        } else {
                          value.changeServiceFilteredStatus();
                        }
                      }),
                  AppBarTitleText(
                    title: "Prix :",
                    size: manageWidth(context, 20),
                  ),
                  SizedBox(
                    width: manageWidth(context, 12),
                  ),
                  AuthTextField(
                    controller: minController,
                    hintText: "Min \$",
                    obscuretext: false,
                    keyboardType: TextInputType.number,
                    width: manageWidth(context, 90),
                    forPriceFilter: true,
                    forArticlePriceFilter: widget.categories == articlesFilters,
                    forMaxPrice: false,
                  ),
                  SizedBox(
                    width: manageWidth(context, 12),
                  ),
                  AuthTextField(
                    controller: maxController,
                    hintText: "Max \$",
                    obscuretext: false,
                    keyboardType: TextInputType.number,
                    width: manageWidth(context, 95),
                    forPriceFilter: true,
                    forArticlePriceFilter: widget.categories == articlesFilters,
                    forMaxPrice: true,
                  )
                ],
              ),
            ),
            SizedBox(
              height: widget.categories == serviceFilters
                  ? manageHeight(context, 5)
                  : 0,
            ),
            SizedBox(
              child: widget.categories == serviceFilters
                  ? Consumer<LocationProvider>(
                      builder: (context, locationProvider, child) =>
                          Row(children: [
                        Checkbox(
                            value: locationProvider.isLocationFiltered,
                            onChanged: (value) {
                              locationProvider.updateLocationFilteredStatus();
                            }),
                        GestureDetector(
                          onTap: () {
                            showBottomSheet(
                              backgroundColor: Colors.white,
                              context: context,
                              builder: (context2) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: manageHeight(context, 580),
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: manageHeight(context, 10),
                                            bottom: manageHeight(context, 25)),
                                        height: manageHeight(context, 3),
                                        width: manageWidth(context, 45),
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade700,
                                            borderRadius: BorderRadius.circular(
                                                manageHeight(context, 1.5))),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                              width: manageWidth(context, 35)),
                                          Icon(
                                            Icons.search,
                                            color: Colors.grey.shade800,
                                          ),
                                          SizedBox(
                                            width: manageWidth(context, 5),
                                          ),
                                          AppBarTitleText(
                                              title: "Rechercher",
                                              size: manageWidth(context, 17)),
                                        ],
                                      ),
                                      SizedBox(
                                        height: manageHeight(context, 10),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal:
                                                manageWidth(context, 15)),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal:
                                                  manageWidth(context, 15)),
                                          child:
                                              GooglePlaceAutoCompleteTextField(
                                            boxDecoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            textEditingController:
                                                adressLocationController,
                                            googleAPIKey:
                                                "AIzaSyBHB7n1fXd7-lerhMLvtyOIHpnI4PIz3Dg",
                                            inputDecoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText:
                                                    "Adresse, Ville, Code Postal",
                                                icon: const Icon(
                                                    Icons.location_on_outlined),
                                                hintStyle: TextStyle(
                                                    fontSize: manageWidth(
                                                        context, 14))),

                                            debounceTime:
                                                800, // default 600 ms,
                                            countries: const [
                                              "fr"
                                            ], // optional by default null is set
                                            isLatLngRequired:
                                                true, // if you required coordinates from place detail
                                            getPlaceDetailWithLatLng:
                                                (Prediction prediction) {
                                              if (prediction.description !=
                                                      null &&
                                                  prediction.lat != null &&
                                                  prediction.lng != null) {
                                                locationProvider.getlocation(
                                                    prediction.description!);
                                                locationProvider.getCenter(
                                                    double.parse(
                                                        prediction.lat!),
                                                    double.parse(
                                                        prediction.lng!));
                                              }

                                              // this method will return latlng with place detail
                                            }, // this callback is called when isLatLngRequired is true
                                            itemClick: (Prediction prediction) {
                                              adressLocationController.text =
                                                  prediction.description ??
                                                      adressLocationController
                                                          .text;
                                              adressLocationController
                                                      .selection =
                                                  TextSelection.fromPosition(
                                                      TextPosition(
                                                          offset: prediction
                                                              .description!
                                                              .length));
                                            },
                                            // if we want to make custom list item builder
                                            itemBuilder: (context, index,
                                                Prediction prediction) {
                                              return Container(
                                                padding: EdgeInsets.all(
                                                    manageWidth(context, 10)),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.location_on),
                                                    SizedBox(
                                                      width: manageWidth(
                                                          context, 7),
                                                    ),
                                                    Expanded(
                                                        child: Text(prediction
                                                                .description ??
                                                            ""))
                                                  ],
                                                ),
                                              );
                                            },
                                            // if you want to add seperator between list items
                                            seperatedBuilder: const Divider(),
                                            // want to show close icon
                                            isCrossBtnShown: true,
                                            // optional container padding
                                            containerHorizontalPadding: 10,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: manageHeight(context, 115),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          locationProvider
                                              .getlocation("Autour de moi");
                                          Location location = Location();

                                          bool serviceEnabled;
                                          PermissionStatus permissionGranted;
                                          LocationData locationData;

                                          serviceEnabled =
                                              await location.serviceEnabled();
                                          if (!serviceEnabled) {
                                            serviceEnabled =
                                                await location.requestService();
                                            if (!serviceEnabled) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                  "Vous devez autoriser TradeHart à acceder à votre localisation",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                backgroundColor: Colors.red,
                                              ));
                                            }
                                          }

                                          permissionGranted =
                                              await location.hasPermission();
                                          if (permissionGranted ==
                                              PermissionStatus.denied) {
                                            permissionGranted = await location
                                                .requestPermission();
                                            if (permissionGranted !=
                                                PermissionStatus.granted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                  "Vous devez autoriser TradeHart à acceder à votre localisation",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                backgroundColor: Colors.red,
                                              ));
                                            }
                                          }

                                          locationData =
                                              await location.getLocation();

                                          if (locationData.latitude != null &&
                                              locationData.longitude != null) {
                                            locationProvider.getCenter(
                                                locationData.latitude!,
                                                locationData.longitude!);
                                          }

                                          Navigator.pop(context2);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                            top: manageHeight(context, 20),
                                          ),
                                          padding: EdgeInsets.fromLTRB(
                                              manageWidth(context, 8),
                                              manageHeight(context, 8),
                                              manageWidth(context, 8),
                                              manageHeight(context, 8)),
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  offset: const Offset(0, 0),
                                                  blurRadius: 5,
                                                  spreadRadius: 0.4)
                                            ],
                                            borderRadius: BorderRadius.circular(
                                                manageHeight(context, 30)),
                                            color: AppColors.mainColor,
                                          ),
                                          width: manageWidth(context, 200),
                                          height: manageHeight(
                                            context,
                                            55,
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                  width:
                                                      manageWidth(context, 15)),
                                              const Icon(
                                                Icons.location_searching,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                  width:
                                                      manageWidth(context, 10)),
                                              Text("Autour de moi",
                                                  style: GoogleFonts.workSans(
                                                    color: Colors.white,
                                                    fontSize: manageWidth(
                                                        context, 16.5),
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: DropdownButton(
                              items: const [],
                              onChanged: (value) {},
                              hint: SizedBox(
                                  width: manageWidth(context, 110),
                                  child: Text(
                                    locationProvider.location.isEmpty
                                        ? "Position"
                                        : locationProvider.location,
                                    overflow: TextOverflow.ellipsis,
                                  ))),
                        ),
                        SizedBox(
                          width: manageWidth(context, 15),
                        ),
                        DropdownButton(
                            items: [
                              DropdownMenuItem(
                                value: 3.0,
                                child: Text(
                                  "3 km",
                                  style: TextStyle(
                                      color: locationProvider.radius == 3.0
                                          ? AppColors.mainColor
                                          : null),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 5.0,
                                child: Text(
                                  "5 km",
                                  style: TextStyle(
                                      color: locationProvider.radius == 5.0
                                          ? AppColors.mainColor
                                          : null),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 10.0,
                                child: Text(
                                  "10 km",
                                  style: TextStyle(
                                      color: locationProvider.radius == 10.0
                                          ? AppColors.mainColor
                                          : null),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 15.0,
                                child: Text(
                                  "15 km",
                                  style: TextStyle(
                                      color: locationProvider.radius == 15.0
                                          ? AppColors.mainColor
                                          : null),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 20.0,
                                child: Text(
                                  "20 km",
                                  style: TextStyle(
                                      color: locationProvider.radius == 20.0
                                          ? AppColors.mainColor
                                          : null),
                                ),
                              ),
                            ],
                            onChanged: (double? newRadius) {
                              locationProvider.updateRadius(newRadius!);
                            },
                            hint: Text("Rayon : ${locationProvider.radius} km"))
                      ]),
                    )
                  : null,
            ),
            SizedBox(
              height: manageHeight(context, 5),
            ),
            Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: manageHeight(context, 1.5),
                      blurRadius: manageHeight(context, 5),
                      offset: const Offset(0, 2),
                    ),
                  ],
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(manageHeight(context, 15))),
              margin: EdgeInsets.all(manageWidth(context, 10)),
              height: manageHeight(context, 560),
              child: ListView.builder(
                itemCount: widget.categories.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: index == widget.categories.keys.length - 1
                        ? [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return SubFiltersPage(
                                        subcategory:
                                            widget.categories == articlesFilters
                                                ? 0
                                                : 1,
                                        filter: widget.categories.keys
                                            .toList()[index]
                                            .title,
                                        subFilters: widget.categories[widget
                                            .categories.keys
                                            .toList()[index]]!);
                                  },
                                ));
                              },
                              child: Stack(
                                children: [
                                  SettingView(
                                      setting: widget.categories.keys
                                          .toList()[index]),
                                  Consumer<SearchFilterProvider>(
                                    builder: (context, value, child) {
                                      return Container(
                                        margin: EdgeInsets.only(
                                            left: manageWidth(context, 280),
                                            top: 17),
                                        width: manageWidth(context, 20),
                                        height: manageWidth(context, 20),
                                        decoration: BoxDecoration(
                                            color: widget.categories ==
                                                    articlesFilters
                                                ? (widget.categories[widget.categories.keys.toList()[index]]!
                                                        .where((element) => value
                                                            .articlesFilters
                                                            .contains(element))
                                                        .isEmpty
                                                    ? Colors.transparent
                                                    : Colors.red)
                                                : (widget.categories[widget.categories.keys.toList()[index]]!
                                                        .where((element) => value
                                                            .servicesFilters
                                                            .contains(element))
                                                        .isEmpty
                                                    ? Colors.transparent
                                                    : Colors.red),
                                            borderRadius:
                                                BorderRadius.circular(manageWidth(context, 10))),
                                        child: Center(
                                          child: Text(
                                            widget.categories == articlesFilters
                                                ? (widget.categories[widget.categories.keys.toList()[index]]!.where((element) => value.articlesFilters.contains(element)).isEmpty
                                                    ? ""
                                                    : widget.categories[widget.categories.keys.toList()[index]]!
                                                        .where((element) => value
                                                            .articlesFilters
                                                            .contains(element))
                                                        .length
                                                        .toString())
                                                : (widget.categories[widget.categories.keys.toList()[index]]!
                                                        .where((element) => value
                                                            .servicesFilters
                                                            .contains(element))
                                                        .isEmpty
                                                    ? ""
                                                    : widget
                                                        .categories[widget.categories.keys.toList()[index]]!
                                                        .where((element) => value.servicesFilters.contains(element))
                                                        .length
                                                        .toString()),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    manageWidth(context, 10)),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ]
                        : [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return SubFiltersPage(
                                        subcategory:
                                            widget.categories == articlesFilters
                                                ? 0
                                                : 1,
                                        filter: widget.categories.keys
                                            .toList()[index]
                                            .title,
                                        subFilters: widget.categories[widget
                                            .categories.keys
                                            .toList()[index]]!);
                                  },
                                ));
                              },
                              child: Stack(
                                children: [
                                  SettingView(
                                      setting: widget.categories.keys
                                          .toList()[index]),
                                  Consumer<SearchFilterProvider>(
                                    builder: (context, value, child) {
                                      return Container(
                                        margin: EdgeInsets.only(
                                            left: manageWidth(context, 280),
                                            top: 17),
                                        width: manageWidth(context, 20),
                                        height: manageWidth(context, 20),
                                        decoration: BoxDecoration(
                                            color: widget.categories ==
                                                    articlesFilters
                                                ? (widget.categories[widget.categories.keys.toList()[index]]!
                                                        .where((element) => value
                                                            .articlesFilters
                                                            .contains(element))
                                                        .isEmpty
                                                    ? Colors.transparent
                                                    : Colors.red)
                                                : (widget.categories[widget.categories.keys.toList()[index]]!
                                                        .where((element) => value
                                                            .servicesFilters
                                                            .contains(element))
                                                        .isEmpty
                                                    ? Colors.transparent
                                                    : Colors.red),
                                            borderRadius:
                                                BorderRadius.circular(manageWidth(context, 10))),
                                        child: Center(
                                          child: Text(
                                            widget.categories == articlesFilters
                                                ? (widget.categories[widget.categories.keys.toList()[index]]!.where((element) => value.articlesFilters.contains(element)).isEmpty
                                                    ? ""
                                                    : widget.categories[widget.categories.keys.toList()[index]]!
                                                        .where((element) => value
                                                            .articlesFilters
                                                            .contains(element))
                                                        .length
                                                        .toString())
                                                : (widget.categories[widget.categories.keys.toList()[index]]!
                                                        .where((element) => value
                                                            .servicesFilters
                                                            .contains(element))
                                                        .isEmpty
                                                    ? ""
                                                    : widget
                                                        .categories[widget.categories.keys.toList()[index]]!
                                                        .where((element) => value.servicesFilters.contains(element))
                                                        .length
                                                        .toString()),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    manageWidth(context, 10)),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: manageHeight(context, 1.5),
                              color: Colors.grey.withOpacity(0.2),
                              margin: const EdgeInsets.only(
                                left: 40,
                              ),
                            )
                          ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
