import 'package:emarket_user/data/model/response/cart_model.dart';
import 'package:emarket_user/data/model/response/product_model.dart';
import 'package:emarket_user/helper/price_converter.dart';
import 'package:emarket_user/helper/responsive_helper.dart';
import 'package:emarket_user/localization/language_constrants.dart';
import 'package:emarket_user/provider/cart_provider.dart';
import 'package:emarket_user/provider/localization_provider.dart';
import 'package:emarket_user/provider/product_provider.dart';
import 'package:emarket_user/utill/color_resources.dart';
import 'package:emarket_user/utill/dimensions.dart';
import 'package:emarket_user/utill/styles.dart';
import 'package:emarket_user/view/base/custom_button.dart';
import 'package:emarket_user/view/base/main_app_bar.dart';
import 'package:emarket_user/view/screens/product/details_app_bar.dart';
import 'package:emarket_user/view/screens/product/widget/product_image_view.dart';
import 'package:emarket_user/view/screens/product/widget/product_title_view.dart';
import 'package:emarket_user/view/screens/product/widget/review_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  final CartModel cart;
  ProductDetailsScreen({@required this.product, this.cart});

  final GlobalKey<DetailsAppBarState> _key = GlobalKey();


  @override
  Widget build(BuildContext context) {
    Variation _variation = Variation();
    GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
    Provider.of<ProductProvider>(context, listen: false).getProductDetails(
      context, product, cart, Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
    );
    Provider.of<ProductProvider>(context, listen: false).getProductReviews(context, product.id);

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        int _stock;
        List _tabChildren;
        double priceWithQuantity;
        bool isExistInCart;
        CartModel _cartModel;
        List _variationList;
        if(productProvider.product != null){
          _tabChildren = [

            (productProvider.product.description == null || productProvider.product.description.isEmpty) ? Center(child: Text(getTranslated('no_description_found', context)))
                : HtmlWidget(productProvider.product.description ?? ''),



            (productProvider.productReviewList != null && productProvider.productReviewList.length == 0) ? Center(child: Text(getTranslated('no_review_found', context))) : ListView.builder(
              itemCount: productProvider.productReviewList != null ? productProvider.productReviewList.length : 3,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
              itemBuilder: (context, index) {
                return productProvider.productReviewList != null ? ReviewWidget(reviewModel: productProvider.productReviewList[index])
                    : ReviewShimmer();
              },

            ),
          ];

          _variationList = [];
          for(int index=0; index < productProvider.product.choiceOptions.length; index++) {
            _variationList.add(productProvider.product.choiceOptions[index].options[productProvider.variationIndex[index]].replaceAll(' ', ''));
          }
          String variationType = '';
          bool isFirst = true;
          _variationList.forEach((variation) {
            if(isFirst) {
              variationType = '$variationType$variation';
              isFirst = false;
            }else {
              variationType = '$variationType-$variation';
            }
          });

          double price = productProvider.product.price;
          _stock = productProvider.product.totalStock;
          for(Variation variation in productProvider.product.variations) {
            if(variation.type == variationType) {
              price = variation.price;
              _variation = variation;
              _stock = variation.stock;
              break;
            }
          }
          double priceWithDiscount = PriceConverter.convertWithDiscount(context, price, productProvider.product.discount, productProvider.product.discountType);
          priceWithQuantity = priceWithDiscount * productProvider.quantity;

          _cartModel = CartModel(
            price, priceWithDiscount, [_variation],
            (price - PriceConverter.convertWithDiscount(context, price, productProvider.product.discount, productProvider.product.discountType)),
            productProvider.quantity, price - PriceConverter.convertWithDiscount(context, price, productProvider.product.tax, productProvider.product.taxType),
            _stock, productProvider.product,
          );
          isExistInCart = Provider.of<CartProvider>(context).isExistInCart(_cartModel, false, null);
        }

        return Scaffold(
          key: _globalKey,
          backgroundColor: Theme.of(context).cardColor,

          appBar: ResponsiveHelper.isDesktop(context)? PreferredSize(child: MainAppBar(), preferredSize: Size.fromHeight(80)) :  DetailsAppBar(key: _key),

          body: productProvider.product != null ? Column(children: [

            Expanded(
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL), physics: BouncingScrollPhysics(),
                  child: Center(
                    child: SizedBox(
                      width: 1170,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            ProductImageView(productModel: productProvider.product),
                            SizedBox(height: 20),

                            ProductTitleView(productModel: productProvider.product),
                            Divider(height: 20, thickness: 2),

                            // Variation
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: productProvider.product.choiceOptions.length,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                  GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: (1 / 0.25),
                                    ),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: productProvider.product.choiceOptions[index].options.length,
                                    itemBuilder: (context, i) {
                                      return InkWell(
                                        onTap: () {
                                          productProvider.setCartVariationIndex(index, i);
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                          decoration: BoxDecoration(
                                            color: productProvider.variationIndex[index] != i ? ColorResources.BACKGROUND_COLOR : Theme.of(context).primaryColor,
                                            borderRadius: BorderRadius.circular(5),
                                            border: productProvider.variationIndex[index] != i ? Border.all(color: ColorResources.BORDER_COLOR, width: 2) : null,
                                          ),
                                          child: Text(
                                            productProvider.product.choiceOptions[index].options[i].trim(), maxLines: 1, overflow: TextOverflow.ellipsis,
                                            style: rubikRegular.copyWith(
                                              color: productProvider.variationIndex[index] != i ? ColorResources.COLOR_BLACK : ColorResources.COLOR_WHITE,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: index != productProvider.product.choiceOptions.length-1 ? Dimensions.PADDING_SIZE_LARGE : 0),
                                ]);
                              },
                            ),
                            productProvider.product.choiceOptions.length > 0 ? SizedBox(height: Dimensions.PADDING_SIZE_LARGE) : SizedBox(),

                            // Quantity
                            Row(children: [
                              Text(getTranslated('quantity', context), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                              Expanded(child: SizedBox()),
                              Container(
                                decoration: BoxDecoration(color: ColorResources.getBackgroundColor(context), borderRadius: BorderRadius.circular(5)),
                                child: Row(children: [
                                  InkWell(
                                    onTap: () {
                                      if (productProvider.quantity > 1) {
                                        productProvider.setQuantity(false, _stock, context);
                                      }
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                      child: Icon(Icons.remove, size: 20),
                                    ),
                                  ),
                                  Text(productProvider.quantity.toString(), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE)),
                                  InkWell(
                                    onTap: () => productProvider.setQuantity(true, _stock, context),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                      child: Icon(Icons.add, size: 20),
                                    ),
                                  ),
                                ]),
                              ),
                            ]),
                            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                            Row(children: [
                              Text('${getTranslated('total_amount', context)}:', style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                              SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                              Text(PriceConverter.convertPrice(context, priceWithQuantity), style: rubikBold.copyWith(
                                color: Theme.of(context).primaryColor, fontSize: Dimensions.FONT_SIZE_LARGE,
                              )),
                            ]),
                            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                            // Tab Bar
                            Row(children: [
                              Expanded(child: InkWell(
                                onTap: () => productProvider.setTabIndex(0),
                                child: Column(children: [
                                  Center(child: Text(getTranslated('description', context), style: productProvider.tabIndex == 0 ? rubikMedium : rubikRegular)),
                                  Divider(thickness: 3, color: Theme.of(context).primaryColor.withOpacity(productProvider.tabIndex == 0 ? 1 : 0.2)),
                                ]),
                              )),
                              Expanded(child: InkWell(
                                onTap: () => productProvider.setTabIndex(1),
                                child: Column(children: [
                                  Center(child: Text(getTranslated('review', context), style: productProvider.tabIndex == 1 ? rubikMedium : rubikRegular)),
                                  Divider(thickness: 3, color: Theme.of(context).primaryColor.withOpacity(productProvider.tabIndex == 1 ? 1 : 0.2)),
                                ]),
                              )),
                            ]),

                            _tabChildren[productProvider.tabIndex],

                          ]),
                    ),
                  ),
                ),
              ),
            ),

            Container(
              width: 1170,
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              child: CustomButton(
                btnTxt: getTranslated(isExistInCart ? 'already_added_in_cart' : _stock <= 0 ? 'out_of_stock' : 'add_to_cart', context),
                backgroundColor: Theme.of(context).primaryColor,
                onTap: (!isExistInCart && _stock > 0) ?  () {
                  if(!isExistInCart && _stock > 0) {
                    Provider.of<CartProvider>(context, listen: false).addToCart(_cartModel, null);
                    _key.currentState.shake();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(getTranslated('added_to_cart', context)),
                      backgroundColor: Colors.green,
                    ));
                  }
                } : null,
              ),
            ),

          ]) : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
        );
      },
    );
  }
}