import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/auth_cubit.dart';
import 'package:test_app/auth_state.dart';
import 'package:test_app/sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String token = "";

  String? getToken() {
    final user = FirebaseAuth.instance.currentUser!;
    String? token;
    user.getIdTokenResult().then((value) {
      token = value.token!;
    });
    return token;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Home"),
      ),
      body: SafeArea(
        child: Container(
          child: Center(
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if(state is AuthLoggedOutState) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(context, CupertinoPageRoute(
                      builder: (context) => SignInScreen()
                  ));
                }

              },
              builder: (context, state) {
                return CupertinoButton(
                  onPressed: () {
                    BlocProvider.of<AuthCubit>(context).logOut();
                  },
                  child: const Text("Log Out"),
                );
              },
            ),

          ),
        ),
      ),
    );
  }
}