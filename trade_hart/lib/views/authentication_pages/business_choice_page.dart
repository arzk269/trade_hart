import 'package:flutter/material.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/views/authentication_pages/sign_up_page.dart';

class BusinessChoicePage extends StatefulWidget {
  const BusinessChoicePage({
    super.key,
  });

  @override
  State<BusinessChoicePage> createState() => _BusinessChoicePageState();
}

class _BusinessChoicePageState extends State<BusinessChoicePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(
            height: manageHeight(context, 30),
          ),
          AppBarTitleText(
            title: "TradeHart",
            size: manageWidth(context, 27),
          ),
          Image.asset(
            "images/business_choice_bg.png",
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.55,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignUpPage(type: "seller"),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: manageHeight(context, 60),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 217, 216, 216),
                    blurRadius: 4,
                    spreadRadius: 0.5,
                  ),
                ],
                borderRadius: BorderRadius.circular(15),
                color: AppColors.mainColor,
              ),
              child: Center(
                child: Text(
                  "Créer une boutique en ligne",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: manageWidth(context, 16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: manageHeight(context, 35),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignUpPage(type: "provider"),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: manageHeight(context, 60),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 217, 216, 216),
                    blurRadius: 4,
                    spreadRadius: 0.5,
                  ),
                ],
                borderRadius: BorderRadius.circular(15),
                color: const Color.fromARGB(255, 255, 86, 131),
              ),
              child: Center(
                child: Text(
                  "Devenir prestataire de services",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: manageWidth(context, 16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
