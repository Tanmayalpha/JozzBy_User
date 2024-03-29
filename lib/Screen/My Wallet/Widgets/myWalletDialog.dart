import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Screen/Payment/Widget/PaymentRadio.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Provider/myWalletProvider.dart';
import 'package:eshop_multivendor/Provider/paymentProvider.dart';
import 'package:eshop_multivendor/Provider/systemProvider.dart';
import 'package:eshop_multivendor/Provider/userWalletProvider.dart';
import 'package:eshop_multivendor/Screen/WebView/PaypalWebviewActivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:my_fatoorah/my_fatoorah.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Helper/String.dart';
import '../../../Helper/routes.dart';
import '../../../Provider/CartProvider.dart';
import '../../../widgets/desing.dart';
import '../../../widgets/security.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/snackbar.dart';
import '../../../widgets/validation.dart';
import '../../WebView/midtransWebView.dart';
import 'package:http/http.dart'as http;

import '../My_Wallet.dart';

class MyWalletDialog {
  static showWithdrawAmountDialog(BuildContext context) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController? bankDetailsController = TextEditingController();
    TextEditingController? amountTextController = TextEditingController();
    await DesignConfiguration.dialogAnimate(
      context,
      AlertDialog(
        contentPadding: const EdgeInsets.all(0.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              circularBorderRadius5,
            ),
          ),
        ),
        content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20.0,
                  20.0,
                  0,
                  2.0,
                ),
                child: Text(
                  getTranslated(context, 'Send Withrawal Request')!,
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontFamily: 'ubuntu',
                      ),
                ),
              ),
              Divider(
                color: Theme.of(context).colorScheme.lightBlack,
              ),
              Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        validator: (val) => StringValidation.validateField(
                            val!, getTranslated(context, 'FIELD_REQUIRED')),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          hintText: getTranslated(context, 'Withdrwal Amount')!,
                          hintStyle: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                color: Theme.of(context).colorScheme.lightBlack,
                                fontWeight: FontWeight.normal,
                              ),
                        ),
                        controller: amountTextController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20.0,
                        0,
                        20.0,
                        0,
                      ),
                      child: TextFormField(
                        validator: (val) => StringValidation.validateField(
                            val!, getTranslated(context, 'FIELD_REQUIRED')),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          hintText: bankDetail,
                          hintStyle: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                color: Theme.of(context).colorScheme.lightBlack,
                                fontWeight: FontWeight.normal,
                              ),
                        ),
                        controller: bankDetailsController,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              getTranslated(context, 'CANCEL')!,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    color: Theme.of(context).colorScheme.lightBlack,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ubuntu',
                  ),
            ),
            onPressed: () {
              Navigator.pop(
                context,
                {
                  'error': true,
                  'status': false,
                  'message': '',
                },
              );
            },
          ),
          TextButton(
            child: Text(
              getTranslated(context, 'SEND')!,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ubuntu',
                  ),
            ),
            onPressed: () async {
              final form = formKey.currentState!;
              if (form.validate()) {
                form.save();

                await context
                    .read<UserTransactionProvider>()
                    .sendAmountWithdrawRequest(
                        userID: CUR_USERID!,
                        withdrawalAmount: amountTextController.text.toString(),
                        bankDetails: bankDetailsController.text.toString())
                    .then(
                  (result) async {
                    showOverlay(result['message'], context);
                    if (result['newBalance'] != '') {
                      context
                          .read<UserProvider>()
                          .setBalance((result['newBalance']).toString());

                    }
                  },
                );
                Future.delayed(
                  const Duration(
                    seconds: 2,
                  ),
                  () {
                    Routes.pop(context);
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  static showFilterDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ButtonBarTheme(
          data: const ButtonBarThemeData(
            alignment: MainAxisAlignment.center,
          ),
          child: AlertDialog(
            elevation: 2.0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(circularBorderRadius5),
              ),
            ),
            contentPadding: const EdgeInsets.all(0.0),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        top: 19.0, bottom: 16.0),
                    child: Text(
                      getTranslated(context, 'FILTER_BY')!,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                            color: Theme.of(context).colorScheme.fontColor,
                            fontFamily: 'ubuntu',
                          ),
                    ),
                  ),
                  Divider(color: Theme.of(context).colorScheme.lightBlack),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MyWalletDialog.getFilterDialogValues(
                            getTranslated(context, 'Transaction History')!,
                            1,
                            context,
                          ),
                          Divider(
                              color: Theme.of(context).colorScheme.lightBlack),
                          MyWalletDialog.getFilterDialogValues(
                            getTranslated(context, 'Wallet History')!,
                            2,
                            context,
                          ),
                          Divider(
                              color: Theme.of(context).colorScheme.lightBlack),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static getFilterDialogValues(String title, int index, BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: TextButton(
        child: Text(
          title,
          style: Theme.of(context).textTheme.subtitle1!.copyWith(
                color: Theme.of(context).colorScheme.lightBlack,
                fontFamily: 'ubuntu',
              ),
        ),
        onPressed: () async {
          Routes.pop(context);
          if (index == 1) {
            context
                .read<MyWalletProvider>()
                .setCurrentSelectedFilterIsTransaction = true;
          } else {
            context
                .read<MyWalletProvider>()
                .setCurrentSelectedFilterIsTransaction = false;
            await context
                .read<MyWalletProvider>()
                .fetchUserWalletAmountWithdrawalRequestTransactions(
                    walletTransactionIsLoadingMore: false, context: context);
          }
        },
      ),
    );
  }

  static Future<Map<String, dynamic>> showAddMoneyDialog(
      BuildContext context) async {
    var response = await showDialog(
      context: context,
      builder: (context) {
        return AddMoneyDialog();
      },
    );
    return response;
  }
}

class AddMoneyDialog extends StatefulWidget {
  AddMoneyDialog({Key? key}) : super(key: key);

  @override
  State<AddMoneyDialog> createState() => _AddMoneyDialogState();
}

class _AddMoneyDialogState extends State<AddMoneyDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController? messageTextController = TextEditingController();

  final TextEditingController amountTextController = TextEditingController();

  bool payWarn = false;
  SystemProvider? systemProvider;
  late Razorpay _razorpay;

  addwalletPayment() async{
   
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}wallet_post'));
    request.fields.addAll({
      'user_id':CUR_USERID ?? '1',
      'amount':amountTextController.text
    });

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    print('___________${ request.fields}__________');
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      Navigator.pop(context);
     // await updateUserWalletAmount();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyWallet()));
    }
    else {
    print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero).then(
      (value) {
        systemProvider = Provider.of<SystemProvider>(context, listen: false);
      },
    );

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    updateUserWalletAmount();


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(
            circularBorderRadius5,
          ),
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20.0,
              20.0,
              0,
              2.0,
            ),
            child: Text(
              getTranslated(context, 'ADD_MONEY')!,
              style: Theme.of(context).textTheme.subtitle1!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontFamily: 'ubuntu',
                  ),
            ),
          ),
          Divider(color: Theme.of(context).colorScheme.lightBlack),
          Form(
            key: formKey,
            child: Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        validator: (val) => StringValidation.validateField(
                            val!, getTranslated(context, 'FIELD_REQUIRED')),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                        decoration: InputDecoration(
                          hintText: getTranslated(context, 'AMOUNT'),
                          hintStyle: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                color: Theme.of(context).colorScheme.lightBlack,
                                fontWeight: FontWeight.normal,
                              ),
                        ),
                        controller: amountTextController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                        decoration: InputDecoration(
                          hintText: getTranslated(context, 'MSG'),
                          hintStyle: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                color: Theme.of(context).colorScheme.lightBlack,
                                fontWeight: FontWeight.normal,
                              ),
                        ),
                        controller: messageTextController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 10, 20.0, 5),
                      child: Text(
                        'Payment Method:   PhonePe'/*getTranslated(context, 'SELECT_PAYMENT')!*/,
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                              fontFamily: 'ubuntu',
                            ),
                      ),
                    ),
                    const Divider(),
                    payWarn
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              getTranslated(context, 'payWarning')!,
                              style:
                                  Theme.of(context).textTheme.caption!.copyWith(
                                        color: Colors.red,
                                        fontFamily: 'ubuntu',
                                      ),
                            ),
                          )
                        : Container(),
                         context.read<SystemProvider>().isPaypalEnable == null
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: getPaymentMethodList(
                              context,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            getTranslated(context, 'CANCEL')!,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: Theme.of(context).colorScheme.lightBlack,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ubuntu',
                ),
          ),
          onPressed: () {
            Routes.pop(context);
          },
        ),
        TextButton(
          child: Text(
            getTranslated(context, 'SEND')!,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ubuntu',
                ),
          ),
          onPressed: () async {
            //systemProvider!.selectedPaymentMethodName = getTranslated(context, 'RAZORPAY_LBL')!.trim() ;
            final form = formKey.currentState!;
            if (form.validate() && amountTextController.text != '0') {
              form.save();
              getPhonpayURL();
              // openCheckout(amount: double.parse(amountTextController.text));
              //doPaymentWithRazorpay(price: int.parse(amountTextController!.text));
              /*if (systemProvider!.selectedPaymentMethodName == null) {
                setState(() {
                  payWarn = true;
                });
              } else {
                if (systemProvider!.selectedPaymentMethodName!.trim() ==
                    getTranslated(context, 'STRIPE_LBL')!.trim()) {
                  // var response = await doPaymentWithStripe(
                  //     price: amountTextController!.text,
                  //     currencyCode:
                  //         context.read<SystemProvider>().stripeCurrencyCode!,
                  //     paymentFor: 'wallet');
                  // Navigator.pop(context, response);
                  await updateUserWalletAmount();
                } else if (systemProvider!.selectedPaymentMethodName!.trim() ==
                    getTranslated(context, 'RAZORPAY_LBL')!.trim()) {
                  var response = await doPaymentWithRazorpay(
                      price: int.parse(amountTextController!.text));
                  await updateUserWalletAmount();
                  Navigator.pop(context, response);
                } else if (systemProvider!.selectedPaymentMethodName!.trim() ==
                    getTranslated(context, 'PAYSTACK_LBL')!.trim()) {
                  var response = await doPaymentWithPayStack(
                      price: int.parse(amountTextController!.text));
                  Navigator.pop(context, response);
                  await updateUserWalletAmount();
                } else if (systemProvider!.selectedPaymentMethodName ==
                    getTranslated(context, 'PAYTM_LBL')) {
                  var response = await doPaymentWithPaytm(
                      price: double.parse(amountTextController!.text));
                  Navigator.pop(context, response);
                  await updateUserWalletAmount();
                } else if (systemProvider!.selectedPaymentMethodName ==
                    getTranslated(context, 'PAYPAL_LBL')) {
                  var response = await doPaymentWithPaypal(
                      price: amountTextController!.text);
                  Navigator.pop(context, response);
                  await updateUserWalletAmount();
                } else if (systemProvider!.selectedPaymentMethodName ==
                    getTranslated(context, 'FLUTTERWAVE_LBL')) {
                  var response = await doPaymentWithFlutterWave(
                      price: amountTextController!.text);
                  Navigator.pop(context, response);
                  await updateUserWalletAmount();
                } else if (systemProvider!.selectedPaymentMethodName ==
                    getTranslated(context, 'MidTrans')) {
                  var response = await doPaymentWithMidTrash(
                      price: amountTextController!.text);
                } else if (systemProvider!.selectedPaymentMethodName ==
                    'My Fatoorah') {
                  var response =
                      await doMyFatoorah(price: amountTextController!.text);
                  await updateUserWalletAmount();
                  Navigator.pop(context, response);
                }*/
              }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  List<Widget> getPaymentMethodList(BuildContext context) {
    return context
        .read<SystemProvider>()
        .paymentMethodList
        .asMap()
        .map(
          (index, element) => MapEntry(index, paymentItem(index, context)),
        )
        .values
        .toList();
  }

  Widget paymentItem(int index, BuildContext context) {
    if (systemProvider == null) {
      systemProvider = Provider.of<SystemProvider>(context, listen: false);
    }
    if (index == 0 && systemProvider!.isPaypalEnable! ||
        index == 1 && systemProvider!.isRazorpayEnable! ||
        index == 2 && systemProvider!.isPayStackEnable! ||
        index == 3 && systemProvider!.isFlutterWaveEnable! ||
        index == 4 && systemProvider!.isStripeEnable! ||
        index == 5 && systemProvider!.isPaytmEnable! ||
        index == 6 && systemProvider!.isMidtrashEnable! ||
        index == 7 && systemProvider!.isMyFatoorahEnable!) {
      return InkWell(
        onTap: () {
          systemProvider!.selectedPaymentMethodIndex = index;
          systemProvider!.selectedPaymentMethodName = systemProvider!
              .paymentMethodList[systemProvider!.selectedPaymentMethodIndex];
          for (var element in systemProvider!.payModel) {
            element.isSelected = false;
          }
          systemProvider!.payModel[index].isSelected = true;
          setState(() {});
        },
        child: RadioItem(systemProvider!.payModel[index]),
      );
    } else {
      return Container();
    }
  }

  Future<Map<String, dynamic>> doPaymentWithPaytm(
      {required double price}) async {
    context.read<MyWalletProvider>().isLoading = true;
    try {
      String orderID = DateTime.now().millisecondsSinceEpoch.toString();

      String paytmCallBackURL = context
                  .read<SystemProvider>()
                  .isPaytmOnTestMode ??
              true
          ? 'https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderID'
          : 'https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderID';

      var response = await context.read<PaymentProvider>().payWithPaytm(
            userID: USER_ID,
            orderID: orderID,
            paymentAmount: price.toString(),
            paytmCallBackURL: paytmCallBackURL,
            paytmMerchantID: context.read<SystemProvider>().paytmMerchantID!,
            isTestingModeEnable:
                context.read<SystemProvider>().isPaytmOnTestMode ?? true,
          );

      return response;
    } catch (e) {
      return {
        'error': true,
        'message': e.toString(),
        'status': false,
      };
    }
  }

  // Future<Map<String, dynamic>> doPaymentWithStripe({
  //   required String price,
  //   required String currencyCode,
  //   required String paymentFor,
  // }) async {
  //   try {
  //
  //     var response = await context.read<PaymentProvider>().payWithStripe(
  //         paymentAmount: price.toString(),
  //         currencyCode: currencyCode,
  //         paymentFor: paymentFor);
  //
  //     return response;
  //   } catch (e) {
  //     return {
  //       'error': true,
  //       'message': e.toString(),
  //       'status': false,
  //     };
  //   }
  // }

  Future<Map<String, dynamic>> doMyFatoorah({
    required String price,
  }) async {
    try {
      String tranId = '';
      String orderID =
          'wallet-refill-user-$CUR_USERID-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}';
      String amount = price;
      String successUrl =
          '${systemProvider!.myfatoorahSuccessUrl!}?txn_id=$tranId&order_id=$orderID&amount=$price';
      String errorUrl =
          '${systemProvider!.myfatoorahErrorUrl!}?txn_id=$tranId&order_id=$orderID&amount=$price';
      String token = systemProvider!.myfatoorahToken!;
      try {
        var response = await MyFatoorah.startPayment(
          context: context,
          successChild: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 200,
              height: 200,
              child: const Icon(
                Icons.done,
                size: 100,
                color: Colors.green,
              ),
            ),
          ),
          request: systemProvider!.myfatoorahPaymentMode == 'test'
              ? MyfatoorahRequest.test(
                  userDefinedField: orderID,
                  currencyIso: () {
                    if (systemProvider!.myfatoorahCosuntry == 'Kuwait') {
                      return Country.Kuwait;
                    } else if (systemProvider!.myfatoorahCosuntry == 'UAE') {
                      return Country.UAE;
                    } else if (systemProvider!.myfatoorahCosuntry == 'Egypt') {
                      return Country.Egypt;
                    } else if (systemProvider!.myfatoorahCosuntry ==
                        'Bahrain') {
                      return Country.Bahrain;
                    } else if (systemProvider!.myfatoorahCosuntry == 'Jordan') {
                      return Country.Jordan;
                    } else if (systemProvider!.myfatoorahCosuntry == 'Oman') {
                      return Country.Oman;
                    } else if (systemProvider!.myfatoorahCosuntry ==
                        'SaudiArabia') {
                      return Country.SaudiArabia;
                    } else if (systemProvider!.myfatoorahCosuntry ==
                        'SaudiArabia') {
                      return Country.Qatar;
                    }
                    return Country.SaudiArabia;
                  }(),
                  successUrl: successUrl,
                  errorUrl: errorUrl,
                  invoiceAmount: double.parse(amount),
                  language: () {
                    if (systemProvider!.myfatoorahLanguage == 'english') {
                      return ApiLanguage.English;
                    }
                    return ApiLanguage.Arabic;
                  }(),
                  token: token,
                )
              : MyfatoorahRequest.live(
                  userDefinedField: orderID,
                  currencyIso: () {
                    if (systemProvider!.myfatoorahCosuntry == 'Kuwait') {
                      return Country.Kuwait;
                    } else if (systemProvider!.myfatoorahCosuntry == 'UAE') {
                      return Country.UAE;
                    } else if (systemProvider!.myfatoorahCosuntry == 'Egypt') {
                      return Country.Egypt;
                    } else if (systemProvider!.myfatoorahCosuntry ==
                        'Bahrain') {
                      return Country.Bahrain;
                    } else if (systemProvider!.myfatoorahCosuntry == 'Jordan') {
                      return Country.Jordan;
                    } else if (systemProvider!.myfatoorahCosuntry == 'Oman') {
                      return Country.Oman;
                    } else if (systemProvider!.myfatoorahCosuntry ==
                        'SaudiArabia') {
                      return Country.SaudiArabia;
                    } else if (systemProvider!.myfatoorahCosuntry ==
                        'SaudiArabia') {
                      return Country.Qatar;
                    }
                    return Country.SaudiArabia;
                  }(),
                  successUrl: successUrl,
                  errorUrl: errorUrl,
                  invoiceAmount: double.parse(amount),
                  language: () {
                    if (systemProvider!.myfatoorahLanguage == 'english') {
                      return ApiLanguage.English;
                    }
                    return ApiLanguage.Arabic;
                  }(),
                  token: token,
                ),
        );
        if (response.status.toString() == 'PaymentStatus.Success') {
          return {
            'error': false,
            'message': 'Transaction Successful',
            'status': true
          };
        }
        if (response.status.toString() == 'PaymentStatus.Error') {
          return {'error': true, 'message': e.toString(), 'status': false};
        }
        if (response.status.toString() == 'PaymentStatus.None') {
          return {'error': true, 'message': e.toString(), 'status': false};
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
      return {
        'error': false,
        'message': 'Transaction Successful',
        'status': true
      };
    } catch (e) {
      return {'error': true, 'message': e.toString(), 'status': false};
    }
  }

  Future<Map<String, dynamic>> doPaymentWithMidTrash({
    required String price,
  }) async {
    try {
      String orderID =
          'wallet-refill-user-$CUR_USERID-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}';
//
      try {
        var parameter = {
          AMOUNT: price,
          USER_ID: CUR_USERID,
          ORDER_ID: orderID,
        };
        apiBaseHelper.postAPICall(createMidtransTransactionApi, parameter).then(
          (getdata) {
            bool error = getdata['error'];
            String? msg = getdata['message'];
            if (!error) {
              var data = getdata['data'];
              String token = data['token'];
              String redirectUrl = data['redirect_url'];
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (BuildContext context) => MidTrashWebview(
                    url: redirectUrl,
                    from: 'order',
                    orderId: orderID,
                  ),
                ),
              ).then(
                (value) async {
                  String msg =
                      await context.read<PaymentProvider>().midtransWebhook(
                            orderID,
                          );
                  if (msg ==
                      'Order id is not matched with transaction order id.') {
                    msg = 'Transaction Failed...!';
                  }
                  String currentBalance = await context
                      .read<PaymentProvider>()
                      .getUserCurrentBalance();
                  if (currentBalance != '') {
                    Provider.of<UserProvider>(context, listen: false)
                        .setBalance(currentBalance);
                  }
                  setSnackbar(msg, context);
                  Navigator.pop(context, value);
                },
              );
            } else {
              setSnackbar(msg!, context);
            }
          },
          onError: (error) {
            setSnackbar(error.toString(), context);
          },
        );
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
      return {
        'error': false,
        'message': 'Transaction Successful',
        'status': true
      };
    } catch (e) {
      return {'error': true, 'message': e.toString(), 'status': false};
    }
  }

  Future<Map<String, dynamic>> doPaymentWithPaypal({
    required String price,
  }) async {
    try {
      String orderID =
          'wallet-refill-user-$CUR_USERID-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}';

      var paypalLink = await context
          .read<PaymentProvider>()
          .getPaypalGatewayLink(
              userID: CUR_USERID.toString(),
              orderID: orderID,
              paymentAmount: price);

      if (paypalLink != '') {
        var response = await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (BuildContext context) => PaypalWebview(
              url: paypalLink,
              from: 'wallet',
            ),
          ),
        );

        if (response == 'true') {
          return {
            'error': true,
            'message': '',
            'status': false,
          };
        }
      }
      return {
        'error': false,
        'message': 'Transaction Successful',
        'status': true
      };
    } catch (e) {
      return {
        'error': true,
        'message': e.toString(),
        'status': false,
      };
    }
  }

  Future<Map<String, dynamic>> doPaymentWithFlutterWave({
    required String price,
  }) async {
    try {
      var flutterWaveLink =
          await context.read<PaymentProvider>().getFlutterWaveGatewayLink(
                userID: CUR_USERID.toString(),
                paymentAmount: price,
                unioqueOrderId:
                    'wallet-refill-user-$CUR_USERID-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}',
              );
  
      if (flutterWaveLink != '') {
        var response = await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (BuildContext context) => PaypalWebview(
              url: flutterWaveLink,
              from: 'wallet',
            ),
          ),
        );
        if (response == 'true') {
          return {
            'error': true,
            'message': '',
            'status': false,
          };
        }
      }
      return {
        'error': false,
        'message': 'Transaction Successful',
        'status': true
      };
    } catch (e) {
      return {
        'error': true,
        'message': e.toString(),
        'status': false,
      };
    }
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<Map<String, dynamic>> doPaymentWithPayStack(
      {required int price}) async {
    try {
      String payStackID = context.read<SystemProvider>().payStackKeyID!;
      String? userEmail = context.read<UserProvider>().email;

      var response = await context.read<PaymentProvider>().payWithPayStack(
            paymentAmount: price,
            userEmail: userEmail,
            reference: _getReference(), // Platform.isIOS ? 'iOS' : 'Android',
            payStackID: payStackID,
            context: context,
          );

      return response;
    } catch (e) {
      return {
        'error': true,
        'message': e.toString(),
        'status': false,
      };
    }
  }

  bool? isPhonePayPaymentSuccess;
  String url = '';
  InAppWebViewController? _webViewController;
  String _paymentStatus = '';

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
                // Extract payment status from URL
                /// String? paymentStatus = extractPaymentStatusFromUrl(url.toString());
                ///
                _handlePaymentStatus(url.toString());


                await _webViewController?.stopLoading();
                if (await _webViewController?.canGoBack() ?? false) {
                  await _webViewController?.goBack();
                  print("==firts print=");
                } else {
                  print("==second print=");
                  Navigator.pop(context);
                }
                if(isPhonePayPaymentSuccess ?? false){
                  print("==thirddd print=");
                  addwalletPayment();
                }else {
                  print("==fourthhh  print=");
                }


                // Stop loading and close WebView
              }
            },
          ),
        ),
      ),
    );
  }

  int? paymentIndex;
  double? deductAmount;

  void _handlePaymentStatus(String url) async {
    print('${'transaction_id $merchantTransactionId'}_______________');
    Map<String, dynamic> responseData = await fetchDataFromUrl();

    print('${responseData['data']}');
    String isError = responseData['data'][0]['error'];
    if (isError == 'true') {
      // Payment success
      isPhonePayPaymentSuccess = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Failure')));
    } else {
      // Payment failure
      isPhonePayPaymentSuccess = true;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Success')));
    }
  }

  String? callBackUrl;
  String? merchantId;
  String? merchantTransactionId;
  Future<Map<String, dynamic>> fetchDataFromUrl() async {
    final response = await http.post(
        Uri.parse("${baseUrl}/check_phonepay_status"),
        body: {'transaction_id': merchantTransactionId},
        headers: headers);
    if (response.statusCode == 200) {
      // If the request is successful, parse the JSON response and return it
      return json.decode(response.body);
    } else {
      // If the request fails, throw an exception or handle the error accordingly
      throw Exception('Failed to load data from the URL');
    }
  }

  String? mobile;
  Future<void> getPhonpayURL() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    mobile = preferences.getString('mobile');
    var request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/initiate_phone_payment'));
    request.fields.addAll({
      'user_id': CUR_USERID.toString(),
      'mobile': mobile.toString(),
      'amount': amountTextController.text
    });
    print('_______request.fields____${request.fields}__________');
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var finalResult = jsonDecode(result);
      url = finalResult['data']['data']['instrumentResponse']['redirectInfo']['url'];
      merchantId = finalResult['data']['data']['merchantId'];
      merchantTransactionId = finalResult['data']['data']['merchantTransactionId'];
       initiatePayment();
      //  print('_____merchantTransactionId______${merchantTransactionId}_____${merchantId}_____');
      //print("aaaaaaaaaaaaaaaaaaaaaa${url}");
    } else {
      print(response.reasonPhrase);
    }
  }


  Future<Map<String, dynamic>> doPaymentWithRazorpay(
      {required int price}) async {
    try {
      String orderID =
          'wallet-refill-user-$CUR_USERID-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}';
      SettingProvider settingsProvider =
          Provider.of<SettingProvider>(context, listen: false);
      String userContactNumber = settingsProvider.mobile;
      String userEmail = settingsProvider.email;
      String razorpayID = context.read<SystemProvider>().razorpayId!;

      double payableAmount = price * 100;
      var razorpayOptions = {
        KEY: razorpayID,
        AMOUNT: payableAmount.toString(),
        NAME: settingsProvider.userName,
        'notes': {'order_id': orderID},
        'prefill': {
          CONTACT: userContactNumber,
          EMAIL: userEmail,
        },
      };

      _razorpay.open(razorpayOptions);

      return {
        'error': true,
        'message': '',
        'status': false,
      };
    } catch (e) {
      return {
        'error': true,
        'message': e.toString(),
        'status': false,
      };
    }
  }

  void openCheckout({double? amount}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? phone = prefs.getString('phone');
   // int amt = deductAmount?.toInt() ?? 0 ;
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
      'amount': (amount?.toInt() ?? 100)*100,
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

  Future<void> updateUserWalletAmount() async {
    try {
      String currentBalance =
          await context.read<PaymentProvider>().getUserCurrentBalance();

      if (currentBalance != '') {
        Provider.of<UserProvider>(context, listen: false)
            .setBalance(currentBalance);
      }
    } catch (e) {}
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    //setSnackbar(getTranslated(context, 'Transaction Successful')!, context);
   // Navigator.pop(context, response);
    addwalletPayment();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setSnackbar(getTranslated(context, "somethingMSg")!, context);
    Navigator.pop(context, response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}
}
