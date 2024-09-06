import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:intl/intl.dart';
// import 'package:trade_hart/main.dart';
// import 'package:trade_hart/views/main_page_components/pages/article_details_page.dart';
// import 'package:trade_hart/views/main_page_components/pages/seller_page.dart';
// import 'package:trade_hart/views/main_page_components/pages/service_detail_page.dart';
// import 'package:trade_hart/views/main_page_components/pages/service_provider_page.dart';
import 'package:uuid/uuid.dart';

class LinkProviderService {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  BranchContentMetaData metadata = BranchContentMetaData();
  BranchLinkProperties lp = BranchLinkProperties();
  late BranchUniversalObject buo;
  late BranchEvent eventStandard;
  late BranchEvent eventCustom;

  StreamSubscription<Map>? streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  StreamController<String> controllerInitSession = StreamController<String>();
  static const imageURL =
      'https://raw.githubusercontent.com/RodrigoSMarques/flutter_branch_sdk/master/assets/branch_logo_qrcode.jpeg';

  void listenDynamicLinks(BuildContext context) async {
    streamSubscription = FlutterBranchSdk.listSession().listen((data) async {
      print('listenDynamicLinks - DeepLink Data: $data');
      controllerData.sink.add((data.toString()));

      if (data.containsKey('+is_first_session') &&
          data['+is_first_session'] == true) {
        // wait 3 seconds to obtain installation data
        await Future.delayed(const Duration(seconds: 3));
        Map<dynamic, dynamic> params =
            await FlutterBranchSdk.getFirstReferringParams();
        controllerData.sink.add(params.toString());
        return;
      }

      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        Navigator.pushNamed(context, data["route"], arguments: data);
        if ((data["articleId"] as String).isNotEmpty) {
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: ((context) =>
          //             ArticleDetailsPage(articleId: data["articleId"]))));

          // navigatorKey.currentState
          //     ?.pushNamed('ArticleDetailsPage', arguments: data);
        }

        if ((data["serviceId"] as String).isNotEmpty) {
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: ((context) =>
          //             ServiceDetailPage(serviceId: data["serviceId"]))));
        }

        if ((data["sellerId"] as String).isNotEmpty) {
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: ((context) =>
          //             SellerPage(sellerId: data["sellerId"]))));
        }
        if ((data["providerId"] as String).isNotEmpty) {
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: ((context) =>
          //             ServiceProviderPage(id: data["providerId"]))));
        }
      }
      print(
          '------------------------------------Link clicked----------------------------------------------');
      print('Title: ${data['\$og_title']}');
      print('Custom string: ${data['custom_string']}');
      print('Custom number: ${data['custom_number']}');
      print('Custom bool: ${data['custom_bool']}');
      print('Custom date: ${data['custom_date_created']}');
      print('Custom list number: ${data['custom_list_number']}');
      print(
          '------------------------------------------------------------------------------------------------');
      showSnackBar(
          message:
              'Link clicked: Custom string - ${data['custom_string']} - Date: ${data['custom_date_created'] ?? ''}',
          duration: 10);
    }, onError: (error) {
      print('listSession error: ${error.toString()}');
    });
  }

  void initDeepLinkData(
      String? articleId,
      String? serviceId,
      String? sellerId,
      String? providerId,
      String route,
      String title,
      String content,
      String imgUrl) {
    String dateString =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    metadata = BranchContentMetaData()
      ..addCustomMetadata('custom_string', 'abcd')
      ..addCustomMetadata('custom_number', 12345)
      ..addCustomMetadata('custom_bool', true)
      ..addCustomMetadata('custom_list_number', [1, 2, 3, 4, 5])
      ..addCustomMetadata('custom_list_string', ['a', 'b', 'c'])
      ..addCustomMetadata('custom_date_created', dateString)
      ..addCustomMetadata('number', "12")
      ..addCustomMetadata('articleId', articleId ?? "")
      ..addCustomMetadata('serviceId', serviceId ?? "")
      ..addCustomMetadata('sellerId', sellerId ?? "")
      ..addCustomMetadata('route', route)
      ..addCustomMetadata('providerId', providerId ?? "");
    //--optional Custom Metadata
    /*
      ..contentSchema = BranchContentSchema.COMMERCE_PRODUCT
      ..price = 50.99
      ..currencyType = BranchCurrencyType.BRL
      ..quantity = 50
      ..sku = 'sku'
      ..productName = 'productName'
      ..productBrand = 'productBrand'
      ..productCategory = BranchProductCategory.ELECTRONICS
      ..productVariant = 'productVariant'
      ..condition = BranchCondition.NEW
      ..rating = 100
      ..ratingAverage = 50
      ..ratingMax = 100
      ..ratingCount = 2
      ..setAddress(
          street: 'street',
          city: 'city',
          region: 'ES',
          country: 'Brazil',
          postalCode: '99999-987')
      ..setLocation(31.4521685, -114.7352207);
      */

    final canonicalIdentifier = const Uuid().v4();
    buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch_$canonicalIdentifier',
        //parameter canonicalUrl
        //If your content lives both on the web and in the app, make sure you set its canonical URL
        // (i.e. the URL of this piece of content on the web) when building any BUO.
        // By doing so, we’ll attribute clicks on the links that you generate back to their original web page,
        // even if the user goes to the app instead of your website! This will help your SEO efforts.
        //canonicalUrl: 'https://flutter.dev',
        title: title,
        imageUrl: imgUrl,
        contentDescription: content,
        contentMetadata: metadata,
        keywords: ['Plugin', 'Branch', 'Flutter'],
        publiclyIndex: true,
        locallyIndex: true,
        expirationDateInMilliSec: DateTime.now()
            .add(const Duration(days: 365))
            .millisecondsSinceEpoch);
    lp = BranchLinkProperties(
        channel: 'share',
        feature: 'sharing',
        //parameter alias
        //Instead of our standard encoded short url, you can specify the vanity alias.
        // For example, instead of a random string of characters/integers, you can set the vanity alias as *.app.link/devonaustin.
        // Aliases are enforced to be unique** and immutable per domain, and per link - they cannot be reused unless deleted.
        //alias: 'https://branch.io' //define link url,
        //alias: 'p/$id', //define link url,
        stage: 'new share',
        campaign: 'campaign',
        tags: ['one', 'two', 'three'])
      ..addControlParam('\$uri_redirect_mode', '1')
      ..addControlParam('\$ios_nativelink', true)
      ..addControlParam('\$match_duration', 7200);
    //..addControlParam('\$always_deeplink', true);
    //..addControlParam('\$android_redirect_timeout', 750)
    //..addControlParam('referring_user_id', 'user_id');
    //..addControlParam('\$fallback_url', 'http')
    //..addControlParam(
    //    '\$fallback_url', 'https://flutter-branch-sdk.netlify.app/');
    //..addControlParam('\$ios_url', 'http');
    //..addControlParam(
    //    '\$android_url', 'https://flutter-branch-sdk.netlify.app/');

    eventStandard = BranchEvent.standardEvent(BranchStandardEvent.ADD_TO_CART)
      //--optional Event data
      ..transactionID = '12344555'
      ..alias = 'StandardEventAlias'
      ..currency = BranchCurrencyType.BRL
      ..revenue = 1.5
      ..shipping = 10.2
      ..tax = 12.3
      ..coupon = 'test_coupon'
      ..affiliation = 'test_affiliation'
      ..eventDescription = 'Event_description'
      ..searchQuery = 'item 123'
      ..adType = BranchEventAdType.BANNER
      ..addCustomData(
          'Custom_Event_Property_Key1', 'Custom_Event_Property_val1')
      ..addCustomData(
          'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');

    eventCustom = BranchEvent.customEvent('Custom_event')
      ..alias = 'CustomEventAlias'
      ..addCustomData(
          'Custom_Event_Property_Key1', 'Custom_Event_Property_val1')
      ..addCustomData(
          'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');
  }

  // void showGeneratedLink(BuildContext context, String url) async {
  //   initDeepLinkData();
  //   showModalBottomSheet(
  //       isDismissible: true ,
  //       isScrollControlled: true,
  //       context: context,
  //       builder: (_) {
  //         return Container(
  //           padding: const EdgeInsets.all(12),
  //           height: 200,
  //           child: Column(
  //             children: <Widget>[
  //               const Center(
  //                   child: Text(
  //                 'Link created',
  //                 style: TextStyle(
  //                     color: Colors.blue, fontWeight: FontWeight.bold),
  //               )),
  //               const SizedBox(
  //                 height: 10,
  //               ),
  //               Text(url,
  //                   maxLines: 1,
  //                   style: const TextStyle(overflow: TextOverflow.ellipsis)),
  //               const SizedBox(
  //                 height: 10,
  //               ),
  //               IntrinsicWidth(
  //                 stepWidth: 300,
  //                 child: ElevatedButton(
  //                     onPressed: () async {
  //                       await Clipboard.setData(ClipboardData(text: url));
  //                       if (context.mounted) {
  //                         Navigator.pop(context);
  //                       }
  //                     },
  //                     child: const Center(child: Text('Copy link'))),
  //               ),
  //               const SizedBox(
  //                 height: 10,
  //               ),
  //               IntrinsicWidth(
  //                 stepWidth: 300,
  //                 child: ElevatedButton(
  //                     onPressed: () {
  //                       FlutterBranchSdk.handleDeepLink(url);
  //                       Navigator.pop(context);
  //                     },
  //                     child: const Center(child: Text('Handle deep link'))),
  //               ),
  //             ],
  //           ),
  //         );
  //       });
  // }

  // void generateLink(BuildContext context) async {
  //   initDeepLinkData();
  //   BranchResponse response =
  //       await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
  //   if (response.success) {
  //     if (context.mounted) {
  //       showGeneratedLink(context, response.result);
  //     }
  //   } else {
  //     showSnackBar(
  //         message: 'Error : ${response.errorCode} - ${response.errorMessage}');
  //   }
  // }

  void shareLink(
      String messageTitle,
      String messageText,
      String? articleId,
      String? serviceId,
      String? sellerId,
      String? providerId,
      String route,
      String imgUrl) async {
    initDeepLinkData(articleId, serviceId, sellerId, providerId, route,
        messageTitle, messageText, imgUrl);
    BranchResponse response = await FlutterBranchSdk.showShareSheet(
        buo: buo,
        linkProperties: lp,
        messageText: messageText,
        androidMessageTitle: messageText,
        androidSharingTitle: 'Partager avec');

    if (response.success) {
      showSnackBar(message: 'showShareSheet Success', duration: 5);
    } else {
      showSnackBar(
          message:
              'showShareSheet Error: ${response.errorCode} - ${response.errorMessage}',
          duration: 5);
    }
  }

  void showSnackBar({required String message, int duration = 2}) {
    scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: duration),
      ),
    );
  }
}
