import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admob_banner.dart';
import 'firebase_manager.dart';
import 'constant.dart';
import 'extension.dart';
import 'common_widget.dart';

/// State notifier provider for login state management
/// Manages the global login state across the application
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) => LoginNotifier());

/// Immutable state class for login status
/// Contains the current login state information
@immutable
class LoginState {
  final bool isLogin;
  const LoginState({
    this.isLogin = false,
  });
}

/// State notifier class for managing login state
/// Provides methods to update the login state
class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(const LoginState());
  void setCurrentLogin(bool isLogin) {
    state = LoginState(isLogin: isLogin);
  }
}

/// Main login page widget for user authentication
/// Handles sign in, sign up, and password reset functionality
class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    /// State management variables for login functionality
    /// Controls login state, UI states, and data permissions
    final login = ref.read(loginProvider.notifier);
    final isLogin = ref.watch(loginProvider).isLogin;
    final isSignUp = useState(false);
    final isLoading = useState(false);
    final isAllowData = useState([false, false]);
    final isPasswordVisible = useState(false);
    final isConfirmPassVisible = useState(false);

    /// Input field state variables
    /// Manages user input for email, password, and confirm password
    final inputEmail = useState("");
    final inputPassword = useState("");
    final inputConfirmPass = useState("");
    final isEmailInput = useState(false);
    final isPasswordInput = useState(false);
    final isConfirmPassInput = useState(false);
    final localSaveDateTime = useState(0);
    final serverSaveDateTime = useState(0);

    /// Widget and manager instances
    /// Provides access to common UI components and data management
    final commonWidget = CommonWidget(context);
    final loginWidget = LoginWidget(context);
    final firestoreManager = FirestoreManager(context, isLogin: isLogin);

    /// Allow saving local data to Firestore
    /// Enables data synchronization from local storage to server
    allowSaveLocalData() {
      SharedPreferences.getInstance().then((prefs) {
        isAllowData.value = [true, false];
        "isAllowSaveLocalDataKey".setSharedPrefBool(prefs, isAllowData.value[0]);
        "isAllowGetServerDataKey".setSharedPrefBool(prefs, isAllowData.value[1]);
        if (context.mounted) context.pushPage("/h");
      });
    }

    /// Allow getting server data from Firestore
    /// Enables data synchronization from server to local storage
    allowGetServerData() {
      SharedPreferences.getInstance().then((prefs) {
        isAllowData.value = [false, true];
        "isAllowSaveLocalDataKey".setSharedPrefBool(prefs, isAllowData.value[0]);
        "isAllowGetServerDataKey".setSharedPrefBool(prefs, isAllowData.value[1]);
        if (context.mounted) context.pushPage("/h");
      });
    }

    /// Handle successful login process
    /// Manages post-login flow including data synchronization decisions
    successLogin(FirebaseAuth auth) async {
      login.setCurrentLogin((auth.currentUser != null));
      "isLogin: $isLogin".debugPrint();
      commonWidget.showSuccessSnackBar(context.loginSuccess());
      SharedPreferences.getInstance().then((prefs) async {
        serverSaveDateTime.value = await firestoreManager.getServerSaveDateTime();
        localSaveDateTime.value = "localSaveDateTimeKey".getSharedPrefInt(prefs, DateTime.now().toDateTimeInt());
        (
          serverSaveDateTime.value != localSaveDateTime.value &&
          serverSaveDateTime.value != DateTime.now().toDateTimeInt() &&
          context.mounted
        ) ? loginWidget.allowGetServerDataAlertDialog(
          onTap1st: () => allowGetServerData(),
          onTap2nd: () => allowSaveLocalData(),
        ): (
          serverSaveDateTime.value != localSaveDateTime.value &&
          serverSaveDateTime.value != DateTime.now().toDateTimeInt()
        ) ? null: allowSaveLocalData();
      });
      isLoading.value = false;
    }

    /// Attempt user login with Firebase authentication
    /// Validates input and handles authentication errors
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
            if (context.mounted) commonWidget.showSuccessSnackBar(context.sentVerifiedEmail());
            isLoading.value = false;
          }
        } on FirebaseAuthException catch (e) {
          if (context.mounted) commonWidget.showFailedSnackBar(context.loginFailed(), context.loginErrorCodeMessage(e.code, "login"));
          isLoading.value = false;
        }
      }
    }

    /// Attempt user sign up with Firebase authentication
    /// Creates new user account and sends verification email
    trySignup() async {
      if (isEmailInput.value && isPasswordInput.value && isConfirmPassInput.value && !isLoading.value) {
        isLoading.value = true;
        final auth = FirebaseAuth.instance;
        auth.setLanguageCode(context.lang());
        context.lang().debugPrint();
        try {
          UserCredential result = await auth.createUserWithEmailAndPassword(
            email: inputEmail.value,
            password: inputPassword.value,
          );
          User? user = result.user;
          if (user != null) {
            await user.sendEmailVerification();
            if (context.mounted) commonWidget.showSuccessSnackBar(context.sentVerifiedEmail());
            await Future.delayed(Duration(seconds: 2)).then((_) => isSignUp.value = false);
            isLoading.value = false;
          } else {
            if (context.mounted) commonWidget.showFailedSnackBar(context.sendMailError(), context.signupErrorMessage());
            isLoading.value = false;
          }
        } on FirebaseAuthException catch (e) {
          if (context.mounted) commonWidget.showFailedSnackBar(context.signupFailed(), context.loginErrorCodeMessage(e.code, "signup"));
          isLoading.value = false;
        }
      }
    }

    /// Attempt password reset via email
    /// Sends password reset email to user's email address
    tryPasswordReset() async {
      if (isEmailInput.value && !isLoading.value) {
        isLoading.value = true;
        final auth = FirebaseAuth.instance;
        auth.setLanguageCode(context.lang());
        context.lang().debugPrint();
        try {
          await auth.sendPasswordResetEmail(email: inputEmail.value);
          if (context.mounted) commonWidget.showSuccessSnackBar(context.sentPassResetMail());
          isLoading.value = false;
          if (context.mounted) context.popPage();
        } on FirebaseAuthException catch (e) {
          if (context.mounted) commonWidget.showFailedSnackBar(context.sendMailError(), context.loginErrorCodeMessage(e.code, ""));
          isLoading.value = false;
          if (context.mounted) context.popPage();
        }
      }
    }

    /// Input validation and change handlers
    /// Email input validation with regex pattern matching
    onChangeInputEmail(String value) {
      inputEmail.value = value.isNotEmpty ? value : "";
      isEmailInput.value = RegExp(emailValidation).hasMatch(value);
      "email: $value, ${isEmailInput.value}".debugPrint();
    }
    /// Password input validation with regex pattern matching
    onChangeInputPassword(String value) {
      inputPassword.value = value.isNotEmpty ? value : "";
      isPasswordInput.value = RegExp(passwordValidation).hasMatch(value);
      "password: $value, ${isPasswordInput.value}".debugPrint();
    }
    /// Confirm password validation against password field
    onChangeInputConfirmPass(String value) {
      inputConfirmPass.value = value.isNotEmpty ? value : "";
      isConfirmPassInput.value = (inputConfirmPass.value == inputPassword.value);
      "confirmPass: $value, ${isConfirmPassInput.value}".debugPrint();
    }

    /// Toggle password visibility for password fields
    /// Controls whether password text is visible or hidden
    changeVisible(String input) {
      if (input == "password") isPasswordVisible.value = !isPasswordVisible.value;
      if (input == "confirmPass") isConfirmPassVisible.value = !isConfirmPassVisible.value;
    }

    /// UseEffect for focus management
    /// Removes focus from input fields on page load
    useEffect(() {
      Future.delayed(Duration.zero, () {
        if (context.mounted) FocusScope.of(context).requestFocus(FocusNode());
      });
      return null;
    }, []);

    /// UseEffect for confirm password validation
    /// Disables confirm password validation when not in sign up mode
    useEffect(() {
      isConfirmPassInput.value = (!isSignUp.value);
      return null;
    }, [isSignUp.value]);

    /// Main widget build method
    /// Returns the complete login page UI structure
    return Stack(children: [
      Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: transpColor,
        /// AppBar with navigation and title
        appBar: loginWidget.loginAppBar(
          isSignUp: isSignUp.value,
          onPressed: () => (isSignUp.value) ? {isSignUp.value = false}: context.pushPage("/h"),
        ),
        /// Main body content with login form
        body: Container(
          decoration: commonWidget.backgroundDecoration(),
          child: Column(
            children: [
              Spacer(flex: 1),
              /// App title display
              loginWidget.loginTitleText(),
              /// Login form container with rounded corners
              ClipRRect(
                borderRadius: BorderRadius.circular(context.loginInputAreaRadius()),
                child: Container(
                  width: context.loginInputAreaWidth(),
                  padding: EdgeInsets.all(context.loginInputAreaPadding()),
                  color: whiteColor,
                  child: Column(children: [
                    /// Email input field
                    loginWidget.loginFormField("email",
                      isVisible: true,
                      onChanged: (value) => onChangeInputEmail(value),
                      onTapVisible: () {}
                    ),
                    /// Password input field with visibility toggle
                    loginWidget.loginFormField("password",
                      isVisible: isPasswordVisible.value,
                      onChanged: (value) => onChangeInputPassword(value),
                      onTapVisible: () => changeVisible("password")
                    ),
                    /// Confirm password field (only in sign up mode)
                    if (isSignUp.value) loginWidget.loginFormField("confirmPass",
                      isVisible: isConfirmPassVisible.value,
                      onChanged: (value) => onChangeInputConfirmPass(value),
                      onTapVisible: () => changeVisible("confirmPass")
                    ),
                    /// Login/Sign up button
                    loginWidget.loginButton(
                      isSignUp: isSignUp.value,
                      isEmailInput: isEmailInput.value,
                      isPasswordInput: isPasswordInput.value,
                      isConfirmPassInput: isConfirmPassInput.value,
                      onTap: () => (isSignUp.value) ? trySignup(): tryLogin(),
                    ),
                    /// Switch to sign up mode button (only in sign in mode)
                    if (!isSignUp.value) loginWidget.moveSignupButton(
                      onTap: () => isSignUp.value = !isSignUp.value,
                    ),
                  ]),
                ),
              ),
              /// Forgot password button (only in sign in mode)
              if (!isSignUp.value) loginWidget.forgetPassButton(
                onChanged: (value) => onChangeInputEmail(value),
                onConfirm:() => tryPasswordReset(),
              ),
              Spacer(flex: 3),
              /// Ad banner at bottom
              AdBannerWidget(),
            ]
          ),
        ),
      ),
      /// Loading indicator overlay
      if (isLoading.value) commonWidget.myCircularProgressIndicator(),
    ]);
  }
}

/// Login widget class that provides UI components for authentication
/// Contains all the widget methods for the login page including forms, buttons, and dialogs
class LoginWidget {

  final BuildContext context;
  const LoginWidget(this.context);

  /// Get common widget instance for shared UI components
  /// Provides access to common styling and widget methods
  CommonWidget commonWidget() => CommonWidget(context);

  /// AppBar widget for the login page
  /// Displays title and back navigation button
  PreferredSize loginAppBar({
    required bool isSignUp,
    required void Function() onPressed  ,
  }) => PreferredSize(
    preferredSize: Size.fromHeight(context.appBarHeight()),
    child: AppBar(
      leading: IconButton(
        icon: Icon(backIcon,
          color: whiteColor,
          size: context.appBarIconSize()
        ),
        onPressed: onPressed
      ),
      title: Text(context.loginAppBarTitleText(isSignUp),
        style: commonWidget().customAccentTextStyle(context.appBarFontSize(), true)
      ),
      automaticallyImplyLeading: false,
      backgroundColor: purpleColor,
      centerTitle: true,
      bottom: commonWidget().appBarBottomLine(),
    ),
  );

  /// App title text widget
  /// Displays the application title with custom styling and shadow effects
  Widget loginTitleText() => Container(
    alignment: Alignment.center,
    margin: EdgeInsets.only(bottom: context.loginTitleMarginBottom()),
    child: Text(context.appTitle(),
      style: TextStyle(
        color: whiteColor,
        fontSize: context.loginTitleSize(),
        fontFamily: context.customAccentFont(),
        fontWeight: FontWeight.bold,
        shadows: [commonWidget().customShadow(context, false)],
      )
    )
  );

  /// Login form field widget with visibility toggle
  /// Provides text input with icon, validation, and optional visibility toggle
  Widget loginFormField(String input, {
    required bool isVisible,
    required Function(String) onChanged,
    required Function() onTapVisible,
  }) => Container(
    margin: EdgeInsets.only(bottom: context.loginTextFieldMarginBottom()),
    child: Stack(children: [
      TextFormField(
        style: loginTextStyle(transpBlackColor),
        decoration: loginInputDecoration(input),
        inputFormatters: input.loginInputFormat(),
        cursorColor: purpleColor,
        autofocus: true,
        obscureText: input.isLoginObscureText(isVisible),
        onChanged: onChanged
      ),
      if (input != "email") GestureDetector(
        onTap: onTapVisible,
        child: Container(
          margin: EdgeInsets.only(
            top: context.loginVisibleMarginTop(),
            right: context.loginVisibleMarginRight(),
          ),
          alignment: Alignment.bottomRight,
          child: Icon(isVisible.visibleIcon(),
            color: isVisible.visibleIconColor(),
            size: context.loginIconSize(),
          )
        )
      ),
    ]),
  );

  /// Login/Sign up button widget
  /// Displays action button with validation-based styling
  Widget loginButton({
    required bool isSignUp,
    required bool isEmailInput,
    required bool isPasswordInput,
    required bool isConfirmPassInput,
    required void Function() onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.only(
        top: context.loginButtonMarginTop(),
        bottom: context.loginButtonMarginBottom()
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.loginButtonRadius()),
        child: Container(
          alignment: Alignment.center,
          width: context.loginButtonWidth(),
          height: context.loginButtonHeight(),
          color: (!(isEmailInput && isPasswordInput && isConfirmPassInput)).selectButtonColor(),
          child: Text(isSignUp ? context.trySignup(): context.tryLogin(),
            style: loginTextStyle(whiteColor),
          ),
        ),
      ),
    )
  );

  /// Switch to sign up mode button
  /// Allows users to toggle between sign in and sign up modes
  Widget moveSignupButton({
    required void Function() onTap
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.only(
        top: context.moveSignupMarginTop(),
        bottom: context.moveSignupMarginBottom()
      ),
      child: loginUnderLineText(context.trySignup(), purpleColor),
    )
  );

  /// Forgot password button
  /// Opens password reset dialog for email input
  Widget forgetPassButton({
    required Function(String) onChanged,
    required void Function() onConfirm
  }) => GestureDetector(
    onTap: () => passwordResetDialog(
      onChanged: onChanged,
      onConfirm: onConfirm,
    ),
    child: Container(
      margin: EdgeInsets.only(top: context.forgetPassMarginTop()),
      child: loginUnderLineText(context.forgotPass(), whiteColor)
    ),
  );

  /// Password reset dialog
  /// Provides email input for password reset functionality
  void passwordResetDialog({
    required Function(String) onChanged,
    required Function() onConfirm,
  }) => showDialog(context: context,
    builder: (context) => AlertDialog(
      title: commonWidget().alertTitleText(context.passwordReset()),
      content: TextFormField(
        style: commonWidget().textFieldTextStyle(),
        decoration: loginInputDecoration("reset"),
        inputFormatters: inputEmailFormat,
        cursorColor: purpleColor,
        cursorWidth: alertCursorWidth,
        cursorHeight: alertCursorHeight,
        autofocus: true,
        obscureText: false,
        onChanged: (value) => onChanged
      ),
      actions: [
        commonWidget().alertCancelButton(),
        const Spacer(),
        commonWidget().alertJudgeButton(context.ok(),
          color: purpleColor,
          onTap: onConfirm,
        ),
      ],
    ),
  );

  /// Dialog for allowing server data retrieval
  /// Prompts user to choose between local and server data synchronization
  void allowGetServerDataAlertDialog({
    required void Function() onTap1st,
    required void Function() onTap2nd,
  }) => showDialog(context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: alertAllowTitleText(),
      content: Text(context.confirmGetServerData()),
      actions: [
        commonWidget().alertJudgeButton(context.no(),
          color: transpBlackColor,
          onTap: () => allowSaveLocalDataAlertDialog(onTap2nd: onTap2nd),
        ),
        const Spacer(),
        commonWidget().alertJudgeButton(context.ok(),
          color:purpleColor,
          onTap: onTap1st,
        ),
      ],
    ),
  );

  /// Dialog for allowing local data saving
  /// Prompts user to confirm local data storage preference
  void allowSaveLocalDataAlertDialog({
    required void Function() onTap2nd
  }) => showDialog(context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: alertAllowTitleText(),
      content: Text(context.confirmStoreLocalData()),
      actions: [
        commonWidget().alertJudgeButton(context.no(),
          color: transpBlackColor,
          onTap: () => context.pushPage("/h"),
        ),
        const Spacer(),
        commonWidget().alertJudgeButton(context.ok(),
            color: purpleColor,
            onTap: onTap2nd
        ),
      ],
    ),
  );

  /// Input decoration for login form fields
  /// Provides consistent styling for text input fields in login forms
  InputDecoration loginInputDecoration(String input) => InputDecoration(
    prefixIcon: Icon(input.loginPrefixIcon(),
      color: transpLightBlackColor,
      size: context.loginIconSize(),
    ),
    prefixIconConstraints: BoxConstraints(
      minWidth: context.loginInputIconSpace(),
      minHeight: context.loginInputIconSpace(),
    ),
    focusedBorder: commonWidget().textFieldUnderLineBorder(purpleColor),
    counterStyle: TextStyle(fontSize: context.loginCounterCharSize()),
    hintText: context.loginFormHint(input),
    hintStyle: commonWidget().textFieldHintStyle(context.loginHintSize()),
    labelText: context.loginFormLabel(input),
    labelStyle: loginTextStyle(purpleColor),
  );

  /// Text style for login form elements
  /// Provides consistent typography for login page text elements
  TextStyle loginTextStyle(Color color) => TextStyle(
    color: color,
    fontSize: context.loginFontSize(),
    fontFamily: "defaultFont",
    fontWeight: FontWeight.bold,
  );

  /// Underlined text widget for interactive elements
  /// Creates clickable text with underline decoration
  Text loginUnderLineText(String title, Color color) => Text(title,
    style: TextStyle(
      color: color,
      fontSize: context.loginFontSize(),
      fontFamily: "defaultFont",
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    ),
  );

  /// Alert dialog title with info icon
  /// Creates title row with information icon and text
  Widget alertAllowTitleText() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(CupertinoIcons.info, size: alertIconSize),
        SizedBox(width: alertIconMargin),
        CommonWidget(context).alertTitleText(context.confirmation()),
      ]
  );
}