// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:trade_hart/authentication_service.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/views/authentication_pages/service_provider_personnalization_page.dart';
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:trade_hart/views/main_page_components/pages/stripe_cretation_account_page.dart';

class ServiceProviderInformationsPage extends StatefulWidget {
  ServiceProviderInformationsPage({super.key});

  @override
  State<ServiceProviderInformationsPage> createState() =>
      _ServiceProviderInformationsPageState();
}

class _ServiceProviderInformationsPageState
    extends State<ServiceProviderInformationsPage> {
  final geo = GeoFlutterFire();

  String? adress;

  bool isLoading = false;
  TextEditingController serviceProviderNameController = TextEditingController();
  TextEditingController serviceProviderNumberController =
      TextEditingController();
  TextEditingController adresssLocationController = TextEditingController();
  int locationGroupValue = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: manageHeight(context, 40),
              ),
              Center(
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  radius: manageWidth(context, 70),
                  child: Icon(
                    CupertinoIcons.bag,
                    size: manageWidth(context, 65),
                  ),
                ),
              ),
              SizedBox(
                height: manageHeight(context, 25),
              ),
              Row(
                children: [
                  SizedBox(
                    width: manageWidth(context, 17),
                  ),
                  Text(
                    "Dites-nous en plus sur vous!",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: manageWidth(context, 15.5),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: manageHeight(context, 25),
              ),
              AuthTextField(
                controller: serviceProviderNameController,
                hintText: "votre pseudo de prestataire*",
                obscuretext: false,
                forProviderInformations: true,
              ),
              SizedBox(
                height: manageHeight(context, 20),
              ),
              AuthTextField(
                controller: serviceProviderNumberController,
                hintText: "numéro de téléphone*",
                obscuretext: false,
                keyboardType: TextInputType.phone,
                forProviderInformations: true,
              ),
              SizedBox(
                height: manageHeight(context, 20),
              ),
              Row(
                children: [
                  SizedBox(
                    width: manageWidth(context, 10),
                  ),
                  Text(
                    "Localisation de vos services",
                    style: GoogleFonts.poppins(
                      fontSize: manageWidth(context, 15.5),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              SizedBox(
                height: manageHeight(context, 10),
              ),
              Row(
                children: [
                  Radio(
                    value: 0,
                    groupValue: locationGroupValue,
                    onChanged: (value) => setState(() {
                      locationGroupValue = value!;
                    }),
                  ),
                  SizedBox(
                    width: manageWidth(context, 7),
                  ),
                  Text(
                    "Service en ligne/à distance",
                    style: GoogleFonts.poppins(
                      fontSize: manageWidth(context, 15.5),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              SizedBox(
                height: manageHeight(context, 15),
              ),
              Row(
                children: [
                  Radio(
                    value: 1,
                    groupValue: locationGroupValue,
                    onChanged: (value) => setState(() {
                      locationGroupValue = value!;
                    }),
                  ),
                  SizedBox(
                    width: manageWidth(context, 7),
                  ),
                  Text(
                    "Service à domicile",
                    style: GoogleFonts.poppins(
                      fontSize: manageWidth(context, 15.5),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              SizedBox(
                height: manageHeight(context, 15),
              ),
              Row(
                children: [
                  Radio(
                    value: 2,
                    groupValue: locationGroupValue,
                    onChanged: (value) => setState(() {
                      locationGroupValue = value!;
                    }),
                  ),
                  SizedBox(
                    width: manageWidth(context, 7),
                  ),
                  Text(
                    "Sur votre propre site",
                    style: GoogleFonts.poppins(
                      fontSize: manageWidth(context, 15.5),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              SizedBox(
                height: manageHeight(context, 15),
              ),
              // AuthTextField(
              //   controller: adresssLocationController,
              //   hintText: "adresse physique",
              //   obscuretext: false,
              // ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: manageWidth(context, 15)),
                width: manageWidth(context, 355),
                height: manageHeight(context, 45),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius:
                        BorderRadius.circular(manageHeight(context, 20))),
                child: GooglePlaceAutoCompleteTextField(
                  boxDecoration: const BoxDecoration(),
                  textEditingController: adresssLocationController,
                  googleAPIKey: "AIzaSyBHB7n1fXd7-lerhMLvtyOIHpnI4PIz3Dg",
                  inputDecoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Adresse",
                  ),
                  debounceTime: 800, // default 600 ms,
                  countries: const ["fr"], // optional by default null is set
                  isLatLngRequired:
                      true, // if you required coordinates from place detail
                  getPlaceDetailWithLatLng: (Prediction prediction) {
                    // this method will return latlng with place detail
                    setState(() {
                      adress = prediction.description;
                    });

                    var geoLocation = geo.point(
                        latitude: double.parse(prediction.lat!),
                        longitude: double.parse(prediction.lng!));
                    print(adress);

                    FirebaseFirestore.instance
                        .collection('Users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({
                      "gelocation": geoLocation.data,
                      "service adress": adress
                    });
                  }, // this callback is called when isLatLngRequired is true
                  itemClick: (Prediction prediction) {
                    adresssLocationController.text = prediction.description ??
                        adresssLocationController.text;
                    adresssLocationController.selection =
                        TextSelection.fromPosition(TextPosition(
                            offset: prediction.description!.length));
                  },
                  // if we want to make custom list item builder
                  itemBuilder: (context, index, Prediction prediction) {
                    return Container(
                      padding: EdgeInsets.all(manageWidth(context, 10)),
                      child: Row(
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(
                            width: manageWidth(context, 7),
                          ),
                          Expanded(child: Text(prediction.description ?? ""))
                        ],
                      ),
                    );
                  },
                  // if you want to add seperator between list items
                  seperatedBuilder: Divider(),
                  // want to show close icon
                  isCrossBtnShown: true,
                  // optional container padding
                  containerHorizontalPadding: 10,
                ),
              ),
              SizedBox(
                height: manageHeight(context, 50),
              ),
              GestureDetector(
                onTap: () async {
                  if (serviceProviderNameController.text.isNotEmpty &&
                      serviceProviderNumberController.text.isNotEmpty &&
                      adress != null &&
                      adress!.isNotEmpty) {
                    setState(() {
                      isLoading = true;
                    });
                    switch (locationGroupValue) {
                      case 0:
                        await AuthService()
                            .addServiceProviderInformations(
                                serviceProviderNameController.text,
                                int.parse(serviceProviderNumberController.text),
                                "Service en ligne/à distance")
                            .then((value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ServiceProviderPersonalizationPage(),
                            ),
                          );
                          setState(() {
                            isLoading = false;
                          });
                        });
                        break;
                      case 1:
                        AuthService()
                            .addServiceProviderInformations(
                                serviceProviderNameController.text,
                                int.parse(serviceProviderNumberController.text),
                                "Service à domicile")
                            .then((value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ServiceProviderPersonalizationPage(),
                            ),
                          );
                          setState(() {
                            isLoading = false;
                          });
                        });
                        break;
                      default:
                        AuthService()
                            .addServiceProviderInformations(
                                serviceProviderNameController.text,
                                int.parse(serviceProviderNumberController.text),
                                adress)
                            .then((value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StripeCreationPage(
                                businessType: 1,
                              ),
                            ),
                          );
                          setState(() {
                            isLoading = false;
                          });
                        });
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        "Veuillez remplir tous les champs",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ));
                  }
                },
                child: Container(
                  width: manageWidth(context, 200),
                  height: manageHeight(context, 50),
                  decoration: BoxDecoration(
                    color: AppColors.mainColor,
                    borderRadius:
                        BorderRadius.circular(manageWidth(context, 25)),
                  ),
                  child: Center(
                    child: Text(
                      "Suivant",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: manageWidth(context, 16),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: manageHeight(context, 50),
              ),
              CircularProgressIndicator(
                color: isLoading ? AppColors.mainColor : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
