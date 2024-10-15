import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/categories_provider.dart';
import 'package:trade_hart/model/link_provider_service.dart';
import 'package:trade_hart/model/service.dart';
import 'package:trade_hart/model/service_reservation_method_provider.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/main_back_button.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/service_view.dart';
import 'package:trade_hart/views/main_page_components/pages/followers_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_add_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_detail_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_editing_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_profil_updating_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_stat_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_with_crenau_editing_page.dart';

class ServiceProviderProfilPage extends StatefulWidget {
  const ServiceProviderProfilPage({super.key});

  @override
  State<ServiceProviderProfilPage> createState() =>
      _ServiceProviderProfilPageState();
}

class _ServiceProviderProfilPageState extends State<ServiceProviderProfilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleText(
          size: manageWidth(context, 18),
          title: "Mes services TradHart",
        ),
        leading: const MainBackButton(),
      ),
      body: SingleChildScrollView(
          child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!(snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData ||
                    snapshot.hasError)) {
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  var images = data["images"] as Map<String, dynamic>?;
                  var service = data["service"] as Map<String, dynamic>?;

                  if (service != null && images != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: manageHeight(
                                      context,
                                      MediaQuery.sizeOf(context).height *
                                          (1 / 3.75)),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    // image: DecorationImage(
                                    //   image: images["cover image"] == null
                                    //       ? AssetImage(
                                    //               "images/service_provider_cover.png")
                                    //           as ImageProvider
                                    //       : NetworkImage(images[""]),
                                    //   fit: BoxFit.cover,
                                    // ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: InstaImageViewer(
                                      imageUrl: images["cover image"],
                                      child: Image.network(
                                          images["cover image"],
                                          fit: BoxFit.cover, errorBuilder:
                                              (context, error, stackTrace) {
                                        return SizedBox(
                                            height: manageHeight(context, 150),
                                            width: manageWidth(context, 165),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  CupertinoIcons
                                                      .exclamationmark_triangle,
                                                  size:
                                                      manageWidth(context, 30),
                                                ),
                                                SizedBox(
                                                  height:
                                                      manageHeight(context, 3),
                                                ),
                                                const Text(
                                                  "Erreur lors du chargement",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                  textAlign: TextAlign.center,
                                                )
                                              ],
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                            ));
                                      }),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: manageWidth(context, 103 * 0.72),
                                  height: manageHeight(context, 103 * 0.72),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        manageWidth(context, 103 * 0.72 * 0.5)),
                                    color: Colors.white,
                                  ),
                                  margin: EdgeInsets.only(
                                    top: manageHeight(context, 165),
                                    left: manageWidth(context, 12),
                                  ),
                                  child: Center(
                                    child: CircleAvatar(
                                        backgroundColor: Colors.grey.shade100,
                                        radius: manageWidth(context, 50 * 0.7),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              manageWidth(context, 50 * 0.7)),
                                          child: Container(
                                            height:
                                                manageWidth(context, 100 * 0.7),
                                            width:
                                                manageWidth(context, 100 * 0.7),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      manageWidth(
                                                          context, 50 * 0.7)),
                                              // image: DecorationImage(
                                              //   image: images["profil image"] ==
                                              //           null
                                              //       ? AssetImage(
                                              //               "images/service_provider_cover.png")
                                              //           as ImageProvider
                                              //       : NetworkImage(
                                              //           images["profil image"]),
                                              //   fit: BoxFit.cover,
                                              // ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      manageWidth(
                                                          context, 50 * 0.7)),
                                              child: InstaImageViewer(
                                                imageUrl:
                                                    images["profil image"],
                                                child: Image.network(
                                                    images["profil image"],
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                  return SizedBox(
                                                      height: manageHeight(
                                                          context, 150),
                                                      width: manageWidth(
                                                          context, 165),
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            CupertinoIcons
                                                                .exclamationmark_triangle,
                                                            size: manageWidth(
                                                                context, 20),
                                                          ),
                                                        ],
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                      ));
                                                }),
                                              ),
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: manageHeight(context, 10),
                        ),
                        Row(
                          children: [
                            SizedBox(width: manageWidth(context, 10)),
                            Text(
                              service["name"],
                              style: GoogleFonts.poppins(
                                color: const Color.fromARGB(255, 74, 74, 74),
                                fontWeight: FontWeight.w500,
                                fontSize: manageWidth(context, 17),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                if (kIsWeb) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                      "Vous devez télécharger l'application mobile",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                  ));
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ServiceUpdatingPage()),
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: manageWidth(context, 22.5)),
                                height: manageHeight(context, 30),
                                width: manageWidth(context, 90),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.mainColor,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      manageWidth(context, 15)),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Edit",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        fontSize: manageWidth(context, 16),
                                        color: AppColors.mainColor,
                                      ),
                                    ),
                                    SizedBox(width: manageWidth(context, 5)),
                                    Icon(
                                      Icons.edit,
                                      color: AppColors.mainColor,
                                      size: manageWidth(context, 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: manageWidth(context, 10)),
                          ],
                        ),
                        SizedBox(height: manageHeight(context, 10)),
// Rest of your UI code with managed dimensions and margins
                        Row(
                          children: [
                            SizedBox(width: manageWidth(context, 10)),
                            Container(
                              padding: EdgeInsets.only(
                                  left: manageWidth(context, 5)),
                              height: manageHeight(context, 40),
                              width: manageWidth(context, 150),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade700,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(
                                    manageWidth(context, 15)),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: manageWidth(context, 5)),
                                  Icon(
                                    Icons.person,
                                    color: Colors.grey.shade700,
                                    size: manageWidth(context, 16),
                                  ),
                                  SizedBox(width: manageWidth(context, 5)),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const FollowersPage()),
                                      );
                                    },
                                    child: StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(FirebaseAuth
                                              .instance.currentUser!.uid)
                                          .collection("Abonnes")
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Text(
                                            "Abonnés: ",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w400,
                                              fontSize:
                                                  manageWidth(context, 15),
                                              color: Colors.grey.shade700,
                                            ),
                                          );
                                        }

                                        if (snapshot.data!.docs.isEmpty ||
                                            !snapshot.hasData) {
                                          return Text(
                                            "Abonnés: 0",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w400,
                                              fontSize:
                                                  manageWidth(context, 15),
                                              color: Colors.grey.shade700,
                                            ),
                                          );
                                        }
                                        return Text(
                                          "Abonnés: ${snapshot.data!.docs.length}",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w400,
                                            fontSize: manageWidth(context, 15),
                                            color: Colors.grey.shade700,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "Voir tous les avis",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize: manageWidth(context, 13),
                                color: Colors.blue.shade400,
                              ),
                            ),
                            SizedBox(width: manageWidth(context, 10)),
                          ],
                        ),
                        SizedBox(height: manageHeight(context, 10)),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (kIsWeb) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                      "Vous devez télécharger l'application mobile",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                  ));
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      context
                                          .read<CategoriesProvider>()
                                          .serviceCategoriesclear();
                                      context
                                          .read<
                                              ServiceReservationMethodProvider>()
                                          .clearAllCrenau();
                                      return const ServiceAddPage();
                                    }),
                                  );
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: manageWidth(context, 10)),
                                padding: EdgeInsets.only(
                                    left: manageWidth(context, 22.5)),
                                height: manageHeight(context, 40),
                                width: manageWidth(context, 200),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 255, 146, 146),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      manageWidth(context, 15)),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Ajouter un service",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        fontSize: manageWidth(context, 16),
                                        color:
                                            const Color.fromARGB(255, 255, 146, 146),
                                      ),
                                    ),
                                    SizedBox(width: manageWidth(context, 5)),
                                    Icon(
                                      Icons.add,
                                      color: const Color.fromARGB(255, 255, 146, 146),
                                      size: manageWidth(context, 18),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                                onPressed: () {
                                  LinkProviderService().shareLink(
                                      "",
                                      "Venez découvirir mes services dans TradHart",
                                      null,
                                      null,
                                      null,
                                      FirebaseAuth.instance.currentUser!.uid,
                                      '/ProviderPage',
                                      images["profil image"]);
                                },
                                icon: const Icon(Icons.ios_share))
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(manageWidth(context, 10)),
                          child: Text(
                            service["description"] ?? "",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: manageWidth(context, 15),
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: manageWidth(context, 10)),
                          child: Text(
                            service["location"] ?? "",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: manageWidth(context, 15),
                              color: const Color.fromARGB(255, 159, 102, 156),
                            ),
                          ),
                        ),
                        SizedBox(height: manageHeight(context, 5)),
                        Padding(
                          padding:
                              EdgeInsets.only(left: manageWidth(context, 10)),
                          child: Text(
                            "Années d'expérience : ${service["experience"] ?? ""}",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: manageWidth(context, 15),
                              color: const Color.fromARGB(255, 74, 74, 74),
                            ),
                          ),
                        ),
                        SizedBox(height: manageHeight(context, 5)),
                        Padding(
                          padding:
                              EdgeInsets.only(left: manageWidth(context, 10)),
                          child: Text(
                            "Nos prestations :",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: manageWidth(context, 19),
                              color: const Color.fromARGB(255, 74, 74, 74),
                            ),
                          ),
                        ),
                        Container(
                          height: manageHeight(context, 490),
                          width: manageWidth(context, 460 * 0.75),
                          margin: EdgeInsets.fromLTRB(
                            manageWidth(context, 7.5),
                            manageHeight(context, 13),
                            manageWidth(context, 7.5),
                            0,
                          ),
                          padding: EdgeInsets.all(manageWidth(context, 5)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey,
                              width: 0.1,
                            ),
                            borderRadius:
                                BorderRadius.circular(manageWidth(context, 15)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: manageWidth(context, 1.5),
                                blurRadius: manageWidth(context, 5),
                                offset: Offset(0, manageWidth(context, 2)),
                              ),
                            ],
                          ),
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('Services')
                                .where('sellerId',
                                    isEqualTo:
                                        FirebaseAuth.instance.currentUser!.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.mainColor,
                                  ),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    "Une erreur s'est produite!",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: manageWidth(context, 20),
                                      color: const Color.fromARGB(255, 180, 44, 44),
                                    ),
                                  ),
                                );
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Text(
                                    "Aucun service",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: manageWidth(context, 20),
                                      color: const Color.fromARGB(255, 74, 74, 74),
                                    ),
                                  ),
                                );
                              }

                              return GridView.builder(
                                itemCount: snapshot.data!.docs.length,
                                cacheExtent: manageHeight(context, 2800),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: manageWidth(context, 10),
                                  crossAxisSpacing: manageWidth(context, 10),
                                  childAspectRatio: manageWidth(context, 0.6),
                                ),
                                itemBuilder: (context, index) {
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
                                    averageRate:
                                        serviceData['average rate'] * 1.0,
                                    date: (serviceData['date'] as Timestamp)
                                        .toDate(),
                                    images: serviceData['images'],
                                    ratesNumber: serviceData['rates number'],
                                    sellerName: serviceData['seller name'],
                                    status: serviceData['status'],
                                    totalPoints:
                                        serviceData['total points'] * 1.0,
                                    creneauReservationStatus: serviceData[
                                        "creneau reservation status"],
                                    crenaux: serviceData["crenaux"],
                                  );

                                  return Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ServiceDetailPage(
                                                serviceId: service.id,
                                              ),
                                            ),
                                          );
                                        },
                                        child: ServiceView(
                                          service: service,
                                        ),
                                      ),
                                      PopupMenuButton(
                                        icon: Container(
                                          margin: EdgeInsets.only(
                                              right: manageWidth(context, 18),
                                              bottom:
                                                  manageHeight(context, 15)),
                                          height: manageHeight(context, 22),
                                          width: manageWidth(context, 22),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                    255, 218, 215, 215)
                                                .withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(
                                                manageWidth(context, 20)),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              CupertinoIcons.ellipsis,
                                              size: manageWidth(context, 16),
                                            ),
                                          ),
                                        ),
                                        itemBuilder: (context) {
                                          return {
                                            'modifier',
                                            'supprimer',
                                            'partager',
                                            'résultats'
                                          }
                                              .map((String choice) =>
                                                  PopupMenuItem(
                                                    value: choice,
                                                    child: Text(
                                                      choice,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: manageWidth(
                                                            context, 15),
                                                        color: const Color.fromARGB(
                                                            255, 74, 74, 74),
                                                      ),
                                                    ),
                                                  ))
                                              .toList();
                                        },
                                        onSelected: (value) {
                                          if (value == "résultats") {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ServiceStatsPage(
                                                          serviceId:
                                                              service.id!,
                                                        )));
                                          }
                                          if (value == 'partager') {
                                            LinkProviderService().shareLink(
                                                service.name,
                                                "${service.description}.\n Reservez sur tradHart chez ${service.sellerName}",
                                                null,
                                                service.id,
                                                null,
                                                service.sellerId,
                                                '/ServiceDetailsPage',
                                                service
                                                    .images.first['image url']);
                                          }
                                          if (value == 'supprimer') {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Confirmation'),
                                                  content: Text(
                                                    'Êtes-vous sûr de vouloir supprimer cet élément ?',
                                                    style: TextStyle(
                                                        fontSize: manageWidth(
                                                            context, 15)),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: const Text('Non'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: const Text('Oui'),
                                                      onPressed: () async {
                                                        var imagesNames = service
                                                            .images
                                                            .map((image) => image[
                                                                'image name'])
                                                            .toList();
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'Services')
                                                            .doc(service.id)
                                                            .delete()
                                                            .then((value) {
                                                          for (var image
                                                              in imagesNames) {
                                                            FirebaseStorage
                                                                .instance
                                                                .ref()
                                                                .child(
                                                                    'services_images_urls/$image')
                                                                .delete();
                                                          }
                                                        });
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }

                                          if (value == 'modifier') {
                                            if (kIsWeb) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text(
                                                  "Vous devez télécharger l'application mobile",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                backgroundColor: Colors.red,
                                              ));
                                            } else {
                                              context
                                                  .read<CategoriesProvider>()
                                                  .serviceCategoriesclear();
                                              context
                                                  .read<
                                                      ServiceReservationMethodProvider>()
                                                  .clearAllCrenau();

                                              context
                                                  .read<CategoriesProvider>()
                                                  .getServiceCategories(
                                                      service.categories);
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                if (service
                                                    .creneauReservationStatus) {
                                                  context
                                                      .read<
                                                          ServiceReservationMethodProvider>()
                                                      .getCreneaux(
                                                          service.crenaux!);
                                                  return ServiceWithCreneauxEditingPage(
                                                      service: service);
                                                }
                                                return EditServicePage(
                                                    service: service);
                                              }));
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(height: manageHeight(context, 20)),
                      ],
                    );
                  }
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: manageHeight(context, 200),
                    ),
                    const Center(child: CircularProgressIndicator()),
                  ],
                );
              })),
    );
  }
}
