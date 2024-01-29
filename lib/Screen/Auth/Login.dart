import 'dart:async';
import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:eshop_multivendor/Provider/Favourite/FavoriteProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Auth/SendOtp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../Model/otpModel.dart';
import '../../Provider/authenticationProvider.dart';
import '../../Provider/productDetailProvider.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/desing.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/systemChromeSettings.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/security.dart';
import '../../widgets/validation.dart';
import '../Dashboard/Dashboard.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import 'Verify_Otp.dart';
import 'package:http/http.dart'as http;
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  String? countryName;
  FocusNode? passFocus, monoFocus = FocusNode();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool isShowPass = true;
  bool isMobile= false;
  int _value = 1;
  bool isSendOtp = false;

  String? mobile, id, countrycode, mobileno;
  @override
  void initState() {
    SystemChromeSettings.setSystemButtomNavigationBarithTopAndButtom();
    SystemChromeSettings.setSystemUIOverlayStyleWithNoSpecification();

    super.initState();
    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChromeSettings.setSystemUIOverlayStyleWithNoSpecification();
    buttonController!.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      isMobile == false ? checkNetwork():
      checkNetwork1()  ;

    }
  }

  otpModel? otpData;
  Future<void> sendOTP()async {
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}send_otp'));
    request.fields.addAll({
      'mobile': '${mobileController.text}',
      'device_token': ''
    });
    print('----gggggg------${request.fields}');
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      await buttonController!.reverse();
      var Result = await response.stream.bytesToString();
      var finalResult = jsonDecode(Result);
      print('---------Result---------${Result}');
      int otpSecond = finalResult['otp'];
      var error = finalResult['error'];
      var msg = finalResult['message'];
       print('-------otp------------${otpSecond}');
       if(error==false){
         setSnackbar(msg!, context);
         Future.delayed(const Duration(seconds: 1)).then(
               (_) {
             Navigator.pushReplacement(
               context,
               CupertinoPageRoute(
                 builder: (context) => VerifyOtp(
                   mobileNumber:mobileController.text,
                   countryCode: countrycode,
                   isMobile: isMobile,
                   responseOtp: otpSecond.toString(),
                   title: getTranslated(context, 'SEND_OTP_TITLE'),
                 ),
               ),
             );
           },
         );
       }
    }
    else {
      print(response.reasonPhrase);
    }





  }

  Future<void> checkNetwork1() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
     // sendOTP();
      Future.delayed(Duration.zero).then(
            (value) => context.read<AuthenticationProvider>().senOtp().then(
              (
              value,
              ) async {
            bool? error = value['error'];
            String? msg = value['message'];
            int? receivedOTP = value['otp'] ;
            await buttonController!.reverse();
            SettingProvider settingsProvider =
            Provider.of<SettingProvider>(context, listen: false);
            if (isMobile==true) {
              print("${value['otp']}");
              setSnackbar(value['message']??"", context);
              if (!error!) {

             print("___________________________");
                Future.delayed(const Duration(seconds: 1)).then(
                      (_) {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => VerifyOtp(
                        mobileNumber:mobileController.text,
                        countryCode: countrycode,
                        isMobile: isMobile,
                        otp: value['otp'].toString(),
                        title: getTranslated(context, 'SEND_OTP_TITLE'),

                      ),
                    ));
                  },
                );
                setSnackbar(msg!, context);
              } else {
                // setSnackbar(msg!, context);
              }
            }
            if (isMobile==false) {
              setSnackbar(value['message']??"", context);
              if (error!) {
                settingsProvider.setPrefrence(MOBILE,
                    context.read<AuthenticationProvider>().mobilenumbervalue);
                settingsProvider.setPrefrence(COUNTRY_CODE, countrycode!);
                Future.delayed(const Duration(seconds: 1)).then(
                      (_) {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => VerifyOtp(
                          mobileNumber: context
                              .read<AuthenticationProvider>()
                              .mobilenumbervalue,
                          countryCode: countrycode,
                          otp: value['otp'].toString(),
                          title: getTranslated(context, 'FORGOT_PASS_TITLE'),
                        ),
                      ),
                    );
                  },
                );
              } else {
                setSnackbar(
                    getTranslated(context, 'FIRSTSIGNUP_MSG')!, context);
              }
            }
          },
        ),
      );
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
            (_) async {
          if (mounted) {
            setState(
                  () {
                isNetworkAvail = false;
              },
            );
          }
          await buttonController!.reverse();
        },
      );
    }
  }

  Future<void> checkNetwork() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      Future.delayed(Duration.zero).then(
        (value) => context.read<AuthenticationProvider>().getLoginData(context).then(
          (
            value,
          ) async {
            bool error = value['error'];
            String? errorMessage = value['message'];
            await buttonController!.reverse();
            if (!error) {
              print('___________${value['data'][0]}__________');
              print("++++++++++++++++++++++++kfksksjd");
              var getdata = value['data'][0];
              UserProvider userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              userProvider.setName(getdata[USERNAME] ?? '');
              userProvider.setEmail(getdata[EMAIL] ?? '');
              userProvider.setShopName(getdata[SHOPNAME] ?? '');
              userProvider.setGstnumber(getdata["gst_number"] ?? '');
              userProvider.setProfilePic(getdata[IMAGE] ?? '');

              SettingProvider settingProvider =
                  Provider.of<SettingProvider>(context, listen: false);
              settingProvider.saveUserDetail(
                getdata[SHOPNAME],
                getdata["gst_number"],
                getdata[ID],
                getdata[USERNAME],
                getdata[EMAIL],
                getdata[MOBILE],
                getdata[CITY],
                getdata[AREA],
                getdata[ADDRESS],
                getdata[PINCODE],
                getdata[LATITUDE],
                getdata[LONGITUDE],
                getdata[IMAGE],
                context,
              );
              offFavAdd().then(
                (value) async {
                  db.clearFav();
                  context.read<FavoriteProvider>().setFavlist([]);
                  List cartOffList = await db.getOffCart();
                  if (singleSellerOrderSystem && cartOffList.isNotEmpty) {
                    forLoginPageSingleSellerSystem = true;
                    offSaveAdd().then(
                      (value) {
                        clearYouCartDialog();
                      },
                    );
                  } else {
                    offCartAdd().then(
                      (value) {
                        db.clearCart();
                        offSaveAdd().then(
                          (value) {
                            db.clearSaveForLater();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (r) => false,
                            );
                          },
                        );
                      },
                    );
                  }
                },
              );
            } else {
              setSnackbar(errorMessage!, context);
            }
          },
        ),
      );
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
        (_) async {
          await buttonController!.reverse();
          if (mounted) {
            setState(
              () {
                isNetworkAvail = false;
              },
            );
          }
        },
      );
    }
  }

  clearYouCartDialog() async {
    await DesignConfiguration.dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    circularBorderRadius5,
                  ),
                ),
              ),
              title: Text(
                getTranslated(context,
                    'Your cart already has an items of another seller would you like to remove it ?')!,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.normal,
                  fontSize: textFontSize16,
                  fontFamily: 'ubuntu',
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: SvgPicture.asset(
                        DesignConfiguration.setSvgPath('appbarCart'),
                        color: colors.primary,
                        height: 50,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text(
                          getTranslated(context, 'CANCEL')!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.lightBlack,
                            fontSize: textFontSize15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ubuntu',
                          ),
                        ),
                        onPressed: () {
                          Routes.pop(context);
                          db.clearSaveForLater();
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/home', (r) => false);
                        },
                      ),
                      TextButton(
                        child: Text(
                          getTranslated(context, 'Clear Cart')!,
                          style: const TextStyle(
                            color: colors.primary,
                            fontSize: textFontSize15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ubuntu',
                          ),
                        ),
                        onPressed: () {
                          if (CUR_USERID != null) {
                            context.read<UserProvider>().setCartCount('0');
                            context
                                .read<ProductDetailProvider>()
                                .clearCartNow()
                                .then(
                              (value) async {
                                if (context
                                        .read<ProductDetailProvider>()
                                        .error ==
                                    false) {
                                  if (context
                                          .read<ProductDetailProvider>()
                                          .snackbarmessage ==
                                      'Data deleted successfully') {
                                  } else {
                                    setSnackbar(
                                        context
                                            .read<ProductDetailProvider>()
                                            .snackbarmessage,
                                        context);
                                  }
                                } else {
                                  setSnackbar(
                                      context
                                          .read<ProductDetailProvider>()
                                          .snackbarmessage,
                                      context);
                                }
                                Routes.pop(context);
                                await offCartAdd();
                                db.clearSaveForLater();
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home',
                                  (r) => false,
                                );
                              },
                            );
                          } else {
                            Routes.pop(context);
                            db.clearSaveForLater();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (r) => false,
                            );
                          }
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  setStateNoInternate() async {
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (BuildContext context) => super.widget,
            ),
          );
        } else {
          await buttonController!.reverse();
          if (mounted) {
            setState(
              () {},
            );
          }
        }
      },
    );
  }

  Future<void> offFavAdd() async {
    List favOffList = await db.getOffFav();
    if (favOffList.isNotEmpty) {
      for (int i = 0; i < favOffList.length; i++) {
        _setFav(favOffList[i]['PID']);
      }
    }
  }

  _setFav(String pid) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: pid};
        Response response =
            await post(setFavoriteApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata['error'];
        String? msg = getdata['message'];
        if (!error) {
          setSnackbar(msg!, context);
        } else {
          setSnackbar(msg!, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }

  Future<void> offCartAdd() async {
    List cartOffList = await db.getOffCart();
    if (cartOffList.isNotEmpty) {
      for (int i = 0; i < cartOffList.length; i++) {
        addToCartCheckout(cartOffList[i]['VID'], cartOffList[i]['QTY']);
      }
    }
  }

  Future<void> addToCartCheckout(String varId, String qty) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {
          PRODUCT_VARIENT_ID: varId,
          USER_ID: CUR_USERID,
          QTY: qty,
        };

        Response response =
            await post(manageCartApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);
          if (getdata['message'] == 'One of the product is out of stock.') {
            homePageSingleSellerMessage = true;
          }
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) isNetworkAvail = false;

      setState(() {});
    }
  }

  Future<void> offSaveAdd() async {
    List saveOffList = await db.getOffSaveLater();

    if (saveOffList.isNotEmpty) {
      for (int i = 0; i < saveOffList.length; i++) {
        saveForLater(saveOffList[i]['VID'], saveOffList[i]['QTY']);
      }
    }
  }

  saveForLater(String vid, String qty) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {
          PRODUCT_VARIENT_ID: vid,
          USER_ID: CUR_USERID,
          QTY: qty,
          SAVE_LATER: '1'
        };
        Response response =
            await post(manageCartApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));
        var getdata = json.decode(response.body);
        bool error = getdata['error'];
        String? msg = getdata['message'];
        if (!error) {
        } else {
          setSnackbar(msg!, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }

  signInTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 40.0,
      ),
      child: Text(
        getTranslated(context, 'WELCOME_ESHOP')!,
        style: Theme.of(context).textTheme.headline6!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
              fontSize: textFontSize20,
              letterSpacing: 0.8,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }


  loginBtnText(){
   return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Radio(
          value: 1,
          fillColor: MaterialStateColor.resolveWith(
                  (states) =>  colors.secondary),
          activeColor:  colors.secondary,
          groupValue: _value,
          onChanged: (int? value) {
            setState(() {
              _value = value!;
              isMobile = false;
            });
          },
        ),
        const Text(
          'Mobile No.',
          style: TextStyle(
              color: colors.secondary, fontSize: 21),
        ),
        const SizedBox(height: 10,),
        Radio(
            value: 2,
            fillColor: MaterialStateColor.resolveWith(
                    (states) => colors.secondary),
            activeColor:   colors.secondary,
            groupValue: _value,
            onChanged: (int? value) {
              setState(() {
                _value = value!;
                isMobile = true;
              });
            }),
        // SizedBox(width: 10.0,),
        const Text(
          'OTP',
          style: TextStyle(
              color:  colors.secondary, fontSize: 21),
        ),
      ],
    );

  }

  signInSubTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 13.0,
      ),
      child: Text(
        getTranslated(context, 'INFO_FOR_LOGIN')!,
        style: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.38),
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  setMobileNo() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Container(
        height: 53,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.lightWhite,
          borderRadius: BorderRadius.circular(circularBorderRadius10),
        ),
        alignment: Alignment.center,
        child: TextFormField(
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(passFocus);
          },
          style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: textFontSize13),
          keyboardType: TextInputType.number,
          controller: mobileController,

          focusNode: monoFocus,
          maxLength: 10,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: "",
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 5,
              ),
              hintText: getTranslated(
                context,
                'MOBILEHINT_LBL',
              )!,
              hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  fontSize: textFontSize13),
              fillColor: Theme.of(context).colorScheme.lightWhite,

          ),
          validator: (val) => StringValidation.validateMob(
              val!,
              getTranslated(context, 'MOB_REQUIRED'),
              getTranslated(context, 'VALID_MOB')),
          onSaved: (String? value) {
            context.read<AuthenticationProvider>().setMobileNumber(value);
          },
        ),
      ),
    );
  }

  setPass() {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Container(
        height: 53,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.lightWhite,
          borderRadius: BorderRadius.circular(circularBorderRadius10),
        ),
        alignment: Alignment.center,
        child: TextFormField(
          style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: textFontSize13),
          onFieldSubmitted: (v) {
            passFocus!.unfocus();
          },
          keyboardType: TextInputType.text,
          obscureText: isShowPass,
          controller: passwordController,
          focusNode: passFocus,
          textInputAction: TextInputAction.next,
          validator: (val) => StringValidation.validatePass(
              val!,
              getTranslated(context, 'PWD_REQUIRED'),
              getTranslated(context, 'PWD_LENGTH')),
          onSaved: (String? value) {
            context.read<AuthenticationProvider>().setPassword(value);
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 5,
            ),
            suffixIcon: InkWell(
              onTap: () {
                setState(
                  () {
                    isShowPass = !isShowPass;
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 10.0),
                child: Icon(
                  !isShowPass ? Icons.visibility : Icons.visibility_off,
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.4),
                  size: 22,
                ),
              ),
            ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 40, maxHeight: 20),
            hintText: getTranslated(context, 'PASSHINT_LBL')!,
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
                fontWeight: FontWeight.bold,
                fontSize: textFontSize13),
            fillColor: Theme.of(context).colorScheme.lightWhite,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  forgetPass() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => SendOtp(
                    title: getTranslated(context, 'FORGOT_PASS_TITLE'),
                  ),
                ),
              );
            },
            child: Text(
              getTranslated(context, 'FORGOT_PASSWORD_LBL')!,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: textFontSize13,
                    fontFamily: 'ubuntu',
                  ),
            ),
          ),
        ],
      ),
    );
  }

  setDontHaveAcc() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            getTranslated(context, 'DONT_HAVE_AN_ACC')!,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ubuntu',
                ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (BuildContext context) => SendOtp(
                    title: getTranslated(context, 'SEND_OTP_TITLE'),
                  ),
                ),
              );
            },
            child: Text(
              getTranslated(context, 'SIGN_UP_LBL')!,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ubuntu',
                  ),
            ),
          )
        ],
      ),
    );
  }

 loginBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Center(
        child: Consumer<AuthenticationProvider>(
          builder: (context, value, child) {
            return AppBtn(
              title:isMobile==false?getTranslated(context, 'SIGNIN_LBL'):getTranslated(context, 'SEND_OTP_TITLE'),
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                if (passFocus != null) {
                  passFocus!.unfocus();
                }
                if (monoFocus != null) {
                  monoFocus!.unfocus();
                }/*
                if(isMobile==true){
                  sendOTP();
                }*/

                  validateAndSubmit();



              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.white,
      key: _scaffoldKey,
      body: isNetworkAvail
          ? SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 23,
                left: 23,
                right: 23,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getLogo(),
                    signInTxt(),
                    signInSubTxt(),
                    loginBtnText(),
                    // verifyCodeTxt(),
                    isMobile==true?setCodeWithMono():
                    setMobileNo(),

                    isMobile==false?setPass():
                    forgetPass(),
                    isMobile==false?forgetPass():SizedBox(),
                    loginBtn(),
                    setDontHaveAcc(),
                  ],
                ),
              ),
            )
          : NoInterNet(
              setStateNoInternate: setStateNoInternate,
              buttonSqueezeanimation: buttonSqueezeanimation,
              buttonController: buttonController,
            ),
    );
  }

  Widget getLogo() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 60),
      child:Image.asset('assets/images/png/splashlogo-removebg-preview.png',height:110,width:110,)
    );
  }



  Widget setCodeWithMono() {
    return Padding(
      padding: const EdgeInsets.only(top: 45),
      child: Container(
        height: 53,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.lightWhite,
          borderRadius: BorderRadius.circular(circularBorderRadius10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: setCountryCode(),
            ),
            Expanded(
              flex: 4,
              child: setMono(),
            )
          ],
        ),
      ),
    );
  }

  Widget setCountryCode() {
    double width = deviceWidth!;
    double height = deviceHeight! * 0.9;
    return CountryCodePicker(
      showCountryOnly: false,
      searchStyle: TextStyle(
        color: Theme.of(context).colorScheme.fontColor,
      ),
      flagWidth: 20,
      boxDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.white,
      ),
      searchDecoration: InputDecoration(
        hintText: getTranslated(context, 'COUNTRY_CODE_LBL'),
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.fontColor),
        fillColor: Theme.of(context).colorScheme.fontColor,
      ),
      showOnlyCountryWhenClosed: false,
      initialSelection: defaultCountryCode,
      dialogSize: Size(width, height),
      alignLeft: true,
      textStyle: TextStyle(
          color: Theme.of(context).colorScheme.fontColor,
          fontWeight: FontWeight.bold),
      onChanged: (CountryCode countryCode) {
        countrycode = countryCode.toString().replaceFirst('+', '');
        countryName = countryCode.name;
      },
      onInit: (code) {
        countrycode = code.toString().replaceFirst('+', '');
      },
    );
  }

  Widget setMono() {
    return TextFormField(
      maxLength: 10,
      keyboardType: TextInputType.number,
      controller: mobileController,
      style: Theme.of(context).textTheme.subtitle2!.copyWith(
          color: Theme.of(context).colorScheme.fontColor,
          fontWeight: FontWeight.normal),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (val) => StringValidation.validateMob(
          val!,
          getTranslated(context, 'MOB_REQUIRED'),
          getTranslated(context, 'VALID_MOB')),
      onSaved: (String? value) {
        print('___________${value}__________');
        context.read<AuthenticationProvider>().setMobileNumber(value);
        mobile = value;
      },
      decoration: InputDecoration(
        border: InputBorder.none,
        counterText: "",
        hintText: getTranslated(context, 'MOBILEHINT_LBL'),
        hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        focusedBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: colors.primary),
          borderRadius: BorderRadius.circular(circularBorderRadius7),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.lightWhite,
          ),
        ),
      ),
    );
  }






}
