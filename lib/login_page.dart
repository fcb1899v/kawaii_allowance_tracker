import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'widget.dart';
import 'admob_banner.dart';
import 'constant.dart';
import 'home_widget.dart';
import 'extension.dart';
import 'login_viewmodel.dart';
import 'login_widget.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    ///State
    final login = ref.read(loginProvider.notifier);
    final isLoginProvider = ref.watch(loginProvider).isLogin;
    final isLogin = useState(isLoginProvider);
    final isSignUp = useState(false);
    final isLoading = useState(false);
    final isAllowData = useState([false, false]); //SaveLocalData, GetServerData
    final isPasswordVisible = useState(false);
    final isConfirmPassVisible = useState(false);

    ///Input
    final inputEmail = useState("");
    final inputPassword = useState("");
    final inputConfirmPass = useState("");
    final isEmailInput = useState(false);
    final isPasswordInput = useState(false);
    final isConfirmPassInput = useState(false);
    final localSaveDateTime = useState(0);
    final serverSaveDateTime = useState(0);

    ///Allow save local data to Firestore
    allowSaveLocalData() {
      initializeSharedPreferences().then((prefs) {
        isAllowData.value = [true, false];
        "isAllowSaveLocalDataKey".setSharedPrefBool(prefs, isAllowData.value[0]);
        "isAllowGetServerDataKey".setSharedPrefBool(prefs, isAllowData.value[1]);
        context.pushPage("/h");
      });
    }

    ///Allow get server data from Firestore
    allowGetServerData() {
      initializeSharedPreferences().then((prefs) {
        isAllowData.value = [false, true];
        "isAllowSaveLocalDataKey".setSharedPrefBool(prefs, isAllowData.value[0]);
        "isAllowGetServerDataKey".setSharedPrefBool(prefs, isAllowData.value[1]);
        context.pushPage("/h");
      });
    }

    ///Allow to get Firestore data
    allowSaveLocalDataAlertDialog(BuildContext context) =>
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) => CupertinoAlertDialog(
            title: alertAllowTitleText(context),
            content: Text(context.confirmStoreLocalData()),
            actions: [
              TextButton(
                child: alertJudgeButtonText(context, "no", transpBlackColor),
                onPressed: () => context.pushPage("/h"),
              ),
              TextButton(
                child: alertJudgeButtonText(context, "ok", purpleColor),
                onPressed: () => allowSaveLocalData(),
              ),
            ],
          ),
        );

    ///Allow to get Firestore data
    allowGetServerDataAlertDialog(BuildContext context) =>
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) => CupertinoAlertDialog(
            title: alertAllowTitleText(context),
            content: Text(context.confirmGetServerData()),
            actions: [
              TextButton(
                child: alertJudgeButtonText(context, "no", transpBlackColor),
                onPressed: () => allowSaveLocalDataAlertDialog(context),
              ),
              TextButton(
                child: alertJudgeButtonText(context, "ok", purpleColor),
                onPressed: () => allowGetServerData(),
              ),
            ],
          ),
        );

    ///Success Login
    successLogin(FirebaseAuth auth) async {
      isLogin.value = (auth.currentUser != null);
      login.setCurrentLogin(isLogin.value);
      "isLogin: ${isLogin.value}".debugPrint();
      showSuccessSnackBar(context, context.loginSuccess());
      initializeSharedPreferences().then((prefs) async {
        serverSaveDateTime.value = await getServerSaveDateTime();
        localSaveDateTime.value = "localSaveDateTimeKey".getSharedPrefInt(prefs, DateTime.now().toDateTimeInt());
        (serverSaveDateTime.value != localSaveDateTime.value && serverSaveDateTime.value != DateTime.now().toDateTimeInt()) ?
          allowGetServerDataAlertDialog(context): allowSaveLocalData();
      });
      isLoading.value = false;
    }

    /// Try Login
    tryLogin() async {
      if (isEmailInput.value && isPasswordInput.value && isConfirmPassInput.value && !isLoading.value) {
        isLoading.value = true;
        final auth = FirebaseAuth.instance;
        auth.setLanguageCode(context.lang());
        try {
          UserCredential result = await auth.signInWithEmailAndPassword(
            email: inputEmail.value,
            password: inputPassword.value
          );
          User? user = result.user;
          if (user != null && user.emailVerified) {
            successLogin(auth);
          } else if (user != null) {
            await user.sendEmailVerification();
            showSuccessSnackBar(context, context.sentVerifiedEmail());
            isLoading.value = false;
          }
        } on FirebaseAuthException catch (e) {
          showFailedSnackBar(context, context.loginFailed(), context.loginErrorCodeMessage(e.code, "login"));
          isLoading.value = false;
        }
      }
    }

    /// Try Sign Up
    trySignup() async {
      if (isEmailInput.value && isPasswordInput.value && isConfirmPassInput.value && !isLoading.value) {
        isLoading.value = true;
        final auth = FirebaseAuth.instance;
        auth.setLanguageCode(context.lang());
        "${context.lang()}".debugPrint();
        try {
          UserCredential result = await auth.createUserWithEmailAndPassword(
            email: inputEmail.value,
            password: inputPassword.value,
          );
          User? user = result.user;
          if (user != null) {
            await user.sendEmailVerification();
            showSuccessSnackBar(context, context.sentVerifiedEmail());
            await Future.delayed(new Duration(seconds: 2)).then((_) => isSignUp.value = false);
            isLoading.value = false;
          } else {
            showFailedSnackBar(context, context.sendMailError(), context.signupErrorMessage());
            isLoading.value = false;
          }
        } on FirebaseAuthException catch (e) {
          showFailedSnackBar(context, context.signupFailed(), context.loginErrorCodeMessage(e.code, "signup"));
          isLoading.value = false;
        }
      }
    }

    /// Try Password Reset
    tryPasswordReset() async {
      if (isEmailInput.value && !isLoading.value) {
        isLoading.value = true;
        final auth = FirebaseAuth.instance;
        auth.setLanguageCode(context.lang());
        "${context.lang()}".debugPrint();
        try {
          await auth.sendPasswordResetEmail(email: inputEmail.value);
          showSuccessSnackBar(context, context.sentPassResetMail());
          isLoading.value = false;
          context.popPage();
        } on FirebaseAuthException catch (e) {
          showFailedSnackBar(context, context.sendMailError(), context.loginErrorCodeMessage(e.code, ""));
          isLoading.value = false;
          context.popPage();
        }
      }
    }

    ///On change input textField
    //Email
    onChangeInputEmail(String value) {
      inputEmail.value = value.isNotEmpty ? value : "";
      isEmailInput.value = RegExp(emailValidation).hasMatch(value);
      "email: $value, ${isEmailInput.value}".debugPrint();
    }
    //Password
    onChangeInputPassword(String value) {
      inputPassword.value = (value.length > 0) ? value : "";
      isPasswordInput.value = RegExp(passwordValidation).hasMatch(value);
      "password: $value, ${isPasswordInput.value}".debugPrint();
    }
    //Confirm Password
    onChangeInputConfirmPass(String value) {
      inputConfirmPass.value = (value.length > 0) ? value : "";
      isConfirmPassInput.value = (inputConfirmPass.value == inputPassword.value);
      "confirmPass: $value, ${isConfirmPassInput.value}".debugPrint();
    }

    changeVisible(String input) {
      if (input == "password") isPasswordVisible.value = !isPasswordVisible.value;
      if (input == "confirmPass") isConfirmPassVisible.value = !isConfirmPassVisible.value;
    }

    loginFormField(String input, bool isVisible) =>
        Container(
          margin: EdgeInsets.only(bottom: context.loginTextFieldMarginBottom()),
          child: Stack(children: [
            TextFormField(
              style: loginTextStyle(context, transpBlackColor),
              decoration: loginInputDecoration(context, input),
              inputFormatters: input.loginInputFormat(),
              cursorColor: purpleColor,
              autofocus: true,
              obscureText: input.isLoginObscureText(isVisible),
              onChanged: (value) {
                if (input == "email") onChangeInputEmail(value);
                if (input == "password") onChangeInputPassword(value);
                if (input == "confirmPass") onChangeInputConfirmPass(value);
              }
            ),
            if (input == "password") GestureDetector(child: loginSuffixIcon(context, isPasswordVisible.value),
              onTap: () => changeVisible(input),
            ),
            if (input == "confirmPass") GestureDetector(child: loginSuffixIcon(context, isConfirmPassVisible.value),
              onTap: () => changeVisible(input),
            ),
          ]),
        );

    passwordResetDialog() =>
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: alertTitleText(context, context.passwordReset()),
            content: TextFormField(
              style: textFieldTextStyle(context),
              decoration: loginInputDecoration(context, "reset"),
              inputFormatters: inputEmailFormat,
              cursorColor: purpleColor,
              cursorWidth: alertCursorWidth,
              cursorHeight: alertCursorHeight,
              autofocus: true,
              obscureText: false,
              onChanged: (value) => onChangeInputEmail(value),
            ),
            actions: [
              TextButton(child: alertJudgeButtonText(context, "cancel", transpBlackColor),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(child: alertJudgeButtonText(context, "ok", purpleColor),
                onPressed: () => tryPasswordReset(),
              ),
            ],
          ),
        );

    useEffect(() {
      Future.delayed(Duration.zero, () {
        FocusScope.of(context).requestFocus(FocusNode());
      });
      return null;
    }, []);

    useEffect(() {
      isConfirmPassInput.value = (!isSignUp.value);
      return null;
    }, [isSignUp.value]);

    return Stack(children: [
      Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: transpColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight),
          child: AppBar(
            leading: IconButton(
              icon: Icon(backIcon, color: whiteColor, size: appBarIconSize),
              onPressed: () => (isSignUp.value) ? {isSignUp.value = false}: context.pushPage("/h"),
            ),
            title: appBarTitleText(context, context.loginAppBarTitleText(isSignUp.value)),
            automaticallyImplyLeading: false,
            backgroundColor: purpleColor,
            centerTitle: true,
            bottom: appBarBottomLine(),
          ),
        ),
        body: Container(
          decoration: backgroundDecoration(),
          child: Center(
            child: Column(children: [
              Spacer(flex: 1),
              loginTitleText(context),
              ClipRRect(
                borderRadius: BorderRadius.circular(context.loginInputAreaRadius()),
                child: Container(
                  width: context.loginInputAreaWidth(),
                  padding: EdgeInsets.all(context.loginInputAreaPadding()),
                  color: whiteColor,
                  child: Column(children: [
                    loginFormField("email", false),
                    loginFormField("password", isPasswordVisible.value),
                    if (isSignUp.value) loginFormField("confirmPass", isConfirmPassVisible.value),
                    GestureDetector(
                      child: loginButtonImage(context, isSignUp.value, isEmailInput.value, isPasswordInput.value, isConfirmPassInput.value),
                      onTap: () => (isSignUp.value) ? trySignup(): tryLogin(),
                    ),
                    if (!isSignUp.value) GestureDetector(child: moveSignupText(context),
                      onTap: () => isSignUp.value = !isSignUp.value,
                    ),
                  ]),
                ),
              ),
              if (!isSignUp.value) GestureDetector(child: forgetPassText(context),
                onTap: () => passwordResetDialog()
              ),
              Spacer(flex: 2),
              AdBannerWidget(),
            ]),
          ),
        ),
      ),
      if (isLoading.value) myCircularProgressIndicator(context),
    ]);
  }
}