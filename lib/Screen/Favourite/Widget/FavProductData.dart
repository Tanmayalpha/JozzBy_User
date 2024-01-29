import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../SQLiteData/SqliteData.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/CartProvider.dart';
import '../../../Provider/Favourite/FavoriteProvider.dart';
import '../../../Provider/Favourite/UpdateFavProvider.dart';
import '../../../Provider/UserProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/networkAvailablity.dart';
import '../../../widgets/snackbar.dart';
import '../../../widgets/star_rating.dart';
import '../../Product Detail/productDetail.dart';
import '../../star_rating.dart';

class FavProductData extends StatefulWidget {
  int? index;
  List<Product> favList = [];
  Function updateNow;

  FavProductData({
    Key? key,
    required this.index,
    required this.updateNow,
    required this.favList,
  }) : super(key: key);

  @override
  State<FavProductData> createState() => _FavProductDataState();
}

class _FavProductDataState extends State<FavProductData> {
  var db = DatabaseHelper();

  int quantity = 0;

  List<int> quantityList = [];

  removeFromCart(
    int index,
    List<Product> favList,
    BuildContext context,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (CUR_USERID != null) {
        if (mounted) {
          context
              .read<UpdateFavProvider>()
              .changeStatus(UpdateFavStatus.inProgress);
        }
        int qty;
        qty = (int.parse(
                context.read<FavoriteProvider>().controllerText[index].text) -
            int.parse(favList[index].qtyStepSize!));

        if (qty < favList[index].minOrderQuntity!) {
          qty = 0;
        }

        var parameter = {
          PRODUCT_VARIENT_ID:
              favList[index].prVarientList![favList[index].selVarient!].id,
          USER_ID: CUR_USERID,
          QTY: qty.toString()
        };

        apiBaseHelper.postAPICall(manageCartApi, parameter).then(
          (getdata) {
            bool error = getdata['error'];
            String? msg = getdata['message'];
            if (!error) {
              var data = getdata['data'];

              String? qty = data['total_quantity'];

              context.read<UserProvider>().setCartCount(data['cart_count']);
              favList[index]
                  .prVarientList![favList[index].selVarient!]
                  .cartCount = qty.toString();

              var cart = getdata['cart'];
              List<SectionModel> cartList = (cart as List)
                  .map((cart) => SectionModel.fromCart(cart))
                  .toList();
              context.read<CartProvider>().setCartlist(cartList);
            } else {
              setSnackbar(msg!, context);
            }

            if (mounted) {
              context
                  .read<UpdateFavProvider>()
                  .changeStatus(UpdateFavStatus.isSuccsess);
              widget.updateNow();
            }
          },
          onError: (error) {
            setSnackbar(error.toString(), context);
            context
                .read<UpdateFavProvider>()
                .changeStatus(UpdateFavStatus.isSuccsess);
            widget.updateNow();
          },
        );
      } else {
        context
            .read<UpdateFavProvider>()
            .changeStatus(UpdateFavStatus.inProgress);
        int qty;

        qty = (int.parse(
                context.read<FavoriteProvider>().controllerText[index].text) -
            int.parse(favList[index].qtyStepSize!));

        if (qty < favList[index].minOrderQuntity!) {
          qty = 0;

          db.removeCart(
              favList[index].prVarientList![favList[index].selVarient!].id!,
              favList[index].id!,
              context);
        } else {
          db.updateCart(
            favList[index].id!,
            favList[index].prVarientList![favList[index].selVarient!].id!,
            qty.toString(),
          );
        }
        context
            .read<UpdateFavProvider>()
            .changeStatus(UpdateFavStatus.isSuccsess);
        widget.updateNow();
      }
    } else {
      if (mounted) {
        isNetworkAvail = false;
        widget.updateNow();
      }
    }
  }

  Future<void> addToCart(
    String qty,
    int from,
    List<Product> favList,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (CUR_USERID != null) {
        try {
          if (mounted) {
            context
                .read<UpdateFavProvider>()
                .changeStatus(UpdateFavStatus.inProgress);
          }

          String qtyr =
              (int.parse(favList[widget.index!].prVarientList![0].cartCount!) +
                      int.parse(favList[widget.index!].qtyStepSize!))
                  .toString();
          if (int.parse(qty) < favList[widget.index!].minOrderQuntity!) {
            qty = favList[widget.index!].minOrderQuntity.toString();
            setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
          }

          var parameter = {
            PRODUCT_VARIENT_ID: favList[widget.index!]
                .prVarientList![favList[widget.index!].selVarient!]
                .id,
            USER_ID: CUR_USERID,
            QTY: qty,
          };
          apiBaseHelper.postAPICall(manageCartApi, parameter).then(
            (getdata) {
              bool error = getdata['error'];
              String? msg = getdata['message'];
              if (!error) {
                //setSnackbar(msg!, context);
                var data = getdata['data'];

                String? qty = data['total_quantity'];
                context.read<UserProvider>().setCartCount(data['cart_count']);

                favList[widget.index!]
                    .prVarientList![favList[widget.index!].selVarient!]
                    .cartCount = qty.toString();

                favList[widget.index!].prVarientList![0].cartCount =
                    qty.toString();
                context
                    .read<FavoriteProvider>()
                    .controllerText[widget.index!]
                    .text = qty.toString();
                var cart = getdata['cart'];
                List<SectionModel> cartList = (cart as List)
                    .map((cart) => SectionModel.fromCart(cart))
                    .toList();
                context.read<CartProvider>().setCartlist(cartList);
              } else {
                setSnackbar(msg!, context);
              }

              if (mounted) {
                context
                    .read<UpdateFavProvider>()
                    .changeStatus(UpdateFavStatus.isSuccsess);
              }
            },
            onError: (error) {
              setSnackbar(error.toString(), context);
            },
          );
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          context.read<FavoriteProvider>().changeStatus(FavStatus.isSuccsess);
          widget.updateNow();
        }
      } else {
        if (singleSellerOrderSystem) {
          if (CurrentSellerID == '' ||
              CurrentSellerID == widget.favList[widget.index!].seller_id!) {
            CurrentSellerID = widget.favList[widget.index!].seller_id!;

            context
                .read<UpdateFavProvider>()
                .changeStatus(UpdateFavStatus.inProgress);
            if (from == 1) {
              db.insertCart(
                widget.favList[widget.index!].id!,
                widget
                    .favList[widget.index!]
                    .prVarientList![widget.favList[widget.index!].selVarient!]
                    .id!,
                qty,
                context,
              );
              context
                  .read<FavoriteProvider>()
                  .controllerText[widget.index!]
                  .text = qty.toString();
              widget.updateNow();
              setSnackbar(getTranslated(context, 'Product Added Successfully')!,
                  context);
            } else {
              if (int.parse(qty) >
                  widget.favList[widget.index!].itemsCounter!.length) {
                setSnackbar(
                    '${getTranslated(context, "Max Quantity is")!}-${int.parse(qty) - 1}',
                    context);
              } else {
                db.updateCart(
                  widget.favList[widget.index!].id!,
                  widget
                      .favList[widget.index!]
                      .prVarientList![widget.favList[widget.index!].selVarient!]
                      .id!,
                  qty,
                );
              }
              context
                  .read<FavoriteProvider>()
                  .controllerText[widget.index!]
                  .text = qty.toString();
              setSnackbar(
                  getTranslated(context, 'Cart Update Successfully')!, context);
            }
          } else {
            setSnackbar(
                getTranslated(context, "only Single Seller Product Allow")!,
                context);
          }
        } else {
          context
              .read<UpdateFavProvider>()
              .changeStatus(UpdateFavStatus.inProgress);
          if (from == 1) {
            db.insertCart(
              widget.favList[widget.index!].id!,
              widget
                  .favList[widget.index!]
                  .prVarientList![widget.favList[widget.index!].selVarient!]
                  .id!,
              qty,
              context,
            );
            context
                .read<FavoriteProvider>()
                .controllerText[widget.index!]
                .text = qty.toString();
            widget.updateNow();
            setSnackbar(
                getTranslated(context, 'Product Added Successfully')!, context);
          } else {
            if (int.parse(qty) >
                widget.favList[widget.index!].itemsCounter!.length) {
              setSnackbar(
                  '${getTranslated(context, "Max Quantity is")!}-${int.parse(qty) - 1}',
                  context);
            } else {
              db.updateCart(
                widget.favList[widget.index!].id!,
                widget
                    .favList[widget.index!]
                    .prVarientList![widget.favList[widget.index!].selVarient!]
                    .id!,
                qty,
              );
            }
            context
                .read<FavoriteProvider>()
                .controllerText[widget.index!]
                .text = qty.toString();
            setSnackbar(
                getTranslated(context, 'Cart Update Successfully')!, context);
          }
        }
        context
            .read<UpdateFavProvider>()
            .changeStatus(UpdateFavStatus.isSuccsess);
        widget.updateNow();
      }
    } else {
      isNetworkAvail = false;

      widget.updateNow();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.favList.forEach((element) {
      quantityList.add(quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index! < widget.favList.length && widget.favList.isNotEmpty) {
      if (context.read<FavoriteProvider>().controllerText.length <
          widget.index! + 1) {
        context
            .read<FavoriteProvider>()
            .controllerText
            .add(TextEditingController());
      }
      return Selector<CartProvider, Tuple2<List<String?>, String?>>(
        builder: (context, data, child) {
          double price = double.parse(widget
              .favList[widget.index!]
              .prVarientList![widget.favList[widget.index!].selVarient!]
              .disPrice!);
          if (price == 0) {
            price = double.parse(widget
                .favList[widget.index!]
                .prVarientList![widget.favList[widget.index!].selVarient!]
                .price!);
          }
          double off = 0;
          if (widget
                  .favList[widget.index!]
                  .prVarientList![widget.favList[widget.index!].selVarient!]
                  .disPrice !=
              '0') {
            off = (double.parse(widget
                        .favList[widget.index!]
                        .prVarientList![
                            widget.favList[widget.index!].selVarient!]
                        .price!) -
                    double.parse(
                      widget
                          .favList[widget.index!]
                          .prVarientList![
                              widget.favList[widget.index!].selVarient!]
                          .disPrice!,
                    ))
                .toDouble();
            off = off *
                100 /
                double.parse(widget
                    .favList[widget.index!]
                    .prVarientList![widget.favList[widget.index!].selVarient!]
                    .price!);
          }
          if (data.item1.contains(widget.favList[widget.index!]
              .prVarientList![widget.favList[widget.index!].selVarient!].id)) {
            context
                .read<FavoriteProvider>()
                .controllerText[widget.index!]
                .text = data.item2.toString();
          } else {
            if (CUR_USERID != null) {
              context
                      .read<FavoriteProvider>()
                      .controllerText[widget.index!]
                      .text =
                  widget
                      .favList[widget.index!]
                      .prVarientList![widget.favList[widget.index!].selVarient!]
                      .cartCount!;
            } else {
              context
                  .read<FavoriteProvider>()
                  .controllerText[widget.index!]
                  .text = '0';
            }
          }
          print(
              '${widget.favList[widget.index!].prVarientList![0].price!}dfgfgdfggfgfg');
          return Padding(
            padding: const EdgeInsetsDirectional.only(
              end: 10,
              start: 10,
              top: 5.0,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    Card(
                      elevation: 0.1,
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(circularBorderRadius10),
                        splashColor: colors.primary.withOpacity(0.2),
                        onTap: () {
                          Product model = widget.favList[widget.index!];
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => ProductDetail(
                                model: model,
                                secPos: 0,
                                index: widget.index!,
                                list: true,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                              // color: colors.primary,
                              ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Hero(
                                tag:
                                    '$heroTagUniqueString${widget.index}!${widget.favList[widget.index!].id}${widget.index} ${widget.favList[widget.index!].name}',
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft:
                                        Radius.circular(circularBorderRadius4),
                                    bottomLeft:
                                        Radius.circular(circularBorderRadius4),
                                  ),
                                  child: Stack(
                                    children: [
                                      DesignConfiguration.getCacheNotworkImage(
                                        context: context,
                                        boxFit: BoxFit.cover,
                                        heightvalue: 100.0,
                                        widthvalue: 100.0,
                                        placeHolderSize: 125,
                                        imageurlString: widget
                                            .favList[widget.index!].image!,
                                      ),
                                      Positioned.fill(
                                        child: widget.favList[widget.index!]
                                                    .availability ==
                                                '0'
                                            ? Container(
                                                height: 55,
                                                color: colors.white70,
                                                padding:
                                                    const EdgeInsets.all(3),
                                                child: Center(
                                                  child: Text(
                                                    getTranslated(context,
                                                        'OUT_OF_STOCK_LBL')!,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .caption!
                                                        .copyWith(
                                                          fontFamily: 'ubuntu',
                                                          color: colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        off != 0
                                            ? Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15)),
                                                    margin:
                                                        const EdgeInsets.only(
                                                      left: 5,
                                                    ),
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 4,
                                                              horizontal: 10),
                                                      child: Text(
                                                        'new',
                                                        style: TextStyle(
                                                          color:
                                                              colors.whiteTemp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily: 'ubuntu',
                                                          fontSize:
                                                              textFontSize10,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      child: GetDicountLabel(
                                                          discount: off)),
                                                ],
                                              )
                                            : Container(),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                            start: 15.0,
                                          ),
                                          child: Text(
                                            widget.favList[widget.index!].name!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2!
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .lightBlack,
                                                  fontFamily: 'ubuntu',
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.normal,
                                                  fontSize: textFontSize12,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                            start: 15.0,
                                            top: 8.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                double.parse(widget
                                                            .favList[
                                                                widget.index!]
                                                            .prVarientList![0]
                                                            .disPrice!) !=
                                                        0
                                                    ? 'MRP:${DesignConfiguration.getPriceFormat(
                                                        context,
                                                        double.parse(
                                                          widget
                                                              .favList[
                                                                  widget.index!]
                                                              .prVarientList![0]
                                                              .price!,
                                                        ),
                                                      )!}'
                                                    : '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .overline!
                                                    .copyWith(
                                                      fontFamily: 'ubuntu',
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      decorationColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .blue,
                                                      decorationStyle:
                                                          TextDecorationStyle
                                                              .solid,
                                                      decorationThickness: 1,
                                                      letterSpacing: 0,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .blue,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                              ),
                                              const SizedBox(
                                                width: 3,
                                              ),
                                              Text(
                                                'Price : ${DesignConfiguration.getPriceFormat(context, price)!}',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  fontWeight: FontWeight.normal,
                                                  fontFamily: 'ubuntu',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                            start: 15.0,
                                            top: 8.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                  double.parse(widget
                                                              .favList[
                                                                  widget.index!]
                                                              .prVarientList![0]
                                                              .disPrice!) !=
                                                          0
                                                      ? 'Margin: ${off.toStringAsFixed(2)}%'
                                                      : '',
                                                  style: const TextStyle(
                                                    color: Colors.green,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontFamily: 'ubuntu',
                                                  )),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'Profit : ${int.parse(/*DesignConfiguration.getPriceFormat(
                                                      context,
                                                      double.parse(
                                                        widget
                                                            .favList[
                                                                widget.index!]
                                                            .prVarientList![0]
                                                            .price!,
                                                      ),
                                                    )!.substring(1)*/
                                                        double.parse(
                                                      widget
                                                          .favList[
                                                              widget.index!]
                                                          .prVarientList![0]
                                                          .price!,
                                                    ).toStringAsFixed(0)) - int.parse(price.toStringAsFixed(0) /*DesignConfiguration.getPriceFormat(context, price)!.substring(1)*/)}',
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.normal,
                                                  fontFamily: 'ubuntu',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // widget.favList[widget.index!].rating! !=
                                        //         '0.00'
                                        //     ?
                                        // Container(
                                        //        margin: EdgeInsets.only(left:20,top: 20),
                                        //         child: StarRating(
                                        //           noOfRatings: widget
                                        //               .favList[widget.index!]
                                        //               .noOfRating!,
                                        //           totalRating: widget
                                        //               .favList[widget.index!].rating!,
                                        //           needToShowNoOfRatings: true,
                                        //         ),
                                        //       ),
                                        // : Container(),
                                        Row(
                                          children: [
                                            widget.favList[widget.index!]
                                                        .availability ==
                                                    '0'
                                                ? Container()
                                                : cartBtnList
                                                    ? Row(
                                                        children: <Widget>[
                                                          // SizedBox(height: 50,),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 18.0,
                                                                    top: 10,
                                                                    bottom: 10),
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    color: colors
                                                                        .blackTemp),
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(
                                                                  Radius
                                                                      .circular(
                                                                          5),
                                                                ),
                                                              ),
                                                              child: Row(
                                                                children: <
                                                                    Widget>[
                                                                  InkWell(
                                                                    child:
                                                                        const Padding(
                                                                      padding:
                                                                          EdgeInsets
                                                                              .all(
                                                                        8.0,
                                                                      ),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .remove,
                                                                        size:
                                                                            15,
                                                                        color: colors
                                                                            .blackTemp,
                                                                      ),
                                                                    ),
                                                                    onTap: () {
                                                                      if (/*int.parse(context
                                                                              .read<FavoriteProvider>()
                                                                              .controllerText[widget.index!]
                                                                              .text)*/
                                                                          quantityList[widget.index ?? 0] >
                                                                              0) {
                                                                        quantityList[
                                                                            widget.index ??
                                                                                0] -= int.parse(widget
                                                                            .favList[widget.index!]
                                                                            .qtyStepSize!);
                                                                        context
                                                                            .read<FavoriteProvider>()
                                                                            .controllerText[widget.index!]
                                                                            .text = quantity.toString();
                                                                        setState(
                                                                            () {});
                                                                        /*removeFromCart(
                                                                          widget
                                                                              .index!,
                                                                          widget
                                                                              .favList,
                                                                          context,
                                                                        );*/
                                                                      }
                                                                    },
                                                                  ),
                                                                  quantityList[widget.index ??
                                                                              0] !=
                                                                          0
                                                                      ? Text(
                                                                          '${quantityList[widget.index ?? 0]}',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Theme.of(context).colorScheme.fontColor,
                                                                          ),
                                                                        )
                                                                      : Text(
                                                                          '${widget.favList[widget.index!].qtyStepSize}',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Theme.of(context).colorScheme.fontColor,
                                                                          ),
                                                                        ),
                                                                  /*SizedBox(
                                                                   /// width: 40,
                                                                    height: 20,
                                                                    child:
                                                                        Stack(
                                                                      children: [
                                                                        Selector<
                                                                            CartProvider,
                                                                            Tuple2<List<String?>,
                                                                                String?>>(
                                                                          builder: (context,
                                                                              data,
                                                                              child) {
                                                                            return*/ /* TextField(
                                                                              textAlign: TextAlign.center,
                                                                              readOnly: true,
                                                                              style: TextStyle(
                                                                                fontSize: textFontSize12,
                                                                                color: Theme.of(context).colorScheme.fontColor,
                                                                              ),
                                                                              controller: context.read<FavoriteProvider>().controllerText[widget.index!],
                                                                              decoration: const InputDecoration(
                                                                                border: InputBorder.none,
                                                                              ),
                                                                            )*/ /*quantityList[widget.index ?? 0] !=0 ? Text('  ${quantityList[widget.index ?? 0]}',textAlign: TextAlign.center, style: TextStyle(
                                                                              fontSize: 16,
                                                                              color: Theme.of(context).colorScheme.fontColor,
                                                                            ),)
                                                                            : Text('  ${widget.favList[widget.index!].qtyStepSize}',textAlign: TextAlign.center, style: TextStyle(
                                                                              fontSize: 16,
                                                                              color: Theme.of(context).colorScheme.fontColor,
                                                                            ),);
                                                                          },
                                                                          selector: (_, provider) => Tuple2(
                                                                              provider.cartIdList,
                                                                              provider.qtyList(widget.favList[widget.index!].id!, widget.favList[widget.index!].prVarientList![widget.favList[widget.index!].selVarient!].id!)),
                                                                        ),
                                                                        PopupMenuButton<
                                                                            String>(
                                                                          tooltip:
                                                                              '',
                                                                          icon:
                                                                              const Icon(
                                                                            Icons.arrow_drop_down,
                                                                            size:
                                                                                1,
                                                                          ),
                                                                          onSelected:
                                                                              (String value) {
                                                                            addToCart(
                                                                              value,
                                                                              2,
                                                                              widget.favList,
                                                                            );
                                                                          },
                                                                          itemBuilder:
                                                                              (BuildContext context) {
                                                                            return widget.favList[widget.index!].itemsCounter!.map<PopupMenuItem<String>>(
                                                                              (String value) {
                                                                                return PopupMenuItem(
                                                                                  value: value,
                                                                                  child: Text(
                                                                                    value,
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'ubuntu',
                                                                                      color: Theme.of(context).colorScheme.fontColor,
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              },
                                                                            ).toList();
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),*/
                                                                  InkWell(
                                                                    child:
                                                                        Container(
                                                                      child:
                                                                          const Padding(
                                                                        padding:
                                                                            EdgeInsets.all(8.0),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .add,
                                                                          size:
                                                                              15,
                                                                          color:
                                                                              colors.blackTemp,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    onTap:
                                                                        () async {
                                                                      /*await addToCart(
                                                                        (int.parse(context.read<FavoriteProvider>().controllerText[widget.index!].text) +
                                                                                int.parse(widget.favList[widget.index!].qtyStepSize!))
                                                                            .toString(),
                                                                        2,
                                                                        widget
                                                                            .favList,
                                                                      );*/

                                                                      quantityList[
                                                                          widget.index ??
                                                                              0] += int.parse(widget
                                                                          .favList[
                                                                              widget.index!]
                                                                          .qtyStepSize!);
                                                                      context
                                                                          .read<
                                                                              FavoriteProvider>()
                                                                          .controllerText[
                                                                              widget.index!]
                                                                          .text = quantity.toString();
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 30,
                                                            //width: 35,
                                                            child: ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                    elevation: 0,

                                                                    /// fixedSize: const Size(20, 20),
                                                                    //maximumSize: const Size(20, 20),

                                                                    padding: const EdgeInsets.all(5),
                                                                    backgroundColor: colors.primary,
                                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                                                                onPressed: () async {
                                                                  if (quantityList[
                                                                          widget.index ??
                                                                              0] ==
                                                                      0 ) {
                                                                    /*setSnackbar(
                                                                        'Please add quantity',
                                                                        context);*/
                                                                    await addToCart(
                                                                      /*context.read<FavoriteProvider>().controllerText[widget.index!].text*/
                                                                      widget
                                                                          .favList[
                                                                      widget.index!]
                                                                          .qtyStepSize!,
                                                                      2,
                                                                      widget
                                                                          .favList,
                                                                    );
                                                                  } else {
                                                                    await addToCart(
                                                                      /*context.read<FavoriteProvider>().controllerText[widget.index!].text*/
                                                                      quantityList[widget.index ??
                                                                              0]
                                                                          .toString(),
                                                                      2,
                                                                      widget
                                                                          .favList,
                                                                    );
                                                                  }
                                                                },
                                                                child: const Text('ADD TO CART', style: TextStyle(fontSize: 10),) /*const Icon(
                                                                  Icons.add,
                                                                  color: colors
                                                                      .whiteTemp,
                                                                  size: 20,
                                                                )*/),
                                                          )
                                                          /*Container(
                                                            height:25,
                                                            width: 40,
                                                            decoration: BoxDecoration(
                                                                color: colors.primary,
                                                                borderRadius: BorderRadius.circular(30)
                                                            ),
                                                            child: Center(
                                                              child: Icon(Icons.add_shopping_cart,color: colors.whiteTemp)*/ /*Text(
                                                                */ /**/ /*getTranslated(context, 'ADD_CART')!*/ /**/ /*'Add To Cart',
                                                                textAlign: TextAlign.center,
                                                                style: Theme.of(context)
                                                                    .textTheme
                                                                    .subtitle1!
                                                                    .copyWith(
                                                                  color: colors.whiteTemp,
                                                                  fontWeight: FontWeight.normal,
                                                                  fontFamily: 'ubuntu',
                                                                  fontSize: 12
                                                                ),
                                                              )*/ /*,
                                                            ),
                                                          )*/
                                                        ],
                                                      )
                                                    : Container(),
                                          ],
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 15, bottom: 10),
                                          child: StarRatingIndicators(
                                            noOfRatings: widget
                                                .favList[widget.index!]
                                                .noOfRating!,
                                            totalRating: widget
                                                .favList[widget.index!].rating!,
                                          ),
                                        )

                                        // Container(
                                        //   margin: EdgeInsets.only(left:20,),
                                        //   child: StarRating(
                                        //     noOfRatings: widget
                                        //         .favList[widget.index!]
                                        //         .noOfRating!,
                                        //     totalRating: widget
                                        //         .favList[widget.index!].rating!,
                                        //     needToShowNoOfRatings: true,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                    Positioned.directional(
                                      textDirection: Directionality.of(context),
                                      end: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                          right: 5,
                                          top: 5.0,
                                        ),
                                        alignment: Alignment.topRight,
                                        child: InkWell(
                                          child: const Icon(
                                            Icons.delete,
                                            color: colors.blackTemp,
                                          ),
                                          onTap: () {
                                            if (CUR_USERID != null) {
                                              Future.delayed(Duration.zero)
                                                  .then(
                                                (value) => context
                                                    .read<UpdateFavProvider>()
                                                    .removeFav(
                                                        widget
                                                            .favList[
                                                                widget.index!]
                                                            .id!,
                                                        widget
                                                            .favList[
                                                                widget.index!]
                                                            .prVarientList![0]
                                                            .id!,
                                                        context),
                                              );
                                            } else {
                                              db.addAndRemoveFav(
                                                  widget.favList[widget.index!]
                                                      .id!,
                                                  false);
                                              context
                                                  .read<FavoriteProvider>()
                                                  .removeFavItem(widget
                                                      .favList[widget.index!]
                                                      .prVarientList![0]
                                                      .id!);

                                              setSnackbar(
                                                  getTranslated(context,
                                                      'Removed from favorite')!,
                                                  context);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider()
                  ],
                ),
              ],
            ),
          );
        },
        selector:

            (_, provider) =>


            Tuple2(
          provider.cartIdList,
          provider.qtyList(
            widget.favList[widget.index!].id!,
            widget.favList[widget.index!].prVarientList![0].id!,
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
