import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/CartProvider.dart';
import '../../../Provider/SettingProvider.dart';
import '../../../widgets/desing.dart';
import '../../../widgets/snackbar.dart';
import '../../Language/languageSettings.dart';
import '../../Dashboard/Dashboard.dart';

class CartListViewLayOut extends StatefulWidget {
  int index;
  Function setState;
  Function saveForLatter;
  VoidCallback delete;
  Function callCartApi;
  CartListViewLayOut({
    Key? key,
    required this.index,
    required this.setState,
    required this.saveForLatter,
    required this.delete,
    required this.callCartApi,
  }) : super(key: key);

  @override
  State<CartListViewLayOut> createState() => _CartListViewLayOutState();
}

class _CartListViewLayOutState extends State<CartListViewLayOut> {
  @override
  Widget build(BuildContext context) {
    List<SectionModel> cartList = context.read<CartProvider>().cartList;
    int index = widget.index;
    int selectedPos = 0;
    for (int i = 0;
        i < cartList[index].productList![0].prVarientList!.length;
        i++) {
      if (cartList[index].varientId ==
          cartList[index].productList![0].prVarientList![i].id) selectedPos = i;
    }

    String? offPer;
    double price = double.parse(
        cartList[index].productList![0].prVarientList![selectedPos].disPrice!);
    if (price == 0) {
      price = double.parse(
          cartList[index].productList![0].prVarientList![selectedPos].price!);
    } else {
      double off = (double.parse(cartList[index]
              .productList![0]
              .prVarientList![selectedPos]
              .price!)) -
          price;
      offPer = (off *
              100 /
              double.parse(cartList[index]
                  .productList![0]
                  .prVarientList![selectedPos]
                  .price!))
          .toStringAsFixed(2);
    }

    cartList[index].perItemPrice = price.toString();

    if (context.read<CartProvider>().controller.length < index + 1) {
      context.read<CartProvider>().controller.add(TextEditingController());
    }
    if (cartList[index].productList![0].availability != '0') {
      cartList[index].perItemTotal =
          (price * double.parse(cartList[index].qty!)).toString();
      context.read<CartProvider>().controller[index].text =
          cartList[index].qty!;
    }
    List att = [], val = [];
    if (cartList[index].productList![0].prVarientList![selectedPos].attr_name !=
        '') {
      att = cartList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .attr_name!
          .split(',');
      val = cartList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .varient_value!
          .split(',');
    }

    if (cartList[index].productList![0].attributeList!.isEmpty) {
      if (cartList[index].productList![0].availability == '0') {
        context.read<CartProvider>().isAvailable = false;
      }
    } else {
      if (cartList[index]
              .productList![0]
              .prVarientList![selectedPos]
              .availability ==
          '0') {
        context.read<CartProvider>().isAvailable = false;
      }
    }

    double total = (price *
        double.parse(cartList[index]
            .productList![0]
            .prVarientList![selectedPos]
            .cartCount!));

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            // color: Color(0xffFAF9F7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Hero(
                  tag:
                      '$heroTagUniqueString$heroTagUniqueString$index${cartList[index].productList![0].id}',
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(circularBorderRadius7),
                        child: Stack(
                          children: [
                            DesignConfiguration.getCacheNotworkImage(
                                boxFit: BoxFit.cover,
                                context: context,
                                heightvalue: 120.0,
                                widthvalue: 100.0,
                                imageurlString: cartList[index]
                                                .productList![0]
                                                .type ==
                                            'variable_product' &&
                                        cartList[index]
                                            .productList![0]
                                            .prVarientList![selectedPos]
                                            .images!
                                            .isNotEmpty
                                    ? cartList[index]
                                        .productList![0]
                                        .prVarientList![selectedPos]
                                        .images![0]
                                    : cartList[index].productList![0].image!,
                                placeHolderSize: null),
                            Positioned.fill(
                              child: cartList[index]
                                          .productList![0]
                                          .prVarientList![selectedPos]
                                          .availability ==
                                      '0'
                                  ? Container(
                                      height: 55,
                                      color: colors.white70,
                                      padding: const EdgeInsets.all(2),
                                      child: Center(
                                        child: Text(
                                          getTranslated(
                                              context, 'OUT_OF_STOCK_LBL')!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                fontFamily: 'ubuntu',
                                                color: colors.red,
                                                fontWeight: FontWeight.bold,
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
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topRight,
                          child: Column(
                            children: [
                              Text(
                                ' ${DesignConfiguration.getPriceFormat(context, price)!} ',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: textFontSize12,
                                  fontFamily: 'ubuntu',
                                ),
                              ),
                              Text(
                                double.parse(cartList[index]
                                            .productList![0]
                                            .prVarientList![selectedPos]
                                            .disPrice!) !=
                                        0
                                    ? DesignConfiguration.getPriceFormat(
                                        context,
                                        double.parse(cartList[index]
                                            .productList![0]
                                            .prVarientList![selectedPos]
                                            .price!),
                                      )!
                                    : '',
                                style: Theme.of(context)
                                    .textTheme
                                    .overline!
                                    .copyWith(
                                        fontFamily: 'ubuntu',
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: colors.darkColor3,
                                        decorationStyle:
                                            TextDecorationStyle.solid,
                                        fontSize: textFontSize12,
                                        decorationThickness: 2,
                                        letterSpacing: 0.7),
                              ),
                              CUR_USERID == null
                                  ? Text(
                                      'Tax ${cartList[index].productList?.first.tax}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .overline!
                                          .copyWith(
                                              fontFamily: 'ubuntu',
                                              decorationColor:
                                                  colors.darkColor3,
                                              decorationStyle:
                                                  TextDecorationStyle.solid,
                                              fontSize: textFontSize12,
                                              decorationThickness: 2,
                                              letterSpacing: 0.7),
                                    )
                                  : cartList[index].tax_percentage != "0"
                                      ? Text(
                                          'Tax ${cartList[index].tax_percentage}%',
                                          style: Theme.of(context)
                                              .textTheme
                                              .overline!
                                              .copyWith(
                                                  fontFamily: 'ubuntu',
                                                  decorationColor:
                                                      colors.darkColor3,
                                                  decorationStyle:
                                                      TextDecorationStyle.solid,
                                                  fontSize: textFontSize12,
                                                  decorationThickness: 2,
                                                  letterSpacing: 0.7),
                                        )
                                      : SizedBox.shrink(),
                            ],
                          ),
                        ),
                        offPer != null
                            ? GetDicountLabel(discount: double.parse(offPer))
                            : Container(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(top: 5.0),
                                child: Text(
                                  cartList[index].productList![0].name!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .copyWith(
                                        fontFamily: 'ubuntu',
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontSize: textFontSize14,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            cartList[index].productList![0].availability ==
                                        '1' ||
                                    cartList[index].productList![0].stockType ==
                                        ''
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Container(
                                        height: 35,
                                        width: 101,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: colors.blackTemp),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5),
                                          ),
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            cartList[index]
                                                        .productList![0]
                                                        .type ==
                                                    'digital_product'
                                                ? Container()
                                                : InkWell(
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Icon(
                                                        Icons.remove,
                                                        size: 15,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      if (context
                                                              .read<
                                                                  CartProvider>()
                                                              .isProgress ==
                                                          false) {
                                                        if (CUR_USERID !=
                                                            null) {
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .removeFromCart(
                                                                  index: index,
                                                                  remove: false,
                                                                  cartList:
                                                                      cartList,
                                                                  move: false,
                                                                  selPos:
                                                                      selectedPos,
                                                                  context:
                                                                      context,
                                                                  update: widget
                                                                      .callCartApi,
                                                                  promoCode: context
                                                                      .read<
                                                                          CartProvider>()
                                                                      .promoC
                                                                      .text,
                                                                  isRemove:
                                                                      true);
                                                          setSnackbar(
                                                              getTranslated(
                                                                  context,
                                                                  'Minimum Order is Fix')!,
                                                              context);
                                                        } else {
                                                          if ((int.parse(cartList[
                                                                      index]
                                                                  .productList![
                                                                      0]
                                                                  .prVarientList![
                                                                      selectedPos]
                                                                  .cartCount!)) >
                                                              1) {
                                                            context
                                                                .read<
                                                                    CartProvider>()
                                                                .addAndRemoveQty(
                                                                  qty: cartList[
                                                                          index]
                                                                      .productList![
                                                                          0]
                                                                      .prVarientList![
                                                                          selectedPos]
                                                                      .cartCount!,
                                                                  from: 2,
                                                                  totalLen: cartList[
                                                                              index]
                                                                          .productList![
                                                                              0]
                                                                          .itemsCounter!
                                                                          .length *
                                                                      int.parse(cartList[
                                                                              index]
                                                                          .productList![
                                                                              0]
                                                                          .qtyStepSize!),
                                                                  index: index,
                                                                  price: price,
                                                                  selectedPos:
                                                                      selectedPos,
                                                                  total: total,
                                                                  cartList:
                                                                      cartList,
                                                                  itemCounter: int.parse(cartList[
                                                                          index]
                                                                      .productList![
                                                                          0]
                                                                      .qtyStepSize!),
                                                                  context:
                                                                      context,
                                                                  update: widget
                                                                      .callCartApi,
                                                                );
                                                            widget.setState();
                                                          }
                                                        }
                                                      }
                                                    },
                                                  ),
                                            cartList[index]
                                                        .productList![0]
                                                        .type ==
                                                    'digital_product'
                                                ? Container()
                                                : SizedBox(
                                                    width: 37,
                                                    height: 20,
                                                    child: Stack(
                                                      children: [
                                                        TextField(
                                                          textAlign:
                                                              TextAlign.center,
                                                          readOnly: true,
                                                          style: TextStyle(
                                                              fontSize:
                                                                  textFontSize12,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .fontColor),
                                                          controller: context
                                                              .read<
                                                                  CartProvider>()
                                                              .controller[index],
                                                          decoration:
                                                              const InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                          ),
                                                        ),
                                                        PopupMenuButton<String>(
                                                          tooltip: '',
                                                          icon: const Icon(
                                                            Icons
                                                                .arrow_drop_down,
                                                            size: 1,
                                                          ),
                                                          onSelected:
                                                              (String value) {
                                                            if (context
                                                                    .read<
                                                                        CartProvider>()
                                                                    .isProgress ==
                                                                false) {
                                                              if (CUR_USERID !=
                                                                  null) {
                                                                context
                                                                    .read<
                                                                        CartProvider>()
                                                                    .addToCart(
                                                                      index:
                                                                          index,
                                                                      qty:
                                                                          value,
                                                                      cartList:
                                                                          cartList,
                                                                      context:
                                                                          context,
                                                                      update: widget
                                                                          .callCartApi,
                                                                    );
                                                              } else {
                                                                context
                                                                    .read<
                                                                        CartProvider>()
                                                                    .addAndRemoveQty(
                                                                      qty:
                                                                          value,
                                                                      from: 3,
                                                                      totalLen: cartList[index]
                                                                              .productList![
                                                                                  0]
                                                                              .itemsCounter!
                                                                              .length *
                                                                          int.parse(cartList[index]
                                                                              .productList![0]
                                                                              .qtyStepSize!),
                                                                      index:
                                                                          index,
                                                                      price:
                                                                          price,
                                                                      selectedPos:
                                                                          selectedPos,
                                                                      total:
                                                                          total,
                                                                      cartList:
                                                                          cartList,
                                                                      itemCounter: int.parse(cartList[
                                                                              index]
                                                                          .productList![
                                                                              0]
                                                                          .qtyStepSize!),
                                                                      context:
                                                                          context,
                                                                      update: widget
                                                                          .callCartApi,
                                                                    );
                                                              }
                                                            }
                                                          },
                                                          itemBuilder:
                                                              (BuildContext
                                                                  context) {
                                                            return cartList[
                                                                    index]
                                                                .productList![0]
                                                                .itemsCounter!
                                                                .map<
                                                                    PopupMenuItem<
                                                                        String>>(
                                                              (String value) {
                                                                return PopupMenuItem(
                                                                  value: value,
                                                                  child: Text(
                                                                    value,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .fontColor,
                                                                      fontFamily:
                                                                          'ubuntu',
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ).toList();
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                            cartList[index]
                                                        .productList![0]
                                                        .type ==
                                                    'digital_product'
                                                ? Container()
                                                : InkWell(
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 15,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      if (context
                                                              .read<
                                                                  CartProvider>()
                                                              .isProgress ==
                                                          false) {
                                                        if (CUR_USERID !=
                                                            null) {
                                                          context.read<CartProvider>().addToCart(
                                                              index: index,
                                                              qty: (int.parse(cartList[
                                                                              index]
                                                                          .qty!) +
                                                                      int.parse(cartList[
                                                                              index]
                                                                          .productList![
                                                                              0]
                                                                          .qtyStepSize!))
                                                                  .toString(),
                                                              cartList:
                                                                  cartList,
                                                              context: context,
                                                              update:widget.callCartApi);
                                                        } else {
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .addAndRemoveQty(
                                                                qty: cartList[
                                                                        index]
                                                                    .productList![
                                                                        0]
                                                                    .prVarientList![
                                                                        selectedPos]
                                                                    .cartCount!,
                                                                from: 1,
                                                                totalLen: cartList[
                                                                            index]
                                                                        .productList![
                                                                            0]
                                                                        .itemsCounter!
                                                                        .length *
                                                                    int.parse(cartList[
                                                                            index]
                                                                        .productList![
                                                                            0]
                                                                        .qtyStepSize!),
                                                                index: index,
                                                                price: price,
                                                                selectedPos:
                                                                    selectedPos,
                                                                total: total,
                                                                cartList:
                                                                    cartList,
                                                                itemCounter: int
                                                                    .parse(cartList[
                                                                            index]
                                                                        .productList![
                                                                            0]
                                                                        .qtyStepSize!),
                                                                context:
                                                                    context,
                                                                update: widget
                                                                    .setState,
                                                              );
                                                        }
                                                      }
                                                    },
                                                  )
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                        cartList[index]
                                        .productList![0]
                                        .prVarientList![selectedPos]
                                        .attr_name !=
                                    null &&
                                cartList[index]
                                    .productList![0]
                                    .prVarientList![selectedPos]
                                    .attr_name!
                                    .isNotEmpty
                            ? ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: att.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          att[index].trim() + ':',
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .copyWith(
                                                fontFamily: 'ubuntu',
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .lightBlack,
                                              ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 5.0),
                                        child: Text(
                                          val[index],
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .lightBlack,
                                                  fontFamily: 'ubuntu',
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              )
                            : Container(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  ' ${DesignConfiguration.getPriceFormat(context, price)!} ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: textFontSize12,
                                    fontFamily: 'ubuntu',
                                  ),
                                ),
                                InkWell(
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      start: 8.0,
                                      end: 8,
                                      bottom: 8,
                                    ),
                                    child: Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                    ),
                                  ),
                                  onTap: () async {
                                    print("Delete+++++++++++=");
                                    widget.delete();
                                    if (context
                                            .read<CartProvider>()
                                            .isProgress ==
                                        false) {
                                      if (CUR_USERID != null) {
                                        context
                                            .read<CartProvider>()
                                            .removeFromCart(
                                              index: index,
                                              remove: true,
                                              cartList: cartList,
                                              move: false,
                                              selPos: selectedPos,
                                              context: context,
                                              update: widget.setState,
                                              promoCode: context
                                                  .read<CartProvider>()
                                                  .promoC
                                                  .text,
                                            );
                                      } else {
                                        if (singleSellerOrderSystem) {
                                          if (cartList.length == 1) {
                                            context
                                                .read<SettingProvider>()
                                                .setCurrentSellerID('');
                                            CurrentSellerID = '';
                                          }
                                        }
                                        db.removeCart(
                                            cartList[index]
                                                .productList![0]
                                                .prVarientList![selectedPos]
                                                .id!,
                                            cartList[index].id!,
                                            context);
                                        cartList.removeWhere((item) =>
                                            item.varientId ==
                                            cartList[index].varientId);
                                        context.read<CartProvider>().oriPrice =
                                            context
                                                    .read<CartProvider>()
                                                    .oriPrice -
                                                total;
                                        context
                                            .read<CartProvider>()
                                            .productIds = (await db.getCart())!;

                                        widget.setState();
                                      }
                                    }
                                  },
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          // Positioned.directional(
          //   textDirection: Directionality.of(context),
          //   end: 5,
          //   bottom: 12,
          //   child: Card(
          //     elevation: 1,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(circularBorderRadius50),
          //     ),
          //     child: InkWell(
          //       onTap: () {
          //         if (singleSellerOrderSystem) {
          //           if (cartList.length == 1) {
          //             context.read<SettingProvider>().setCurrentSellerID('');
          //             CurrentSellerID = '';
          //           }
          //         }
          //         if (!context.read<CartProvider>().saveLater &&
          //             !context.read<CartProvider>().isProgress) {
          //           if (CUR_USERID != null) {
          //             context.read<CartProvider>().saveLater = true;
          //             widget.setState();
          //             context.read<CartProvider>().saveForLater(
          //                   update: widget.setState,
          //                   fromSave: false,
          //                   id: cartList[index].productList![0].availability ==
          //                           '0'
          //                       ? cartList[index]
          //                           .productList![0]
          //                           .prVarientList![selectedPos]
          //                           .id!
          //                       : cartList[index].varientId,
          //                   price: double.parse(cartList[index].perItemTotal!),
          //                   context: context,
          //                   qty: cartList[index].productList![0].availability ==
          //                           '0'
          //                       ? '1'
          //                       : cartList[index].qty,
          //                   save: '1',
          //                   curItem: cartList[index],
          //                   promoCode: context.read<CartProvider>().promoC.text,
          //                 );
          //           } else {
          //             () async {
          //               context.read<CartProvider>().saveLater = true;
          //               context.read<CartProvider>().setProgress(true);
          //               await widget.saveForLatter(
          //                 index: index,
          //                 selectedPos: selectedPos,
          //                 total: total,
          //                 cartList: cartList,
          //               );
          //             }();
          //           }
          //         } else {}
          //       },
          //       child: const Padding(
          //         padding: EdgeInsets.all(8.0),
          //         child: Icon(
          //           Icons.archive_rounded,
          //           size: 50,
          //         ),
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
