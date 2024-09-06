import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/model/identifyed_product.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/views/main_page_components/pages/cart_page.dart';
import 'package:trade_hart/views/main_page_components/product_details_components/details_rate_view.dart';

class ProductDetailsPage extends StatefulWidget {
  final IdentifyedProduct detailedProduct;
  const ProductDetailsPage({super.key, required this.detailedProduct});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(
          children: [
            SizedBox(
              child: Image.asset(
                widget.detailedProduct.product.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 320,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 30, left: 15, right: 15),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      CupertinoIcons.clear_thick_circled,
                      color: const Color.fromARGB(255, 141, 141, 141)
                          .withOpacity(0.8),
                      size: 30,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return CartPage();
                        },
                      ));
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey.withOpacity(0.6),
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 20,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsetsDirectional.all(0.8),
                            height: 13.5,
                            width: 13.5,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7.75)),
                            child: Container(
                              margin: const EdgeInsets.only(top: 0),
                              height: 12.5,
                              width: 12.5,
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6.25)),
                              child: const Center(
                                child: Text(
                                  "4",
                                  style: TextStyle(
                                      fontSize: 8, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            const SizedBox(
              width: 15,
            ),
            Text(widget.detailedProduct.product.name,
                style: GoogleFonts.workSans(
                    fontSize: 18, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text('\$${widget.detailedProduct.product.price}',
                style: GoogleFonts.workSans(
                  fontSize: 18,
                )),
            const SizedBox(
              width: 15,
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            const SizedBox(
              width: 15,
            ),
            DetailsRateStars(
                rate: widget.detailedProduct.product.rate,
                nbRates: widget.detailedProduct.product.nbRates),
            const Spacer(),
            Text("voir tous les avis",
                style: GoogleFonts.workSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueAccent)),
            const SizedBox(
              width: 15,
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            const SizedBox(
              width: 15,
            ),
            Text("Vendu par : ${widget.detailedProduct.seller.name}",
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                )),
            const Spacer(),
            Text("visiter la boutique",
                style: GoogleFonts.workSans(
                    fontSize: 12, color: Colors.blueAccent)),
            const SizedBox(
              width: 23.5,
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          margin: const EdgeInsets.only(left: 15, right: 15),
          child: Center(
            child: Text(widget.detailedProduct.product.description,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.justify,
                style: GoogleFonts.workSans(fontSize: 14, color: Colors.black)),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            const SizedBox(
              width: 15,
            ),
            Text("Voir tous les détails",
                style: GoogleFonts.workSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainColor)),
            const Icon(
              Icons.arrow_right,
              size: 15,
            ),
            const Spacer(),
            const Icon(
              CupertinoIcons.share,
              color: AppColors.iconColor2,
            ),
            const SizedBox(
              width: 15,
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            const SizedBox(
              width: 15,
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      offset: const Offset(0, 0),
                      blurRadius: 5,
                      spreadRadius: 0.4)
                ],
                borderRadius: BorderRadius.circular(30),
                color: const Color.fromARGB(255, 250, 102, 92),
              ),
              width: 200,
              height: 55,
              child: Center(
                child: Text("Add To Cart",
                    style: GoogleFonts.workSans(
                      color: Colors.white,
                      fontSize: 16.5,
                    )),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      offset: const Offset(0, 0),
                      blurRadius: 5,
                      spreadRadius: 0.4)
                ],
                borderRadius: BorderRadius.circular(30),
                color:
                    const Color.fromARGB(255, 119, 101, 172).withOpacity(0.4),
              ),
              width: 80,
              height: 55,
              child: const Icon(
                CupertinoIcons.heart,
                color: Color.fromARGB(255, 255, 111, 101),
                size: 32,
              ),
            ),
            const SizedBox(
              width: 15,
            )
          ],
        ),
        const SizedBox(
          height: 15,
        )
      ]),
    );
  }
}
