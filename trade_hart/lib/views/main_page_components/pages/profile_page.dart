// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trade_hart/model/settings.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/views/main_page_components/profile_page_components/setting_view.dart';
import 'package:trade_hart/views/main_page_components/profile_page_components/user_profile_view.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            var userData = snapshot.data!.data();
            return Column(children: [
              UserProfileView(
                username: userData!['first name'],
              ),
              SizedBox(
                height: manageHeight(context, 4),
              ),
              SizedBox(
                child: userData["user type"]=="buyer"? null: Container(
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: manageWidth(context, 1.5),
                          blurRadius: manageWidth(context, 5),
                          offset: Offset(0, 2),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(manageHeight(context, 20))),
                  margin: EdgeInsets.fromLTRB(
                      manageWidth(context, 8),
                      manageHeight(context, 8),
                      manageWidth(context, 8),
                      manageHeight(context, 8)),
                  height: manageHeight(context, 210),
                  child: userData["user type"] == "seller"
                      ? ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: sellerSettings.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: index == sellerSettings.length - 1
                                  ? [
                                      GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        sellerSettingsPages[
                                                            index]));
                                          },
                                          child: Stack(
                                            children: [
                                              StreamBuilder(
                                                  stream: FirebaseFirestore
                                                      .instance
                                                      .collection('Users')
                                                      .doc(FirebaseAuth.instance
                                                          .currentUser!.uid)
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState.waiting) {
                                                      return Padding(
                                                        padding: EdgeInsets.only(
                                                            top: manageHeight(
                                                                context, 23.0),
                                                            left: manageWidth(
                                                                context, 40)),
                                                        child: CircleAvatar(
                                                          radius: manageWidth(
                                                              context, 5),
                                                          backgroundColor:
                                                              Colors.transparent,
                                                        ),
                                                      );
                                                    }
                                                    if (!snapshot.data!.exists) {
                                                      return Padding(
                                                        padding: EdgeInsets.only(
                                                            top: manageHeight(
                                                                context, 23.0),
                                                            left: manageWidth(
                                                                context, 40)),
                                                        child: CircleAvatar(
                                                          radius: manageWidth(
                                                              context, 5),
                                                          backgroundColor:
                                                              Colors.transparent,
                                                        ),
                                                      );
                                                    }
                                                    var isAllRead = snapshot.data!
                                                                .data()![
                                                            'is all comments read'] ??
                                                        true;
                
                                                    if (isAllRead != false) {
                                                      return Padding(
                                                        padding: EdgeInsets.only(
                                                            top: manageHeight(
                                                                context, 23.0),
                                                            left: manageHeight(
                                                                context, 40)),
                                                        child: CircleAvatar(
                                                          radius: manageWidth(
                                                              context, 5),
                                                          backgroundColor:
                                                              Colors.transparent,
                                                        ),
                                                      );
                                                    }
                                                    return Padding(
                                                      padding: EdgeInsets.only(
                                                          top: manageHeight(
                                                              context, 23.0),
                                                          left: manageHeight(
                                                              context, 40)),
                                                      child: CircleAvatar(
                                                        radius: manageWidth(
                                                            context, 5),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }),
                                              SettingView(
                                                  setting: sellerSettings[index]),
                                            ],
                                          )),
                                    ]
                                  : index == 2
                                      ? [
                                          Column(
                                            children: [
                                              GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                sellerSettingsPages[
                                                                    index]));
                                                  },
                                                  child: Stack(
                                                    children: [
                                                      StreamBuilder(
                                                          stream: FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'Commands')
                                                              .where("seller id",
                                                                  isEqualTo:
                                                                      FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .uid)
                                                              .where("status",
                                                                  isNotEqualTo:
                                                                      "Livré")
                                                              .snapshots(),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .waiting) {
                                                              return Padding(
                                                                padding: EdgeInsets.only(
                                                                    top: manageHeight(
                                                                        context,
                                                                        23.0),
                                                                    left: manageHeight(
                                                                        context,
                                                                        40)),
                                                                child:
                                                                    CircleAvatar(
                                                                  radius:
                                                                      manageHeight(
                                                                          context,
                                                                          5),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                ),
                                                              );
                                                            }
                                                            if (snapshot.data!
                                                                .docs.isEmpty) {
                                                              return Padding(
                                                                padding: EdgeInsets.only(
                                                                    top: manageHeight(
                                                                        context,
                                                                        23.0),
                                                                    left: manageHeight(
                                                                        context,
                                                                        250)),
                                                                child:
                                                                    CircleAvatar(
                                                                  radius:
                                                                      manageHeight(
                                                                          context,
                                                                          5),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                ),
                                                              );
                                                            }
                
                                                            return Padding(
                                                              padding: EdgeInsets.only(
                                                                  top:
                                                                      manageHeight(
                                                                          context,
                                                                          17),
                                                                  left:
                                                                      manageWidth(
                                                                          context,
                                                                          290)),
                                                              child: CircleAvatar(
                                                                radius:
                                                                    manageHeight(
                                                                        context,
                                                                        5),
                                                                backgroundColor:
                                                                    Colors.red,
                                                              ),
                                                            );
                                                          }),
                                                      SettingView(
                                                          setting: sellerSettings[
                                                              index]),
                                                    ],
                                                  )),
                                              Container(
                                                height:
                                                    manageHeight(context, 1.5),
                                                color:
                                                    Colors.grey.withOpacity(0.2),
                                                margin: EdgeInsets.only(
                                                  left: manageWidth(context, 40),
                                                ),
                                              )
                                            ],
                                          ),
                                        ]
                                      : [
                                          GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            sellerSettingsPages[
                                                                index]));
                                              },
                                              child: SettingView(
                                                  setting:
                                                      sellerSettings[index])),
                                          Container(
                                            height: manageHeight(context, 1.5),
                                            color: Colors.grey.withOpacity(0.2),
                                            margin: EdgeInsets.only(
                                              left: manageWidth(context, 40),
                                            ),
                                          )
                                        ],
                            );
                          },
                        )
                      : userData["user type"] == "provider"
                          ? ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: providerSettings.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: index == providerSettings.length - 1
                                      ? [
                                          GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            sellerSettingsPages[
                                                                index]));
                                              },
                                              child: Stack(
                                                children: [
                                                  StreamBuilder(
                                                      stream: FirebaseFirestore
                                                          .instance
                                                          .collection('Users')
                                                          .doc(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid)
                                                          .snapshots(),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return Padding(
                                                            padding: EdgeInsets.only(
                                                                top: manageHeight(
                                                                    context,
                                                                    23.0),
                                                                left:
                                                                    manageHeight(
                                                                        context,
                                                                        40)),
                                                            child: CircleAvatar(
                                                              radius:
                                                                  manageHeight(
                                                                      context, 5),
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                            ),
                                                          );
                                                        }
                                                        if (!snapshot
                                                            .data!.exists) {
                                                          return Padding(
                                                            padding: EdgeInsets.only(
                                                                top: manageHeight(
                                                                    context,
                                                                    23.0),
                                                                left:
                                                                    manageHeight(
                                                                        context,
                                                                        40)),
                                                            child: CircleAvatar(
                                                              radius:
                                                                  manageHeight(
                                                                      context, 5),
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                            ),
                                                          );
                                                        }
                                                        var isAllRead = snapshot
                                                                    .data!
                                                                    .data()![
                                                                'is all comments read'] ??
                                                            true;
                
                                                        return Padding(
                                                          padding: EdgeInsets.only(
                                                              top: manageHeight(
                                                                  context, 17),
                                                              left: manageWidth(
                                                                  context,290)),
                                                          child: CircleAvatar(
                                                            radius: manageWidth(
                                                                context, 5),
                                                            backgroundColor:
                                                                isAllRead == true
                                                                    ? Colors
                                                                        .transparent
                                                                    : Colors.red,
                                                          ),
                                                        );
                                                      }),
                                                  SettingView(
                                                      setting:
                                                          sellerSettings[index]),
                                                ],
                                              )),
                                        ]
                                      : index == 2
                                          ? [
                                              GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                providerSettingsPage[
                                                                    index]));
                                                  },
                                                  child: Stack(
                                                    children: [
                                                      StreamBuilder(
                                                          stream: FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'Reservations')
                                                              .where("seller id",
                                                                  isEqualTo:
                                                                      FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .uid)
                                                              .where("status",
                                                                  isNotEqualTo:
                                                                      "Terminé")
                                                              .snapshots(),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .waiting) {
                                                              return Padding(
                                                                padding: EdgeInsets.only(
                                                                    top: manageHeight(
                                                                        context,
                                                                        23.0),
                                                                    left: manageHeight(
                                                                        context,
                                                                        40)),
                                                                child:
                                                                    CircleAvatar(
                                                                  radius:
                                                                      manageHeight(
                                                                          context,
                                                                          5),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                ),
                                                              );
                                                            }
                                                            if (snapshot.data!
                                                                .docs.isEmpty) {
                                                              return Padding(
                                                                padding: EdgeInsets.only(
                                                                    top: manageHeight(
                                                                        context,
                                                                        23.0),
                                                                    left: manageHeight(
                                                                        context,
                                                                        40)),
                                                                child:
                                                                    CircleAvatar(
                                                                  radius:
                                                                      manageHeight(
                                                                          context,
                                                                          5),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                ),
                                                              );
                                                            }
                
                                                            return Padding(
                                                              padding: EdgeInsets.only(
                                                                  top:
                                                                      manageHeight(
                                                                          context,
                                                                        17),
                                                                  left:
                                                                      manageWidth(
                                                                          context,
                                                                          290)),
                                                              child: CircleAvatar(
                                                                radius:
                                                                    manageHeight(
                                                                        context,
                                                                        5),
                                                                backgroundColor:
                                                                    Colors.red,
                                                              ),
                                                            );
                                                          }),
                                                      SettingView(
                                                          setting:
                                                              providerSettings[
                                                                  index]),
                                                    ],
                                                  )),
                                              Container(
                                                height:
                                                    manageHeight(context, 1.5),
                                                color:
                                                    Colors.grey.withOpacity(0.2),
                                                margin: EdgeInsets.only(
                                                  left: manageWidth(context, 40),
                                                ),
                                              )
                                            ]
                                          : [
                                              GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                providerSettingsPage[
                                                                    index]));
                                                  },
                                                  child: SettingView(
                                                      setting: providerSettings[
                                                          index])),
                                              Container(
                                                height:
                                                    manageHeight(context, 1.5),
                                                color:
                                                    Colors.grey.withOpacity(0.2),
                                                margin: EdgeInsets.only(
                                                  left: manageWidth(context, 40),
                                                ),
                                              )
                                            ],
                                );
                              },
                            )
                          : null,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: manageWidth(context, 1.5),
                        blurRadius: manageWidth(context, 5),
                        offset: Offset(0, 2),
                      ),
                    ],
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(manageHeight(context, 20))),
                margin: EdgeInsets.fromLTRB(
                    manageWidth(context, 10),
                    manageHeight(context, 10),
                    manageWidth(context, 10),
                    manageHeight(context, 10)),
                height: manageHeight(context, 520),
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: settings1.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: index == settings1.length - 1
                          ? [SettingView(setting: settings1[index])]
                          : index == 0 || index == 1
                              ? [
                                  Stack(
                                    children: [
                                      StreamBuilder(
                                          stream: index == 0
                                              ? FirebaseFirestore.instance
                                                  .collection('Commands')
                                                  .where("buyer id",
                                                      isEqualTo: FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .uid)
                                                  .where("status",
                                                      isNotEqualTo: "Livré")
                                                  .snapshots()
                                              : FirebaseFirestore.instance
                                                  .collection('Reservations')
                                                  .where("buyer id",
                                                      isEqualTo: FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .uid)
                                                  .where("status",
                                                      isNotEqualTo: "Terminé")
                                                  .snapshots(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                    top: manageHeight(
                                                        context, 23.0),
                                                    left: manageHeight(
                                                        context, 40)),
                                                child: CircleAvatar(
                                                  radius:
                                                      manageHeight(context, 5),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                ),
                                              );
                                            }
                                            if (snapshot.data!.docs.isEmpty) {
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                    top: 23.0, left: 40),
                                                child: CircleAvatar(
                                                  radius:
                                                      manageHeight(context, 5),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                ),
                                              );
                                            }

                                            return Padding(
                                              padding: EdgeInsets.only(
                                                  top: manageHeight(
                                                      context, 17),
                                                  left: manageWidth(
                                                      context, 290)),
                                              child: CircleAvatar(
                                                radius:
                                                    manageHeight(context, 5),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }),
                                      GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        defaultSettings[
                                                            index]));
                                          },
                                          child: SettingView(
                                              setting: settings1[index])),
                                    ],
                                  ),
                                  Container(
                                    height: manageHeight(context, 1.5),
                                    color: Colors.grey.withOpacity(0.2),
                                    margin: EdgeInsets.only(
                                      left: manageWidth(context, 40),
                                    ),
                                  )
                                ]
                              : [
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    defaultSettings[index]));
                                      },
                                      child: SettingView(
                                          setting: settings1[index])),
                                  Container(
                                    height: manageHeight(context, 1.5),
                                    color: Colors.grey.withOpacity(0.2),
                                    margin: EdgeInsets.only(
                                      left: manageWidth(context, 40),
                                    ),
                                  )
                                ],
                    );
                  },
                ),
              ),
            ]);
          }),
    );
  }
}
