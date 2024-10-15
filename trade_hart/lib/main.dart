// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:provider/provider.dart';
// import 'package:trade_hart/constants.dart';
// import 'package:trade_hart/firebase_options.dart';
// import 'package:trade_hart/model/amount_article_command_provider.dart';
// import 'package:trade_hart/model/article_size_provider.dart';
// import 'package:trade_hart/model/categories_provider.dart';
// import 'package:trade_hart/model/color_index_provider.dart';
// import 'package:trade_hart/model/colors_provider.dart';
// import 'package:trade_hart/model/detail_article_index_provider.dart';
// import 'package:trade_hart/model/feed_provider.dart';
// import 'package:trade_hart/model/filters_provider.dart';
// import 'package:trade_hart/model/firebase_api.dart';
// import 'package:trade_hart/model/search_filter_provider.dart';
// import 'package:trade_hart/model/service_reservation_method_provider.dart';
// import 'package:trade_hart/model/size_index_privider.dart';
// import 'package:flutter/services.dart';x
// // ignore: depend_on_referenced_packages
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:trade_hart/views/main_page_components/pages/notification_specific_page.dart';
// import 'package:trade_hart/views/main_page_components/pages/notification_test_page.dart';
// import 'package:trade_hart/views/main_page_components/pages/stripe_account_creation_page.dart';
// import 'package:trade_hart/views/main_page_components/pages/test_articles_page.dart';

// final navigatorKey = GlobalKey<NavigatorState>();
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   Stripe.publishableKey = PUBLIC_KEY;

//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   await FirebaseApi().requestPermission();
//   initNotification();
//   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
//       .then((_) {
//     runApp(MultiProvider(providers: [
//       ChangeNotifierProvider(create: (_) => CategoriesProvider()),
//       ChangeNotifierProvider(create: (_) => DetailsIndexProvider()),
//       ChangeNotifierProvider(create: (_) => ColorProvider()),
//       ChangeNotifierProvider(create: (_) => ColorIndexProvider()),
//       ChangeNotifierProvider(create: (_) => SizeIndexProvider()),
//       ChangeNotifierProvider(create: (_) => ArticleSizeProvider()),
//       ChangeNotifierProvider(create: (_) => ServiceReservationMethodProvider()),
//       ChangeNotifierProvider(create: (_) => FeedPovider()),
//       ChangeNotifierProvider(create: (_) => FiltersProvider()),
//       ChangeNotifierProvider(create: (_) => SearchFilterProvider()),
//       ChangeNotifierProvider(create: (_) => AmountArticleCommandProvider())
//     ], child: const TradeHart()));
//   });
// }

// ignore_for_file: prefer_const_constructors

// class TradeHart extends StatelessWidget {
//   const TradeHart({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       routes: {'/notification_screen': (context) => const NotificationPage()},
//       localizationsDelegates: GlobalMaterialLocalizations.delegates,
//       supportedLocales: const [
//         Locale('fr'),
//         Locale('en')
//         // Français, France
//       ],
//       title: 'TradeHart',
//       theme: ThemeData(
//         useMaterial3: true,
//       ),
//       debugShowCheckedModeBanner: false,
//       home: const NotificationTestPage(),
//     );
//   }
// }
// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:googleapis/bigquery/v2.dart';
// import 'package:googleapis_auth/auth_io.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/constants.dart';
import 'package:trade_hart/firebase_options.dart';
// import 'package:trade_hart/model/adress_page.dart';
import 'package:trade_hart/model/amount_article_command_provider.dart';
import 'package:trade_hart/model/article_size_provider.dart';
import 'package:trade_hart/model/categories_provider.dart';
import 'package:trade_hart/model/color_index_provider.dart';
import 'package:trade_hart/model/conversation_provider.dart';
import 'package:trade_hart/model/detail_article_index_provider.dart';
import 'package:trade_hart/model/fcmtoken_provider.dart';
import 'package:trade_hart/model/feed_provider.dart';
import 'package:trade_hart/model/filters_provider.dart'; 
// import 'package:trade_hart/model/link_provider_service.dart';
import 'package:trade_hart/model/location_provider.dart';
import 'package:trade_hart/model/notification_api.dart';
import 'package:trade_hart/model/price_filter_provider.dart';
import 'package:trade_hart/model/search_filter_provider.dart';
import 'package:trade_hart/model/selected_articles_provider.dart';
import 'package:trade_hart/model/service_reservation_method_provider.dart';
import 'package:trade_hart/model/size_index_privider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:trade_hart/model/test_lien.dart';
// import 'package:trade_hart/size_manager.dart';
// import 'package:trade_hart/tools/widgets/provider_reservation_view.dart';
import 'package:trade_hart/views/authentication_pages/login_page.dart';
// import 'package:trade_hart/views/authentication_pages/service_provider_informations_page.dart';
// import 'package:trade_hart/views/authentication_pages/service_provider_personnalization_page.dart';
// import 'package:trade_hart/views/authentication_pages/shop_informations_page.dart';
// import 'package:trade_hart/views/authentication_pages/shop_personalisation_page.dart';
import 'package:trade_hart/views/main_page.dart';
import 'package:trade_hart/views/main_page_components/pages/article_details_page.dart';
import 'package:trade_hart/views/main_page_components/pages/article_rates_page.dart';
import 'package:trade_hart/views/main_page_components/pages/conversation_page.dart';
// import 'package:trade_hart/views/main_page_components/pages/following_page.dart';
// import 'package:trade_hart/views/main_page_components/pages/insta.dart';
// import 'package:trade_hart/views/main_page_components/pages/notification_specific_page.dart';
// import 'package:trade_hart/views/main_page_components/pages/notification_test_page.dart';
// import 'package:trade_hart/views/main_page_components/pages/page1.dart';
// import 'package:trade_hart/views/main_page_components/pages/page2.dart';
// import 'package:trade_hart/views/main_page_components/pages/privacy_policy_page.dart';
// import 'package:trade_hart/views/main_page_components/pages/profile_page.dart';
// import 'package:trade_hart/views/main_page_components/pages/provider_reservation_page.dart';
import 'package:trade_hart/views/main_page_components/pages/seller_command_page.dart';
import 'package:trade_hart/views/main_page_components/pages/seller_page.dart';
import 'package:trade_hart/views/main_page_components/pages/seller_rate_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_detail_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_provider_page.dart';
// import 'package:trade_hart/views/main_page_components/pages/service_provider_profil_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_rates_page.dart';
// import 'package:trade_hart/views/main_page_components/pages/stats_page.dart';
// import 'package:trade_hart/views/main_page_components/pages/stripe_account_creation_page.dart';
// import 'package:trade_hart/views/main_page_components/pages/stripe_cretation_account_page.dart';
// import 'package:trade_hart/views/main_page_components/pages/stripe_web_view.dart';
// import 'package:trade_hart/views/main_page_components/pages/test_articles_page.dart';
// import 'package:trade_hart/views/main_page_components/pages/transfert_test_page.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = PUBLIC_KEY;

  await FlutterBranchSdk.init(enableLogging: true, disableTracking: false);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    FirebaseApi().requestPermission();
    initNotification();
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => CategoriesProvider()),
      ChangeNotifierProvider(create: (_) => DetailsIndexProvider()),
      ChangeNotifierProvider(create: (_) => ColorIndexProvider()),
      ChangeNotifierProvider(create: (_) => SizeIndexProvider()),
      ChangeNotifierProvider(create: (_) => ArticleSizeProvider()),
      ChangeNotifierProvider(create: (_) => ServiceReservationMethodProvider()),
      ChangeNotifierProvider(create: (_) => FeedPovider()),
      ChangeNotifierProvider(create: (_) => FiltersProvider()),
      ChangeNotifierProvider(create: (_) => SearchFilterProvider()),
      ChangeNotifierProvider(create: (_) => AmountArticleCommandProvider()),
      ChangeNotifierProvider(create: (_) => SelectedArticle()),
      ChangeNotifierProvider(create: (_) => PriceFilterProvider()),
      ChangeNotifierProvider(create: (_) => LocationProvider()),
      ChangeNotifierProvider(create: (_) => FcmtokenProvider()),
      ChangeNotifierProvider(create: (_) => ConversationProvider())
    ], child: TradeHart()));
  });
}

class TradeHart extends StatelessWidget {
  TradeHart({super.key});

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: MainPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/ArticleDetailsPage': (context) => ArticleDetailsPage(),
        '/ServiceDetailsPage': (context) => ServiceDetailPage(),
        '/CommandsSeller': (context) => SellerCommandPage(),
        '/ArticleRatesPage': (context) => ArticleRatePage(),
        '/ConversationPage': (context) => ConversationPage(),
        '/ServiceRatesPage': (context) => ServiceRatePage(),
        '/SellerRatesPage': (context) =>
            SellerRatesPage(sellerId: FirebaseAuth.instance.currentUser!.uid),
        '/SellerPage': (context) => SellerPage(),
        '/ProviderPage': (context) => ServiceProviderPage()
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'),
        Locale('en')
        // Français, France
      ],
      title: 'TradHart',
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
//03sxnmCRlMfQqAYmIdu2
//acP89xQRZmPKOSLZlOjO
//dykuVYCx8yZKpUQLZFsowiL3ipw1
