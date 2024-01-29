import 'dart:io';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/routes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../Helper/Constant.dart';
import '../../../Model/Order_Model.dart';
import '../../../Provider/Order/UpdateOrderProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/snackbar.dart';
import 'OrderTrackDataSheet.dart';
import 'SingleProduct.dart';

class GetOrderDetails extends StatelessWidget {
  OrderModel model;
  ScrollController controller;
  Future<List<Directory>?>? externalStorageDirectories;
  Function updateNow;
  GetOrderDetails({
    Key? key,
    this.externalStorageDirectories,
    required this.controller,
    required this.updateNow,
    required this.model,
  }) : super(key: key);

  priceDetails(BuildContext context, OrderModel model) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Text(
                getTranslated(context, 'PRICE_DETAIL')!,
                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Divider(
              color: Theme.of(context).colorScheme.lightBlack,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${getTranslated(context, 'PRICE_LBL')!} :",
                    style: Theme.of(context).textTheme.button!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack2,
                        ),
                  ),
                  Text(
                    ' ${DesignConfiguration.getPriceFormat(context, double.parse(model.subTotal!))!}',
                    style: Theme.of(context).textTheme.button!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack2,
                        ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${getTranslated(context, 'TAX_AMOUNT')!} :",
                      style: Theme.of(context).textTheme.button!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack2)),
                  model.taxAmount == '' || model.taxAmount==null ? Text(
                    ' ${DesignConfiguration.getPriceFormat(context, double.parse('0.0'))}',
                    style: Theme.of(context).textTheme.button!.copyWith(
                      color: Theme.of(context).colorScheme.lightBlack2,
                    ),
                  ) :Text(
                    ' ${DesignConfiguration.getPriceFormat(context, double.parse(model.taxAmount!))!}',
                    style: Theme.of(context).textTheme.button!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack2,
                        ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${getTranslated(context, 'DELIVERY_CHARGE')!} :',
                      style: Theme.of(context).textTheme.button!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack2)),
                  Text(
                      '+${DesignConfiguration.getPriceFormat(context, double.parse(model.delCharge!))!}',
                      style: Theme.of(context).textTheme.button!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack2))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${getTranslated(context, 'PROMO_CODE_DIS_LBL')!} :',
                      style: Theme.of(context).textTheme.button!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack2)),
                  Text(
                      '-${DesignConfiguration.getPriceFormat(context, double.parse(model.promoDis!))!}',
                      style: Theme.of(context).textTheme.button!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack2))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${getTranslated(context, 'WALLET_BAL')!} :',
                    style: Theme.of(context).textTheme.button!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack2,
                        ),
                  ),
                  Text(
                    '-${DesignConfiguration.getPriceFormat(context, double.parse(model.walBal!))!}',
                    style: Theme.of(context).textTheme.button!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack2,
                        ),
                  )
                ],
              ),
            ),

            // Padding(
            //   padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text(
            //         //'${getTranslated(context, 'WALLET_BAL')!} :',
            //         'Advance Amount:',
            //         style: Theme.of(context).textTheme.button!.copyWith(
            //           color: Theme.of(context).colorScheme.lightBlack2,
            //         ),
            //       ),
            //       Text(
            //         '${DesignConfiguration.getPriceFormat(context, double.parse(model.advanceAmt!))!}',
            //         style: Theme.of(context).textTheme.button!.copyWith(
            //           color: Theme.of(context).colorScheme.lightBlack2,
            //         ),
            //       )
            //     ],
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text(
            //         //'${getTranslated(context, 'WALLET_BAL')!} :',
            //         'Remaining Amount:',
            //         style: Theme.of(context).textTheme.button!.copyWith(
            //           color: Theme.of(context).colorScheme.lightBlack2,
            //         ),
            //       ),
            //       Text(
            //         '${DesignConfiguration.getPriceFormat(context, double.parse(model.remaingAmt!))!}',
            //         style: Theme.of(context).textTheme.button!.copyWith(
            //           color: Theme.of(context).colorScheme.lightBlack2,
            //         ),
            //       )
            //     ],
            //   ),
            // ),

            Padding(
              padding: const EdgeInsetsDirectional.only(
                  start: 15.0, end: 15.0, top: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${getTranslated(context, 'PAYABLE')!} :',
                    style: Theme.of(context).textTheme.button!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack,
                        ),
                  ),
                  Text(
                    DesignConfiguration.getPriceFormat(
                        context, double.parse(model.payable!))!,
                    style: Theme.of(context).textTheme.button!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack,
                        ),
                  ),
                ],
              ),
            ),


            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 15.0,
                end: 15.0,
                top: 5.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${getTranslated(context, 'TOTAL_PRICE')!} :',
                      style: Theme.of(context).textTheme.button!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack,
                          fontWeight: FontWeight.bold)),
                  Text(
                    DesignConfiguration.getPriceFormat(
                      context,
                      double.parse(model.total!),
                    )!,
                    style: Theme.of(context).textTheme.button!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack,
                          fontWeight: FontWeight.bold,
                        ),
                  )
                ],
              ),
            ),

            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    //'${getTranslated(context, 'WALLET_BAL')!} :',
                    'Advance Amount:',
                    style: Theme.of(context).textTheme.button!.copyWith(
                      color: Theme.of(context).colorScheme.lightBlack2,
                    ),
                  ),
                  Text(
                    '${DesignConfiguration.getPriceFormat(context, double.parse(model.advanceAmt!))!}',
                    style: Theme.of(context).textTheme.button!.copyWith(
                      color: Theme.of(context).colorScheme.lightBlack2,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    //'${getTranslated(context, 'WALLET_BAL')!} :',
                    'Remaining Amount:',
                    style: Theme.of(context).textTheme.button!.copyWith(
                      color: Theme.of(context).colorScheme.lightBlack2,
                    ),
                  ),
                  Text(
                    '${DesignConfiguration.getPriceFormat(context, double.parse(model.remaingAmt!))!}',
                    style: Theme.of(context).textTheme.button!.copyWith(
                      color: Theme.of(context).colorScheme.lightBlack2,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _imgFromGallery(BuildContext context) async {
    var result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      context.read<UpdateOrdProvider>().files =
          result.paths.map((path) => File(path!)).toList();
      updateNow();
    } else {
      // User canceled the picker
    }
  }

  bankProof(OrderModel model) {
    String status = model.attachList![0].bankTranStatus!;
    Color clr;
    if (status == '0') {
      status = 'Pending';
      clr = Colors.cyan;
    } else if (status == '1') {
      status = 'Rejected';
      clr = Colors.red;
    } else {
      status = 'Accepted';
      clr = Colors.green;
    }

    return Card(
      elevation: 0,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: model.attachList!.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      child: Text(
                        '${getTranslated(context, 'Attachment')} ${i + 1}',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                      onTap: () {
                        _launchURL(
                          model.attachList![i].attachment!,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: clr,
              borderRadius: BorderRadius.circular(circularBorderRadius5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(status),
            ),
          )
        ],
      ),
    );
  }

  void _launchURL(String url) async => await canLaunchUrlString(url)
      ? await launchUrlString(url)
      : throw 'Could not launch $url';
bool isvisible = true ;
String? itemIdies ;
List <String> itemIdList = [] ;
  shippingDetails(BuildContext context, OrderModel model) {
    model.itemList?.forEach((element) {
      if(element.status == 'received' || element.status == 'processed' || element.status == 'shipped' || element.status == 'cancelled' || element.status == 'returned' || element.status== 'return_request_pending' || element.status== 'return_request_approved' ){
        isvisible = false ;
      }

      itemIdList.add(element.id ?? '');
    });
    itemIdies = itemIdList.join(',');
    return  Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
                child: Text(
                  getTranslated(context, 'SHIPPING_DETAIL')!,
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              isvisible ? Padding(
                padding: const EdgeInsets.only(right: 8.0),
                 child: Align(
                  alignment: Alignment.bottomRight,
                  child: OutlinedButton(
                    onPressed: () {
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
                                  'Would you like to return all these product?')!,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .fontColor,
                              ),
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
                                      .isReturnClick = true;
                                  context
                                      .read<UpdateOrdProvider>()
                                      .changeStatus(
                                      UpdateOrdStatus.inProgress);
                                  setSnackbar(
                                      getTranslated(context,
                                          'Status Updated Successfully')!,
                                      context);
                                  Future.delayed(Duration.zero).then(
                                        (value) => context
                                        .read<UpdateOrdProvider>()
                                        .cancelOrder(
                                        /*model.itemList?.first.id ??'',*/itemIdies ?? '',
                                        updateOrderItemApi,
                                        RETURNED,
                                        context)
                                        .then(
                                          (value) {},
                                    ),
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

                    child: const Text("Return All"),
                  ),
                ),
              ) : SizedBox.shrink()
            ],),
            Divider(
              color: Theme.of(context).colorScheme.lightBlack,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Text(
                model.userAddressName ?? '' ',',
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Text(
                model.address!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.lightBlack2,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Text(
                model.mobile!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.lightBlack2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  dwnInvoice(
    Future<List<Directory>?>? _externalStorageDirectories,
    OrderModel model,
    Function update,
  ) {
    //print('_____surendra______${model.invoice}______${model.id}____');
   // print('____ssssss_______${model.id}_________');
    return FutureBuilder<List<Directory>?>(
      future: _externalStorageDirectories,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Card(
          elevation: 0,
          child: InkWell(
            child: ListTile(
              dense: true,
              trailing: const Icon(
                Icons.keyboard_arrow_right,
                color: colors.primary,
              ),
              leading: const Icon(
                Icons.receipt,
                color: colors.primary,
              ),
              title: Text(
                getTranslated(context, 'DWNLD_INVOICE')!,
                style: Theme.of(context)
                    .textTheme
                    .subtitle2!
                    .copyWith(color: Theme.of(context).colorScheme.lightBlack),
              ),
            ),
            onTap: () async {
              Directory? directory ;
              final status = await Permission.storage.request();
              if (status == PermissionStatus.granted) {
                context
                    .read<UpdateOrdProvider>()
                    .changeStatus(UpdateOrdStatus.inProgress);
                updateNow();
              }
              var targetPath;

              if (Platform.isIOS) {
                var target = await getApplicationDocumentsDirectory();
                targetPath = target.path.toString();
              } else {
                directory = Directory('/storage/emulated/0/Download');
                if (!await directory.exists()) directory = await getExternalStorageDirectory();
                /*if (snapshot.hasData) {

                  targetPath = (snapshot.data as List<Directory>).first.path;
                  print('___________${targetPath}__________');

                }*/
              }
              var targetFileName = 'Invoice_${model.id!}';
              var generatedPdfFile, filePath;
              try {
                generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
                    model.invoice ?? '<br>NO DATA</br>', directory?.path ?? '', targetFileName);
                filePath = generatedPdfFile.path;
              } catch (e) {
                context
                    .read<UpdateOrdProvider>()
                    .changeStatus(UpdateOrdStatus.inProgress);
                updateNow();
                setSnackbar(getTranslated(context, "somethingMSg")!, context);
                return;
              }
              context
                  .read<UpdateOrdProvider>()
                  .changeStatus(UpdateOrdStatus.isSuccsess);
              updateNow();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "${getTranslated(context, 'INVOICE_PATH')} $targetFileName",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.black),
                  ),
                  action: SnackBarAction(
                    label: getTranslated(context, 'VIEW')!,
                    textColor: Theme.of(context).colorScheme.fontColor,
                    onPressed: () async {
                      await OpenFilex.open(filePath);
                    },
                  ),
                  backgroundColor: Theme.of(context).colorScheme.white,
                  elevation: 1.0,
                ),
              );
            },
          ),
        );
      },
    );
  }


Widget trackYourOrder (BuildContext context) {
    return Card(child: InkWell(
      onTap: (){
showBottomSheet(context: context, builder: (context) => OrderTrackDataBottomSheet(awb: '1057847214' ),);
    },child: ListTile(
      dense: true,
      trailing: const Icon(
        Icons.keyboard_arrow_right,
        color: colors.primary,
      ),
      leading: const Icon(
        Icons.traffic_outlined,
        color: colors.primary,
      ),
      title: Text(
        getTranslated(context, 'TRACK_ORDER')!,
        style: Theme.of(context)
            .textTheme
            .subtitle2!
            .copyWith(color: Theme.of(context).colorScheme.lightBlack),
      ),
    ),),);
}

  bankTransfer(OrderModel model, BuildContext context, String id) {
    return model.payMethod == 'Bank Transfer'
        ? Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getTranslated(context, 'BANKRECEIPT')!,
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack),
                      ),
                      SizedBox(
                        height: 30,
                        child: IconButton(
                          icon: const Icon(
                            Icons.add_photo_alternate,
                            color: colors.primary,
                            size: 20.0,
                          ),
                          onPressed: () {
                            _imgFromGallery(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  model.attachList!.isNotEmpty ? bankProof(model) : Container(),
                  Consumer<UpdateOrdProvider>(builder: (context, value, child) {
                    return Container(
                      padding: const EdgeInsetsDirectional.only(
                          start: 20.0, end: 20.0, top: 5),
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .black26,
                                        child: const Icon(
                                          Icons.clear,
                                          size: 15,
                                        ),
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    value.files.removeAt(i);
                                    updateNow();
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
                                  Radius.circular(
                                    circularBorderRadius4,
                                  ),
                                ),
                              ),
                              child: Text(
                                getTranslated(context, 'SUBMIT_LBL')!,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .fontColor),
                              ),
                            ),
                            onTap: () {
                              Future.delayed(Duration.zero).then(
                                (value) => context
                                    .read<UpdateOrdProvider>()
                                    .sendBankProof(id, context),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  })
                ],
              ),
            ),
          )
        : Container();
  }

  showNote(OrderModel model, BuildContext context) {
    return model.note! != ''
        ? SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${getTranslated(context, 'NOTE')}:",
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack2)),
                    Text(model.note!,
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack2)),
                  ],
                ),
              ),
            ),
          )
        : const SizedBox();
  }

  Widget getOrderNoAndOTPDetails(OrderModel model, BuildContext context) {
    return Card(
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${getTranslated(context, "ORDER_ID_LBL")!} - ${model.id}",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2),
                ),
                Text(
                  '${model.dateTime}',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2),
                )
              ],
            ),
            model.otp != null && model.otp!.isNotEmpty && model.otp != '0'
                ? Text(
                    "${getTranslated(context, "OTP")!} - ${model.otp}",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.lightBlack2),
                  )
                : Container(),
            Text(
              'Email - ${model.email}',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.lightBlack2),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            getOrderNoAndOTPDetails(model, context),
            model.delDate != null && model.delDate!.isNotEmpty
                ? Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "${getTranslated(context, 'PREFER_DATE_TIME')!}: ${model.delDate!} - ${model.delTime!}",
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack2),
                      ),
                    ),
                  )
                : Container(),

            showNote(model, context),
            bankTransfer(model, context, model.id!),
            GetSingleProduct(
              model: model,
              activeStatus: '',
              id: model.id!,
              updateNow: updateNow,
            ),
            dwnInvoice(
              externalStorageDirectories,
              model,
              updateNow,
            ),
            trackYourOrder(context,),
            model.itemList![0].productType != 'digital_product'
                ? shippingDetails(
                    context,
                    model,
                  )
                : Container(),
            priceDetails(
              context,
              model,
            ),
          ],
        ),
      ),
    );
  }
}
