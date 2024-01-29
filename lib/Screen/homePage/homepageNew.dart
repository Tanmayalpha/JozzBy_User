import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:eshop_multivendor/Screen/brand_list/brandlist.dart';
import 'package:eshop_multivendor/Screen/star_rating.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:uni_links/uni_links.dart';

import 'package:flutter/services.dart';
import 'package:http/http.dart'as http;
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Screen/SQLiteData/SqliteData.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/Search/SearchProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Provider/systemProvider.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/MostLikeSection.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/hideAppBarBottom.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/homePageDialog.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/horizontalCategoryList.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/section.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:version/version.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../Model/Get_Images_model.dart';
import '../../Model/Get_brands_model.dart';

import '../../Provider/Favourite/FavoriteProvider.dart';
import '../../Provider/homePageProvider.dart';
import '../../deeplinking/deeplinking_service.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/security.dart';
import '../../widgets/snackbar.dart';
import '../NoInterNetWidget/NoInterNet.dart';

import '../ProductList&SectionView/ProductList.dart';

import '../SellerDetail/Seller_Details.dart';

String? brandId;
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage>, TickerProviderStateMixin {
  late Animation buttonSqueezeanimation;
  late AnimationController buttonController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  var db = DatabaseHelper();
  final ScrollController _scrollBottomBarController = ScrollController();
  DateTime? currentBackPressTime;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  int count = 1;
 String? brandId,brandName, brandImage;
  String? s_id;
  int sellerListOffset = 0;
  int totalSelletCount = 0;
  String? seller_id;
  String? sellerImage;
  String? sellerStoreName,sellerRating,storeDesc;
  List<Product> sellerList = [];


  @override
  bool get wantKeepAlive => true;

  bool getBrand = true;

  setStateNow() {
    setState(() {});
  }

  setSnackBarFunctionForCartMessage() {
    Future.delayed(const Duration(seconds: 6)).then(
      (value) {
        if (homePageSingleSellerMessage) {
          homePageSingleSellerMessage = false;
          showOverlay(
            getTranslated(context,
                'One of the product is out of stock, We are not able To Add In Cart')!,
            context,
          );
        }
      },
    );
  }

  @override
  void initState() {
    //_handleIncomingLinks();
    // DynamicLinkHandler().initDynamicLinks(context);
    //getImagesApi();
    getImagesThirdSliderApi();
    getImagesFourthdSliderApi();
    getBrandApi();
   // getSeller();

    isSet =true;

    UserProvider user = Provider.of<UserProvider>(context, listen: false);
    SettingProvider setting =
        Provider.of<SettingProvider>(context, listen: false);
    user.setMobile(setting.mobile);
    user.setName(setting.userName);
    user.setEmail(setting.email);
    user.setProfilePic(setting.profileUrl);
    user.setGstnumber(setting.gstNumber);
    user.setShopName(setting.shopName);
    Future.delayed(Duration.zero).then(
      (value) {
        callApi();
      },
    );

    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
    setSnackBarFunctionForCartMessage();
    Future.delayed(Duration.zero).then(
      (value) {
        hideAppbarAndBottomBarOnScroll(
          _scrollBottomBarController,
          context,
        );
      },
    );
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: colors.primary1,
      key: _scaffoldKey,
      body: WillPopScope(
        onWillPop: onWillPopScope,
        child: SafeArea(
          child: isNetworkAvail
              ? RefreshIndicator(
                  color: colors.primary,
                  key: _refreshIndicatorKey,
                  onRefresh: _refresh,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    //controller: _scrollBottomBarController,
                    slivers: [
                      // SliverPersistentHeader(
                      //   floating: false,
                      //   pinned: true,
                      //   delegate: SearchBarHeaderDelegate(),
                      // ),
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const HorizontalCategoryList(),
                            const SizedBox(height: 20,),
                            CustomSlider(),
                            InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>const BrandList()));
                            },
                            child: Image.asset('assets/images/png/app products_1.gif')),

                            const SizedBox(height: 10,),
                            const Section(),
                            //getImagesModel?.data?.isEmpty ?? true ? const SizedBox() :  imageCard(),

                           // context.read<HomePageProvider>().sellerList.isEmpty ? const Text('Seller Not Found',style: TextStyle(color: colors.blackTemp),):getSellerList(),
                            const SizedBox(height: 10,),
                           /* const Divider(
                              thickness: 0.6,
                              color:Colors.grey,
                            ),*/
                            //getImagesModel2?.data?.isEmpty ?? true ? SizedBox() :  imageCard2(),
                            /*Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                color: colors.primary1,
                                  width: MediaQuery.of(context).size.width/1,
                                  height: 40,
                                  child: const Center(child: Text("All Brand List",style: TextStyle(color: colors.blackTemp,fontWeight: FontWeight.bold,fontSize: 20),))),
                            ),
                            const SizedBox(height: 10,),
                           brandcard()*/
                            const Divider(
                              thickness: 1,
                              color:Colors.grey,
                            ),
                            const MostLikeSection(),
                            const SizedBox(height: 10,),
                            getImagesModel3?.data?.isEmpty ?? true ? const SizedBox() :  imageCard3(),
                            const SizedBox(height: 50,),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              : NoInterNet(
                  buttonController: buttonController,
                  buttonSqueezeanimation: buttonSqueezeanimation,
                  setStateNoInternate: setStateNoInternate,
                ),
        ),
      ),
    );
  }

  /*void getSeller() {
    Map parameter = {
      LIMIT: perPage.toString(),
      OFFSET: sellerListOffset.toString(),
    };
    // if (_controller.text != '') {
    //   parameter = {
    //     SEARCH: _controller.text.trim(),
    //   };
    // }

    apiBaseHelper.postAPICall(getSellerApi, parameter).then(
          (getdata) {
            print('_____cccccccccccc______${getSellerApi}______${parameter}____');
        bool error = getdata['error'];
        String? msg = getdata['message'];
        List<Product> tempSellerList = [];
        tempSellerList.clear();
        if (!error) {
          totalSelletCount = int.parse(getdata['total']);
          var data = getdata['data'];

          tempSellerList =
              (data as List).map((data) => Product.fromSeller(data)).toList();
          sellerListOffset += perPage;
          setState(() {});
        } else {
          setSnackbar1(msg!,);
        }
        sellerList.addAll(tempSellerList);
        context.read<HomePageProvider>().setSellerLoading(false);


      },
      onError: (error) {
        setSnackbar1(error.toString());
        context.read<HomePageProvider>().setSellerLoading(false);
      },
    );

    setState(() {});
  }*/

  setSnackbar1(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.black),
      ),
      backgroundColor: Theme.of(context).colorScheme.white,
      elevation: 1.0,
    ));
  }

/* getSellerList(){

    return Container(
      color: colors.primary1,
      height: 190,
      child: ListView.separated(
          itemCount:context.read<HomePageProvider>().sellerList.length,
          separatorBuilder: (BuildContext context, int index) => const Divider(),
          scrollDirection: Axis.horizontal,

          itemBuilder: (c,i){
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(onTap: (){

                setState(() {
                  s_id = context.read<HomePageProvider>().sellerList[i].seller_id;

                });

                seller_id = context.read<HomePageProvider>().sellerList[i].seller_id;
                sellerImage =context.read<HomePageProvider>().sellerList[i].seller_profile;
                sellerStoreName =context.read<HomePageProvider>().sellerList[i].store_name;
                sellerRating = context.read<HomePageProvider>().sellerList[i].seller_rating;
                storeDesc = context.read<HomePageProvider>().sellerList[i].store_description;
                //
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => SellerProfile(totalProductsOfSeller: '',s_id:s_id,sellerImage: sellerImage,sellerStoreName:sellerStoreName,sellerRating: sellerRating,storeDesc: storeDesc
                    ),
                  ),
                );

              },
                child: Container(
                    decoration: BoxDecoration(
                        color:Color(0xffEFEFEF),
                        border: Border.all(color: colors.blackTemp),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    width: 165,
                    height: 180,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10,),
                        Container(
                          height: 100,width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(60),
                            // border: Border.all(color: colors.blackTemp)
                          ),
                          child: ClipRRect(
                             borderRadius: BorderRadius.circular(60),
                              child: Image.network("${context.read<HomePageProvider>().sellerList[i].seller_profile}",fit: BoxFit.fill,)),
                        ),
                        const SizedBox(height:15,),
                        Container(
                            width: 90,
                            child: Center(child: Text("${context.read<HomePageProvider>().sellerList[i].seller_name}",overflow: TextOverflow.ellipsis,maxLines: 2,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),))),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 15, bottom: 10),
                      child: StarRatingIndicators(
                        noOfRatings: context.read<HomePageProvider>().sellerList[i]
                            .noOfRating ?? '0.0',
                        totalRating: context.read<HomePageProvider>().sellerList[i].rating ?? '0.0',
                      ),),

                      ],
                    )
                ),
              ),
            );
          }),
    );


 }*/

  brandcard(){
    return Padding(
      padding: const EdgeInsets.only(left:5.0,right: 5),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Card(
          elevation: 4,
          child: Column(
            children: [
              Container(
                height: 40,
                width: MediaQuery.of(context).size.width/1,
                decoration: BoxDecoration(
                    color: colors.secondary,
                  borderRadius: BorderRadius.circular(5)
                ),
                child: const Center(child: Text('The brand List',style: TextStyle(fontWeight: FontWeight.bold,fontSize:20),)),
              ),
              const SizedBox(height: 10,),
              const Text('For Brands this is botton to redirect list',style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10,),
              InkWell(
                onTap: () {
                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>BrandList()));
                },
                child: Container(
                    height: 40,
                    width: 110,
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      borderRadius: BorderRadius.circular(80)
                    ),
                    child:Center(child: Text('CLICK HERE',style: TextStyle(color: colors.whiteTemp),))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  imageCard(){
    return SizedBox(
      height:200,
        width:double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount:getImagesModel?.data?.length ,
            // physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (context, index) {
            return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network("${getImagesModel?.data?[index].image}",fit: BoxFit.fill,width: MediaQuery.of(context).size.width/1.05,));
          },)

        ));
  }
  imageCard2(){
    return SizedBox(
        height:200,
        width:double.infinity,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount:getImagesModel2?.data?.length ,
              // physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network("${getImagesModel2?.data?[index].image}",fit: BoxFit.fill,width: MediaQuery.of(context).size.width/1.05,));
              },)

        ));
  }

  imageCard3(){
    return SizedBox(
        height:200,
        width:double.infinity,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount:getImagesModel3?.data?.length ,
              // physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network("${getImagesModel3?.data?[index].image}",fit: BoxFit.fill,width: MediaQuery.of(context).size.width/1.05,));
              },)

        ));
  }

  brandListCart(){
    return Container(
     color: colors.primary1,
      height: 160,
      child: ListView.separated(
          itemCount: getBrandsModel?.data?.length.toInt()??0,
          separatorBuilder: (BuildContext context, int index) => const Divider(),
        scrollDirection: Axis.horizontal,

          itemBuilder: (c,i){
        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () async {

                setState(() {
                  brandId =   getBrandsModel!.data![i].id;
                  brandName = getBrandsModel?.data?[i].name;
                  brandImage = getBrandsModel?.data?[i].image;
                });
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.setString('brand_name', brandName!);
                print('brandName------kkkk------------${getBrandsModel!.data![i].name}__________');

                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => ProductList(getBrand: true,brandId: brandId,brandName: brandName,),
                  ),
                );

            },
                child: Container(
                  decoration: BoxDecoration(
                    color:Color(0xffEFEFEF),
                    borderRadius: BorderRadius.circular(10)
                  ),
                     width: 100,
                    height: 180,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                            Container(
                            height: 90,
                             width: double.infinity,
                             child: ClipRRect(
                               borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                                 child:getBrandsModel?.data?[i].image==null||getBrandsModel?.data?[i].image==""?Image.asset('assets/images/png/placeholder.png'): Image.network("$imageUrl${getBrandsModel?.data?[i].image}",fit: BoxFit.fill,))),
                            const SizedBox(height:10,),
                            Container(
                                width: 90,
                                child: Center(child: Text("${getBrandsModel?.data?[i].name}",overflow: TextOverflow.ellipsis,maxLines: 2,textAlign: TextAlign.center,))),

                    ],
                  )
                ),
              ),
            ),
            Container(
              height:150,
              width:0.50,
              color: Colors.grey,
            ),
          ],
        );
      }),
    );
  }
  GetImagesModel? getImagesModel;
  GetImagesModel? getImagesModel2;
  GetImagesModel? getImagesModel3;

  getImagesApi() async {
    var headers = {
      'Cookie': 'ci_session=072b6f29be0b884e59f61a1530aec13e11b5f470'
    };
    var request = http.MultipartRequest('GET', Uri.parse('$baseUrl/get_slider_images_bottom'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print('_______________imagesPath_________________');
   var  result = await response.stream.bytesToString();
   var finalResult = GetImagesModel.fromJson(jsonDecode(result));
      setState(() {
        getImagesModel =  finalResult;
      });

   print('____imagesPath_______${result}__________');

    }
    else {
    print(response.reasonPhrase);
    }

  }

  getImagesThirdSliderApi() async {
    var headers = {
      'Cookie': 'ci_session=072b6f29be0b884e59f61a1530aec13e11b5f470'
    };
    var request = http.MultipartRequest('GET', Uri.parse('$baseUrl/get_slider_images_third'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print('_______________imagesPath_________________');
      var  result = await response.stream.bytesToString();
      var finalResult = GetImagesModel.fromJson(jsonDecode(result));
      setState(() {
        getImagesModel2 =  finalResult;
      });

      print('____imagesPath_______${result}__________');

    }
    else {
      print(response.reasonPhrase);
    }

  }

  getImagesFourthdSliderApi() async {
    var headers = {
      'Cookie': 'ci_session=072b6f29be0b884e59f61a1530aec13e11b5f470'
    };
    var request = http.MultipartRequest('GET', Uri.parse('$baseUrl/get_slider_images_fourth'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print('_______________imagesPath_________________');
      var  result = await response.stream.bytesToString();
      var finalResult = GetImagesModel.fromJson(jsonDecode(result));
      setState(() {
        getImagesModel3 =  finalResult;
      });

      print('____imagesPath_______${result}__________');

    }
    else {
      print(response.reasonPhrase);
    }

  }


  GetBrandsModel? getBrandsModel;

  getBrandApi() async {
    var headers = {
      'Cookie': 'ci_session=b458202437d40c57fd9d5ea22c70e00ddc4d2723'
    };
    var request = http.MultipartRequest('GET', Uri.parse('$baseUrl/get_brand'));

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
       var result =  await response.stream.bytesToString();
       var finalResult =  GetBrandsModel.fromJson(jsonDecode(result));
       setState(() {
         getBrandsModel = finalResult;

         for(var i=0;i<getBrandsModel!.data!.length;i++){
           brandId = getBrandsModel!.data![i].id;

           print('----------brand_id--------------${brandId}');

         }
       });
    }
    else {
    print(response.reasonPhrase);
    }

  }

  StreamSubscription? _sub;
  Uri? _latestUri;
  Object? _err;


  void _handleIncomingLinks() {

    if (!kIsWeb) {

      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        print('got uri: $uri');
        setState(() {
          _latestUri = uri;
          _err = null;
        });
      }, onError: (Object err) {
        if (!mounted) return;
        print('got err: $err');
        setState(() {
          _latestUri = null;
          if (err is FormatException) {
            _err = err;
          } else {
            _err = null;
          }
        });
      });
    }
  }



  Future<void> _refresh() {
    context.read<HomePageProvider>().catLoading = true;
    context.read<HomePageProvider>().secLoading = true;
    context.read<HomePageProvider>().sliderLoading = true;
    context.read<HomePageProvider>().mostLikeLoading = true;
    context.read<HomePageProvider>().offerLoading = true;
    context.read<HomePageProvider>().proIds.clear();
    context.read<HomePageProvider>().sliderList.clear();
    context.read<HomePageProvider>().offerImagesList.clear();
    context.read<HomePageProvider>().sectionList.clear();
    return callApi();
  }

  Future<void> callApi() async {
    UserProvider user = Provider.of<UserProvider>(context, listen: false);
    SettingProvider setting =
        Provider.of<SettingProvider>(context, listen: false);

    user.setUserId(setting.userId);

    isNetworkAvail = await isNetworkAvailable();
    print('ccccccccccccccccc${isNetworkAvail}');
    if (isNetworkAvail) {
      getSetting();
      //getImagesApi();
      getImagesThirdSliderApi();
      getImagesFourthdSliderApi();
      getBrandApi();
      context.read<HomePageProvider>().getSeller();

      context.read<HomePageProvider>().getSections();
      context.read<HomePageProvider>().getImagesApi();
      context.read<HomePageProvider>().getImagesThirdSliderApi();
      print('kkkkkkkkkkkkkk');
      context.read<HomePageProvider>().getSliderImages();
      context.read<HomePageProvider>().getCategories(context);
      context.read<HomePageProvider>().getOfferImages();

      context.read<HomePageProvider>().getMostLikeProducts();
      context.read<HomePageProvider>().getMostFavouriteProducts();
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
    return;
  }








  void getSetting() {
    CUR_USERID = context.read<SettingProvider>().userId;
    context.read<SystemProvider>().getSystemSettings(userID: CUR_USERID).then(
      (systemConfigData) async {
        if (!systemConfigData['error']) {
          //
          //Tag list from system API
          if (systemConfigData['tagList'] != null) {
            context.read<SearchProvider>().tagList =
                systemConfigData['tagList'];
          }
          //check whether app is under maintenance
          if (systemConfigData['isAppUnderMaintenance'] == '1') {
            HomePageDialog.showUnderMaintenanceDialog(context);
          }

          if (CUR_USERID != null) {
            context
                .read<UserProvider>()
                .setCartCount(systemConfigData['cartCount']);
            context
                .read<UserProvider>()
                .setBalance(systemConfigData['userBalance']);
            context
                .read<UserProvider>()
                .setPincode(systemConfigData['pinCode']);

            if (systemConfigData['referCode'] == null ||
                systemConfigData['referCode'] == '' ||
                systemConfigData['referCode']!.isEmpty) {
              generateReferral();
            }

            context.read<HomePageProvider>().getFav(context, setStateNow);
            context.read<CartProvider>().getUserCart(save: '0');
            _getOffFav();
            context.read<CartProvider>().getUserOfflineCart();
          }
          if (systemConfigData['isVersionSystemOn'] == '1') {
            String? androidVersion = systemConfigData['androidVersion'];
            String? iOSVersion = systemConfigData['iOSVersion'];

            PackageInfo packageInfo = await PackageInfo.fromPlatform();

            String version = packageInfo.version;

            final Version currentVersion = Version.parse(version);
            final Version latestVersionAnd = Version.parse(androidVersion!);
            final Version latestVersionIos = Version.parse(iOSVersion!);

            if ((Platform.isAndroid && latestVersionAnd > currentVersion) ||
                (Platform.isIOS && latestVersionIos > currentVersion)) {
              HomePageDialog.showAppUpdateDialog(context);
            }
          }
          setState(() {});
        } else {
          setSnackbar(systemConfigData['message']!, context);
        }
      },
    ).onError(
      (error, stackTrace) {
        setSnackbar(error.toString(), context);
      },
    );
  }

  Future<void>? getDialogForClearCart() {
    HomePageDialog.clearYouCartDialog(context);
  }

  Future<void> _getOffFav() async {
    if (CUR_USERID == null || CUR_USERID == '') {
      List<String>? proIds = (await db.getFav())!;
      if (proIds.isNotEmpty) {
        isNetworkAvail = await isNetworkAvailable();

        if (isNetworkAvail) {
          try {
            var parameter = {
              'product_ids': proIds.join(','),

            };

            Response response =
                await post(getProductApi, body: parameter, headers: headers)
                    .timeout(const Duration(seconds: timeOut));

            var getdata = json.decode(response.body);
            bool error = getdata['error'];
            if (!error) {
              var data = getdata['data'];

              List<Product> tempList =
                  (data as List).map((data) => Product.fromJson(data)).toList();

              context.read<FavoriteProvider>().setFavlist(tempList);
            }
            if (mounted) {
              setState(() {
                context.read<FavoriteProvider>().setLoading(false);
              });
            }
          } on TimeoutException catch (_) {
            setSnackbar(getTranslated(context, 'somethingMSg')!, context);
            context.read<FavoriteProvider>().setLoading(false);
          }
        } else {
          if (mounted) {
            setState(() {
              isNetworkAvail = false;
              context.read<FavoriteProvider>().setLoading(false);
            });
          }
        }
      } else {
        context.read<FavoriteProvider>().setFavlist([]);
        setState(() {
          context.read<FavoriteProvider>().setLoading(false);
        });
      }
    }
  }

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<void> generateReferral() async {
    String refer = getRandomString(8);

    Map parameter = {
      REFERCODE: refer,
    };

    apiBaseHelper.postAPICall(validateReferalApi, parameter).then(
      (getdata) {
        bool error = getdata['error'];
        if (!error) {
          REFER_CODE = refer;

          Map parameter = {
            USER_ID: CUR_USERID,
            REFERCODE: refer,
          };

          apiBaseHelper.postAPICall(getUpdateUserApi, parameter);
        } else {
          if (count < 5) generateReferral();
          count++;
        }

        context.read<HomePageProvider>().secLoading = false;
      },
      onError: (error) {
        setSnackbar(error.toString(), context);
        context.read<HomePageProvider>().secLoading = false;
      },
    );
  }

  Widget homeShimmer() {
    return SizedBox(
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: SingleChildScrollView(
            child: Column(
          children: [
            HorizontalCategoryList.catLoading(context),
            sliderLoading(),
            Section.sectionLoadingShimmer(context),
          ],
        )),
      ),
    );
  }

  Widget sliderLoading() {
    double width = deviceWidth!;
    double height = width / 2;
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.simmerBase,
      highlightColor: Theme.of(context).colorScheme.simmerHigh,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        height: height,
        color: Theme.of(context).colorScheme.white,
      ),
    );
  }

  setStateNoInternate() async {
    context.read<HomePageProvider>().catLoading = true;
    context.read<HomePageProvider>().secLoading = true;
    context.read<HomePageProvider>().offerLoading = true;
    context.read<HomePageProvider>().mostLikeLoading = true;
    context.read<HomePageProvider>().sliderLoading = true;
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          if (mounted) {
            setState(
              () {
                isNetworkAvail = true;
              },
            );
          }
          callApi();
        } else {
          await buttonController.reverse();
          if (mounted) setState(() {});
        }
      },
    );
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  @override
  void dispose() {
    _scrollBottomBarController.removeListener(() {});
    super.dispose();
  }

  Future<bool> onWillPopScope() {
    DateTime now = DateTime.now();

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      setSnackbar(getTranslated(context, 'Press back again to Exit')!, context);
      return Future.value(false);
    }
    return Future.value(true);
  }
}

class SearchBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        color: Theme.of(context).colorScheme.lightWhite,
        padding: EdgeInsets.fromLTRB(
          10,
          context.watch<HomePageProvider>().getBars ? 10 : 30,
          10,
          0,
        ),
        child: GestureDetector(
          child: SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: TextField(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.normal,
                ),
                enabled: false,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.lightWhite,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(circularBorderRadius10),
                    ),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(
                      Radius.circular(circularBorderRadius10),
                    ),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(
                      Radius.circular(circularBorderRadius10),
                    ),
                  ),
                  isDense: true,
                  hintText: getTranslated(context, 'searchHint'),
                  hintStyle: Theme.of(context).textTheme.bodyText2!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontSize: textFontSize12,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                      ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SvgPicture.asset(
                      DesignConfiguration.setSvgPath('homepage_search'),
                      height: 15,
                      width: 15,
                    ),
                  ),
                  suffixIcon: Selector<ThemeNotifier, ThemeMode>(
                    selector: (_, themeProvider) =>
                        themeProvider.getThemeMode(),
                    builder: (context, data, child) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child:
                        // (data == ThemeMode.system &&
                        //             MediaQuery.of(context).platformBrightness ==
                        //                 Brightness.light) ||
                        //         data == ThemeMode.light
                        //     ? SvgPicture.asset(
                        //         DesignConfiguration.setSvgPath('voice_search'),
                        //         height: 15,
                        //         width: 15,
                        //       )
                        //     :
                        SvgPicture.asset(
                          DesignConfiguration.setSvgPath(
                              'voice_search'),
                          height: 25,
                          width: 25,
                        ),
                      );
                    },
                  ),
                  fillColor: Theme.of(context).colorScheme.white,
                  filled: true,
                ),
              ),
            ),
          ),
          onTap: () async {
            Routes.navigateToSearchScreen(context);
          },
        ),
      ),
    );
  }

  @override
  double get maxExtent => 75;

  @override
  double get minExtent => 75;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
bool isSet= true ;