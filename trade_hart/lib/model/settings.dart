import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:googleapis/bigquery/v2.dart';
import 'package:trade_hart/model/adress_page.dart';
import 'package:trade_hart/model/setting.dart';
import 'package:trade_hart/tools/widgets/provider_stat_page.dart';
import 'package:trade_hart/views/main_page_components/pages/following_page.dart';
import 'package:trade_hart/views/main_page_components/pages/presentation_page.dart';
import 'package:trade_hart/views/main_page_components/pages/privacy_policy_page.dart';
import 'package:trade_hart/views/main_page_components/pages/provider_reservation_page.dart';
import 'package:trade_hart/views/main_page_components/pages/seller_command_page.dart';
import 'package:trade_hart/views/main_page_components/pages/seller_rate_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_provider_profil_page.dart';
import 'package:trade_hart/views/main_page_components/pages/setting_page.dart';
import 'package:trade_hart/views/main_page_components/pages/shop_page_seller.dart';
import 'package:trade_hart/views/main_page_components/pages/stats_page.dart';
import 'package:trade_hart/views/main_page_components/pages/suport_service_page.dart';
import 'package:trade_hart/views/main_page_components/pages/use_condition.dart';
import 'package:trade_hart/views/main_page_components/pages/user_command_page.dart';
import 'package:trade_hart/views/main_page_components/pages/user_reservations_page.dart';

var settings1 = [
  Setting(title: "Vos commandes", icon: CupertinoIcons.square_list),
  Setting(title: "Vos réservations", icon: CupertinoIcons.square_list),
  Setting(
      title: "Boutiques et Prestaitaires suivis", icon: CupertinoIcons.heart),
  Setting(title: "Adresses", icon: CupertinoIcons.location),
  Setting(
      title: "Politique de confidentialité", icon: CupertinoIcons.lock_shield),
  Setting(title: "Condition d'utilisation", icon: CupertinoIcons.doc_plaintext),
  Setting(title: "Paramètres", icon: CupertinoIcons.settings),
  Setting(title: "Services Client", icon: CupertinoIcons.phone),
  Setting(title: "A propos de nous", icon: CupertinoIcons.info),
  Setting(
      title: "Donnez une note à TradeHart", icon: CupertinoIcons.square_pencil),
  Setting(title: "Partager cette application", icon: CupertinoIcons.share),
];

var sellerSettings = [
  Setting(title: "Ma boutique", icon: CupertinoIcons.bag),
  Setting(title: "Statistiques", icon: Icons.line_axis),
  Setting(title: "Commandes client", icon: CupertinoIcons.square_list),
  Setting(title: "Avis Client", icon: CupertinoIcons.star),
];

var providerSettings = [
  Setting(title: "mes services", icon: Icons.handshake_outlined),
  Setting(title: "Statistiques", icon: Icons.line_axis),
  Setting(title: "Reservations client", icon: CupertinoIcons.square_list),
  Setting(title: "Avis client", icon: CupertinoIcons.star),
];

var sellerSettingsPages = [
  const ShopPageSeller(),
  StatsPage(),
  const SellerCommandPage(),
  SellerRatesPage(sellerId: FirebaseAuth.instance.currentUser!.uid)
];
var providerSettingsPage = [
  ServiceProviderProfilPage(),
  const ProviderStatsPage(),
  const ProviderReservationsPage(),
  SellerRatesPage(sellerId: FirebaseAuth.instance.currentUser!.uid)
];

var defaultSettings = const [
  UserCommandsPage(),
  UserReservationsPage(),
  FollowingPage(),
  AdressPage(),
  PrivacyPolicyPage(),
  UseConditionsPage(),
  SettingPage(),
  SuportServicePage(),
  PresentationPage()
];
