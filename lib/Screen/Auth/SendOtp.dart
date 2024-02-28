import 'dart:async';
import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Screen/PrivacyPolicy/Privacy_Policy.dart';
import 'package:eshop_multivendor/Screen/Auth/Verify_Otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Provider/UserProvider.dart';
import '../../Provider/authenticationProvider.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/desing.dart';
import '../../widgets/security.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/systemChromeSettings.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/validation.dart';
import 'package:http/http.dart' as http;
import '../NoInterNetWidget/NoInterNet.dart';

class SendOtp extends StatefulWidget {
  String? title;
  String? mobileFromChangePasswordScreen;

  SendOtp({Key? key, this.title, this.mobileFromChangePasswordScreen})
      : super(key: key);

  @override
  _SendOtpState createState() => _SendOtpState();
}

class _SendOtpState extends State<SendOtp> with TickerProviderStateMixin {
  bool visible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final ccodeController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? mobile, id, countrycode, countryName, mobileno;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  forgetPass() async {
    print("wokingg");
    
    var request = http.MultipartRequest('POST',
        Uri.parse('https://admin.jozzbybazar.com/app/v1/api/verify_user_forgot'));
    request.fields.addAll({'mobile': mobileController.text});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var finalResponse = await response.stream.bytesToString();
      final jsonresponse = json.decode(finalResponse);
      print('responsees ${jsonresponse} ${finalResponse}');
      int? receivedOTP = jsonresponse['data'];
      print('optttt $receivedOTP');
      Future.delayed(const Duration(seconds: 1)).then(
        (_) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => VerifyOtp(
                mobileNumber: mobileController.text,
                // countryCode: countrycode,
                responseOtp: receivedOTP.toString(),
                title: getTranslated(context, 'FORGOT_PASS_TITLE'),
              ),
            ),
          );
        },
      );
      setSnackbar(jsonresponse['message'], context);
    } else {
      print(response.reasonPhrase);
    }
  }

  int? receivedOTP;

  Future<void> checkNetwork() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (widget.title == getTranslated(context, 'FORGOT_PASS_TITLE')) {
      
        var request = http.MultipartRequest(
            'POST',
            Uri.parse(
                'https://admin.jozzbybazar.com/app/v1/api/verify_user_forgot'));
        request.fields.addAll({'mobile': mobileController.text});
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          var finalResponse = await response.stream.bytesToString();
          final jsonresponse = json.decode(finalResponse);
          print("responsees ${jsonresponse} ${finalResponse}");
          setSnackbar(jsonresponse['message'], context);
          if (jsonresponse['error'] == false) {
            int? receivedOTP = jsonresponse['data'];
            print("optttt ${receivedOTP}");
            Future.delayed(const Duration(seconds: 1)).then(
              (_) {
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => VerifyOtp(
                      mobileNumber: mobileController.text,
                      countryCode: countrycode,
                      otp: receivedOTP.toString(),
                      responseOtp: receivedOTP.toString(),
                      title: getTranslated(context, 'FORGOT_PASS_TITLE'),
                    ),
                  ),
                );
              },
            );
          } else {
            await buttonController!.reverse();
          }
        } else {
          await buttonController!.reverse();
          print(response.reasonPhrase);
        }
      } else {
        Future.delayed(Duration.zero).then(
          (value) =>
              context.read<AuthenticationProvider>().getVerifyUser().then(
            (
              value,
            ) async {
              bool? error = value['error'];
              String? msg = value['message'];
              if (value['data'] != "") {
                receivedOTP = value['data'];
                print('____receivedOTP_______${receivedOTP}__________');
              }
              await buttonController!.reverse();
              SettingProvider settingsProvider =
                  Provider.of<SettingProvider>(context, listen: false);
              if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
                print('1');
                if (!error!) {
                  print('2');
                  // setSnackbar(msg!, context);
                  Future.delayed(const Duration(seconds: 1)).then(
                    (_) {
                      Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => VerifyOtp(
                            mobileNumber: mobile!,
                            countryCode: countrycode,
                            otp: receivedOTP.toString(),
                            responseOtp: receivedOTP.toString(),
                            title: getTranslated(context, 'SEND_OTP_TITLE'),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  print('3');
                  setSnackbar(msg!, context);
                }
              }
              // if (widget.title == getTranslated(context, 'FORGOT_PASS_TITLE')) {
              //   print('${error} ------------terter-------');
              //   if (error == false) {
              //     settingsProvider.setPrefrence(MOBILE,
              //         context.read<AuthenticationProvider>().mobilenumbervalue);
              //     settingsProvider.setPrefrence(COUNTRY_CODE, countrycode!);
              //     Future.delayed(const Duration(seconds: 1)).then(
              //       (_) {
              //         Navigator.pushReplacement(
              //           context,
              //           CupertinoPageRoute(
              //             builder: (context) => VerifyOtp(
              //               mobileNumber: context
              //                   .read<AuthenticationProvider>()
              //                   .mobilenumbervalue,
              //               countryCode: countrycode,
              //               responseOtp: receivedOTP.toString(),
              //               title: getTranslated(context, 'FORGOT_PASS_TITLE'),
              //             ),
              //           ),
              //         );
              //       },
              //     );
              //   } else {
              //     setSnackbar(
              //         getTranslated(context, 'FIRSTSIGNUP_MSG')!, context);
              //   }
              // }
            },
          ),
        );
      }
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

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    SystemChromeSettings.setSystemButtomNavigationBarithTopAndButtom();
    SystemChromeSettings.setSystemUIOverlayStyleWithNoSpecification();

    buttonController!.dispose();
    super.dispose();
  }

  setStateNoInternate() async {
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (BuildContext context) => super.widget),
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

  Widget verifyCodeTxt() {
    return Padding(
      padding: const EdgeInsets.only(top: 13.0),
      child: Text(
        getTranslated(context, 'SEND_VERIFY_CODE_LBL')!,
        style: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.4),
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        maxLines: 3,
      ),
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
      readOnly: widget.mobileFromChangePasswordScreen != null &&
          widget.mobileFromChangePasswordScreen != '' ? true : false,
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
    // return Selector<UserProvider, String>(selector: (_, provider) => provider.mob,
    //   builder: (context, userMobile, child) {
    //     mobileController.text = userMobile;
    //
    //   },
    // );
  }

  Widget verifyBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Center(
        child: AppBtn(
          title: widget.title == getTranslated(context, 'SEND_OTP_TITLE')
              ? getTranslated(context, 'SEND_OTP')
              : getTranslated(context, 'GET_PASSWORD'),
          btnAnim: buttonSqueezeanimation,
          btnCntrl: buttonController,
          onBtnSelected: () async {
            validateAndSubmit();
            // forgetPass();
          },
        ),
      ),
    );
  }

  Widget termAndPolicyTxt() {
    return widget.title == getTranslated(context, 'SEND_OTP_TITLE')
        ? SizedBox(
            height: deviceHeight! * 0.18,
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getTranslated(context, 'CONTINUE_AGREE_LBL')!,
                  style: Theme.of(context).textTheme.caption!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'ubuntu',
                      ),
                ),
                const SizedBox(
                  height: 3.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => PrivacyPolicy(
                              title: getTranslated(context, 'TERM'),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        getTranslated(context, 'TERMS_SERVICE_LBL')!,
                        style: Theme.of(context).textTheme.caption!.copyWith(
                              color: Theme.of(context).colorScheme.fontColor,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'ubuntu',
                            ),
                        overflow: TextOverflow.clip,
                        softWrap: true,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Text(
                      getTranslated(context, 'AND_LBL')!,
                      style: Theme.of(context).textTheme.caption!.copyWith(
                            color: Theme.of(context).colorScheme.fontColor,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'ubuntu',
                          ),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => PrivacyPolicy(
                              title: getTranslated(context, 'PRIVACY'),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        getTranslated(context, 'PRIVACY')!,
                        style: Theme.of(context).textTheme.caption!.copyWith(
                              color: Theme.of(context).colorScheme.fontColor,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'ubuntu',
                            ),
                        overflow: TextOverflow.clip,
                        softWrap: true,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        : const SizedBox();
  }

  @override
  void initState() {
    SystemChromeSettings.setSystemButtomNavigationBarithTopAndButtom();
    SystemChromeSettings.setSystemUIOverlayStyleWithNoSpecification();
    super.initState();
    if(widget.mobileFromChangePasswordScreen != null &&
        widget.mobileFromChangePasswordScreen != '') {
      mobileController.text = widget.mobileFromChangePasswordScreen ?? '';
    }

    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
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
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        leading: widget.mobileFromChangePasswordScreen != null &&
            widget.mobileFromChangePasswordScreen != ''
            ? InkWell(
          onTap: (){
            Navigator.pop(context);
          },
            child: const Icon(Icons.arrow_back, color: Colors.black,))  : const SizedBox(),
        backgroundColor: Colors.transparent,
        /*automaticallyImplyLeading:
            widget.mobileFromChangePasswordScreen != null &&
                    widget.mobileFromChangePasswordScreen != ''
                ? true
                : false,*/
      ),
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.white,
      bottomNavigationBar: termAndPolicyTxt(),
      body: isNetworkAvail
          ? Center(
              child: SingleChildScrollView(
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
                      signUpTxt(),
                      verifyCodeTxt(),
                      setCodeWithMono(),
                      verifyBtn(),
                    ],
                  ),
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
        child: Image.asset(
          'assets/images/png/splashlogo-removebg-preview.png',
          height: 110,
          width: 110,
        ));
  }

  Widget signUpTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 40.0,
      ),
      child: Text(
        widget.title == getTranslated(context, 'SEND_OTP_TITLE')
            ? getTranslated(context, 'SIGN_UP_LBL')!
            : getTranslated(context, 'FORGOT_PASSWORDTITILE')!,
        style: Theme.of(context).textTheme.headline6!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
              fontSize: textFontSize23,
              fontFamily: 'ubuntu',
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}
