import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trade_hart/authentication_service.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';

class ResetPassWordPage extends StatefulWidget {
  ResetPassWordPage({super.key});

  @override
  State<ResetPassWordPage> createState() => _ResetPassWordPageState();
}

class _ResetPassWordPageState extends State<ResetPassWordPage> {
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: AppBarTitleText(
              title: "Mot de passe oublié", size: manageWidth(context, 18)),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            SizedBox(
              height: manageHeight(context, 45),
            ),
            Center(
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                radius: manageWidth(context, 70),
                child: Center(
                  child: Icon(
                    CupertinoIcons.lock,
                    size: manageWidth(context, 65),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: manageHeight(context, 45),
            ),
            AuthTextField(
              controller: emailController,
              hintText: "email",
              obscuretext: false,
            ),
            SizedBox(
              height: manageHeight(context, 35),
            ),
            TextButton(
              onPressed: () async {
                await AuthService().resetPassword(emailController.text);
                setState(() {});
              },
              child: Text(
                "Réinitialiser le mot de passe",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: manageWidth(context, 20),
              ),
              child: Text(
                resetMessage,
                style: TextStyle(
                  color: AppColors.mainColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        )));
  }
}
