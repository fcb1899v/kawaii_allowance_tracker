import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_widget.dart';
import 'login_viewmodel.dart';
import 'admob_banner.dart';
import 'extension.dart';
import 'home_chart.dart';
import 'home_widget.dart';
import 'constant.dart';
import 'widget.dart';

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    ///State
    final login = ref.read(loginProvider.notifier);
    final isPremiumProvider = ref.watch(loginProvider).isLogin;
    final isLogin = useState(isPremiumProvider);
    final isSummary = useState(false);
    final isLoading = useState(false);
    final isAllowData = useState([false, false]);

    ///Allowance Data
    final index = useState(0);
    final maxIndex = useState(0);
    final listNumber = useState([1]);
    final allowanceDate = useState([[0]]);
    final allowanceItem = useState([[""]]);
    final allowanceAmnt = useState([[0.0]]);
    final balance = useState([0.0]);
    final percent = useState([0.0]);
    final spends = useState([0.0]);
    final assets = useState([0.0]);

    ///Personal Data
    final name = useState("");
    final unit = useState("\$");
    final initialAssets = useState(0.0);
    final targetAssets = useState(0.0);
    final currentDate = DateTime.now().toDateString();
    final currentDateTime = DateTime.now().toDateTimeInt();
    final startDate = useState(currentDate);
    final localSaveDateTime = useState(0);
    final serverSaveDateTime = useState(0);

    ///Input Data
    final isInput = useState(false);
    final inputName = useState("");
    final inputInitial = useState(0.0);
    final isInitialInput = useState(false);
    final inputTarget = useState(0.0);
    final isTargetInput = useState(false);
    final inputDay = useState(0);
    final inputItem = useState("");
    final inputAmount = useState(0.0);
    final isDayInput = useState(false);
    final isItemInput = useState(false);
    final isAmountInput = useState(false);

    /// Reset Login State
    resetLoginState(SharedPreferences prefs, FirebaseAuth auth) {
      isLogin.value = (auth.currentUser != null);
      login.setCurrentLogin(isLogin.value);
      "Login: ${isLogin.value}".debugPrint();
      isAllowData.value = [false, false];
      "isAllowSaveLocalDataKey".setSharedPrefBool(prefs, isAllowData.value[0]);
      "isAllowGetServerDataKey".setSharedPrefBool(prefs, isAllowData.value[1]);
    }

    /// Logout
    logout(SharedPreferences prefs) async {
      if (!isLoading.value) {
        isLoading.value = true;
        FirebaseAuth auth = FirebaseAuth.instance;
        try {
          await auth.signOut().then((_) => resetLoginState(prefs, auth));
          showSuccessSnackBar(context, context.logoutSuccess());
          isLoading.value = false;
        } on FirebaseAuthException catch (_) {
          showSuccessSnackBar(context, context.logoutFailed());
          isLoading.value = false;
        }
      }
    }

    ///Delete Account
    deleteAccount(SharedPreferences prefs) async {
      if (!isLoading.value) {
        isLoading.value = true;
        FirebaseAuth auth = await FirebaseAuth.instance;
        try {
          User? user = await auth.currentUser;
          "user: ${user}".debugPrint();
          await user?.delete();
          await resetLoginState(prefs, auth);
          showSuccessSnackBar(context, context.deleteAccountSuccess());
          isLoading.value = false;
          context.popPage();
        } catch (e) {
          showSuccessSnackBar(context, context.deleteAccountFailed());
          isLoading.value = false;
          context.popPage();
        }
      }
    }

    ///Set allowance data in local storage
    setAllowanceData(prefs) async {
      await setAllowanceDataFirestore(context, prefs, isLogin.value, isAllowData.value[0], allowanceDate.value, allowanceItem.value, allowanceAmnt.value);
      maxIndex.value = await allowanceAmnt.value.calcMaxIndex();
      listNumber.value = await allowanceAmnt.value.calcListNumber();
      percent.value = await allowanceAmnt.value.calcPercent(maxIndex.value);
      balance.value = await allowanceAmnt.value.calcBalance(maxIndex.value);
      spends.value = await allowanceAmnt.value.calcSpends(maxIndex.value);
      assets.value = await balance.value.calcAssets(maxIndex.value, initialAssets.value);
    }

    ///Set all allowance data in firestore
    setAllDataFirestore(SharedPreferences prefs) async {
      if (isLogin.value && isAllowData.value[0]) {
        try {
          User? user = await FirebaseAuth.instance.currentUser;
          DocumentReference docRef = await FirebaseFirestore.instance.collection('users').doc(user!.uid);
          await docRef.set({"startDateKey": startDate.value}, SetOptions(merge: true));
          await docRef.set({"nameKey": name.value}, SetOptions(merge: true));
          await docRef.set({"unitKey": unit.value}, SetOptions(merge: true));
          await docRef.set({"initialAssetsKey": initialAssets.value}, SetOptions(merge: true));
          // await docRef.set({"targetAssetsKey": targetAssets.value}, SetOptions(merge: true));
          await docRef.set({"dateKey": jsonEncode(allowanceDate.value)}, SetOptions(merge: true));
          await docRef.set({"itemKey": jsonEncode(allowanceItem.value)}, SetOptions(merge: true));
          await docRef.set({"amntKey": jsonEncode(allowanceAmnt.value)}, SetOptions(merge: true));
          await docRef.set({"serverSaveDateTimeKey": currentDateTime}, SetOptions(merge: true));
          isAllowData.value = [true, true];
          await "serverSaveDateTimeKey".setSharedPrefInt(prefs, currentDateTime);
          await "isAllowGetServerDataKey".setSharedPrefBool(prefs, isAllowData.value[1]);
          showSuccessSnackBar(context, context.storeDataSuccess());
          isLoading.value = false;
        } on FirebaseException catch (e) {
          '${e.code}: $e'.debugPrint();
          showFailedSnackBar(context, context.storeDataFailed(), null);
          isLoading.value = false;
        }
      }
    }

    ///Get all allowance data from firestore
    getAllDataFirestore(SharedPreferences prefs) async {
      if (isLogin.value && isAllowData.value[1]) {
        try {
          User? user = await FirebaseAuth.instance.currentUser;
          DocumentReference docRef = await FirebaseFirestore.instance.collection('users').doc(user!.uid);
          DocumentSnapshot snapshot = await docRef.get();
          Map<String, dynamic>? data = await snapshot.data() as Map<String, dynamic>?;
          if (data != null) {
            "data: $data".debugPrint();
            name.value = await data.getFirestoreString(prefs, "nameKey", "");
            unit.value = await data.getFirestoreString(prefs, "unitKey", context.defaultUnit());
            initialAssets.value = await data.getFirestoreDouble(prefs, "initialAssetsKey", 0.0);
            targetAssets.value = await data.getFirestoreDouble(prefs, "targetAssetsKey", 0.0);
            startDate.value = await data.getFirestoreString(prefs, "startDateKey", currentDate);
            index.value = await startDate.value.toCurrentIndex();
            allowanceDate.value = await data.getFirestoreDate(prefs);
            allowanceItem.value = await data.getFirestoreItem(prefs);
            allowanceAmnt.value = await data.getFirestoreAmnt(prefs);
            maxIndex.value = await allowanceAmnt.value.calcMaxIndex();
            listNumber.value = await allowanceAmnt.value.calcListNumber();
            percent.value = await allowanceAmnt.value.calcPercent(maxIndex.value);
            balance.value = await allowanceAmnt.value.calcBalance(maxIndex.value);
            spends.value = await allowanceAmnt.value.calcSpends(maxIndex.value);
            assets.value = await balance.value.calcAssets(maxIndex.value, initialAssets.value);
            showSuccessSnackBar(context, context.getDataSuccess());
            localSaveDateTime.value = await currentDateTime;
            isAllowData.value = [true, true];
            await "localSaveDateTimeKey".setSharedPrefInt(prefs, currentDateTime);
            await "isAllowSaveLocalDataKey".setSharedPrefBool(prefs, isAllowData.value[0]);
            isLoading.value = false;
          } else {
            showFailedSnackBar(context, context.noDataAvailable(), null);
            isLoading.value = false;
          }
        } on FirebaseException catch (e) {
          '${e.code}: $e'.debugPrint();
          showFailedSnackBar(context, context.getDataFailed(), null);
          isLoading.value = false;
        }
      }
    }

    ///Get all allowance data from local storage
    getAllowanceData(prefs) async {
      name.value = await "nameKey".getSharedPrefString(prefs, "");
      unit.value = await "unitKey".getSharedPrefString(prefs, context.defaultUnit());
      initialAssets.value = await "initialAssetsKey".getSharedPrefDouble(prefs, 0.0);
      targetAssets.value = await "targetAssetsKey".getSharedPrefDouble(prefs, 0.0);
      startDate.value = await "startDateKey".getSharedPrefString(prefs, currentDate);
      index.value = await startDate.value.toCurrentIndex();
      allowanceDate.value = await "dateKey".getSharedPrefString(prefs, "[[0]]").toString().toListListDate();
      allowanceItem.value = await "itemKey".getSharedPrefString(prefs, "[[""]]").toString().toListListItem();
      allowanceAmnt.value = await "amntKey".getSharedPrefString(prefs, "[[0.0]]").toString().toListListAmnt();
      maxIndex.value = await allowanceAmnt.value.calcMaxIndex();
      listNumber.value = await allowanceAmnt.value.calcListNumber();
      percent.value = await allowanceAmnt.value.calcPercent(maxIndex.value);
      balance.value = await allowanceAmnt.value.calcBalance(maxIndex.value);
      spends.value = await allowanceAmnt.value.calcSpends(maxIndex.value);
      assets.value = await balance.value.calcAssets(maxIndex.value, initialAssets.value);
      "toSetFirestore: ${isAllowData.value[0] && !isAllowData.value[1]}".debugPrint();
      await (isAllowData.value[0] && !isAllowData.value[1]) ? setAllDataFirestore(prefs): {isLoading.value = false};
    }

    ///Get allowance data for initialization
    getInitializeData(SharedPreferences prefs) async {
      isLoading.value = true;
      try {
        FirebaseAuth auth = FirebaseAuth.instance;
        if (!("isStartKey".getSharedPrefBool(prefs, false))) {
          await auth.signOut();
          "startDateKey".setSharedPrefString(prefs, startDate.value);
          "isStartKey".setSharedPrefBool(prefs, true);
        }
        isLogin.value = (auth.currentUser != null);
        login.setCurrentLogin(isLogin.value);
        "isLogin: ${isLogin.value}, user: ${(isLogin.value) ? auth.currentUser!.uid: "none"}".debugPrint();
        localSaveDateTime.value = "localSaveDateTimeKey".getSharedPrefInt(prefs, currentDateTime);
        serverSaveDateTime.value = "serverSaveDateTimeKey".getSharedPrefInt(prefs, currentDateTime);
        isAllowData.value[0] = await "isAllowSaveLocalDataKey".getSharedPrefBool(prefs, false);
        isAllowData.value[1] = await "isAllowGetServerDataKey".getSharedPrefBool(prefs, false);
        "toFirestore: ${!isAllowData.value[0] && isAllowData.value[1]}".debugPrint();
        (!isAllowData.value[0] && isAllowData.value[1]) ? getAllDataFirestore(prefs): getAllowanceData(prefs);
      } catch (e) {
        "Error: $e".debugPrint();
        showFailedSnackBar(context, context.getDataFailed(), null);
        isLoading.value = false;
      }
    }

    sortAllowanceList() {
      final List<AllowanceList> sortList = allowanceAmnt.value[index.value].getAllowanceList(allowanceDate.value[index.value], allowanceItem.value[index.value]);
      sortList.sort((a,b) => a.date.compareTo(b.date));
      sortList.removeAt(0);
      sortList.add(AllowanceList(0, "", 0.0));
      allowanceDate.value[index.value] = sortList.getDateFromAllowanceList();
      allowanceItem.value[index.value] = sortList.getItemFromAllowanceList();
      allowanceAmnt.value[index.value] = sortList.getAmntFromAllowanceList();
    }

    ///Delete Allowance Data
    deleteAllowance(int id) {
      final int i = index.value;
      allowanceDate.value[i].removeAt(id);
      allowanceItem.value[i].removeAt(id);
      allowanceAmnt.value[i].removeAt(id);
      sortAllowanceList();
      initializeSharedPreferences().then((prefs) => setAllowanceData(prefs));
    }

    ///Change Summary
    changeSummary() {
      isSummary.value = !isSummary.value;
      index.value = startDate.value.toCurrentIndex();
      "isSummary: ${isSummary.value}".debugPrint();
    }

    ///Change Index(Month)
    changeIndex(bool isPlus) async {
      if (!isPlus && (index.value > 0)) index.value--;
      if (isPlus) index.value++;
      "index: ${index.value}".debugPrint();
      //Change Max Index
      if (isPlus && (index.value > maxIndex.value)) {
        allowanceDate.value.add([0]);
        allowanceItem.value.add([""]);
        allowanceAmnt.value.add([0.0]);
        initializeSharedPreferences().then((prefs) => setAllowanceData(prefs));
      }
    }

    ///On Change User Name
    onChangeName(String value) {
      "value: $value".debugPrint();
      if (value.isNotEmpty) inputName.value = value;
    }

    ///Set User Name
    setName() async {
      if (inputName.value.isNotEmpty) {
        name.value = inputName.value;
        inputName.value = "";
        initializeSharedPreferences().then((prefs) =>
          setStringFirestore(context, prefs, isLogin.value, isAllowData.value[0], "nameKey", name.value),
        );
      }
      context.popPage();
    }

    ///Set Money Unit
    setUnit(String value) async {
      "value: $value".debugPrint();
      if (value.isNotEmpty) {
        unit.value = value;
        initializeSharedPreferences().then((prefs) =>
          setStringFirestore(context, prefs, isLogin.value, isAllowData.value[0], "unitKey", unit.value),
        );
      }
      context.popPage();
    }

    ///On Change Initial Assets
    onChangeInitialAssets(String value) {
      "value: $value".debugPrint();
      isInput.value = value.setIsInput(false);
      inputInitial.value = value.setInputAmount(isInput.value, false, unit.value);
      isInitialInput.value = value.setIsInitialAssetsInput(isInput.value);
    }

    ///Set Initial Assets
    setInitialAssets() async {
      if (isInitialInput.value) {
        initialAssets.value = inputInitial.value;
        inputInitial.value = 0;
        initializeSharedPreferences().then((prefs) {
          setDoubleFirestore(context, prefs, isLogin.value, isAllowData.value[0], "initialAssetsKey", initialAssets.value);
          setAllowanceData(prefs);
        });
      }
      context.popPage();
    }

    ///On Change Target Assets
    onChangeTargetAssets(String value) {
      "value: $value".debugPrint();
      isInput.value = value.setIsInput(false);
      inputTarget.value = value.setInputAmount(isInput.value, false, unit.value);
      isTargetInput.value = value.setIsAmountInput(isInput.value);
    }

    ///Set Target Assets
    setTargetAssets() async {
      if (isTargetInput.value) {
        targetAssets.value = inputTarget.value;
        inputTarget.value = 0;
        initializeSharedPreferences().then((prefs) =>
          setDoubleFirestore(context, prefs, isLogin.value, isAllowData.value[0], "targetAssetsKey", targetAssets.value),
        );
      }
      context.popPage();
    }

    ///Select Date
    selectDate(DateTime? picked, int id) async {
      if (picked != null) {
        "picked: $picked.day".debugPrint();
        allowanceDate.value[index.value][id] = picked.day;
        sortAllowanceList();
        initializeSharedPreferences().then((prefs) => setAllowanceData(prefs));
      }
    }

    ///on Change Item
    onChangeItem(String value, bool isSpend) {
      "value: $value".debugPrint();
      isInput.value = value.isNotEmpty;
      inputItem.value =  value.setInputItem(context, isInput.value, isSpend);
      isItemInput.value = value.setIsItemInput(isInput.value, isSpend);
    }

    ///Rewrite Allowance Item
    rewriteAllowanceItem(int id) async {
      if (isItemInput.value) {
        allowanceItem.value[index.value][id] = inputItem.value;
        inputItem.value = "";
        initializeSharedPreferences().then((prefs) => setAllowanceData(prefs));
      }
      context.popPage();
    }

    ///On Change Amount
    onChangeAmount(String value, bool isSpend) {
      "value: $value".debugPrint();
      isInput.value = value.setIsInput(false);
      inputAmount.value = value.setInputAmount(isInput.value, isSpend, unit.value);
      isAmountInput.value = value.setIsAmountInput(isInput.value);
    }

    ///Change Allowance Amount
    rewriteAllowanceAmnt(int id) {
      if (isAmountInput.value) {
        allowanceAmnt.value[index.value][id] = inputAmount.value;
        inputAmount.value = 0.0;
        initializeSharedPreferences().then((prefs) => setAllowanceData(prefs));
      }
      context.popPage();
    }

    ///Set new Allowance or Spend
    setNewAllowance(bool isSpend) {
      if (isDayInput.value && isItemInput.value && isAmountInput.value) {
        allowanceDate.value[index.value].insert(0, inputDay.value);
        allowanceItem.value[index.value].insert(0, inputItem.value);
        allowanceAmnt.value[index.value].insert(0, inputAmount.value);
        sortAllowanceList();
        inputDay.value = 0;
        inputItem.value = "";
        inputAmount.value = 0.0;
        initializeSharedPreferences().then((prefs) => setAllowanceData(prefs));
      }
      context.popPage();
    }

    ///Set User Name Dialog
    nameFieldDialog() async =>
        await showDialog(context: context,
          builder: (context) => AlertDialog(
            title: alertTitleText(context, context.drawerAlertTitle("name")),
            content: TextField(
              controller: TextEditingController(),
              decoration: drawerAlertDecoration(context, "name"),
              keyboardType: TextInputType.name,
              cursorWidth: alertCursorWidth,
              cursorHeight: alertCursorHeight,
              cursorColor: "name".drawerAlertColor(),
              maxLength: context.inputNameMaxLength(),
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              autofocus: true,
              onChanged: (value) => onChangeName(value),
            ),
            actions: [
              TextButton(child: alertJudgeButtonText(context, "cancel", transpBlackColor),
                onPressed: () => context.popPage()
              ),
              TextButton(child: alertJudgeButtonText(context, "ok", purpleColor),
                onPressed: () => setName()
              ),
            ],
          ),
        );

    ///Set Money Unit Dialog
    unitDropDownList() async =>
        await showDialog(context: context,
          builder: (context) => AlertDialog(
            title: alertTitleText(context, context.drawerAlertTitle("unit")),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [DropdownButton(
                  style: selectUnitTextStyle(context),
                  value: unit.value,
                  itemHeight: max(kMinInteractiveDimension, drawerUnitItemHeight),
                  items: context.unitList().map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (value) => setUnit(value!),
                )],
              ),
            ),
          ),
        );

    ///Set Initial Assets Dialog
    setInitialAssetsDialog() async =>
        await showDialog(context: context,
          builder: (context) => AlertDialog(
            title: alertTitleText(context, context.drawerAlertTitle("initialAssets")),
            content: TextField(
              controller: TextEditingController(),
              style: textFieldTextStyle(context),
              decoration: drawerAlertDecoration(context, "initialAssets"),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: inputMoneyFormat,
              cursorWidth: alertCursorWidth,
              cursorHeight: alertCursorHeight,
              cursorColor: "initialAssets".drawerAlertColor(),
              maxLength: inputMoneyMaxLength,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              autofocus: true,
              onChanged: (value) => onChangeInitialAssets(value),
            ),
            actions: [
              TextButton(child: alertJudgeButtonText(context, "cancel", transpBlackColor),
                onPressed: () => context.popPage()
              ),
              TextButton(child: alertJudgeButtonText(context, "ok", pinkColor),
                onPressed: () => setInitialAssets()
              ),
            ],
          ),
        );

    ///Set Target Assets Dialog
    setTargetAssetsDialog() async =>
        await showDialog(context: context,
          builder: (context) => AlertDialog(
            title: alertTitleText(context, context.drawerAlertTitle("targetAssets")),
            content: TextField(
              controller: TextEditingController(),
              style: textFieldTextStyle(context),
              decoration: drawerAlertDecoration(context, "targetAssets"),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: inputMoneyFormat,
              cursorWidth: alertCursorWidth,
              cursorColor: "targetAssets".drawerAlertColor(),
              maxLength: inputMoneyMaxLength,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              autofocus: true,
              onChanged: (value) => onChangeTargetAssets(value),
            ),
            actions: [
              TextButton(child: alertJudgeButtonText(context, "cancel", transpBlackColor),
                onPressed: () => context.popPage()
              ),
              TextButton(child: alertJudgeButtonText(context, "ok", purpleColor),
                onPressed: () => setTargetAssets()
              ),
            ],
          ),
        );

    ///Set Initial Assets Dialog
    deleteAccountDialog() async =>
        await showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            title: alertTitleText(context, context.tryDeleteAccount()),
            content: Text(context.confirmDeleteAccount()),
            actions: [
              TextButton(child: alertJudgeButtonText(context, "cancel", purpleColor),
                  onPressed: () => context.popPage()
              ),
              TextButton(child: alertJudgeButtonText(context, "ok", transpBlackColor),
                  onPressed: () => initializeSharedPreferences().then((prefs) => deleteAccount(prefs)),
              ),
            ],
          ),
        );

    ///Spend and Allowance Input TextField Dialog
    allowanceInputDialog(bool isSpend) async =>
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: alertTitleText(context, context.speedDialTitle(isSpend)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  style: textFieldTextStyle(context),
                  controller: TextEditingController(),
                  decoration: spreadSheetAlertDecoration(context, "item", isSpend),
                  cursorWidth: alertCursorWidth,
                  cursorHeight: alertCursorHeight,
                  cursorColor: isSpend.speedDialColor(),
                  maxLength: context.inputItemMaxLength(),
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  autofocus: true,
                  onChanged: (value) => onChangeItem(value, isSpend),
                ),
                TextField(
                  style: textFieldTextStyle(context),
                  controller: TextEditingController(),
                  decoration: spreadSheetAlertDecoration(context, "amnt", isSpend),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: inputMoneyFormat,
                  cursorWidth: alertCursorWidth,
                  cursorHeight: alertCursorHeight,
                  cursorColor: isSpend.speedDialColor(),
                  maxLength: inputMoneyMaxLength,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  autofocus: false,
                  onChanged: (String value) => onChangeAmount(value, isSpend),
                ),
              ],
            ),
            actions: [
              TextButton(child: alertJudgeButtonText(context, "cancel", transpBlackColor),
                onPressed: () => context.popPage()
              ),
              TextButton(child: alertJudgeButtonText(context, "ok", isSpend.speedDialColor()),
                onPressed: () => setNewAllowance(isSpend)
              ),
            ],
          ),
        );

    ///Picked Day to Allowance Input Dialog
    pickedDayToAllowanceInput(DateTime? picked, bool isSpend) {
      if (picked != null) {
        "picked: ${picked.day}".debugPrint();
        isInput.value = picked.day.toString().setIsInput(true);
        inputDay.value = picked.day.toString().setInputDay(isInput.value);
        isDayInput.value = picked.day.toString().setIsDayInput(isInput.value);
        if (isDayInput.value) allowanceInputDialog(isSpend);
      }
    }

    ///connect to Firestore
    connectFirestore(SharedPreferences prefs, int i) {
      isLoading.value = true;
      isAllowData.value[i] = true;
      "isAllowSaveLocalDataKey".setSharedPrefBool(prefs, isAllowData.value[i]);
      (i == 0) ? setAllDataFirestore(prefs): getAllDataFirestore(prefs);
      context.popPage();
    }

    ///Spend and Allowance Select Date Dialog
    allowanceSelectDateDialog(bool isSpend) async {
      DateTime? picked = await showDatePicker(
        context: context,
        builder: (context, child) => Theme(
          data: selectDateTheme(context, isSpend),
          child: child!
        ),
        initialDate: startDate.value.toThisDate(index.value),
        firstDate: startDate.value.toThisMonthFirstDay(index.value),
        lastDate: startDate.value.toThisMonthLastDay(index.value),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        locale: context.selectDayLocale(),
        helpText: context.settingDateHint(),
      );
      pickedDayToAllowanceInput(picked, isSpend);
    }

    ///Select Date Dialog
    selectDateDialog(double amount, int id) async {
      DateTime? picked = await showDatePicker(
        context: context,
        builder: (context, child) => Theme(
          data: selectDateTheme(context, amount < 0),
          child: child!
        ),
        initialDate: startDate.value.toThisDate(index.value),
        firstDate: startDate.value.toThisMonthFirstDay(index.value),
        lastDate: startDate.value.toThisMonthLastDay(index.value),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        locale: context.selectDayLocale(),
        helpText: context.modifyDateTitle(),
      );
      selectDate(picked, id);
    }

    ///Item Input TextField Dialog
    itemFieldDialog(double amount, int id) async =>
        await showDialog(context: context,
          builder: (context) => AlertDialog(
            title: alertTitleText(context, context.spreadSheetAlertTitleText("item")),
            content: TextField(
              style: textFieldTextStyle(context),
              controller: TextEditingController(),
              decoration: spreadSheetAlertDecoration(context, "item", amount < 0),
              cursorWidth: alertCursorWidth,
              cursorHeight: alertCursorHeight,
              cursorColor: amount.amountColor(),
              maxLength: context.inputItemMaxLength(),
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              autofocus: true,
              onChanged: (value) => onChangeItem(value, true),
            ),
            actions: [
              TextButton(child: alertJudgeButtonText(context, "cancel", transpBlackColor),
                onPressed: () => context.popPage()
              ),
              TextButton(child: alertJudgeButtonText(context, "ok", (amount < 0).speedDialColor()),
                onPressed: () => rewriteAllowanceItem(id)
              ),
            ],
          ),
        );

    ///Amount Input TextField Dialog
    amntFieldDialog(double amount, int id) async =>
        await showDialog(context: context,
          builder: (context) => AlertDialog(
            title: alertTitleText(context, context.spreadSheetAlertTitleText("amnt")),
            content: TextField(
              style: textFieldTextStyle(context),
              controller: TextEditingController(),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: inputMoneyFormat,
              decoration: spreadSheetAlertDecoration(context, "amnt", amount < 0),
              cursorWidth: alertCursorWidth,
              cursorHeight: alertCursorHeight,
              cursorColor: amount.amountColor(),
              maxLength: inputMoneyMaxLength,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              autofocus: true,
              onChanged: (value) => onChangeAmount(value, amount < 0),
            ),
            actions: [
              TextButton(child: alertJudgeButtonText(context, "cancel", transpBlackColor),
                onPressed: () => context.popPage()
              ),
              TextButton(child: alertJudgeButtonText(context, "ok", (amount < 0).speedDialColor()),
                onPressed: () => rewriteAllowanceAmnt(id)
              ),
            ],
          ),
        );

    ///DeleteButton
    deleteButtonPopUp(double amount, int id) =>
        Container(
          width: context.deleteButtonWidth(),
          alignment: Alignment.centerLeft,
          child: PopupMenuButton(
            onSelected: (_) => deleteAllowance(id),
            icon: Icon(moreIcon, color: amount.amountColor()),
            iconSize: context.spreadSheetFontSize(),
            initialValue: "",
            itemBuilder: (BuildContext context) => [
              deleteButtonImage(context, amount, id, listNumber.value[index.value])
            ],
          ),
        );

    ///SpeedDialChild
    spreadSheetSpeedDialChild(bool isSpend) =>
        SpeedDialChild(
          foregroundColor: whiteColor,
          backgroundColor: isSpend.speedDialColor(),
          label: context.speedDialTitle(isSpend),
          labelBackgroundColor: isSpend.speedDialColor(),
          labelStyle: speedDialTextStyle(context),
          child: Icon(isSpend.speedDialIcon(),
            size: context.speedDialChildIconSize(),
            shadows: [customShadow(false, shadowOffset)],
          ),
          onTap: () => allowanceSelectDateDialog(isSpend),
        );

    ///UseEffect for Initialize
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        isLoading.value = true;
        initPlugin(context);
        await initializeSharedPreferences().then((prefs) => getInitializeData(prefs));
        FlutterNativeSplash.remove();
      });
      return null;
    }, []);

    ///Main
    return Stack(children: [
      Scaffold(
        backgroundColor: transpColor,
        ///AppBar
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight),
          child: AppBar(
            leading: (!isSummary.value) ? null: IconButton(
              icon: Icon(backIcon, color: whiteColor, size: appBarIconSize),
              onPressed: () => isSummary.value = false,
            ),
            title: appBarTitle(context, isSummary.value),
            backgroundColor: purpleColor,
            bottom: appBarBottomLine(),
            actions: [
              (isSummary.value) ? IconButton(icon: Icon(moreIcon, color: transpColor),
                onPressed: () {},
              ): PopupMenuButton(
                onSelected: (_) async => (isLogin.value) ? initializeSharedPreferences().then((prefs) => logout(prefs)): context.pushPage("/l"),
                icon: Icon(moreIcon, color: whiteColor),
                initialValue: context.popupMenuText(isLogin.value),
                itemBuilder: (context) => [context.popupMenuText(isLogin.value)].map(
                  (value) => appBarPopupMenu(context, value)
                ).toList(),
              ),
            ],
          ),
        ),
        ///Drawer
        drawer: (isSummary.value) ? null: SafeArea(
          child: ClipRRect(borderRadius: context.drawerBorderRadius(),
            child: Container(
              width: context.drawerWidth(),
              child: Drawer(
                child: ListView(children: [
                  drawerHeader(context, name.value),
                  SizedBox(height: context.drawerMenuListMarginTop()),
                  GestureDetector(child: menuNameListTile(context, name.value),
                    onTap: () => nameFieldDialog(),
                  ),
                  GestureDetector(child: menuUnitListTile(context, unit.value),
                    onTap: () => unitDropDownList(),
                  ),
                  GestureDetector(child: menuAssetsListTile(context, initialAssets.value, unit.value, true),
                    onTap: () => setInitialAssetsDialog(),
                  ),
                  // GestureDetector(child: menuAssetsListTile(context, targetAssets.value, unit.value, false),
                  //   onTap: () => setTargetAssetsDialog(),
                  // ),
                  menuStartDateListTile(context, startDate.value),
                  if (!isAllowData.value[0]) GestureDetector(child: menuLoginTile(context, isLogin.value, true),
                    onTap: () => (isLogin.value) ? initializeSharedPreferences().then((prefs) => connectFirestore(prefs, 0)): context.pushPage("/l"),
                  ),
                  if (!isAllowData.value[1] && isLogin.value) GestureDetector(child: menuLoginTile(context, isLogin.value, false),
                    onTap: () => (isLogin.value) ? initializeSharedPreferences().then((prefs) => connectFirestore(prefs, 1)): context.pushPage("/l"),
                  ),
                  //StartDate
                  if (isLogin.value) GestureDetector(child: menuDeleteAccountListTile(context, context.deleteAccount()),
                    onTap: () => deleteAccountDialog(),
                  ),
                ]),
              ),
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.only(top: context.mainBodyMarginTop()),
          decoration: backgroundDecoration(),
          child: isSummary.value ? MyHomeChart(): Column(children: [
            ///PlusMinus
            Stack(children: [
              Container(
                margin: EdgeInsets.only(top: context.plusMinusMarginTop()),
                child: Row(children: [
                  Spacer(flex: 1),
                  GestureDetector(
                    child: plusMinusImage(context, false, startDate.value.monthPlusMinusColor(false, index.value)),
                    onTap: () => changeIndex(false),
                  ),
                  SizedBox(width: context.plusMinusSpace()),
                  GestureDetector(
                    child: plusMinusImage(context, true, startDate.value.monthPlusMinusColor(true, index.value)),
                    onTap: () => changeIndex(true),
                  ),
                  Spacer(flex: 1),
                ]),
              ),
              Center(child: monthYearText(context, startDate.value.stringThisMonthYear(index.value)))
            ]),
            ///Balance & Percent
            Container(
              child: FittedBox(
                child: Column(children: [
                  balanceView(context, balance.value[index.value], unit.value),
                  percentView(context, percent.value[index.value])
                ]),
              ),
            ),
            ///
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.scrollViewMarginHorizontal(),
                  vertical: context.scrollViewMarginVertical(),
                ),
                child: SingleChildScrollView(
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: purpleColor),
                    child: Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(context.spreadSheetCornerRadius()),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            ///ListData
                            child: DataTable(
                              headingRowHeight: context.spreadSheetRowHeight(),
                              dataRowMaxHeight: context.spreadSheetRowHeight(),
                              dataRowMinHeight: context.spreadSheetRowHeight(),
                              showCheckboxColumn: true,
                              columnSpacing: context.spreadSheetColumnSpacing(),
                              dividerThickness: spreadSheetDividerWidth,
                              decoration: BoxDecoration(color: whiteColor),
                              headingRowColor: MaterialStateColor.resolveWith((states) => purpleColor),
                              columns: dataColumnTitles(context),
                              rows: List.generate(listNumber.value[index.value], (i) {
                                int day = allowanceDate.value[index.value][i];
                                String item = allowanceItem.value[index.value][i];
                                double amount = allowanceAmnt.value[index.value][i];
                                return DataRow(cells: [
                                  DataCell(GestureDetector(
                                    child: spreadSheetText(context, amount, startDate.value.stringThisMonthDay(index.value, day)),
                                    onTap: () => (amount != 0.0) ? selectDateDialog(amount, i): null,
                                  )),
                                  DataCell(VerticalDivider(color: purpleColor, thickness: spreadSheetDividerWidth)),
                                  DataCell(GestureDetector(
                                    child: spreadSheetText(context, amount, amount.stringItem(context, item)),
                                    onTap: () => (amount != 0.0) ? itemFieldDialog(amount, i): null,
                                  )),
                                  DataCell(VerticalDivider(color: purpleColor, thickness: spreadSheetDividerWidth)),
                                  DataCell(GestureDetector(
                                    child: spreadSheetAmountText(context, amount, amount.stringAmount(unit.value), unit.value),
                                    onTap: () => amntFieldDialog(amount, i)//(amount != 0.0) ? amntFieldDialog(amount, i): null,
                                  )),
                                  DataCell(VerticalDivider(color: purpleColor, thickness: spreadSheetDividerWidth)),
                                  DataCell((amount != 0.0) ? deleteButtonPopUp(amount, i): Text("")),
                                ]);
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AdBannerWidget(),
          ]),
        ),
        floatingActionButton: (isSummary.value) ? null: Container(
          margin: EdgeInsets.only(bottom: context.floatingActionBottomMargin()),
          child: Row(children: [
            SizedBox(width: floatingActionButtonLeftMargin),
            // Change to List or Change to Summary
            if (maxIndex.value > 0 && (assets.value.reduce(max) > 0 || spends.value.reduce(max) > 0))
              GestureDetector(child: summaryButtonImage(context), onTap: () => changeSummary()),
            Spacer(),
            // Input Speed Dial
            Container(
              decoration: actionButtonBoxDecoration(purpleColor),
              child: SpeedDial(
                icon: openIcon,
                activeIcon: closeIcon,
                iconTheme: IconThemeData(size: context.speedDialIconSize()),
                direction: SpeedDialDirection.up,
                buttonSize: circleSize(context.floatingActionButtonSize()),
                childrenButtonSize: circleSize(context.speedDialChildButtonSize()),
                spaceBetweenChildren: context.speedDialSpaceHeight(),
                foregroundColor: whiteColor,
                backgroundColor: purpleColor,
                curve: Curves.bounceIn,
                spacing: context.speedDialSpacing(),
                children: [
                  spreadSheetSpeedDialChild(true),  //Spend
                  spreadSheetSpeedDialChild(false), //Allowance
                ],
              ),
            ),
          ]),
        ),
      ),
      if (isLoading.value) myCircularProgressIndicator(context),
    ]);
  }
}