import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Screen/ProductList&SectionView/ProductList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../Helper/Constant.dart';
import '../../../Provider/homePageProvider.dart';
import '../../../widgets/desing.dart';
import '../../SubCategory/SubCategory.dart';

class HorizontalCategoryList extends StatelessWidget {
  const HorizontalCategoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomePageProvider>(
      builder: (context, categoryData, child) {
        return categoryData.catLoading
            ? SizedBox(
                width: double.infinity,
                child: Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.simmerBase,
                  highlightColor: Theme.of(context).colorScheme.simmerHigh,
                  child: catLoading(context),
                ),
              )
            : Container(
                height: 140,
                color: colors.primary1.withOpacity(0.4),
                padding: const EdgeInsets.only(top: 15,left:10),
                child: ListView.builder(
                  itemCount: categoryData.catList.length < 10
                      ? categoryData.catList.length
                      : 10,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,

                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container();
                    } else {
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(end: 18),
                        child: GestureDetector(
                          onTap: () async {
                            if (categoryData.catList[index].subList == null ||
                                categoryData.catList[index].subList!.isEmpty) {
                              await Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => ProductList(
                                    name: categoryData.catList[index].name,
                                    id: categoryData.catList[index].id,
                                    tag: false,
                                    fromSeller: false,
                                  ),
                                ),
                              );
                            } else {
                              await Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => SubCategory(
                                    title: categoryData.catList[index].name!,
                                    subList:
                                        categoryData.catList[index].subList,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    circularBorderRadius25),
                                child: DesignConfiguration.getCacheNotworkImage(
                                  boxFit: BoxFit.cover,
                                  context: context,
                                  heightvalue: 90.0,
                                  widthvalue: 90.0,
                                  placeHolderSize: 50,
                                  imageurlString:
                                      categoryData.catList[index].image!,
                                ),
                              ),
                              Container(
                                width:70,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    categoryData.catList[index].name!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption!
                                        .copyWith(
                                      fontFamily: 'ubuntu',
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: textFontSize10,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        ),
                      );
                    }
                  },
                ),
              );
      },
    );
  }

  static Widget catLoading(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                  .map(
                    (_) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.white,
                        shape: BoxShape.circle,
                      ),
                      width: 50.0,
                      height: 50.0,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ),
      ],
    );
  }
}