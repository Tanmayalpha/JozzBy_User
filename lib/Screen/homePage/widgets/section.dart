import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Model/Get_Images_model.dart';
import 'package:eshop_multivendor/Model/Model.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/homePageProvider.dart';
import 'package:eshop_multivendor/Screen/Product%20Detail/productDetail.dart';
import 'package:eshop_multivendor/Screen/ProductList&SectionView/ProductList.dart';
import 'package:eshop_multivendor/Screen/ProductList&SectionView/SectionList.dart';
import 'package:eshop_multivendor/Screen/SellerDetail/Seller_Details.dart';
import 'package:eshop_multivendor/Screen/SubCategory/SubCategory.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/offerImage.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/singleProductContainer.dart';
import 'package:eshop_multivendor/Screen/star_rating.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../Helper/String.dart';
import '../../Language/languageSettings.dart';

class Section extends StatelessWidget {
  const Section({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<HomePageProvider, bool>(
      builder: (context, isLoading, child) {
        return isLoading /*|| supportedLocale == null*/
            ? SizedBox(
                width: double.infinity,
                child: Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.simmerBase,
                  highlightColor: Theme.of(context).colorScheme.simmerHigh,
                  child: sectionLoadingShimmer(context),
                ),
              )
            : Container(
          color: colors.primary1,
              child: ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: context.read<HomePageProvider>().sectionList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {

                    return SingleSection(
                      index: index,
                      from: 1,
                      sectionTitle: context
                              .read<HomePageProvider>()
                              .sectionList[index]
                              .title ??
                          '',
                      sectionStyle: context
                              .read<HomePageProvider>()
                              .sectionList[index]
                              .style ??
                          '',
                      sectionSubTitle: context
                              .read<HomePageProvider>()
                              .sectionList[index]
                              .shortDesc ??
                          '',
                      productList: context
                              .read<HomePageProvider>()
                              .sectionList[index]
                              .productList ??
                          [],
                      wantToShowOfferImageBelowSection: false,
                      imageList: context
                          .read<HomePageProvider>()
                          .homeImageSliderList,
                      sellerList: context.read<HomePageProvider>().sellerList,
                      imageList2: context.read<HomePageProvider>().homeImageThiredSliderList,

                    );


                  },
                ),
            );
      },
      selector: (_, homePageProvider) => homePageProvider.secLoading,
    );
  }

  static Widget sectionLoadingShimmer(BuildContext context) {
    return Column(
      children: [0, 1, 2, 3, 4]
          .map(
            (_) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 40),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(circularBorderRadius20),
                              topRight: Radius.circular(circularBorderRadius20),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            width: double.infinity,
                            height: 18.0,
                            color: Theme.of(context).colorScheme.white,
                          ),
                          GridView.count(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            childAspectRatio: 1.0,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            children: List.generate(
                              6,
                              (index) {
                                return Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Theme.of(context).colorScheme.white,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.simmerBase,
                  highlightColor: Theme.of(context).colorScheme.simmerHigh,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: double.infinity,
                    height: (deviceWidth! / 2),
                    color: Theme.of(context).colorScheme.white,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class SectionHeadingContainer extends StatelessWidget {
  final String title;
  final String subTitle;
  final int index;
  final List<Product> productList;


  const SectionHeadingContainer({
    Key? key,
    required this.title,
    required this.index,
    required this.subTitle,
    required this.productList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 15.0,
        top: 0.0,
        left: 15.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
              fontFamily: 'ubuntu',
              fontSize: textFontSize16,
              color: Theme.of(context).colorScheme.fontColor,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 3,
                child: Text(
                  subTitle,
                  style: const TextStyle(
                    fontSize: textFontSize12,
                    fontFamily: 'ubuntu',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: GestureDetector(
                  child: Text(
                    getTranslated(context, 'Show All')!,
                    style: Theme.of(context).textTheme.caption!.copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontSize: textFontSize12,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'ubuntu',
                        ),
                  ),
                  onTap: () {
                    SectionModel model =
                        context.read<HomePageProvider>().sectionList[index];

                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => SectionList(
                          index: index,
                          section_model: model,
                          from: title ==
                                  getTranslated(context, 'You might also like')!
                              ? 2
                              : 1,
                          productList: productList,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const Divider(thickness: 1),
        ],
      ),
    );
  }
}

class SingleSection extends StatelessWidget {
  final int index;
  final String sectionTitle;
  final String sectionSubTitle;
  final String sectionStyle;
  final int from;
  final List<Product> productList;
  final bool wantToShowOfferImageBelowSection;
  final List<GetImageModelList>? imageList ;
  final List<GetImageModelList>? imageList2 ;
  final List<Product>? sellerList ;

  const SingleSection({
    Key? key,
    required this.index,
    required this.productList,
    required this.from,
    required this.sectionTitle,
    required this.sectionSubTitle,
    required this.sectionStyle,
    required this.wantToShowOfferImageBelowSection,
    this.imageList, this.sellerList,this.imageList2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return

      productList.isNotEmpty
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[

                    sectionTitle.toLowerCase().contains('best selling') ?  imageCard(imageList) : const SizedBox.shrink(),
                    sectionTitle.toLowerCase().contains('best selling') ?
                    getSellerList(sellerList, context): const SizedBox.shrink(),
                    sectionTitle.toLowerCase().contains('feature') ? imageCard(imageList2): const SizedBox.shrink(),
                    const SizedBox(height: 10,),

                    SectionHeadingContainer(
                      title: sectionTitle,
                      index: index,
                      subTitle: sectionSubTitle,
                      productList: productList,
                    ),
                    SingleSectionContainer(
                      index: index,
                      productList: productList,
                      sectionStyle: sectionStyle,
                    ),

                  ],
                ),
              ),
              context.read<HomePageProvider>().offerImagesList.length > index &&
                      wantToShowOfferImageBelowSection
                  ? Padding(
                      padding:
                          const EdgeInsets.only(top: 20, right: 10, left: 10),
                      child: OfferImage(
                        offerImage: context
                            .read<HomePageProvider>()
                            .offerImagesList[index]
                            .image!,
                        onOfferClick: () {
                          _onOfferImageClick(
                              context,
                              context
                                  .read<HomePageProvider>()
                                  .offerImagesList[index]);
                        },
                        placeHolderAssetImage: 'sliderph',
                      ),
                    )
                  : Container(),
            ],
          )
        : Container();
  }

  _onOfferImageClick(BuildContext context, Model offerImageData) {
    if (offerImageData.type == 'products') {
      Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (_, __, ___) => ProductDetail(
                model: offerImageData.list, secPos: 0, index: 0, list: true)),
      );
    } else if (offerImageData.type == 'categories') {
      Product item = offerImageData.list;
      if (item.subList == null || item.subList!.isEmpty) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ProductList(
              name: item.name,
              id: item.id,
              tag: false,
              fromSeller: false,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => SubCategory(
              title: item.name!,
              subList: item.subList,
            ),
          ),
        );
      }
    }
  }

  imageCard(List<GetImageModelList>? imageList){
    return SizedBox(
        height:200,
        width:double.infinity,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount:imageList?.length  ?? 0,
              // physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network("${imageList?[index].image}",fit: BoxFit.fill,width: MediaQuery.of(context).size.width/1.05,));
              },)

        ));
  }


  getSellerList(List<Product>? sellerList, BuildContext context){

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left:10.0,top: 5),
          child: Text("All Seller",style: TextStyle(color: colors.blackTemp,fontWeight: FontWeight.bold,fontSize: 20),),
        ),
        Container(
          color: colors.primary1,
          height: 190,
          child: ListView.separated(
              itemCount: sellerList?.length ?? 0,
              separatorBuilder: (BuildContext context, int index) => const Divider(),
              scrollDirection: Axis.horizontal,

              itemBuilder: (c,i){
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(onTap: (){
                    String? s_id,seller_id,sellerImage,sellerStoreName,sellerRating,storeDesc;

                      s_id = sellerList?[i].seller_id;
                    seller_id = context.read<HomePageProvider>().sellerList[i].seller_id;
                    sellerImage =context.read<HomePageProvider>().sellerList[i].seller_profile;
                    sellerStoreName =context.read<HomePageProvider>().sellerList[i].store_name;
                    sellerRating = context.read<HomePageProvider>().sellerList[i].seller_rating;
                    storeDesc = context.read<HomePageProvider>().sellerList[i].store_description;
                    //
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => SellerProfile(totalProductsOfSeller: '',s_id:s_id,sellerImage: sellerImage,sellerStoreName:sellerStoreName,sellerRating: sellerRating,storeDesc: storeDesc
                        ),
                      ),
                    );

                  },
                    child: Container(
                        decoration: BoxDecoration(
                            color:Color(0xffEFEFEF),
                            border: Border.all(color: colors.blackTemp),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        width: 165,
                        height: 180,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10,),
                            Container(
                              height: 100,width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(60),
                                // border: Border.all(color: colors.blackTemp)
                              ),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.network("${context.read<HomePageProvider>().sellerList[i].seller_profile}",fit: BoxFit.fill,)),
                            ),
                            const SizedBox(height:15,),
                            SizedBox(
                                width: 90,
                                child: Center(child: Text("${context.read<HomePageProvider>().sellerList[i].seller_name}",overflow: TextOverflow.ellipsis,maxLines: 2,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),))),
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 15, bottom: 10),
                              child: StarRatingIndicators(
                                noOfRatings: context.read<HomePageProvider>().sellerList[i].seller_rating ?? '0.0',
                                totalRating: context.read<HomePageProvider>().sellerList[i].seller_rating ?? '0.0',
                                
                              ),),


                          ],
                        )
                    ),
                  ),
                );
              }),
        ),
      ],
    );


  }

}

class SingleSectionContainer extends StatelessWidget {
  final int index;
  final List<Product> productList;
  final String sectionStyle;

  const SingleSectionContainer(
      {Key? key,
      required this.index,
      required this.productList,
      required this.sectionStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var orient = MediaQuery.of(context).orientation;
    return productList.isNotEmpty
        ? sectionStyle == DEFAULT
            ? Padding(
                padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
                child: GridView.count(
                  padding: const EdgeInsetsDirectional.only(top: 5),
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  childAspectRatio: 0.620, //750
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(
                    productList.length < 4 ? productList.length : 4,
                    (productIndex) {
                      return SingleProductContainer(
                        sectionPosition: index,
                        index: productIndex,
                        pictureFlex: 10,
                        textFlex: 8,
                        productDetails: productList[productIndex],
                        length: productList.length,
                        showDiscountAtSameLine: false,
                      );
                    },
                  ),
                ),
              )
            : sectionStyle == STYLE1
                ? Padding(
                    padding:
                        const EdgeInsets.only(top: 10, right: 10, left: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 3,
                          fit: FlexFit.loose,
                          child: SizedBox(
                            height: orient == Orientation.portrait
                                ? deviceHeight! * 0.745 // 0.6
                                : deviceHeight!,
                            child: SingleProductContainer(
                              sectionPosition: index,
                              index: 0,
                              pictureFlex: 14,
                              textFlex: 3,
                              productDetails: productList[0],
                              length: productList.length,
                              showDiscountAtSameLine: true,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.loose,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                productList.length < 2
                                    ? Container()
                                    : SizedBox(
                                        height: orient == Orientation.portrait
                                            ? deviceHeight! * 0.35 //0.2975
                                            : deviceHeight! * 0.6,
                                        child: SingleProductContainer(
                                          sectionPosition: index,
                                          index: 1,
                                          pictureFlex: 5,
                                          textFlex: 4,
                                          productDetails: productList[1],
                                          length: productList.length,
                                          showDiscountAtSameLine: false,
                                        ),
                                      ),
                                Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: productList.length < 3
                                        ? Container()
                                        : SizedBox(
                                            height:
                                                orient == Orientation.portrait
                                                    ? deviceHeight! * 0.35 //0.2975
                                                    : deviceHeight! * 0.6,
                                            child: SingleProductContainer(
                                              sectionPosition: index,
                                              index: 2,
                                              pictureFlex: 5,
                                              textFlex: 4,
                                              productDetails: productList[2],
                                              length: productList.length,
                                              showDiscountAtSameLine: false,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : sectionStyle == STYLE2
                    ? Padding(
                        padding:
                            const EdgeInsets.only(top: 10, right: 10, left: 10),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 2,
                              fit: FlexFit.loose,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: SizedBox(
                                        height: orient == Orientation.portrait
                                            ? deviceHeight! * 0.2975
                                            : deviceHeight! * 0.6,
                                        child: SingleProductContainer(
                                          sectionPosition: index,
                                                                                                                                                                                                                                                                                          index: 0,
                                          pictureFlex: 3,
                                          textFlex: 4,    
                                          productDetails: productList[0],
                                          length: productList.length,
                                          showDiscountAtSameLine: false,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: productList.length < 2
                                            ? Container()
                                            : SizedBox(
                                                height: orient ==
                                                        Orientation.portrait
                                                    ? deviceHeight! * 0.2975
                                                    : deviceHeight! * 0.6,
                                                child: SingleProductContainer(
                                                  sectionPosition: index,
                                                  index: 1,
                                                  pictureFlex: 3,
                                                  textFlex: 4,
                                                  productDetails:
                                                      productList[1],
                                                  length: productList.length,
                                                  showDiscountAtSameLine: false,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 3,
                              fit: FlexFit.loose,
                              child: productList.length < 3
                                  ? Container()
                                  : SizedBox(
                                      height: orient == Orientation.portrait
                                          ? deviceHeight! * 0.6
                                          : deviceHeight!,
                                      child: SingleProductContainer(
                                        sectionPosition: index,
                                        index: 2,
                                        pictureFlex: 7,
                                        textFlex: 3,
                                        productDetails: productList[2],
                                        length: productList.length,
                                        showDiscountAtSameLine: true,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      )
                    : sectionStyle == STYLE3
                        ? Padding(
                            padding: const EdgeInsets.only(
                              top: 10,
                              right: 10,
                              left: 10,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.loose,
                                  child: SizedBox(
                                    height: orient == Orientation.portrait
                                        ? deviceHeight! * 0.3
                                        : deviceHeight! * 0.6,
                                    child: SingleProductContainer(
                                      sectionPosition: index,
                                      index: 0,
                                      pictureFlex: 7,
                                      textFlex: 4,
                                      productDetails: productList[0],
                                      length: productList.length,
                                      showDiscountAtSameLine: true,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: orient == Orientation.portrait
                                      ? deviceHeight! * 0.3
                                      : deviceHeight! * 0.6,
                                  child: Row(
                                    children: [
                                      Flexible(
                                        flex: 1,
                                        fit: FlexFit.loose,
                                        child: productList.length < 2
                                            ? Container()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 5, top: 5),
                                                child: SingleProductContainer(
                                                  sectionPosition: index,
                                                  index: 1,
                                                  pictureFlex: 5,
                                                  textFlex: 4,
                                                  productDetails:
                                                      productList[1],
                                                  length: productList.length,
                                                  showDiscountAtSameLine: false,
                                                ),
                                              ),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        fit: FlexFit.loose,
                                        child: productList.length < 3
                                            ? Container()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 5, top: 5),
                                                child: SingleProductContainer(
                                                  sectionPosition: index,
                                                  index: 2,
                                                  pictureFlex: 5,
                                                  textFlex: 4,
                                                  productDetails:
                                                      productList[2],
                                                  length: productList.length,
                                                  showDiscountAtSameLine: false,
                                                ),
                                              ),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        fit: FlexFit.loose,
                                        child: productList.length < 4
                                            ? Container()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: SingleProductContainer(
                                                  sectionPosition: index,
                                                  index: 3,
                                                  pictureFlex: 5,
                                                  textFlex: 4,
                                                  productDetails:
                                                      productList[3],
                                                  length: productList.length,
                                                  showDiscountAtSameLine: false,
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : sectionStyle == STYLE4
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, right: 10, left: 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      fit: FlexFit.loose,
                                      child: SizedBox(
                                        height: orient == Orientation.portrait
                                            ? deviceHeight! * 0.3
                                            : deviceHeight! * 0.6,
                                        child: SingleProductContainer(
                                          sectionPosition: index,
                                          index: 0,
                                          pictureFlex: 7,
                                          textFlex: 4,
                                          productDetails: productList[0],
                                          length: productList.length,
                                          showDiscountAtSameLine: true,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: orient == Orientation.portrait
                                          ? deviceHeight! * 0.3
                                          : deviceHeight! * 0.6,
                                      child: Row(
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            fit: FlexFit.loose,
                                            child: productList.length < 2
                                                ? Container()
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 5,
                                                      top: 5,
                                                    ),
                                                    child:
                                                        SingleProductContainer(
                                                      sectionPosition: index,
                                                      index: 1,
                                                      pictureFlex: 5,
                                                      textFlex: 4,
                                                      productDetails:
                                                          productList[1],
                                                      length:
                                                          productList.length,
                                                      showDiscountAtSameLine:
                                                          false,
                                                    ),
                                                  ),
                                          ),
                                          Flexible(
                                            flex: 1,
                                            fit: FlexFit.loose,
                                            child: productList.length < 3
                                                ? Container()
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 5,
                                                    ),
                                                    child:
                                                        SingleProductContainer(
                                                      sectionPosition: index,
                                                      index: 2,
                                                      pictureFlex: 5,
                                                      textFlex: 4,
                                                      productDetails:
                                                          productList[2],
                                                      length:
                                                          productList.length,
                                                      showDiscountAtSameLine:
                                                          false,
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: GridView.count(
                                  padding:
                                      const EdgeInsetsDirectional.only(top: 5),
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  childAspectRatio: 1.2,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 0,
                                  crossAxisSpacing: 0,
                                  children: List.generate(
                                    productList.length < 6
                                        ? productList.length
                                        : 6,
                                    (index) {
                                      return SingleProductContainer(
                                        sectionPosition: index,
                                        index: index,
                                        pictureFlex: 1,
                                        textFlex: 1,
                                        productDetails: productList[index],
                                        length: productList.length,
                                        showDiscountAtSameLine: false,
                                      );
                                    },
                                  ),
                                ),
                              )
        : Container();
  }
}
