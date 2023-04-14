import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthCubit() : super( AuthInitialState() ) {
    User? currentUser = _auth.currentUser;
    if(currentUser != null) {
      emit( AuthLoggedInState(currentUser) );
    }
    else {
      emit( AuthLoggedOutState() );
    }
  }

  String? _verificationId;

  void sendOTP(String phoneNumber) async {
    emit( AuthLoadingState() );
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      codeSent: (verificationId, forceResendingToken) {
        _verificationId = verificationId;
        emit( AuthCodeSentState() );
      },
      verificationCompleted: (phoneAuthCredential) {
        signInWithPhone(phoneAuthCredential);
      },
      verificationFailed: (error) {
        emit( AuthErrorState(error.message.toString()) );
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  void verifyOTP(String phone, String otp) async {
    emit( AuthLoadingState() );
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: _verificationId!, smsCode: otp);
    final isReg = await checkUserIfRegister(phone);
    if(isReg) signInWithPhone(credential);
  }

  void signInIfNotRegister(String userName, String phone, String email, String otp) async {
    try{
      emit(AuthLoadingState());
      registerUser(userName, phone, email);
      signInWithPhone(PhoneAuthProvider.credential(verificationId: _verificationId!, smsCode: otp));
    } on FirebaseException catch (e) {
      emit(AuthErrorState(e.message!));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  void signInWithPhone(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      if(userCredential.user != null) {
        emit( AuthLoggedInState(userCredential.user!) );
      }
    } on FirebaseAuthException catch(ex) {
      emit( AuthErrorState(ex.message.toString()) );
    }
  }

  void logOut() async {
    await _auth.signOut();
    emit( AuthLoggedOutState() );
  }

  void registerUser(String userName, String phone, String email) async{
    emit(AuthLoadingState());
    try{
      final user = {
        "user_name": userName,
        "phone_number": phone,
        "email": email
      };
      await FirebaseFirestore.instance.collection('users_new').add(user);
      emit(AuthRegisterSuccess());
    } on FirebaseException catch(e) {
      emit(AuthErrorState(e.message!));
    } catch(e){
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<bool> checkUserIfRegister(String phone) async {
    try {
      emit(AuthLoadingState());
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users_new')
          .where('phone_number', isEqualTo: phone)
          .get();
      if(result.docs.isEmpty) {
        emit(UserIsNotRegistered());
        return false;
      }else{
        emit(UserIsRegistered());
        return true;
      }
    } on FirebaseException catch (e) {
      emit(AuthErrorState(e.message!));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
    return false;
  }
}