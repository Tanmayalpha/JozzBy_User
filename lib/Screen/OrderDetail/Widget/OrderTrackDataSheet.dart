import 'dart:developer';

import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Provider/Order/TrackOrderProvider.dart';
import 'package:eshop_multivendor/repository/Order/OrderRepository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class OrderTrackDataBottomSheet extends StatefulWidget {
  const OrderTrackDataBottomSheet({Key? key, this.awb}) : super(key: key);

  final String? awb ;

  @override
  State<OrderTrackDataBottomSheet> createState() => _OrderTrackDataBottomSheetState();
}

class _OrderTrackDataBottomSheetState extends State<OrderTrackDataBottomSheet> {
  Map<String, dynamic>? data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("____________________${widget.awb}_______");
    getTrackData(widget.awb ?? '').then((parsedData) {
      setState(() {
        data = parsedData;
      });
    }).catchError((error) {
      print('Error: $error');
    });
  }
  Widget build(BuildContext context) {

    return Center(
      child: data == null
          ? const CircularProgressIndicator()
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildAwbTile(),
      Expanded(
        child: ListView.builder(
          itemCount: data!['scans'].length,
          itemBuilder: (context, index) {
            final scanData = data!['scans'][index];
            return TimelineItem(
              status: scanData['status'],
              location: scanData['location_city'],
              employee: scanData['Employee'],
              reasonCode: scanData['reason_code'],
              date: scanData['updated_on'],
              isFirst: index == 0,
              isLast: index == data!['scans'].length - 1,
            );
          },
        ),
      ),

          // Display other fields as needed
        ],
      ),
    );
  }


  Widget buildAwbTile() {
    return ListTile(
      title: Text('AWB Number: ${data!['awb_number']}'),
      subtitle: Text('Order ID: ${data!['orderid']}'),
      // Add other AWB data fields as needed
    );
  }




  var result;
     List<Map<String, dynamic>> scans = [];

  Future <Map<String, dynamic>?> getTrackData (String awb ) async{



    var request = http.MultipartRequest('POST', Uri.parse('https://plapi.ecomexpress.in/track_me/api/mawbd/'));
    request.fields.addAll({
      'username': 'JOSSBYTECHNOLOGIESINDIAPVTLTD-EGS514326',
      'password': '5hGBxrCzly',
      'awb': widget.awb ?? '1057847214'
    });


    http.StreamedResponse response = await request.send();
    final Map<String, dynamic> data = {};
    if (response.statusCode == 200) {

      result = await response.stream.bytesToString();
      final document = xml.XmlDocument.parse(result);


      final objectElement = document.findAllElements('object').first;
      final fieldElements = objectElement.findAllElements('field');
      fieldElements.forEach((fieldElement) {
        final name = fieldElement.getAttribute('name');
        final value = fieldElement.text;
        data[name ?? ''] = value;
      });


      log(document.toString());

      final scansFieldElement  = document.findAllElements('object').where(
            (element) => element.getAttribute('model') == 'scan_stages',
      );


      if (scansFieldElement != null) {

        scans = scansFieldElement.map(parseScanObject).toList();
      }

      data['scans'] = scans;

      log('___________${data}__________');

      return data ;

    }
    else {
      print(response.reasonPhrase);
    }
  }

  Map<String, dynamic> parseScanObject(xml.XmlElement scanElement) {
    final Map<String, dynamic> scanData = {};
    final fieldElements = scanElement.findElements('field');
    fieldElements.forEach((fieldElement) {
      final name = fieldElement.getAttribute('name');
      final value = fieldElement.text;
      scanData[name ?? ''] = value;
    });
    return scanData;
  }

/*  Future <void> trackOrder() async{
    var request = http.MultipartRequest('GET', Uri.parse('https://clbeta.ecomexpress.in/track_me/api/mawbd/'));
    request.fields.addAll({
      'username': 'JOSSBYTECHNOLOGIESINDIAPVTLTD-EGS514326',
      'password': '5hGBxrCzly',
      'awb': '114970250'
    });


    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }*/
}

class TimelinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double lineWidth = 2;
    final double startY = 16;
    final double endY = size.height - 16;
    final double lineX = 30;

    final Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = lineWidth;

    canvas.drawLine(
      Offset(lineX, startY),
      Offset(lineX, endY),
      paint,
    );
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) => false;
}

class TimelineItem extends StatelessWidget {
  final String? status;
  final String? location;
  final String? employee;
  final String? reasonCode;
  final String? date;
  final bool? isFirst;
  final bool? isLast;

  const TimelineItem({
    Key? key,
    this.status,
    this.location,
    this.employee,
    this.reasonCode,
    this.date,
    this.isFirst = false,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: $status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Location: $location'),
                    SizedBox(height: 8),
                    Text('Employee: $employee'),
                    SizedBox(height: 8),
                    Text('Reason Code: $reasonCode'),
                    SizedBox(height: 8),
                    Text('Date: $date'),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            width: 2,
            height: 100,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
