import 'package:daily_tracker/main.dart';
import 'package:daily_tracker/screens/viewnotifiers/login_notifier.dart';
import 'package:daily_tracker/services/navigation_service.dart';
import 'package:daily_tracker/shared/ui_helpers.dart';
import 'package:daily_tracker/widgets/busy_button.dart';
import 'package:flutter/material.dart';
import 'package:provider_architecture/_viewmodel_provider.dart';
import '../../locator.dart';
import '../../widgets/text_box.dart';


class LoginScreen extends StatelessWidget{
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final NavigationService _navigationService = locator<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return ViewModelProvider<LoginNotifier>.withConsumer(
        viewModelBuilder: () => LoginNotifier(),
        builder: (context, model, child) => Scaffold(
            body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 38
                            )),]
                    ),
                    verticalSpaceLarge,
                    TextBox(
                        controller: emailController,
                        placeholder: 'Email'
                    ),
                    verticalSpaceSmall,
                    TextBox(
                      controller: passwordController,
                      placeholder: 'Password',
                      password: true,
                    ),
                    verticalSpaceMedium,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        BusyButton(
                          title: 'Login',
                          busy: model.busy,
                          onPressed: () {
                            print('email: ${emailController.text} | password ${passwordController.text}');
                            model.login(email: emailController.text, password: passwordController.text,);
                          },
                        )
                      ],
                    ),
                    verticalSpaceMedium,
                    GestureDetector(
                        onTap: (){
                          model.navigateToSignUp();
                        },
                        child: Text(
                          'Click here to make a new account',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        )
                    )
                  ],
                )
            )
        )
    );
  }
}