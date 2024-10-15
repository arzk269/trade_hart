import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({super.key});
  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController adressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController codePostalController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleText(
            title: "TradeHart Inscription", size: manageWidth(context, 20)),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(
            height: manageHeight(context, 15),
          ),
          Center(
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              radius: manageWidth(context, 50),
              child: Center(
                child: Icon(
                  CupertinoIcons.person,
                  size: manageWidth(context, 45),
                ),
              ),
            ),
          ),
          SizedBox(
            height: manageHeight(context, 25),
          ),
          // NAME FIELD
          AuthTextField(
            controller: nameController,
            hintText: "Nom",
            obscuretext: false,
          ),
          SizedBox(
            height: manageHeight(context, 20),
          ),
          // FIRST NAME FIELD
          AuthTextField(
            controller: firstNameController,
            hintText: "Prénom",
            obscuretext: false,
          ),
          SizedBox(
            height: manageHeight(context, 20),
          ),
          // ADRESS FIELD
          AuthTextField(
            controller: adressController,
            hintText: "Adresse",
            obscuretext: false,
          ),
          SizedBox(
            height: manageHeight(context, 20),
          ),
          // CODE POSTAL FIELD
          AuthTextField(
            controller: codePostalController,
            hintText: "Code postal",
            obscuretext: false,
            keyboardType: TextInputType.number,
          ),
          SizedBox(
            height: manageHeight(context, 20),
          ),
          // CITY FIELD
          AuthTextField(
            controller: cityController,
            hintText: "Ville",
            obscuretext: false,
          ),
          SizedBox(
            height: manageHeight(context, 25),
          ),
          GestureDetector(
            onTap: () async {},
            child: Container(
              width: manageWidth(context, 200),
              height: manageHeight(context, 50),
              decoration: BoxDecoration(
                color: AppColors.mainColor,
                borderRadius: BorderRadius.circular(manageWidth(context, 25)),
              ),
              child: Center(
                child: Text(
                  "Suivant",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: manageWidth(context, 16),
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
