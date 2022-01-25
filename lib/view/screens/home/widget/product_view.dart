import 'package:emarket_user/provider/localization_provider.dart';
import 'package:flutter/material.dart';
import 'package:emarket_user/data/model/response/product_model.dart';
import 'package:emarket_user/helper/product_type.dart';
import 'package:emarket_user/helper/responsive_helper.dart';
import 'package:emarket_user/provider/product_provider.dart';
import 'package:emarket_user/utill/dimensions.dart';
import 'package:emarket_user/view/base/no_data_screen.dart';
import 'package:emarket_user/view/base/product_shimmer.dart';
import 'package:emarket_user/view/base/product_widget.dart';
import 'package:provider/provider.dart';

class ProductView extends StatelessWidget {
  final ProductType productType;
  final ScrollController scrollController;
  ProductView({@required this.productType, this.scrollController});

  @override
  Widget build(BuildContext context) {

    int offset = 1;
    scrollController?.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Provider.of<ProductProvider>(context, listen: false).popularProductList != null
          && !Provider.of<ProductProvider>(context, listen: false).isLoading) {
        int pageSize;
        if (productType == ProductType.POPULAR_PRODUCT) {
          pageSize = (Provider.of<ProductProvider>(context, listen: false).popularPageSize / 10).ceil();
        }
        if (offset < pageSize) {
          offset++;
          print('end of the page');
          Provider.of<ProductProvider>(context, listen: false).showBottomLoader();
          Provider.of<ProductProvider>(context, listen: false).getPopularProductList(
            context, offset.toString(), false, Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
          );
        }
      }
    });
    return Consumer<ProductProvider>(
      builder: (context, prodProvider, child) {
        List<Product> productList;
        if (productType == ProductType.POPULAR_PRODUCT) {
          productList = prodProvider.popularProductList;
        }

        return Column(children: [
          productList != null ? productList.length > 0 ? GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 4,
                crossAxisCount: ResponsiveHelper.isDesktop(context) ? 3 : ResponsiveHelper.isTab(context) ? 2 : 1),
            itemCount: productList.length,
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_SMALL),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return ProductWidget(product: productList[index]);
            },
          ) : NoDataScreen() : GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 4,
                  crossAxisCount: ResponsiveHelper.isDesktop(context) ? 3 : ResponsiveHelper.isTab(context) ? 2 : 1),
              itemCount: 10,
              itemBuilder: (BuildContext context, int index) {
                return ProductShimmer(isEnabled: productList == null);
              },
              padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL)),

          prodProvider.isLoading ? Center(child: Padding(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
          )) : SizedBox(),
        ]);
      },
    );
  }
}
