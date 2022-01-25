import 'dart:ui';

import 'package:emarket_user/utill/routes.dart';
import 'package:emarket_user/view/screens/product/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:emarket_user/data/model/response/product_model.dart';
import 'package:emarket_user/helper/price_converter.dart';
import 'package:emarket_user/provider/splash_provider.dart';
import 'package:emarket_user/provider/theme_provider.dart';
import 'package:emarket_user/utill/color_resources.dart';
import 'package:emarket_user/utill/dimensions.dart';
import 'package:emarket_user/utill/images.dart';
import 'package:emarket_user/utill/styles.dart';
import 'package:emarket_user/view/base/rating_bar.dart';
import 'package:provider/provider.dart';

class ProductWidget extends StatelessWidget {
  final Product product;
  ProductWidget({@required this.product});

  @override
  Widget build(BuildContext context) {

    double _startingPrice;
    double _endingPrice;
    if(product.variations.length != 0) {
      List<double> _priceList = [];
      product.variations.forEach((variation) => _priceList.add(variation.price));
      _priceList.sort((a, b) => a.compareTo(b));
      _startingPrice = _priceList[0];
      if(_priceList[0] < _priceList[_priceList.length-1]) {
        _endingPrice = _priceList[_priceList.length-1];
      }
    }else {
      _startingPrice = product.price;
    }

    double _discountedPrice = PriceConverter.convertWithDiscount(context, product.price, product.discount, product.discountType);

    return Padding(
      padding: EdgeInsets.only(right: Dimensions.PADDING_SIZE_LARGE, bottom: 5,),
      child: InkWell(
        onTap: () {

          Navigator.of(context).pushNamed(
            Routes.getProductDetailsRoute(product.id),
            arguments: ProductDetailsScreen(product: product),
          );
        },
        child: Container(
          height: 220,
          width: 170,
          padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL, horizontal: Dimensions.PADDING_SIZE_SMALL),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(
                color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 700 : 300],
                blurRadius: 5, spreadRadius: 1,
              )]
          ),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FadeInImage.assetNetwork(
                placeholder: Images.placeholder,
                image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls.productImageUrl}/${product.image[0]}',
                width: 120, fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
            Expanded(
              child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(product.name, style: rubikMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 10),
                Text(
                  '${PriceConverter.convertPrice(context, _startingPrice, discount: product.discount, discountType: product.discountType, asFixed: 1)}'
                      '${_endingPrice!= null ? ' - ${PriceConverter.convertPrice(context, _endingPrice, discount: product.discount,
                      discountType: product.discountType, asFixed: 1)}' : ''}',
                  style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                ),
                product.price > _discountedPrice ? Text('${PriceConverter.convertPrice(context, _startingPrice, asFixed: 1)}'
                    '${_endingPrice!= null ? ' - ${PriceConverter.convertPrice(context, _endingPrice, asFixed: 1)}' : ''}', style: rubikMedium.copyWith(
                  color: ColorResources.COLOR_GREY,
                  decoration: TextDecoration.lineThrough,
                  fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                )) : SizedBox(),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Icon(Icons.add),
              Expanded(child: SizedBox()),
              RatingBar(rating: product.rating.length > 0 ? double.parse(product.rating[0].average) : 0.0, size: 10),
            ]),
          ]),
        ),
      ),
    );
  }
}
