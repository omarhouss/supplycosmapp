import 'dart:convert';

import 'package:emarket_user/data/model/response/product_model.dart';
import 'package:emarket_user/helper/responsive_helper.dart';
import 'package:emarket_user/provider/product_provider.dart';
import 'package:emarket_user/provider/splash_provider.dart';
import 'package:emarket_user/utill/dimensions.dart';
import 'package:emarket_user/utill/images.dart';
import 'package:emarket_user/utill/routes.dart';
import 'package:emarket_user/view/screens/product/product_image_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductImageView extends StatefulWidget {
  final Product productModel;
  ProductImageView({@required this.productModel});

  @override
  _ProductImageViewState createState() => _ProductImageViewState();
}

class _ProductImageViewState extends State<ProductImageView> {
  PageController _controller;

  @override
  void initState() {
    _controller = PageController();
    Provider.of<ProductProvider>(context,listen:  false,).image_controller = _controller;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, product, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => Navigator.of(context).pushNamed(
                Routes.getProductImageRoute(jsonEncode(widget.productModel.image)),
                arguments: ProductImageScreen(imageList: widget.productModel.image),
              ),
              child: Stack(children: [
                SizedBox(
                  height: ResponsiveHelper.isDesktop(context)? 350: MediaQuery.of(context).size.width * 0.7,
                  child:
                  PageView.builder(
                    controller: _controller,
                    itemCount: widget.productModel.image.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: FadeInImage.assetNetwork(
                          placeholder: Images.placeholder,
                          image: '${Provider.of<SplashProvider>(context,listen: false).baseUrls.productImageUrl}/${widget.productModel.image[product.imageSliderIndex]}',
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                        ),
                      );
                    },
                    onPageChanged: (index) {
                      product.setImageSliderIndex(index);
                    },
                  ),
                ),
                Positioned(
                  left: 0, right: 0, bottom: 0,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_SMALL),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _indicators(context),
                    ),
                  ),
                ),

              ]),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _indicators(BuildContext context) {
    List<Widget> indicators = [];
    for (int index = 0; index < widget.productModel.image.length; index++) {
      indicators.add(TabPageSelectorIndicator(
        backgroundColor: index == Provider.of<ProductProvider>(context).imageSliderIndex ? Theme.of(context).primaryColor : Colors.white,
        borderColor: Colors.white,
        size: 10,
      ));
    }
    return indicators;
  }
}
