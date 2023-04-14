import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/auth_cubit.dart';
import 'package:test_app/auth_state.dart';
import 'package:test_app/home_screen.dart';

class SignUpScreen extends StatelessWidget {
  final String phone;
  final String otp;
  const SignUpScreen({Key? key, required this.phone, required this.otp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if(state is AuthLoggedInState) {
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(context, CupertinoPageRoute(
              builder: (context) => HomeScreen()
          ));
        }else if(state is AuthErrorState){
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(state.error),
                duration: Duration(milliseconds: 2000),
              )
          );
        }
      },
      builder: (context, state) {
        if(state is AuthLoadingState){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: CupertinoButton(
                onPressed: () {
                  BlocProvider.of<AuthCubit>(context).registerUser('Ayush', phone, 'email@email.com');
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(context, CupertinoPageRoute(
                      builder: (context) => HomeScreen()
                  ));
                },
                child: Text(
                    'Sign Up'
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
