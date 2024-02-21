import 'dart:convert';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';

import '../Helper/Constant.dart';
import '../Model/Section_Model.dart';
import '../Screen/Product Detail/productDetail.dart';

class DynamicLinkHandler {
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  Future<void> initDynamicLinks(BuildContext context) async {

    print("DEEP URL");
    dynamicLinks.onLink.listen((dynamicLinkData) {

      // Listen and retrieve dynamic links here
      final String deepLink = dynamicLinkData.link.toString(); // Get DEEP LINK
      // Ex: https://namnp.page.link/product/013232
      final String path = dynamicLinkData.link.path; // Get PATH
      // Ex: product/013232
      if(deepLink.isEmpty)  return;
      handleDeepLink(dynamicLinkData.link.toString(),context);
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
    initUniLinks(context);
  }
  Future<void> initUniLinks(BuildContext context) async {

    print("I M HERE");
    try {
      final initialLink = await dynamicLinks.getInitialLink();

      if(initialLink == null)  return;
      handleDeepLink(initialLink.link.toString(),context);
    } catch (e) {
      // Error
    }
  }
  void handleDeepLink(String path,BuildContext context) {

    // navigate to detailed product screen
    String encodedProductJson = Uri.base.queryParameters['data']!;
    String productJson = Uri.decodeComponent(encodedProductJson);

    // Convert the JSON back to the Product model
  var  product = Product.fromJson(jsonDecode(productJson));

    // Retrieve secPos and index from the URL
  int   secPos = int.parse(Uri.base.queryParameters['secPos']!);
   int index = int.parse(Uri.base.queryParameters['index']!);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ProductDetail(
          model: product,
          secPos: secPos,
          index: index,
          list: false,
        ),
      ),
    );
  }

  createdeeplinking(String id,String secPos,String index,bool list) async {
  var url=Uri.parse("https://admin.jossbuy.com/product?data=$id&secPos=$secPos&index=$index&list=$list");
    // final dynamicLinkParams = DynamicLinkParameters(
    //   link: Uri.parse("https://jozzbybazar.com/product?data=$id&secPos=$secPos&index=$index&list=$list"),
    //   uriPrefix: deepLinkUrlPrefix,
    //   androidParameters: const AndroidParameters(
    //     packageName: packageName,
    //     minimumVersion: 30,
    //   ),
    //   // iosParameters: const IOSParameters(
    //   //   bundleId: "com.example.app.ios",
    //   //   appStoreId: "123456789",
    //   //   minimumVersion: "1.0.1",
    //   // ),
    //   // googleAnalyticsParameters: const GoogleAnalyticsParameters(
    //   //   source: "twitter",
    //   //   medium: "social",
    //   //   campaign: "example-promo",
    //   // ),
    //   // socialMetaTagParameters: SocialMetaTagParameters(
    //   //   title: "Example of a Dynamic Link",
    //   //   imageUrl: Uri.parse("https://example.com/image.png"),
    //   // ),
    // );
    // final dynamicLink =
    //     await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    // return dynamicLink.shortUrl;
    return url;
  }
}
