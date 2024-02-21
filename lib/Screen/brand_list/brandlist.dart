import 'dart:convert';

import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Screen/Dashboard/Dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Helper/Constant.dart';
import '../../Model/Get_brands_model.dart';
import '../../widgets/security.dart';
import '../ProductList&SectionView/ProductList.dart';
import '../homePage/homepageNew.dart';

class BrandList extends StatefulWidget {
  const BrandList({Key? key}) : super(key: key);

  @override
  State<BrandList> createState() => _BrandListState();
}

class _BrandListState extends State<BrandList> {
  String? brandId,brandName, brandImage;
  GetBrandsModel? getBrandsModel;

  getBrandApi() async {
   
    var request = http.MultipartRequest('GET', Uri.parse('$baseUrl/get_brand'));

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result =  await response.stream.bytesToString();
      var finalResult =  GetBrandsModel.fromJson(jsonDecode(result));
      setState(() {
        getBrandsModel = finalResult;

        for(var i=0;i<getBrandsModel!.data!.length;i++){
          brandId = getBrandsModel!.data![i].id;


        }
      });
    }
    else {
      print(response.reasonPhrase);
    }

  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBrandApi();
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPopScope,
      child: Scaffold(
        backgroundColor: colors.primary1,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor:colors.whiteTemp,
          title: const Text('All Brand List',style: TextStyle(color: colors.blackTemp,fontWeight: FontWeight.bold),),
          leading: InkWell(
              onTap: () {

                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const Dashboard()));
              },
              child: const Icon(Icons.arrow_back,color: colors.blackTemp,)),
        ),
        body:getBrandsModel == null ? const Center(child: CircularProgressIndicator(),) : GridView.builder(
          gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:2,
            childAspectRatio:1,
              crossAxisSpacing:0,
            mainAxisSpacing:5,
          ),
          itemCount: getBrandsModel?.data?.length,
          itemBuilder: (context, index) {
              return    Padding(
                padding: const EdgeInsets.only(left: 10.0,right:10,top:20),
                child: InkWell(
                  onTap: () async {

                    setState(() {
                      brandId =   getBrandsModel!.data![index].id;
                      brandName = getBrandsModel?.data?[index].name;
                      brandImage = getBrandsModel?.data?[index].image;
                    });
                    SharedPreferences pref = await SharedPreferences.getInstance();
                    pref.setString('brand_name', brandName!);
                    print('brandName------kkkk------------${getBrandsModel!.data![index].name}__________');

                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => ProductList(getBrand: true, brandId: brandId,brandName: brandName,),
                      ),
                    );

                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color:Color(0xffEFEFEF),
                          borderRadius: BorderRadius.circular(10)
                      ),
                      width: 140,
                      height: 155,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: 110,
                              width: double.infinity,
                              child: ClipRRect(
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                                  child:getBrandsModel?.data?[index].image==null||getBrandsModel?.data?[index].image==""?Image.asset('assets/images/png/placeholder.png'): Image.network("$imageUrl${getBrandsModel?.data?[index].image}",fit: BoxFit.fill,))),
                          const SizedBox(height:10,),
                          SizedBox(
                              width: 90,
                              child: Center(child: Text("${getBrandsModel?.data?[index].name}",overflow: TextOverflow.ellipsis,maxLines: 2,textAlign: TextAlign.center,style:TextStyle(fontWeight: FontWeight.bold),))),

                        ],
                      )
                  ),
                ),
              );
            },),
      ),
    );
  }


  Future<bool> onWillPopScope() {


    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const Dashboard()));


    return Future.value(true);
  }
}
