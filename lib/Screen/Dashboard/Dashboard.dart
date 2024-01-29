import 'dart:async';
import 'dart:convert';
import 'package:eshop_multivendor/Provider/homePageProvider.dart';
import 'package:eshop_multivendor/Screen/Product%20Detail/productDetail.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Screen/Profile/MyProfile.dart';
import 'package:eshop_multivendor/Screen/ExploreSection/explore.dart';
import 'package:eshop_multivendor/Screen/Search/Search.dart';
import 'package:eshop_multivendor/deeplinking/deeplinking_service.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import '../../Helper/String.dart';
import '../../widgets/security.dart';
import '../../widgets/systemChromeSettings.dart';
import '../PushNotification/PushNotificationService.dart';
import '../SQLiteData/SqliteData.dart';
import '../../Helper/routes.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/snackbar.dart';
import '../AllCategory/All_Category.dart';
import '../Cart/Cart.dart';
import '../Cart/Widget/clearTotalCart.dart';
import '../Notification/NotificationLIst.dart';
import '../homePage/homepageNew.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

var db = DatabaseHelper();

class _DashboardPageState extends State<Dashboard>
    with TickerProviderStateMixin {
  int _selBottom = 0;
  late TabController _tabController;

  late StreamSubscription streamSubscription;

  late AnimationController navigationContainerAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  @override
  void initState() {
    SystemChromeSettings.setSystemButtomNavigationBarithTopAndButtom();
    SystemChromeSettings.setSystemUIOverlayStyleWithNoSpecification();
   // DynamicLinkHandler().initDynamicLinks(context);

   // initDynamicLinks();
    init();
    _tabController = TabController(
      length: 5,
      vsync: this,
    );

    final pushNotificationService = PushNotificationService(
        context: context, tabController: _tabController);
    pushNotificationService.initialise();

    _tabController.addListener(
      () {
        Future.delayed(const Duration(seconds: 0)).then(
          (value) {},
        );
        setState(
          () {
            _selBottom = _tabController.index;
          },
        );
        if (_tabController.index == 3) {
          cartTotalClear(context);
        }
      },
    );

    Future.delayed(
      Duration.zero,
      () {
        context.read<HomePageProvider>()
          ..setAnimationController(navigationContainerAnimationController)
          ..setBottomBarOffsetToAnimateController(
              navigationContainerAnimationController)
          ..setAppBarOffsetToAnimateController(
              navigationContainerAnimationController);
      },
    );
    super.initState();
  }

  setSnackBarFunctionForCartMessage() {
    Future.delayed(const Duration(seconds: 5)).then(
      (value) {
        if (homePageSingleSellerMessage) {
          homePageSingleSellerMessage = false;
          showOverlay(
              getTranslated(context,
                  'One of the product is out of stock, We are not able To Add In Cart')!,
              context);
        }
      },
    );
  }
   Future<void> init({checkActualVersion = false}) async {
    // This is used for cases when: APP is not running and the user clicks on a link.
    try {
      final Uri? uri = await getInitialUri();
      _uniLinkHandler(uri: uri);
    } on PlatformException {
      if (kDebugMode) print("(PlatformException) Failed to receive initial uri.");
    } on FormatException catch (error) {
      if (kDebugMode) print("(FormatException) Malformed Initial URI received. Error: $error");
    }

    // This is used for cases when: APP is already running and the user clicks on a link.
    uriLinkStream.listen((Uri? uri) async {
      _uniLinkHandler(uri: uri);
    }, onError: (error) {
      if (kDebugMode) print('UniLinks onUriLink error: $error');
    });
  }

   Future<void> _uniLinkHandler({required Uri? uri}) async {
    if (uri == null || uri.queryParameters.isEmpty) return;
    Map<String, String> params = uri.queryParameters;
    getProduct(params['data'].toString(), int.parse(params['index'].toString()), int.parse(params['secPos'].toString()),  params['list']=="true"?true:false);

     // String receivedPromoId = params['promo-id'] ?? '';
    // if (receivedPromoId.isEmpty) return;
    // _promoId = receivedPromoId;
    //
    // if (_promoId == 'ABC1') {
    //
    // }
    //
    // if (_promoId == 'ABC2') {
    //
    // }
  }

  void initDynamicLinks() async {
    print("****************************8");
    streamSubscription = FirebaseDynamicLinks.instance.onLink.listen(
      (event) {
        final Uri deepLink = event.link;
        if (deepLink.queryParameters.isNotEmpty) {
          print("${ deepLink}");
          print("${ deepLink.queryParameters['index']}");
        //   int index = int.parse(deepLink.queryParameters['index']!);
        //
        //   int secPos = int.parse(deepLink.queryParameters['secPos']!);
        //
        //   String? id = deepLink.queryParameters['data'];
        //
        // //  String? list = deepLink.queryParameters['list'];
        //   int? index;
        //   int? secPos;
        //   String? id;
        //
        //   if (deepLink.queryParameters.containsKey('index')) {
        //     index = int.tryParse(deepLink.queryParameters['index']??"0");
        //   }
        //
        //   if (deepLink.queryParameters.containsKey('secPos')) {
        //     secPos = int.tryParse(deepLink.queryParameters['secPos']??"0");
        //   }
        //
        //   id = deepLink.queryParameters['data'];
        //
        //   print('Index: $index');
        //   print('SecPos: $secPos');
        //   print('ID: $id');
        //
           getProduct(deepLink.queryParameters['data'].toString(), int.parse(deepLink.queryParameters['index'].toString()), int.parse(deepLink.queryParameters['secPos'].toString()),  deepLink.queryParameters['list']=="true"?true:false);
        }
      },
    );
  }

  Future<void> getProduct(String id, int index, int secPos, bool list) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {
          ID: id,
        };

        Response response =
            await post(getProductApi, headers: headers, body: parameter)
                .timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata['error'];
        String msg = getdata['message'];
        if (!error) {
          var data = getdata['data'];

          List<Product> items = [];

          items = (data as List).map((data) => Product.fromJson(data)).toList();
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => ProductDetail(
                index: list ? int.parse(id) : index,
                model: list
                    ? items[0]
                    : context
                        .read<HomePageProvider>()
                        .sectionList[secPos]
                        .productList![index],
                secPos: secPos,
                list: list,
              ),
            ),
          );
        } else {
          if (msg != 'Products Not Found !') setSnackbar(msg, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      {
        if (mounted) {
          setState(
            () {
              isNetworkAvail = false;
            },
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_tabController.index != 0) {
          _tabController.animateTo(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: false,

        extendBody: true,
        backgroundColor:colors.primary1,
        appBar: _selBottom == 0
            ? _getAppBar()
            : PreferredSize(
                preferredSize: Size.zero,
                child: Container(),
              ),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: const [
              HomePage(),
              AllCategory(),
              Explore(),
              Cart(
                fromBottom: true,
              ),
              MyProfile(),
            ],
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: Colors.pink,
        //   child: const Icon(Icons.add),
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       CupertinoPageRoute(
        //         builder: (context) => const AnimationScreen(),
        //       ),
        //     );
        //   },
        // ),
        bottomNavigationBar: _getBottomBar(),
      ),
    );
  }

  _getAppBar() {
    String? title;
    if (_selBottom == 1) {
      title = getTranslated(context, 'CATEGORY');
    } else if (_selBottom == 2) {
      title = getTranslated(context, 'EXPLORE');
    } else if (_selBottom == 3) {
      title = getTranslated(context, 'MYBAG');
    } else if (_selBottom == 4) {
      title = getTranslated(context, 'PROFILE');
    }
    final appBar = AppBar(
      //toolbarHeight: 200,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      backgroundColor: colors.whiteTemp,
      title: _selBottom == 0
          ?Image.asset('assets/images/png/splashlogo-removebg-preview.png',height:110,width: 110,)
          : Text(
              title!,
              style: const TextStyle(
                color: colors.primary,
                fontFamily: 'ubuntu',
                fontWeight: FontWeight.normal,
              ),
            ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(
            end: 10.0,
            bottom: 10.0,
            top: 10.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(circularBorderRadius10),
              color:colors.whiteTemp,
            ),
            width: 50,
            child: InkWell(
              onTap: () {
                CUR_USERID != null
                    ? Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const Search(),
                  ),
                ).then(
                      (value) {
                    if (value != null && value) {
                      _tabController.animateTo(1);
                    }
                  },
                )
                    : Routes.navigateToSearchScreen(context);
              },
              child: Icon(
                Icons.search,color:colors.blackTemp,
                size: 25,

              ),
            ),
          ),
        ),


        Padding(
          padding: const EdgeInsetsDirectional.only(
              end: 10.0, bottom: 10.0, top: 10.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(circularBorderRadius10),
              color: colors.whiteTemp,
            ),
            width: 50,
            child: IconButton(
              icon: SvgPicture.asset(
                  DesignConfiguration.setSvgPath('fav_black'),
                  color: Theme.of(context)
                      .colorScheme
                      .black // Add your color here to apply your own color
                  ),
              onPressed: () {
                Routes.navigateToFavoriteScreen(context);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(
            end: 10.0,
            bottom: 10.0,
            top: 10.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(circularBorderRadius10),
              color:colors.whiteTemp,
            ),
            width: 50,
            child: IconButton(
              icon: SvgPicture.asset(
                DesignConfiguration.setSvgPath('notification_black'),
                color: Theme.of(context).colorScheme.black,
              ),
              onPressed: () {
                CUR_USERID != null
                    ? Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const NotificationList(),
                        ),
                      ).then(
                        (value) {
                          if (value != null && value) {
                            _tabController.animateTo(1);
                          }
                        },
                      )
                    : Routes.navigateToLoginScreen(context);
              },
            ),
          ),
        ),
      ],
    );

    return PreferredSize(
      preferredSize: appBar.preferredSize,
      child: SlideTransition(
        position: context.watch<HomePageProvider>().animationAppBarBarOffset,
        child: SizedBox(
          height: context.watch<HomePageProvider>().getBars ? 100 : 0,
          child: appBar,
        ),
      ),
    );
  }

  getTabItem(String enabledImage, String disabledImage, int selectedIndex,
      String name) {
    return Wrap(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: SizedBox(
                height: 25,
                child: _selBottom == selectedIndex
                    ? Lottie.asset(
                        DesignConfiguration.setLottiePath(enabledImage),
                        repeat: false,
                        height: 25,)
                    : SvgPicture.asset(
                        DesignConfiguration.setSvgPath(disabledImage),
                        color: colors.primary,
                        height: 20,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Container(
                width:90,
                child: Text(
                  getTranslated(context, name)!,
                  style: TextStyle(
                    color: _selBottom == selectedIndex
                        ? Theme.of(context).colorScheme.fontColor
                        : Theme.of(context).colorScheme.lightBlack,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: textFontSize8,
                    fontFamily: 'ubuntu',
                  ),
                  textAlign: TextAlign.center,
                  maxLines:1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _getBottomBar() {
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;

    return AnimatedContainer(
      duration: Duration(
        milliseconds: context.watch<HomePageProvider>().getBars ? 500 : 500,
      ),
      height: context.watch<HomePageProvider>().getBars
          ? kBottomNavigationBarHeight
          : 0,
      decoration: BoxDecoration(
        color:Color(0xffF3E0C0) ,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.black26,
            blurRadius: 5,
          )
        ],
      ),
      child: Selector<ThemeNotifier, ThemeMode>(
        selector: (_, themeProvider) => themeProvider.getThemeMode(),
        builder: (context, data, child) {
          return TabBar(
            controller: _tabController,

            tabs: [
              Tab(
                child: getTabItem(
                  /*(data == ThemeMode.system &&
                              currentBrightness == Brightness.dark) ||
                          data == ThemeMode.dark*/false
                      ? 'dark_active_home'
                      : 'light_active_home',
                  'home',
                  0,
                  'HOME_LBL',
                ),
              ),
              Tab(
                child: getTabItem(
                    /*(data == ThemeMode.system &&
                                currentBrightness == Brightness.dark) ||
                            data == ThemeMode.dark*/ false
                        ? 'dark_active_category'
                        : 'light_active_category',
                    'category',
                    1,
                    'CATEGORY'),
              ),
              Tab(
                child: getTabItem(
                  /*(data == ThemeMode.system &&
                              currentBrightness == Brightness.dark) ||
                          data == ThemeMode.dark*/false
                      ? 'dark_active_explorer'
                      : 'light_active_explorer',
                  'brands',
                  2,
                  'EXPLORE',
                ),
              ),
              Tab(
                child: getTabItem(
                  /*(data == ThemeMode.system &&
                              currentBrightness == Brightness.dark) ||
                          data == ThemeMode.dark*/false
                      ? 'dark_active_cart'
                      : 'light_active_cart',
                  'cart',
                  3,
                  'CART',
                ),
              ),
              Tab(
                child: getTabItem(
                  /*(data == ThemeMode.system &&
                              currentBrightness == Brightness.dark) ||
                          data == ThemeMode.dark*/ false
                      ? 'dark_active_profile'
                      : 'light_active_profile',
                  'profile',
                  4,
                  'PROFILE',
                ),
              ),
            ],
            indicatorColor: Colors.transparent,
            labelColor: colors.primary,

            isScrollable: false,
            labelStyle: const TextStyle(fontSize: textFontSize12),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
