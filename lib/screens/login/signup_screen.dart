import 'package:daily_tracker/screens/viewnotifiers/signup_notifier.dart';
import 'package:daily_tracker/shared/ui_helpers.dart';
import 'package:daily_tracker/widgets/busy_button.dart';
import 'package:daily_tracker/widgets/expansion_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_architecture/_viewmodel_provider.dart';
import '../../widgets/text_box.dart';

class SignUpScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ViewModelProvider<SignUpNotifier>.withConsumer(
      viewModelBuilder: () => SignUpNotifier(),
      builder: (context, model, child) => Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text('Sign Up', style: TextStyle(fontSize: 38)),
              ]),
              verticalSpaceLarge,
              TextBox(controller: fullNameController, placeholder: 'Full Name'),
              verticalSpaceSmall,
              TextBox(controller: emailController, placeholder: 'Email'),
              verticalSpaceSmall,
              TextBox(
                controller: passwordController,
                placeholder: 'Password',
                password: true,
              ),
              verticalSpaceSmall,
              ExpansionList<String>(
                items: ['Admin', 'User'],
                title: model.selectedRole,
                onItemSelected: model.setSelectedRole,
              ),
              verticalSpaceMedium,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BusyButton(
                    title: 'Sign Up',
                    busy: model.busy,
                    onPressed: () {
                      print(
                          'email: ${emailController.text} | password ${passwordController.text}');
                      model.signUp(
                          email: emailController.text,
                          password: passwordController.text,
                          fullName: fullNameController.text);
                    },
                  )
                ],
              ),
              GestureDetector(
                  onTap: (){
                    model.navigateToLogin();
                  },
                  child: Text(
                    'Click here to sign in',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
