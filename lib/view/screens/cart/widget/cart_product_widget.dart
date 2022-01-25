import 'package:emarket_user/helper/responsive_helper.dart';
import 'package:emarket_user/provider/coupon_provider.dart';
import 'package:flutter/material.dart';
import 'package:emarket_user/data/model/response/cart_model.dart';
import 'package:emarket_user/helper/price_converter.dart';
import 'package:emarket_user/localization/language_constrants.dart';
import 'package:emarket_user/provider/cart_provider.dart';
import 'package:emarket_user/provider/splash_provider.dart';
import 'package:emarket_user/provider/theme_provider.dart';
import 'package:emarket_user/utill/color_resources.dart';
import 'package:emarket_user/utill/dimensions.dart';
import 'package:emarket_user/utill/images.dart';
import 'package:emarket_user/utill/styles.dart';
import 'package:emarket_user/view/base/rating_bar.dart';
import 'package:emarket_user/view/screens/home/widget/cart_bottom_sheet.dart';
import 'package:provider/provider.dart';

class CartProductWidget extends StatelessWidget {
  final CartModel cart;
  final int cartIndex;
  CartProductWidget({@required this.cart, @required this.cartIndex});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
      ResponsiveHelper.isMobile(context) ? showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (con) => CartBottomSheet(
          product: cart.product,
          callback: (CartModel cartModel) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getTranslated('added_to_cart', context)), backgroundColor: Colors.green));
          },
        ),
      ): showDialog(context: context, builder: (con) => Dialog(
        child: SizedBox(
          width: 500,
          child: CartBottomSheet(
            product: cart.product,
            callback: (CartModel cartModel) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getTranslated('added_to_cart', context)), backgroundColor: Colors.green));
            },
          ),
        ),
      )) ;
    },

      child: Container(
        margin: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_DEFAULT),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
        child: Stack(children: [
          Positioned(
            top: 0, bottom: 0, right: 0, left: 0,
            child: Icon(Icons.delete, color: ColorResources.COLOR_WHITE, size: 50),
          ),
          Dismissible(
            key: UniqueKey(),
            onDismissed: (DismissDirection direction) => Provider.of<CartProvider>(context, listen: false).removeFromCart(cart),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL, horizontal: Dimensions.PADDING_SIZE_SMALL),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(
                  color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 700 : 300],
                  blurRadius: 5, spreadRadius: 1,
                )],
              ),
              child: Column(
                children: [

                  Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: FadeInImage.assetNetwork(
                        placeholder: Images.placeholder,
                        image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls.productImageUrl}/${cart.product.image[0]}',
                        height: 70, width: 85, fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(cart.product.name, style: rubikMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                        SizedBox(height: 2),
                        RatingBar(rating: cart.product.rating.length > 0 ? double.parse(cart.product.rating[0].average) : 0.0, size: 12),
                        SizedBox(height: 5),
                        Text(
                          PriceConverter.convertPrice(context, cart.discountedPrice),
                          style: rubikBold,
                        ),
                        cart.discountAmount > 0 ? Text(PriceConverter.convertPrice(context, cart.discountedPrice+cart.discountAmount), style: rubikBold.copyWith(
                          color: ColorResources.COLOR_GREY,
                          fontSize: Dimensions.FONT_SIZE_SMALL,
                          decoration: TextDecoration.lineThrough,
                        )) : SizedBox(),
                      ]),
                    ),

                    Container(
                      decoration: BoxDecoration(color: ColorResources.getBackgroundColor(context), borderRadius: BorderRadius.circular(5)),
                      child: Row(children: [
                        InkWell(
                          onTap: () {
                            if (cart.quantity > 1) {
                              Provider.of<CartProvider>(context, listen: false).setQuantity(false, cart, cart.maxQty, context);
                              Provider.of<CouponProvider>(context, listen: false).removeCouponData(true);
                            }else if(cart.quantity == 1) {
                              Provider.of<CartProvider>(context, listen: false).removeFromCart(cart);
                              Provider.of<CouponProvider>(context, listen: false).removeCouponData(true);
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            child: Icon(Icons.remove, size: 20),
                          ),
                        ),
                        Text(cart.quantity.toString(), style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE)),
                        InkWell(
                          onTap: () => Provider.of<CartProvider>(context, listen: false).setQuantity(true, cart, cart.maxQty, context),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            child: Icon(Icons.add, size: 20),
                          ),
                        ),
                      ]),
                    ),

                    !ResponsiveHelper.isMobile(context) ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                      child: IconButton(
                        onPressed: () {
                          Provider.of<CartProvider>(context, listen: false).removeFromCart(cart);
                        },
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                    ) : SizedBox(),


                  ]),

                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
