import 'dart:io';

import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Helper/routes.dart';
import '../../../Model/Order_Model.dart';
import '../../../Provider/Order/UpdateOrderProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/snackbar.dart';
import 'BottomSheetWidget.dart';
import 'OrderStatusData.dart';

class ProductItemWidget extends StatefulWidget {
  OrderItem orderItem;
  OrderModel model;
  String id;
  Function updateNow;

  ProductItemWidget({
    Key? key,
    required this.id,
    required this.model,
    required this.orderItem,
    required this.updateNow,
  }) : super(key: key);

  @override
  State<ProductItemWidget> createState() => _ProductItemWidgetState();
}

class _ProductItemWidgetState extends State<ProductItemWidget> {
  String filePath = '';

  setSanckBarNow(String msg) {
    setSnackbar(msg, context);
    context.read<UpdateOrdProvider>().reviewPhotos.clear();
    context.read<UpdateOrdProvider>().changeStatus(UpdateOrdStatus.isSuccsess);
  }

  @override
  Widget build(BuildContext context) {
    String? pDate, prDate, sDate, dDate, cDate, rDate, aDate;

    if (widget.orderItem.listStatus!.contains(WAITING)) {
      aDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(WAITING)];
    }
    if (widget.orderItem.listStatus!.contains(PLACED)) {
      pDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(PLACED)];
    }
    if (widget.orderItem.listStatus!.contains(PROCESSED)) {
      prDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(PROCESSED)];
    }
    if (widget.orderItem.listStatus!.contains(SHIPED)) {
      sDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(SHIPED)];
    }
    if (widget.orderItem.listStatus!.contains(DELIVERD)) {
      dDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(DELIVERD)];
    }
    if (widget.orderItem.listStatus!.contains(CANCLED)) {
      cDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(CANCLED)];
    }
    if (widget.orderItem.listStatus!.contains(RETURNED)) {
      rDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(RETURNED)];
    }
    List att = [], val = [];
    if (widget.orderItem.attr_name!.isNotEmpty) {
      att = widget.orderItem.attr_name!.split(',');
      val = widget.orderItem.varient_values!.split(',');
    }
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(circularBorderRadius7),
                  child: DesignConfiguration.getCacheNotworkImage(
                    boxFit: BoxFit.cover,
                    context: context,
                    heightvalue: 90.0,
                    widthvalue: 90.0,
                    imageurlString: widget.orderItem.image!,
                    placeHolderSize: 90,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.orderItem.name??"",
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.lightBlack,
                                  fontWeight: FontWeight.normal),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        widget.orderItem.attr_name!.isNotEmpty
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
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .lightBlack2),
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
                                              ),
                                        ),
                                      )
                                    ],
                                  );
                                },
                              )
                            : Container(),
                        Row(
                          children: [
                            Text(
                              '${getTranslated(context, 'QUANTITY_LBL')!}:',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack2),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 5.0),
                              child: Text(
                                widget.orderItem.qty!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack,
                                    ),
                              ),
                            )
                          ],
                        ),
                        Text(
                          DesignConfiguration.getPriceFormat(
                              context, double.parse(widget.orderItem.price!))!,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.blue),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Divider(
              color: Theme.of(context).colorScheme.lightBlack,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  pDate != null
                      ? getPlaced(pDate, context)
                      : getPlaced(aDate ?? '', context),
                  widget.orderItem.productType == 'digital_product'
                      ? Container()
                      : getProcessed(prDate, cDate, context),
                  widget.orderItem.productType == 'digital_product'
                      ? Container()
                      : getShipped(sDate, cDate, context),
                  widget.orderItem.productType == 'digital_product'
                      ? Container()
                      : getDelivered(dDate, cDate, context),
                  widget.orderItem.productType == 'digital_product'
                      ? widget.orderItem.downloadAllowed == '1'
                          ? cDate == null
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          child: VerticalDivider(
                                            thickness: 2,
                                            color: dDate == null
                                                ? Colors.grey
                                                : colors.primary,
                                          ),
                                        ),
                                        Icon(
                                          Icons.circle,
                                          color: dDate == null
                                              ? Colors.grey
                                              : colors.primary,
                                          size: 15,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsetsDirectional.only(
                                          start: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            getTranslated(
                                                context, 'ORDER_DELIVERED')!,
                                            style: const TextStyle(
                                                fontSize: textFontSize8),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            dDate ?? ' ',
                                            style: const TextStyle(
                                                fontSize: textFontSize8),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Container()
                          : Container()
                      : Container(),
                  widget.orderItem.productType == 'digital_product'
                      ? widget.orderItem.downloadAllowed != '1'
                          ? cDate == null
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          child: VerticalDivider(
                                            thickness: 2,
                                            color: dDate == null
                                                ? Colors.grey
                                                : colors.primary,
                                          ),
                                        ),
                                        Icon(
                                          Icons.circle,
                                          color: dDate == null
                                              ? Colors.grey
                                              : colors.primary,
                                          size: 15,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsetsDirectional.only(
                                          start: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            getTranslated(
                                                context, 'ORDER_DELIVERED')!,
                                            style: const TextStyle(
                                                fontSize: textFontSize8),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            dDate ?? ' ',
                                            style: const TextStyle(
                                                fontSize: textFontSize8),
                                            textAlign: TextAlign.center,
                                          ),
                                          const Text(
                                            'Please check your Mail for instruction',
                                            style: TextStyle(
                                                fontSize: textFontSize8),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Container()
                          : Container()
                      : Container(),
                  getCanceled(cDate, context),
                  getReturned(widget.orderItem, rDate, widget.model, context),
                ],
              ),
            ),
            widget.orderItem.downloadAllowed == '1'
                ? downloadProductFile(context, widget.orderItem.id!)
                : Container(),
            Divider(
              color: Theme.of(context).colorScheme.lightBlack,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${getTranslated(context, "STORE_NAME")!} : ",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.lightBlack,
                            fontWeight: FontWeight.bold),
                      ),
                      // Text(
                      //   "${getTranslated(context, "OTP")!} : ",
                      //   style: TextStyle(
                      //       color: Theme.of(context).colorScheme.lightBlack,
                      //       fontWeight: FontWeight.bold),
                      // ),
                      widget.orderItem.courier_agency! != ''
                          ? Text(
                              "${getTranslated(context, 'COURIER_AGENCY')!}: ",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.lightBlack,
                                  fontWeight: FontWeight.bold),
                            )
                          : Container(),
                      widget.orderItem.tracking_id! != ''
                          ? Text(
                              "${getTranslated(context, 'TRACKING_ID')!}: ",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.lightBlack,
                                  fontWeight: FontWeight.bold),
                            )
                          : Container(),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        child: Text(
                          '${widget.orderItem.store_name}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.lightBlack2,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () {
                          Routes.navigateToSellerProfileScreen(
                            context,
                            widget.orderItem.seller_id,
                            widget.orderItem.seller_profile,
                            widget.orderItem.seller_name,
                            widget.orderItem.seller_rating,
                            widget.orderItem.seller_name,
                            widget.orderItem.store_description,
                            '0',
                          );
                        },
                      ),
                      // Text(
                      //   '${widget.orderItem.item_otp} ',
                      //   style: TextStyle(
                      //     color: Theme.of(context).colorScheme.lightBlack2,
                      //   ),
                      // ),
                      widget.orderItem.courier_agency! != ''
                          ? Text(
                              widget.orderItem.courier_agency!,
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.lightBlack2,
                              ),
                            )
                          : Container(),
                          widget.orderItem.tracking_id! != ''
                          ? RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: widget.orderItem.tracking_id!,
                                    style: const TextStyle(
                                        color: colors.primary,
                                        decoration: TextDecoration.underline),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        var url =
                                            '${widget.orderItem.tracking_url}';

                                        if (await canLaunchUrlString(url)) {
                                          await launchUrlString(url);
                                        } else {
                                          setSnackbar(
                                              getTranslated(
                                                  context, 'URL_ERROR')!,
                                              context);
                                        }
                                      },
                                  )
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            widget.orderItem.status=='cancelled' ? Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Message : ",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.lightBlack,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Cancel by:',
                        style: TextStyle(
                            color:
                            Theme.of(context).colorScheme.lightBlack,
                            fontWeight: FontWeight.bold),
                      )

                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.orderItem.cancelReason}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.lightBlack2,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      Text(
                        '${widget.orderItem.cancelIdentity} ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.lightBlack2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ) : SizedBox(),
            Consumer<UpdateOrdProvider>(
              builder: (context, value, child) {
                return Container(
                  padding: const EdgeInsetsDirectional.only(
                    start: 20.0,
                    end: 20.0,
                    top: 5,
                  ),
                  height: value.files.isNotEmpty ? 180 : 0,
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: value.files.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, i) {
                            return InkWell(
                              child: Stack(
                                alignment: AlignmentDirectional.topEnd,
                                children: [
                                  Image.file(
                                    value.files[i],
                                    width: 180,
                                    height: 180,
                                  ),
                                  Container(
                                    color:
                                        Theme.of(context).colorScheme.black26,
                                    child: const Icon(
                                      Icons.clear,
                                      size: 15,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                value.files.removeAt(i);
                              },
                            );
                          },
                        ),
                      ),
                      InkWell(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.lightWhite,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(circularBorderRadius4),
                            ),
                          ),
                          child: Text(
                            getTranslated(context, 'SUBMIT_LBL')!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.fontColor),
                          ),
                        ),
                        onTap: () {
                          Future.delayed(Duration.zero).then(
                            (value) => context
                                .read<UpdateOrdProvider>()
                                .sendBankProof(widget.id, context),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.orderItem.status == DELIVERD)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        openBottomSheet(
                          context,
                          widget.orderItem,
                          setSanckBarNow,
                        );
                      },
                      icon: const Icon(Icons.rate_review_outlined,
                          color: colors.primary),
                      label: Text(
                        widget.orderItem.userReviewRating != '0'
                            ? getTranslated(context, 'UPDATE_REVIEW_LBL')!
                            : getTranslated(context, 'WRITE_REVIEW_LBL')!,
                        style: const TextStyle(color: colors.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.btnColor),
                      ),
                    ),
                  ),
                widget.orderItem.cancelIdentity == "user"?
                Row(
                  children: [
                    Text("Wait For Admin Approval", style: TextStyle(color: Colors.red),),
                  ],
                ):
                Text(""),

                if (!widget.orderItem.listStatus!.contains(DELIVERD) &&
                    (!widget.orderItem.listStatus!.contains(RETURNED)) &&
                    widget.orderItem.isCancle == '1' &&
                    widget.orderItem.isAlrCancelled == '0')
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: OutlinedButton(
                        onPressed: /*context
                                .read<UpdateOrdProvider>()
                                .isReturnClick
                            ?*/ () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        getTranslated(
                                            context, 'ARE_YOU_SURE?')!,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .fontColor),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                        Text(
                                          getTranslated(context,
                                              'Would you like to cancel this product?')!,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .fontColor,
                                          ),
                                        ),
                                          cancelReasonField()
                                      ],),
                                      actions: [
                                        TextButton(
                                          child: Text(
                                            getTranslated(context, 'YES')!,
                                            style: const TextStyle(
                                                color: colors.primary),
                                          ),
                                          onPressed: () {
                                            if(cancelReasonController.text.isNotEmpty) {
                                              Routes.pop(context);
                                              // Navigator.pop(context);
                                              context
                                                  .read<UpdateOrdProvider>()
                                                  .isReturnClick = false;
                                              /*context
                                                  .read<UpdateOrdProvider>()
                                                  .changeStatus(UpdateOrdStatus
                                                      .inProgress);*/
                                              /*setSnackbar(
                                                  getTranslated(context,
                                                      'Status Updated Successfully')!,
                                                  context);*/
                                              Future.delayed(Duration.zero).then(
                                                (value) => context.read<UpdateOrdProvider>().cancelOrder(widget.orderItem.id!, updateOrderItemApi,
                                                    CANCLED, context,msg: cancelReasonController.text).then((value) {}),
                                              );
                                              Navigator.pop(context);
                                            }
                                            else{
                                              setSnackbar('Please enter cancel reason!', context);
                                            }
                                          },
                                        ),
                                        TextButton(
                                          child: Text(
                                            getTranslated(context, 'NO')!,
                                            style: const TextStyle(color: colors.primary)),
                                          onPressed: () {
                                            Routes.pop(context);
                                          },
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                           // : null,
                        child: Text(
                          getTranslated(context, 'ITEM_CANCEL')!,
                        ),
                      ),
                    ),
                  )
                else
                  (widget.orderItem.listStatus!.contains(DELIVERD) &&
                          widget.orderItem.isReturn == '1' &&
                          widget.orderItem.isAlrReturned == '0' && widget.orderItem.status != 'return_request_approved' && widget.orderItem.status != 'return_request_pending')
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: OutlinedButton(
                            onPressed:/* context
                                    .read<UpdateOrdProvider>()
                                    .isReturnClick
                                ?*/ () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            getTranslated(
                                                context, 'ARE_YOU_SURE?')!,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .fontColor),
                                          ),
                                          content: Text(
                                            getTranslated(context,
                                                'Would you like to cancel this product?')!,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .fontColor),
                                          ),
                                          actions: [
                                            TextButton(
                                              child: Text(
                                                getTranslated(context, 'YES')!,
                                                style: const TextStyle(
                                                    color: colors.primary),
                                              ),
                                              onPressed: () {
                                                Routes.pop(context);

                                                context
                                                    .read<UpdateOrdProvider>()
                                                    .isReturnClick = false;
                                                context
                                                    .read<UpdateOrdProvider>()
                                                    .changeStatus(
                                                        UpdateOrdStatus
                                                            .inProgress);

                                                Future.delayed(Duration.zero).then(
                                                  (value) => context.read<UpdateOrdProvider>().cancelOrder(widget.orderItem.id!, updateOrderItemApi, RETURNED, context,),
                                                );
                                              },
                                            ),
                                            TextButton(
                                              child: Text(
                                                getTranslated(context, 'NO')!,
                                                style: const TextStyle(
                                                    color: colors.primary),
                                              ),
                                              onPressed: () {
                                                Routes.pop(context);
                                              },
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                //: null,
                            child: Text(getTranslated(context, 'ITEM_RETURN')!),
                          ),
                        )
                      : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }
TextEditingController cancelReasonController = TextEditingController();
 Widget cancelReasonField() {
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
          maxLines: 4,
          style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: textFontSize13),
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.words,
          controller: cancelReasonController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 5,
              ),
              hintText: 'Cancel Reason',
              hintStyle: TextStyle(
                  color:
                  Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  fontSize: textFontSize13),
              fillColor: Theme.of(context).colorScheme.lightWhite,
              border: InputBorder.none),
        ),
      ),
    );
  }


  Future<bool> Checkpermission(AsyncSnapshot snapshot) async {
    var status = await Permission.storage.status;

    if (status != PermissionStatus.granted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();

      if (statuses[Permission.storage] == PermissionStatus.granted) {
        FileDirectoryPrepare(snapshot);
        return true;
      }
    } else {
      FileDirectoryPrepare(snapshot);
      return true;
    }
    return false;
  }

  Future<void> FileDirectoryPrepare(AsyncSnapshot snapshot) async {
    if (Platform.isIOS) {
      Directory target = await getApplicationDocumentsDirectory();
      filePath = target.path.toString();
    } else {
      if (snapshot.hasData) {
        filePath = (snapshot.data as List<Directory>).first.path;
      }
    }
  }

  downloadProductFile(BuildContext context, String orderiteamID) {
    return FutureBuilder<List<Directory>?>(
      future: context.read<UpdateOrdProvider>().externalStorageDirectories,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  context
                      .read<UpdateOrdProvider>()
                      .getDownloadLink(
                        context,
                        orderiteamID,
                      )
                      .then(
                    (value) async {
                      if (!value) {
                        if (context
                                .read<UpdateOrdProvider>()
                                .currentLinkForDownload !=
                            '') {
                          context
                              .read<UpdateOrdProvider>()
                              .changeStatus(UpdateOrdStatus.inProgress);
                          bool checkpermission =
                              await Checkpermission(snapshot);
                          if (checkpermission) {
                            if (Platform.isIOS) {
                              Directory target =
                                  await getApplicationDocumentsDirectory();
                              filePath = target.path.toString();
                            } else {
                              final _externalDirectory =
                                  await getExternalStorageDirectory();
                              var dir = await Directory(
                                      '${_externalDirectory!.path}/Download')
                                  .create();
                              if (snapshot.hasData) {
                                filePath = dir.path;
                                // snapshot.data!
                                //     .map((Directory d) => d.path)
                                //     .join(', ');
                              }
                            }
                            String fileName = context
                                .read<UpdateOrdProvider>()
                                .currentLinkForDownload
                                .substring(context
                                        .read<UpdateOrdProvider>()
                                        .currentLinkForDownload
                                        .lastIndexOf('/') +
                                    1);
                            File file = File('${filePath}/$fileName');
                            bool hasExisted = await file.exists();
                            if (hasExisted) {
                              final openFile =
                                  await OpenFilex.open('${filePath}/$fileName');
                            }
                            setSnackbar(getTranslated(context, 'Downloading')!,
                                context);
                            final taskid = await FlutterDownloader.enqueue(
                              url: context
                                  .read<UpdateOrdProvider>()
                                  .currentLinkForDownload,
                              savedDir: filePath,
                              headers: {'auth': 'test_for_sql_encoding'},
                              showNotification: true,
                              openFileFromNotification: true,
                            ).onError((error, stackTrace) {
                              context
                                  .read<UpdateOrdProvider>()
                                  .changeStatus(UpdateOrdStatus.isSuccsess);
                              setSnackbar('Error : $error', context);
                            }).catchError((error, stackTrace) {
                              context
                                  .read<UpdateOrdProvider>()
                                  .changeStatus(UpdateOrdStatus.isSuccsess);
                            }).whenComplete(() {
                              context
                                  .read<UpdateOrdProvider>()
                                  .changeStatus(UpdateOrdStatus.isSuccsess);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Open Downloaded File',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .black),
                                  ),
                                  action: SnackBarAction(
                                    label: getTranslated(context, 'VIEW')!,
                                    textColor:
                                        Theme.of(context).colorScheme.fontColor,
                                    onPressed: () async {
                                      await OpenFilex.open(filePath);
                                    },
                                  ),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.white,
                                  elevation: 1.0,
                                ),
                              );
                              context
                                  .read<UpdateOrdProvider>()
                                  .cancelOrder(
                                    widget.orderItem.id!,
                                    updateOrderItemApi,
                                    'delivered',
                                    context,
                                  )
                                  .then(
                                    (value) {},
                                  );
                            });
                          } else {
                            context
                                .read<UpdateOrdProvider>()
                                .changeStatus(UpdateOrdStatus.isSuccsess);
                            setSnackbar('permission is not given for download.',
                                context);
                          }
                        } else {
                          setSnackbar(
                              'something wrong file is not available yet .',
                              context);
                        }
                      }
                    },
                  );
                },
                icon: const Icon(Icons.download, color: colors.primary),
                label: const Text(
                  'Download',
                  style: TextStyle(color: colors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  side:
                      BorderSide(color: Theme.of(context).colorScheme.btnColor),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
