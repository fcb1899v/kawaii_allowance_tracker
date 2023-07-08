import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(),
);

@immutable
class LoginState {
  final bool isLogin;
  const LoginState({
    this.isLogin = false,
  });
}

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(const LoginState());
  void setCurrentLogin(bool isLogin) {
    state = LoginState(isLogin: isLogin);
  }
}