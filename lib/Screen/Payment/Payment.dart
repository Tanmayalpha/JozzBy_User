import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../Model/Section_Model.dart';
import '../../Provider/CartProvider.dart';
import '../../Provider/paymentProvider.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/desing.dart';
import '../../widgets/security.dart';
import '../../widgets/snackbar.dart';
import 'Widget/PaymentRadio.dart';
import '../../widgets/appBar.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import 'package:http/http.dart' as http;

class Payment extends StatefulWidget {
  final Function update;
  final String? msg;

  const Payment(this.update, this.msg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StatePayment();
  }
}

bool? isPaymentSuccess = false;

class StatePayment extends State<Payment> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  int? paymentIndex;
  bool isAdvancePaymentSuccess = true;
  double? deductAmount;

  setStateNow() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // getPhonpayURL();

    context.read<PaymentProvider>().payModel.clear();
    context.read<PaymentProvider>().getdateTime(context, setStateNow);
    context.read<PaymentProvider>().timeSlotList.length = 0;
    context.read<PaymentProvider>().timeModel.clear();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    Future.delayed(
      Duration.zero,
      () {
        context.read<PaymentProvider>().paymentMethodList = [
          Platform.isIOS
              ? getTranslated(context, 'APPLEPAY')
              : getTranslated(context, 'GPAY'),
          getTranslated(context, 'COD_LBL'),
          getTranslated(context, 'PAYPAL_LBL'),
          getTranslated(context, 'PHONE_PAY'),
          // getTranslated(context, 'PHONE_PAY'),
          getTranslated(context, 'RAZORPAY_LBL'),
          getTranslated(context, 'PAYSTACK_LBL'),
          getTranslated(context, 'FLUTTERWAVE_LBL'),
          getTranslated(context, 'STRIPE_LBL'),
          getTranslated(context, 'PAYTM_LBL'),
          getTranslated(context, 'BANKTRAN'),
          getTranslated(context, 'MidTrans')!,
          getTranslated(context, 'My Fatoorah'),
        ];
      },
    );

    if (widget.msg != '') {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => setSnackbar(
          widget.msg!,
          context,
        ),
      );
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

  InAppWebViewController? _webViewController;
  String _paymentStatus = '';
  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  String? mobile;
  setStateNoInternate() async {
    _playAnimation();
    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          context.read<PaymentProvider>().getdateTime(
                context,
                setStateNow,
              );
        } else {
          await buttonController!.reverse();
          if (mounted) setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<SectionModel> tempCartListForTestCondtion =
        context.read<CartProvider>().cartList;
    return WillPopScope(
      onWillPop: () async {
        /* if(paymentIndex== 3   && (isPhonePayPaymentSuccess ?? false)){
          return true;
        }else if( paymentIndex== 3  && !(isPhonePayPaymentSuccess ?? false)){
          initiatePayment();
        }else if(razorAdvancePaySuccess== true && paymentIndex==1 ){
          return true;
        }else if(razorAdvancePaySuccess!= true && paymentIndex==1){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please pay first advance payment in case on cash on delivery')));
        }*/
        if (paymentIndex == 3 && !(isPhonePayPaymentSuccess ?? false)) {
          setSnackbar(
            'Payment Not Done',
            context,
          );
          context.read<CartProvider>().payMethod = null;
          context.read<CartProvider>().selectedMethod = null;
        }
        if (paymentIndex == 1 && !(razorAdvancePaySuccess == true)) {
          setSnackbar(
            'Advance Payment Not Done',
            context,
          );
          context.read<CartProvider>().payMethod = null;
          context.read<CartProvider>().selectedMethod = null;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: colors.whiteTemp,
        key: _scaffoldKey,
        // appBar: getSimpleAppBar(getTranslated(context, 'PAYMENT_METHOD_LBL')!, context),
        appBar: AppBar(
          title: Text(
            '${getTranslated(context, 'PAYMENT_METHOD_LBL')}',
            style: const TextStyle(
              color: colors.whiteTemp,
              fontWeight: FontWeight.normal,
              fontFamily: 'ubuntu',
            ),
          ),
          leading: Builder(
            builder: (BuildContext context) {
              return Container(
                margin: const EdgeInsets.all(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(circularBorderRadius4),
                  onTap: () {
                    /*if(paymentIndex== 3   && (isPhonePayPaymentSuccess ?? false)){
                      Navigator.of(context).pop();
                    }else if( paymentIndex== 3  && !(isPhonePayPaymentSuccess ?? false)){
                      initiatePayment();
                    }else if(razorAdvancePaySuccess== true && paymentIndex==1 ){
                      Navigator.of(context).pop();
                    }else if(razorAdvancePaySuccess!= true && paymentIndex==1){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please pay first advance payment in case on cash on delivery')));
                    }*/
                    if (paymentIndex == 3 &&
                        !(isPhonePayPaymentSuccess ?? false)) {
                      setSnackbar(
                        'Payment Not Done',
                        context,
                      );
                      context.read<CartProvider>().payMethod = null;
                      context.read<CartProvider>().selectedMethod = null;
                    }
                    if (paymentIndex == 1 &&
                        !(razorAdvancePaySuccess == true)) {
                      setSnackbar(
                        'Advance Payment Not Done',
                        context,
                      );
                      context.read<CartProvider>().payMethod = null;
                      context.read<CartProvider>().selectedMethod = null;
                    }

                    Navigator.of(context).pop();
                    //  print("paymentIndex______$paymentIndex  isPhonePayPaymentSuccess________$isPhonePayPaymentSuccess    razorAdvancePaySuccess_____ $razorAdvancePaySuccess");
                  },
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: colors.whiteTemp,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        body: isNetworkAvail
            ? context.read<PaymentProvider>().isLoading
                ? DesignConfiguration.getProgress()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Consumer<UserProvider>(
                                  builder: (context, userProvider, _) {
                                    return Card(
                                      elevation: 0,
                                      child: userProvider.curBalance != '0' &&
                                              userProvider
                                                  .curBalance.isNotEmpty &&
                                              userProvider.curBalance != ''
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: CheckboxListTile(
                                                dense: true,
                                                contentPadding:
                                                    const EdgeInsets.all(0),
                                                value: context
                                                    .read<CartProvider>()
                                                    .isUseWallet,
                                                onChanged: (bool? value) {
                                                  if (mounted) {
                                                    setState(
                                                      () {
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .isUseWallet = value;
                                                        if (value!) {
                                                          if (context
                                                                  .read<
                                                                      CartProvider>()
                                                                  .totalPrice <=
                                                              double.parse(
                                                                  userProvider
                                                                      .curBalance)) {
                                                            context
                                                                .read<
                                                                    CartProvider>()
                                                                .remWalBal = (double.parse(
                                                                    userProvider
                                                                        .curBalance) -
                                                                context
                                                                    .read<
                                                                        CartProvider>()
                                                                    .totalPrice);
                                                            context
                                                                    .read<
                                                                        CartProvider>()
                                                                    .usedBalance =
                                                                context
                                                                    .read<
                                                                        CartProvider>()
                                                                    .totalPrice;
                                                            context
                                                                    .read<
                                                                        CartProvider>()
                                                                    .payMethod =
                                                                'Wallet';

                                                            context
                                                                .read<
                                                                    CartProvider>()
                                                                .isPayLayShow = false;
                                                          } else {
                                                            context
                                                                .read<
                                                                    CartProvider>()
                                                                .remWalBal = 0;
                                                            context
                                                                    .read<
                                                                        CartProvider>()
                                                                    .usedBalance =
                                                                double.parse(
                                                                    userProvider
                                                                        .curBalance);
                                                            context
                                                                .read<
                                                                    CartProvider>()
                                                                .isPayLayShow = true;
                                                          }

                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .totalPrice = context
                                                                  .read<
                                                                      CartProvider>()
                                                                  .totalPrice -
                                                              context
                                                                  .read<
                                                                      CartProvider>()
                                                                  .usedBalance;
                                                        } else {
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .totalPrice = context
                                                                  .read<
                                                                      CartProvider>()
                                                                  .totalPrice +
                                                              context
                                                                  .read<
                                                                      CartProvider>()
                                                                  .usedBalance;
                                                          context
                                                                  .read<
                                                                      CartProvider>()
                                                                  .remWalBal =
                                                              double.parse(
                                                                  userProvider
                                                                      .curBalance);
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .payMethod = null;
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .selectedMethod = null;
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .usedBalance = 0;
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .isPayLayShow = true;
                                                        }

                                                        widget.update();
                                                      },
                                                    );
                                                  }
                                                },
                                                title: Text(
                                                  getTranslated(
                                                      context, 'USE_WALLET')!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle1,
                                                ),
                                                subtitle: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  child: Text(
                                                    context
                                                            .read<
                                                                CartProvider>()
                                                            .isUseWallet!
                                                        ? '${getTranslated(context, 'REMAIN_BAL')!} : ${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().remWalBal)}'
                                                        : '${getTranslated(context, 'TOTAL_BAL')!} : ${DesignConfiguration.getPriceFormat(context, double.parse(userProvider.curBalance))!}',
                                                    style: TextStyle(
                                                      fontSize: textFontSize15,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    );
                                  },
                                ),
                                context.read<CartProvider>().isTimeSlot!
                                    ? Card(
                                        elevation: 0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                getTranslated(
                                                    context, 'PREFERED_TIME')!,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .fontColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: textFontSize16,
                                                ),
                                              ),
                                            ),
                                            const Divider(),
                                            Container(
                                              height: 90,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: int.parse(context
                                                    .read<PaymentProvider>()
                                                    .allowDay!),
                                                itemBuilder: (context, index) {
                                                  return dateCell(index);
                                                },
                                              ),
                                            ),
                                            const Divider(),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: context
                                                  .read<PaymentProvider>()
                                                  .timeModel
                                                  .length,
                                              itemBuilder: (context, index) {
                                                return timeSlotItem(index);
                                              },
                                            )
                                          ],
                                        ),
                                      )
                                    : Container(),
                                context.read<CartProvider>().isPayLayShow! &&
                                        context
                                            .read<PaymentProvider>()
                                            .payModel
                                            .isNotEmpty
                                    ? Card(
                                        elevation: 0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                getTranslated(
                                                    context, 'SELECT_PAYMENT')!,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .fontColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: textFontSize16,
                                                ),
                                              ),
                                            ),
                                            const Divider(),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: context
                                                  .read<PaymentProvider>()
                                                  .paymentMethodList
                                                  .length,
                                              itemBuilder: (context, index) {
                                                if (index == 1 &&
                                                    context
                                                        .read<PaymentProvider>()
                                                        .cod &&
                                                    tempCartListForTestCondtion[
                                                                0]
                                                            .productType !=
                                                        'digital_product') {
                                                  return paymentItem(index);
                                                } else if (index == 2 &&
                                                    context
                                                        .read<PaymentProvider>()
                                                        .paypal) {
                                                  return paymentItem(index);
                                                } else if (index == 3 &&
                                                    context
                                                        .read<PaymentProvider>()
                                                        .phonepay) {
                                                  return paymentItem(index);
                                                }
                                                // else if (index == 3 &&
                                                //     context
                                                //         .read<PaymentProvider>()
                                                //         .paumoney) {
                                                //   return paymentItem(index);
                                                //
                                                // }
                                                else if (index == 4 &&
                                                    context
                                                        .read<PaymentProvider>()
                                                        .razorpay) {
                                                  return paymentItem(index);
                                                } else if (index == 5 &&
                                                    context
                                                        .read<PaymentProvider>()
                                                        .paystack) {
                                                  return paymentItem(index);
                                                } else if (index == 6 &&
                                                    context
                                                        .read<PaymentProvider>()
                                                        .flutterwave) {
                                                  return paymentItem(index);
                                                } else if (index == 7 &&
                                                    context
                                                        .read<PaymentProvider>()
                                                        .stripe) {
                                                  return paymentItem(index);
                                                } else if (index == 8 &&
                                                    context
                                                        .read<PaymentProvider>()
                                                        .paytm) {
                                                  return paymentItem(index);
                                                } else if (index == 0 &&
                                                    context
                                                        .read<PaymentProvider>()
                                                        .gpay) {
                                                  return paymentItem(index);
                                                } else if (index == 9 &&
                                                    context
                                                        .read<PaymentProvider>()
                                                        .bankTransfer) {
                                                  return paymentItem(index);
                                                } else if (index == 10 &&
                                                    context
                                                        .read<PaymentProvider>()
                                                        .midtrans) {
                                                  return paymentItem(index);
                                                } else if (index == 11 &&
                                                    context
                                                        .read<PaymentProvider>()
                                                        .myfatoorah) {
                                                  return paymentItem(index);
                                                } else {
                                                  return Container();
                                                }
                                              },
                                            ),
                                            paymentIndex == 1
                                                ? Align(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: Card(
                                                      elevation: 0,
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                              '*Pay $ADVANCE_PERCENT% Advance amount of Order amount'),
                                                          razorAdvancePaySuccess == true
                                                              ? SizedBox()
                                                              : ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    print(
                                                                        '_____sddssssds______${context.read<CartProvider>().totalPrice}__________');
                                                                    double percent = double.parse(ADVANCE_PERCENT ?? '0.0');
                                                                    deductAmount = context.read<CartProvider>().totalPrice * percent / 100;
                                                                    // openCheckout();
                                                                    initiatePayment();
                                                                    setState(
                                                                        () {}
                                                                    );
                                                                  },
                                                                  child: Text(
                                                                      'Pay ${deductAmount ?? ''}'),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(),
                                            // paymentIndex ==1 ?
                                            // InkWell(
                                            //   onTap: initiatePayment,
                                            //     child: const Text('PhonePay')) : SizedBox(),
                                          ],
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                        ),
                        SimBtn(
                            borderRadius: circularBorderRadius5,
                            size: 0.8,
                            title: getTranslated(context, 'DONE'),
                            //                     onBtnSelected: /*paymentIndex==1 && isAdvancePaymentSuccess ? (){
                            //                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pay advance amount first')));
                            //                     } :*/
                            //
                            //                     paymentIndex== 3   && (isPhonePayPaymentSuccess ?? false) ? (){
                            //                                      Routes.pop(context);
                            //                                  }:
                            //                     razorAdvancePaySuccess== true && paymentIndex==1 ? (){Routes.pop(context);}
                            // :  paymentIndex== 3  && !(isPhonePayPaymentSuccess ?? false) ? initiatePayment : (){
                            //                       Routes.pop(context);
                            //                     }

                            ///------------
                            onBtnSelected: () {
                              if (context.read<CartProvider>().isUseWallet ==
                                  true) {
                                Navigator.pop(context, true);
                                // print("sdffffffsfsfsf");
                              } else if (paymentIndex == 3 &&
                                  (isPhonePayPaymentSuccess ?? false)) {
                                Routes.pop(context);
                              } else if (paymentIndex == 3 &&
                                  !(isPhonePayPaymentSuccess ?? false)) {
                                initiatePayment();
                              } else if (razorAdvancePaySuccess == true &&
                                  paymentIndex == 1) {
                                Routes.pop(context);
                              } else if (razorAdvancePaySuccess != true &&
                                  paymentIndex == 1) {
                                print(
                                    '___________${razorAdvancePaySuccess}__________');
                                setSnackbar(
                                    'Please pay first advance payment in case on cash on delivery',
                                    context);
                              }

                              //    fsfsf
                            }),
                      ],
                    ),
                  )
            : NoInterNet(
                setStateNoInternate: setStateNoInternate,
                buttonSqueezeanimation: buttonSqueezeanimation,
                buttonController: buttonController,
              ),
      ),
    );
  }

  bool? isPhonePayPaymentSuccess;
  String url = '';

  void initiatePayment() {
    // Replace this with the actual PhonePe payment URL you have
    String phonePePaymentUrl = url;
    callBackUrl = 'https://admin.jozzbybazar.com/home/phonepay_success';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('PhonePe Payment'),
          ),
          body: InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse(phonePePaymentUrl)),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: ((controller, url) {}),
            onLoadStop: (controller, url) async {
              if (url.toString().contains(callBackUrl!)) {
                print('========url herrre=======$url===========');
                // Extract payment status from URL
                /// String? paymentStatus = extractPaymentStatusFromUrl(url.toString());
                ///
                _handlePaymentStatus(url.toString());
                await _webViewController?.stopLoading();
                if (await _webViewController?.canGoBack() ?? false) {
                  await _webViewController?.goBack();
                } else {
                  Navigator.pop(context);
                }
                // Update payment status
                /*setState(() {
                  _paymentStatus = paymentStatus!;
                });*/
                // Stop loading and close WebView
              }
            },
          ),
        ),
      ),
    );
  }

  void _handlePaymentStatus(String url) async {
    Map<String, dynamic> responseData = await fetchDataFromUrl();
    String isError = responseData['data'][0]['error'];
    if (isError == 'true') {
      // Payment success
      _paymentStatus = 'Payment Failure';
      isPhonePayPaymentSuccess = false;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Payment Failure')));
    } else {
      isAdvancePaymentSuccess = false;
      context.read<CartProvider>().totalPrice =
          context.read<CartProvider>().totalPrice - deductAmount!;
      context.read<CartProvider>().deductAmount = deductAmount ?? 0.0;
      setState(() {});
      // Payment failure
      _paymentStatus = 'Payment Success';
      isPhonePayPaymentSuccess = true;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Success')));
    }
    print('___________${_paymentStatus}____vssdfff______');
    setState(() {});
  }

  String? callBackUrl;
  String? merchantId;
  String? merchantTransactionId;

  Future<Map<String, dynamic>> fetchDataFromUrl() async {
    final response = await http.post(
        Uri.parse("${baseUrl}/check_phonepay_status"),
        body: {"transaction_id": merchantTransactionId},
        headers: headers);
    if (response.statusCode == 200) {
      // If the request is successful, parse the JSON response and return it
      return json.decode(response.body);
    } else {
      // If the request fails, throw an exception or handle the error accordingly
      throw Exception('Failed to load data from the URL');
    }
  }

  getPhonpayURL({int? i}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    mobile = preferences.getString('mobile');
    var request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/initiate_phone_payment'));
    request.fields.addAll({
      'user_id': CUR_USERID.toString(),
      'mobile': mobile.toString(),
      'amount': i != null
          ? '$deductAmount'
          : '${context.read<CartProvider>().totalPrice}'
    });
    print('_______request.fields____${request.fields}__________');
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var finalResult = jsonDecode(result);
      url = finalResult['data']['data']['instrumentResponse']['redirectInfo']
          ['url'];
      merchantId = finalResult['data']['data']['merchantId'];
      merchantTransactionId =
          finalResult['data']['data']['merchantTransactionId'];
      //  print('_____merchantTransactionId______${merchantTransactionId}_____${merchantId}_____');
      //print("aaaaaaaaaaaaaaaaaaaaaa${url}");
    } else {
      print(response.reasonPhrase);
    }
  }

//   Future<void> getPhonpayURL () async{
// SharedPreferences preferences = await SharedPreferences.getInstance();
// mobile = preferences.getString("mobile");
//     var parameter = {
//       'user_id': CUR_USERID,
//       'mobile': "${mobile}",
//       'amount':"2"
//       // context.read<CartProvider>().totalPrice
//     };
//     print('____hhhhhhhhhhh_______${parameter}__________');
//     apiBaseHelper.postAPICall(phonePayPaymentIntiat, parameter).then((value) {
//       print('___________${value['error']}__________');
//       url = value['data']['data']['instrumentResponse']['redirectInfo']['url'];
//       merchantId = value['data']['data']['merchantId'];
//       merchantTransactionId = value['data']['data']['merchantTransactionId'];
//
//       print('_____merchantTransactionId______${merchantTransactionId}_____${merchantId}_____');
//       print("aaaaaaaaaaaaaaaaaaaaaa${url}");
//
//     });
//
//   }

  dateCell(int index) {
    DateTime today =
        DateTime.parse(context.read<PaymentProvider>().startingDate!);
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(circularBorderRadius10),
          gradient: context.read<CartProvider>().selectedDate == index
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.grad1Color, colors.grad2Color],
                  stops: [0, 1],
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('EEE').format(
                today.add(
                  Duration(
                    days: index,
                  ),
                ),
              ),
              style: TextStyle(
                color: context.read<CartProvider>().selectedDate == index
                    ? Theme.of(context).colorScheme.white
                    : Theme.of(context).colorScheme.lightBlack2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                DateFormat('dd').format(
                  today.add(
                    Duration(days: index),
                  ),
                ),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.read<CartProvider>().selectedDate == index
                      ? Theme.of(context).colorScheme.white
                      : Theme.of(context).colorScheme.lightBlack2,
                ),
              ),
            ),
            Text(
              DateFormat('MMM').format(
                today.add(
                  Duration(
                    days: index,
                  ),
                ),
              ),
              style: TextStyle(
                color: context.read<CartProvider>().selectedDate == index
                    ? Theme.of(context).colorScheme.white
                    : Theme.of(context).colorScheme.lightBlack2,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        DateTime date = today.add(Duration(days: index));

        if (mounted) context.read<CartProvider>().selectedDate = index;
        context.read<CartProvider>().selectedTime = null;
        context.read<CartProvider>().selTime = null;
        context.read<CartProvider>().selDate =
            DateFormat('yyyy-MM-dd').format(date);
        context.read<PaymentProvider>().timeModel.clear();
        DateTime cur = DateTime.now();
        DateTime tdDate = DateTime(cur.year, cur.month, cur.day);
        if (date == tdDate) {
          if (context.read<PaymentProvider>().timeSlotList.isNotEmpty) {
            for (int i = 0;
                i < context.read<PaymentProvider>().timeSlotList.length;
                i++) {
              DateTime cur = DateTime.now();
              String time =
                  context.read<PaymentProvider>().timeSlotList[i].lastTime!;
              DateTime last = DateTime(
                cur.year,
                cur.month,
                cur.day,
                int.parse(time.split(':')[0]),
                int.parse(time.split(':')[1]),
                int.parse(time.split(':')[2]),
              );

              if (cur.isBefore(last)) {
                context.read<PaymentProvider>().timeModel.add(
                      RadioModel(
                        isSelected:
                            i == context.read<CartProvider>().selectedTime
                                ? true
                                : false,
                        name: context
                            .read<PaymentProvider>()
                            .timeSlotList[i]
                            .name,
                        img: '',
                      ),
                    );
              }
            }
          }
        } else {
          if (context.read<PaymentProvider>().timeSlotList.isNotEmpty) {
            for (int i = 0;
                i < context.read<PaymentProvider>().timeSlotList.length;
                i++) {
              context.read<PaymentProvider>().timeModel.add(
                    RadioModel(
                      isSelected: i == context.read<CartProvider>().selectedTime
                          ? true
                          : false,
                      name:
                          context.read<PaymentProvider>().timeSlotList[i].name,
                      img: '',
                    ),
                  );
            }
          }
        }
        setState(() {});
      },
    );
  }

  Widget timeSlotItem(int index) {
    return InkWell(
      onTap: () {
        if (mounted) {
          setState(
            () {
              context.read<CartProvider>().selectedTime = index;
              context.read<CartProvider>().selTime = context
                  .read<PaymentProvider>()
                  .timeModel[context.read<CartProvider>().selectedTime!]
                  .name;
              for (var element in context.read<PaymentProvider>().timeModel) {
                element.isSelected = false;
              }
              context.read<PaymentProvider>().timeModel[index].isSelected =
                  true;
            },
          );
        }
      },
      child: RadioItem(context.read<PaymentProvider>().timeModel[index]),
    );
  }

  Widget paymentItem(int index) {
    return InkWell(
      onTap: () {
        if (mounted) {
          setState(
            () {
              context.read<CartProvider>().selectedMethod = index;
              context.read<CartProvider>().payMethod =
                  context.read<PaymentProvider>().paymentMethodList[
                      context.read<CartProvider>().selectedMethod!];
              for (var element in context.read<PaymentProvider>().payModel) {
                element.isSelected = false;
              }
              context.read<PaymentProvider>().payModel[index].isSelected = true;
              if (index == 1) {
                paymentIndex = index;
                getPhonpayURL(i: index);
              }
              if (index == 3) {
                paymentIndex = index;
                getPhonpayURL();
              }
            },
          );
        }
      },
      child: Column(
        children: [
          RadioItem(
            context.read<PaymentProvider>().payModel[index],
          ),
          if (index == 3 &&
              (context.read<PaymentProvider>().payModel[index].isSelected ??
                  false))
            InkWell(
              onTap: () {
                bool userIsAvailable = true;
                if (userIsAvailable) {
                  if (int.parse(availableCredit ?? '0') <
                      context.read<CartProvider>().totalPrice) {
                    context.read<CartProvider>().totalPrice =
                        context.read<CartProvider>().totalPrice -
                            int.parse(availableCredit ?? '0');
                    initiatePayment();
                    //openCheckout(amount: context.read<CartProvider>().totalPrice);
                  }
                }
              },
              child: const Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    '*Pay in advance',
                    style: TextStyle(decoration: TextDecoration.underline),
                  )),
            )
          else
            const SizedBox(),
          Text(availableCredit ?? '')
        ],
      ),
    );
  }

  late Razorpay _razorpay;
  String? availableCredit;

  void openCheckout({double? amount}) async {
    print('___________ddddddddd__________');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? phone = prefs.getString('phone');
    int amt = deductAmount?.toInt() ?? 0;
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
      'amount': amount?.toInt() ?? amt * 100,
      'name': 'Jozz by Bazar',
      'description': 'Jozz by Bazar',
      "currency": "INR",
      'prefill': {'contact': '$phone', 'email': '$email'},
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  bool razorAdvancePaySuccess = false;

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // RazorpayDetailApi();
    // Order_cash_ondelivery();
    /* advancePayment( widget.data.quotation!.id
        .toString(),
        widget.data.quotation!
            .assignmentId
            .toString(),
        response.paymentId);*/
    print("++++++++++++++++++++++++++++++++++++++");
    isAdvancePaymentSuccess = false;
    razorAdvancePaySuccess = true;
    context.read<CartProvider>().totalPrice =
        context.read<CartProvider>().totalPrice - deductAmount!;
    context.read<CartProvider>().deductAmount = deductAmount!;

    //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Success')));
    setState(() {});
    Navigator.pop(context, true);
    // Navigator.pop(context);
    // Routes.pop(context);
    // Navigator.push(context, MaterialPageRoute(builder: (context)=>DashBoardScreen()));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Fluttertoast.showToast(
    //     msg: "ERROR: " + response.code.toString() + " - " + response.message!,
    //     toastLength: Toast.LENGTH_SHORT);
    print('${response.error}________error_________');
    print('${response.code}________code_________');
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment cancelled by user')));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('EXTERNAL_WALLET: ${response.walletName!}')));
  }
}
