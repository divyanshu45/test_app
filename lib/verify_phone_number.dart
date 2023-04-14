import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/SignUpScreen.dart';
import 'package:test_app/auth_cubit.dart';
import 'package:test_app/auth_state.dart';
import 'package:test_app/home_screen.dart';

class VerifyPhoneNumberScreen extends StatelessWidget {
  final String phoneNUmber;

  TextEditingController otpController = TextEditingController();

  VerifyPhoneNumberScreen({super.key, required this.phoneNUmber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Verify Phone Number"),
      ),
      body: SafeArea(
        child: ListView(
          children: [

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  TextField(
                    controller: otpController,
                    maxLength: 6,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "6-Digit OTP",
                        counterText: ""
                    ),
                  ),

                  SizedBox(height: 10,),

                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {

                      if(state is AuthLoggedInState) {
                        Navigator.popUntil(context, (route) => route.isFirst);
                        Navigator.pushReplacement(context, CupertinoPageRoute(
                            builder: (context) => HomeScreen()
                        ));
                      }
                      else if(state is AuthErrorState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(state.error),
                              duration: Duration(milliseconds: 2000),
                            )
                        );
                      }else if(state is UserIsNotRegistered){
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text('User is not register'),
                              duration: Duration(milliseconds: 2000),
                            )
                        );
                        Navigator.pushReplacement(context, CupertinoPageRoute(
                            builder: (context) => SignUpScreen(phone: phoneNUmber, otp: otpController.text)
                        ));
                      }else if(state is UserIsRegistered){
                        Navigator.pushReplacement(context, CupertinoPageRoute(
                            builder: (context) => HomeScreen()
                        ));
                      }

                    },
                    builder: (context, state) {

                      if(state is AuthLoadingState) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: CupertinoButton(
                          onPressed: () {

                            BlocProvider.of<AuthCubit>(context).verifyOTP(phoneNUmber, otpController.text);

                          },
                          color: Colors.blue,
                          child: Text("Verify"),
                        ),
                      );
                    },
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}