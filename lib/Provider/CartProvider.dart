import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:collection/src/iterable_extensions.dart';
import 'package:eshop_multivendor/Model/delivery_charges_response.dart';
import 'package:eshop_multivendor/Screen/SQLiteData/SqliteData.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/promoCodeProvider.dart';
import 'package:eshop_multivendor/repository/cartRepository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Helper/String.dart';
import '../Model/Model.dart';
import '../Model/User.dart';
import '../Screen/Dashboard/Dashboard.dart';
import '../Screen/Language/languageSettings.dart';
import '../widgets/networkAvailablity.dart';
import '../widgets/snackbar.dart';
import 'UserProvider.dart';

class CartProvider extends ChangeNotifier {
  List<File> prescriptionImages = [];
  List<String> productVariantIds = [];
  List<String> productIds = [];
  List<User> addressList = [];
  List<Promo> promoList = [];
  final List<TextEditingController> controller = [];
  TextEditingController noteController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController promoC = TextEditingController();
  double totalPrice = 0, oriPrice = 0, deliveryCharge = 0, taxPer = 0,deductAmount = 0;
  int? selectedAddress = 0;
  String? selAddress, payMethod, selTime, selDate, promocode;
  bool? isTimeSlot,
      isPromoValid = false,
      isUseWallet = false,
      isPayLayShow = true;
  int? selectedTime, selectedDate, selectedMethod;
  bool saveLater = false, addCart = false;
  double promoAmt = 0;
  double remWalBal = 0, usedBalance = 0;
  bool isAvailable = true;
  String? razorpayId,
      paystackId,
      phoneID,
      stripeId,
      stripeSecret,
      stripeMode = 'test',
      stripeCurCode,
      stripePayId,
      paytmMerId,
      paytmMerKey;

  String? midtransPaymentMode,
      midtransPaymentMethod,
      midtrashClientKey,
      midTranshMerchandId,
      midtransServerKey;

  String? myfatoorahToken,
      myfatoorahPaymentMode,
      myfatoorahSuccessUrl,
      myfatoorahErrorUrl,
      myfatoorahLanguage,
      myfatoorahCountry;
  bool payTesting = true;
  bool isPromoLen = false;
  List<SectionModel> saveLaterList = [];
  List<Model> deliverableList = [];
  StateSetter? checkoutState;
  bool deliverable = false;
  get getprescriptionImages => prescriptionImages;
  setprescriptionImages(List<File> prescriptionImagesList) {
    prescriptionImages = prescriptionImagesList;
    notifyListeners();
  }

  setproVarIds(productVariantIdsValue) {
    productVariantIds = productVariantIdsValue;
    notifyListeners();
  }

  setProductIds(productIdsValue) {
    productIds = productIdsValue;
  }

  setaddressList(addressListValue) {
    addressList = addressListValue;
  }

  setpromoList(promoListValue) {
    promoList = promoListValue;
  }

  settotalPrice(totalPriceValue) {
    totalPrice = totalPriceValue;
  }

  setselectedAddress(selectedAddressValue) {
    selectedAddress = selectedAddressValue;
  }

  List<SectionModel> _cartList = [];
  List<DeliveryChargeData> deliveryChargeList = [];

  get cartList => _cartList;
  bool _isProgress = false;

  get cartIdList => _cartList.map((fav) => fav.varientId).toList();

  String? qtyList(String id, String vId) {
    SectionModel? tempId =
        _cartList.firstWhereOrNull((cp) => cp.id == id && cp.varientId == vId);
   notifyListeners();
    if (tempId != null) {
      return tempId.qty;
    } else {
      return '0';
    }
  }

  get isProgress => _isProgress;

  setProgress(bool progress) {
    _isProgress = progress;
    notifyListeners();
  }

  removeCartItem(String id) {
    _cartList.removeWhere((item) => item.varientId == id);
    notifyListeners();
  }

  addCartItem(SectionModel? item) {
    if (item != null) {
      _cartList.add(item);
      notifyListeners();
    }
  }

  updateCartItem(String? id, String qty, int index, String vId) {
    final i = _cartList.indexWhere((cp) => cp.id == id && cp.varientId == vId);

    _cartList[i].qty = qty;
    _cartList[i].productList![0].prVarientList![index].cartCount = qty;

    notifyListeners();
  }

  setCartlist(List<SectionModel> cartList) {
    _cartList.clear();
    _cartList.addAll(cartList);
    notifyListeners();
  }

  Future getUserCart({required String save}) async {
    try {
      var parameter = {USER_ID: CUR_USERID, SAVE_LATER: save};
           print("get user xcarttt ${parameter}");
      CartRepository.fetchUserCart(parameter: parameter).then(
        (value) {
          if (!value['error']) {
            _cartList = value['cartList'];
            print(_cartList[0].title.toString()+"++++++++++++++++++++++++");
          }
        },
      );
    } catch (e) {}
  }

  Future <void> getDeliveryCharge() async {

    try {
      CartRepository.fetchDeliveryCharge().then(
            (value) {
          if (!value['error']) {
            deliveryChargeList = value['deliveryCharge'];
          }
        },
      );
    } catch (e) {}
  }



  Future getUserOfflineCart() async {
    if (CUR_USERID == null || CUR_USERID == '') {
      DatabaseHelper db = DatabaseHelper();
      List<String>? proIds = (await db.getCart())!;

      if (proIds.isNotEmpty) {
        try {
          var parameter = {'product_variant_ids': proIds.join(',')};
          CartRepository.fetchUserOfflineCart(parameter: parameter).then(
              (offlineCartData) async {
            String? msg = offlineCartData['message'];
            if (!offlineCartData['error']) {
              List<Product> tempList = offlineCartData['offlineCartList'];
              List<SectionModel> cartSecList = [];
              for (int i = 0; i < tempList.length; i++) {
                for (int j = 0; j < tempList[i].prVarientList!.length; j++) {
                  if (proIds.contains(tempList[i].prVarientList![j].id)) {
                    String qty = (await db.checkCartItemExists(
                        tempList[i].id!, tempList[i].prVarientList![j].id!))!;
                    List<Product>? prList = [];
                    prList.add(tempList[i]);
                    cartSecList.add(
                      SectionModel(
                        id: tempList[i].id,
                        varientId: tempList[i].prVarientList![j].id,
                        qty: qty,
                        productList: prList,
                      ),
                    );
                  }
                }
              }
              _cartList = cartSecList;
            }
            _isProgress = false;
          }, onError: (error) {});
        } catch (e) {}
      } else {
        _isProgress = false;
      }
    } else {
      _cartList = [];
      _isProgress = false;
    }
  }

  Future<void> saveForLater(
      {required Function update,
      required BuildContext context,
      required String? id,
      required String save,
      required String? qty,
      required double price,
      required SectionModel curItem,
      required bool fromSave,
      required String promoCode}) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        setProgress(true);
        var parameter = {
          PRODUCT_VARIENT_ID: id,
          USER_ID: CUR_USERID,
          QTY: qty,
          SAVE_LATER: save
        };

        dynamic result =
            await CartRepository.manageCartAPICall(parameter: parameter);
        bool error = result['error'];
        String? msg = result['message'];
        if (!error) {
          var data = result['data'];
          context.read<UserProvider>().setCartCount(
                data['cart_count'],
              );
          if (save == '1') {
            saveLaterList.add(curItem);
            removeCartItem(id!);
            saveLater = false;
            update();
            oriPrice = oriPrice - price;
          } else {
            addCartItem(curItem);
            saveLaterList.removeWhere((item) => item.varientId == id);
            addCart = false;
            update();
            oriPrice = oriPrice + price;
          }
          getDeliveryCharge();

          if(oriPrice < double.parse(deliveryChargeList.first.maximum ?? '0.0')){
            deliveryCharge = double.parse(deliveryChargeList.first.deliveryCharge ?? '0.0');
          }


          totalPrice = 0;

          /*if (!ISFLAT_DEL) {
            if (addressList.isNotEmpty &&
                (oriPrice) <
                    double.parse(addressList[selectedAddress!].freeAmt!)) {
              deliveryCharge =
                  double.parse(addressList[selectedAddress!].deliveryCharge!);
            } else {
              deliveryCharge = 0;
            }
          } else {
            if ((oriPrice) < double.parse(MIN_AMT!)) {
              deliveryCharge = double.parse(CUR_DEL_CHR!);
            } else {
              deliveryCharge = 0;
            }
          }*/
          totalPrice = deliveryCharge + oriPrice;

          if (isPromoValid!) {
            await context
                .read<PromoCodeProvider>()
                .validatePromocode(
                    check: false,
                    context: context,
                    promocode: promoCode,
                    update: update)
                .then(
              (value) {
                FocusScope.of(context).unfocus();
                update();
              },
            );
          } else if (isUseWallet!) {
            setProgress(false);
            remWalBal = 0;
            payMethod = null;
            usedBalance = 0;
            isUseWallet = false;
            isPayLayShow = true;
            update();
          } else {
            setProgress(false);
            update();
          }
        } else {
          setSnackbar(msg!, context);
        }
        setProgress(false);
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
        setProgress(false);
      }
    } else {
      isNetworkAvail = false;
      update();
    }
  }

  Future<void> removeFromCart({
    required int index,
    required bool remove,
    required List<SectionModel> cartList,
    required bool move,
    required int selPos,
    required BuildContext context,
    required Function update,
    required String promoCode,
    bool? isRemove
  }) async {
    isNetworkAvail = await isNetworkAvailable();
    if (!remove &&
        int.parse(cartList[index].qty!) ==
            cartList[index].productList![0].minOrderQuntity) {
      setSnackbar(
        "${getTranslated(context, 'MIN_MSG')}${cartList[index].qty}",
        context,
      );
    } else {
      if (isNetworkAvail) {
        try {
          setProgress(true);
          int? qty;
          if (remove) {
            qty = 0;
          } else {
            qty = (int.parse(cartList[index].qty!) -
                int.parse(cartList[index].productList![0].qtyStepSize!));

            if (qty < cartList[index].productList![0].minOrderQuntity!) {
              qty = cartList[index].productList![0].minOrderQuntity;
              setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
            }
          }
          String varId;
          if (cartList[index].productList![0].availability == '0') {
            varId = cartList[index].productList![0].prVarientList![selPos].id!;
          } else {
            varId = cartList[index].varientId!;
          }

          var parameter = {
            PRODUCT_VARIENT_ID: varId,
            USER_ID: CUR_USERID,
            QTY: remove ? qty.toString() : cartList[index].productList![0].qtyStepSize,//qty.toString()
            REMOVE: isRemove ?? false || remove ? '0' : '1'
          };

          print('___________${parameter}__________');
          dynamic result =
              await CartRepository.manageCartAPICall(parameter: parameter);
          bool error = result['error'];
          String? msg = result['message'];
          if (!error) {

            var data = result['data'];
            String qty = data['total_quantity'];
            context.read<UserProvider>().setCartCount(data['cart_count']);
            if (move == false) {
              if (qty == '0') remove = true;

              if (remove) {
                cartList.removeWhere(
                    (item) => item.varientId == cartList[index].varientId);
              } else {
                cartList[index].qty = qty.toString();
              }
              var cart = result['cart'];
              List<SectionModel> uptcartList = (cart as List)
                  .map((cart) => SectionModel.fromCart(cart))
                  .toList();
              setCartlist(uptcartList);

              oriPrice = double.parse(data[SUB_TOTAL]);

              /*if (!ISFLAT_DEL) {
                if (addressList.isNotEmpty &&
                    (oriPrice) <
                        double.parse(addressList[selectedAddress!].freeAmt!)) {
                  deliveryCharge = double.parse(
                      addressList[selectedAddress!].deliveryCharge!);
                } else {
                  deliveryCharge = 0;
                }
                update();
              } else {
                if ((oriPrice) < double.parse(MIN_AMT!)) {
                  deliveryCharge = double.parse(CUR_DEL_CHR!);
                } else {
                  deliveryCharge = 0;
                }
              }*/
               getDeliveryCharge();

               if(deliveryChargeList.isNotEmpty) {
                if (oriPrice <
                    double.parse(deliveryChargeList.first.maximum ?? '0.0')) {
                  deliveryCharge = double.parse(
                      deliveryChargeList.first.deliveryCharge ?? '0.0');
                }
              }
              totalPrice = 0;

              totalPrice = deliveryCharge + oriPrice;

              if (isPromoValid!) {
                await context
                    .read<PromoCodeProvider>()
                    .validatePromocode(
                      check: false,
                      context: context,
                      promocode: promoCode,
                      update: update,
                    )
                    .then(
                  (value) {
                    FocusScope.of(context).unfocus();
                    update();
                  },
                );
              } else if (isUseWallet!) {
                setProgress(false);
                remWalBal = 0;
                payMethod = null;
                usedBalance = 0;
                isPayLayShow = true;
                isUseWallet = false;
                update();
              } else {
                setProgress(false);
                update();
              }
            } else {
              if (qty == '0') remove = true;

              if (remove) {
                cartList.removeWhere(
                    (item) => item.varientId == cartList[index].varientId);
              }
            }
          } else {
            setSnackbar(msg!, context);
          }
          update();
          setProgress(false);
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          setProgress(false);
        }
      } else {
        isNetworkAvail = false;
        update();
      }
    }
  }

  Future<void> addAndRemoveQty({
    required String qty,
    required int from,
    required int totalLen,
    required int index,
    required double price,
    required int selectedPos,
    required double total,
    required List<SectionModel> cartList,
    required int itemCounter,
    required BuildContext context,
    required Function update,
  }) async {
    if (from == 1) {
      if (int.parse(qty) >= totalLen) {
        setSnackbar("${getTranslated(context, 'MAXQTY')!}  $qty", context);
      } else {
        db.updateCart(
          cartList[index].id!,
          cartList[index].productList![0].prVarientList![selectedPos].id!,
          (int.parse(qty) + itemCounter).toString(),
        );
        updateCartItem(
            cartList[index].productList![0].id!,
            (int.parse(qty) + itemCounter).toString(),
            selectedPos,
            cartList[index].productList![0].prVarientList![selectedPos].id!);
        oriPrice = (oriPrice + price);
        update();
      }
    } else if (from == 2) {
      if (int.parse(qty) <= cartList[index].productList![0].minOrderQuntity!) {
        db.updateCart(
          cartList[index].id!,
          cartList[index].productList![0].prVarientList![selectedPos].id!,
          itemCounter.toString(),
        );
        updateCartItem(
            cartList[index].productList![0].id!,
            itemCounter.toString(),
            selectedPos,
            cartList[index].productList![0].prVarientList![selectedPos].id!);
        update();
      } else {
        db.updateCart(
          cartList[index].id!,
          cartList[index].productList![0].prVarientList![selectedPos].id!,
          (int.parse(qty) - itemCounter).toString(),
        );
        updateCartItem(
            cartList[index].productList![0].id!,
            (int.parse(qty) - itemCounter).toString(),
            selectedPos,
            cartList[index].productList![0].prVarientList![selectedPos].id!);
        oriPrice = (oriPrice - price);
        getDeliveryCharge();
        update();
      }
    } else {
      db.updateCart(
        cartList[index].id!,
        cartList[index].productList![0].prVarientList![selectedPos].id!,
        qty,
      );
      updateCartItem(cartList[index].productList![0].id!, qty, selectedPos,
          cartList[index].productList![0].prVarientList![selectedPos].id!);
      oriPrice = (oriPrice - total + (int.parse(qty) * price));
      update();
    }
  }

  Future<void> removeFromCartCheckout({
    required int index,
    required bool remove,
    required List<SectionModel> cartList,
    required String promoCode,
    required BuildContext context,
    required Function update,
  }) async {
    isNetworkAvail = await isNetworkAvailable();

    if (!remove &&
        int.parse(cartList[index].qty!) ==
            cartList[index].productList![0].minOrderQuntity) {
      setSnackbar('${getTranslated(context, 'MIN_MSG')}${cartList[index].qty}',
          context);
    } else {
      if (isNetworkAvail) {
        try {
          setProgress(true);
          int? qty;
          if (remove) {
            qty = 0;
          } else {
            qty = (int.parse(cartList[index].qty!) -
                int.parse(cartList[index].productList![0].qtyStepSize!));

            if (qty < cartList[index].productList![0].minOrderQuntity!) {
              qty = cartList[index].productList![0].minOrderQuntity;

              setSnackbar(
                "${getTranslated(context, 'MIN_MSG')}$qty",
                context,
              );
            }
          }

          var parameter = {
            PRODUCT_VARIENT_ID: cartList[index].varientId,
            USER_ID: CUR_USERID,
            QTY: qty.toString()
          };

          dynamic result = await CartRepository.manageCartAPICall(
            parameter: parameter,
          );

          bool error = result['error'];
          String? msg = result['message'];
          if (!error) {
            var data = result['data'];

            String qty = data['total_quantity'];

            context.read<UserProvider>().setCartCount(
                  data['cart_count'],
                );
            if (qty == '0') remove = true;

            if (remove) {
              removeCartItem(cartList[index].varientId!);
            } else {
              cartList[index].qty = qty.toString();
            }

            oriPrice = double.parse(data[SUB_TOTAL]);


            controller[index].text = qty;

            /*if (!ISFLAT_DEL) {
              if ((oriPrice) <
                  double.parse(addressList[selectedAddress!].freeAmt!)) {
                deliveryCharge =
                    double.parse(addressList[selectedAddress!].deliveryCharge!);
              } else {
                deliveryCharge = 0;
              }
            } else {
              if ((oriPrice) < double.parse(MIN_AMT!)) {
                deliveryCharge = double.parse(CUR_DEL_CHR!);
              } else {
                deliveryCharge = 0;
              }
            }*/
             getDeliveryCharge();

            if(deliveryChargeList.isNotEmpty) {
              if (oriPrice <
                  double.parse(deliveryChargeList.first.maximum ?? '0.0')) {
                deliveryCharge = double.parse(
                    deliveryChargeList.first.deliveryCharge ?? '0.0');
              }
            }

            totalPrice = 0;

            totalPrice = deliveryCharge + oriPrice;

            if (isPromoValid!) {
              await context
                  .read<PromoCodeProvider>()
                  .validatePromocode(
                      check: true,
                      context: context,
                      promocode: promoCode,
                      update: update)
                  .then(
                (value) {
                  FocusScope.of(context).unfocus();
                  update();
                },
              );
            } else if (isUseWallet!) {
              checkoutState!(() {
                remWalBal = 0;
                payMethod = null;
                usedBalance = 0;
                isPayLayShow = true;
                isUseWallet = false;
              });

              setProgress(false);
              update();
            } else {
              setProgress(false);

              checkoutState!(() {});
              update();
            }
          } else {
            setSnackbar(msg!, context);
            setProgress(false);
          }
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          setProgress(false);
        }
      } else {
        checkoutState!(
          () {
            isNetworkAvail = false;
          },
        );

        update();
      }
    }
  }

  Future<void> addToCartCheckout({
    required int index,
    required String qty,
    required List<SectionModel> cartList,
    required BuildContext context,
    required Function update,
  }) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        setProgress(true);

        if (int.parse(qty) < cartList[index].productList![0].minOrderQuntity!) {
          qty = cartList[index].productList![0].minOrderQuntity.toString();

          setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
        }

        var parameter = {
          PRODUCT_VARIENT_ID: cartList[index].varientId,
          USER_ID: CUR_USERID,
          QTY: qty,
        };

        dynamic result =
            await CartRepository.manageCartAPICall(parameter: parameter);
        bool error = result['error'];
        String? msg = result['message'];
        if (!error) {
          var data = result['data'];

          String qty = data['total_quantity'];

          context.read<UserProvider>().setCartCount(data['cart_count']);
          cartList[index].qty = qty;

          oriPrice = double.parse(data['sub_total']);
          controller[index].text = qty;
          totalPrice = 0;

          /*if (!ISFLAT_DEL) {
            if ((oriPrice) <
                double.parse(addressList[selectedAddress!].freeAmt!)) {
              deliveryCharge =
                  double.parse(addressList[selectedAddress!].deliveryCharge!);
            } else {
              deliveryCharge = 0;
            }
          } else {
            if ((oriPrice) < double.parse(MIN_AMT!)) {
              deliveryCharge = double.parse(CUR_DEL_CHR!);
            } else {
              deliveryCharge = 0;
            }
          }*/

         await  getDeliveryCharge();

          if(deliveryChargeList.isNotEmpty){

            if(oriPrice < double.parse(deliveryChargeList.first.maximum ?? '0.0')){
              deliveryCharge = double.parse(deliveryChargeList.first.deliveryCharge ?? '0.0');
            }
          }

          totalPrice = deliveryCharge + oriPrice;
          if (isPromoValid!) {
            await context
                .read<PromoCodeProvider>()
                .validatePromocode(
                    check: true,
                    context: context,
                    promocode: promoC.text,
                    update: update)
                .then(
              (value) {
                FocusScope.of(context).unfocus();
                update();
              },
            );
          } else if (isUseWallet!) {
            checkoutState!(() {
              remWalBal = 0;
              payMethod = null;
              usedBalance = 0;
              isUseWallet = false;
              isPayLayShow = true;
              selectedMethod = null;
            });

            update();
          } else {
            setProgress(false);
            update();
            checkoutState!(() {});
          }
        } else {
          setSnackbar(msg!, context);
          setProgress(false);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
        setProgress(false);
      }
    } else {
      checkoutState!(() {
        isNetworkAvail = false;
      });

      update();
    }
  }

  Future<void> addToCart({
    required int index,
    required String qty,
    required List<SectionModel> cartList,
    required BuildContext context,
    required Function update,
  }) async {
    isNetworkAvail = await isNetworkAvailable();

    if (isNetworkAvail) {
      try {
        setProgress(true);
        if (int.parse(qty) < cartList[index].productList![0].minOrderQuntity!) {
          qty = cartList[index].productList![0].minOrderQuntity.toString();
          setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
        }
        var parameter = {
          PRODUCT_VARIENT_ID: cartList[index].varientId ,
          USER_ID: CUR_USERID,
          QTY: cartList[index].productList![0].qtyStepSize == "1"? qty: cartList[index].productList![0].qtyStepSize,//qty,
          //  QTY: qty,
          REMOVE: '1'
        };
        print('------------parameter1111------------$parameter');
        dynamic result = await CartRepository.manageCartAPICall(parameter: parameter);
        bool error = result['error'];
        String? msg = result['message'];
        if (!error) {
          var data = result['data'];
          String qty = data['total_quantity'];
          context.read<UserProvider>().setCartCount(data['cart_count']);
          cartList[index].qty = qty;
          oriPrice = double.parse(data['sub_total']);
          controller[index].text = qty;
          totalPrice = 0;
          var cart = result['cart'];
          List<SectionModel> uptcartList = (cart as List)
              .map((cart) => SectionModel.fromCart(cart))
              .toList();
          setCartlist(uptcartList);
          /*if (!ISFLAT_DEL) {
            if (addressList.isEmpty) {
              deliveryCharge = 0;
            } else {
              if ((oriPrice) <
                  double.parse(addressList[selectedAddress!].freeAmt!)) {
                deliveryCharge =
                    double.parse(addressList[selectedAddress!].deliveryCharge!);
              } else {
                deliveryCharge = 0;
              }
            }
          } else {
            if (oriPrice < double.parse(MIN_AMT!)) {
              deliveryCharge = double.parse(CUR_DEL_CHR!);
            } else {
              deliveryCharge = 0;
            }
          }*/
           getDeliveryCharge();
          // if(oriPrice < double.parse(deliveryChargeList.first.maximum ?? '0.0')){
          //   deliveryCharge = double.parse(deliveryChargeList.first.deliveryCharge ?? '0.0');
          // }

          totalPrice = deliveryCharge + oriPrice;
          if (isPromoValid!) {
            await context
                .read<PromoCodeProvider>()
                .validatePromocode(
                    check: false,
                    context: context,
                    promocode: promoC.text,
                    update: update)
                .then(
              (value) {
                FocusScope.of(context).unfocus();
                update();
              },
            );
          } else if (isUseWallet!) {
            setProgress(false);
            remWalBal = 0;
            payMethod = null;
            usedBalance = 0;
            isUseWallet = false;
            isPayLayShow = true;
            selectedMethod = null;
            update();
          } else {
            update();
            setProgress(false);
          }
        } else {
          setSnackbar(msg!, context);
          setProgress(false);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
        setProgress(false);
      }
    } else {
      isNetworkAvail = false;
      update();
    }
  }



}
