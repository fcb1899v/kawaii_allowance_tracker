import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_manager.dart';
import 'firebase_manager.dart';
import 'common_widget.dart';
import 'login_page.dart';
import 'admob_banner.dart';
import 'extension.dart';
import 'chart_page.dart';
import 'home_widget.dart';
import 'constant.dart';
import 'main.dart';

/// Main homepage widget for the allowance tracker application
/// This widget manages the entire allowance tracking functionality including
/// data storage, user authentication, and UI interactions
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    /// State management variables for application state
    /// Controls login status, loading states, and data permissions
    final login = ref.read(loginProvider.notifier);
    final isLogin = ref.watch(loginProvider).isLogin;
    final isSummary = useState(false);
    final isLoading = useState(false);
    final isAllowData = useState([false, false]);

    /// Allowance data storage variables
    /// Stores all allowance-related data including dates, items, amounts, and calculations
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

    /// Personal user data variables
    /// Stores user-specific information like name, currency unit, and initial assets
    final name = useState("");
    final unit = useState("\$");
    final initialAssets = useState(0.0);
    final currentDate = DateTime.now().toDateString();
    final currentDateTime = DateTime.now().toDateTimeInt();
    final startDate = useState(currentDate);
    final localSaveDateTime = useState(0);
    final serverSaveDateTime = useState(0);

    /// Input data variables for user interactions
    /// Manages temporary input states for adding/editing allowance entries
    final isInput = useState(false);
    final inputName = useState("");
    final inputInitial = useState(0.0);
    final isInitialInput = useState(false);
    final inputDay = useState(0);
    final inputItem = useState("");
    final inputAmount = useState(0.0);
    final isDayInput = useState(false);
    final isItemInput = useState(false);
    final isAmountInput = useState(false);

    /// Widget instances for UI components
    /// Provides access to common UI widgets and home-specific widgets
    final commonWidget = CommonWidget(context);
    final homeWidget = HomeWidget(context, isLogin: isLogin);

    /// Manager instances for data operations
    /// Handles Firestore operations and data management
    final authManager = AuthManager(context);
    final firestoreManager = FirestoreManager(context, isLogin: isLogin);

    /// Reset login state and clear local data permissions
    /// Called when user logs out or account is deleted
    resetLoginState(SharedPreferences prefs) {
      login.setCurrentLogin(authManager.isLoggedIn);
      "Login: $isLogin".debugPrint();
      isAllowData.value = [false, false];
      "isAllowSaveLocalDataKey".setSharedPrefBool(prefs, isAllowData.value[0]);
      "isAllowGetServerDataKey".setSharedPrefBool(prefs, isAllowData.value[1]);
    }

    /// Handle user logout process
    /// Signs out from Firebase and resets local state
    logout(SharedPreferences prefs) async {
      if (!isLoading.value) {
        isLoading.value = true;
        try {
          await authManager.signOut();
          resetLoginState(prefs);
          if (context.mounted) commonWidget.showSuccessSnackBar(context.logoutSuccess());
        } on FirebaseAuthException catch (_) {
          if (context.mounted) commonWidget.showSuccessSnackBar(context.logoutFailed());
        } finally {
          isLoading.value = false;
        }
      }
    }

    /// Handle account deletion process
    /// Deletes user account from Firebase and clears local data
    deleteAccount(SharedPreferences prefs) async {
      if (!isLoading.value) {
        isLoading.value = true;
        try {
          authManager.deleteAccount();
          resetLoginState(prefs);
          if (context.mounted) commonWidget.showSuccessSnackBar(context.deleteAccountSuccess());
        } catch (e) {
          if (context.mounted) commonWidget.showSuccessSnackBar(context.deleteAccountFailed());
        } finally {
          isLoading.value = false;
          if (context.mounted) context.popPage();
        }
      }
    }

    /// Set allowance data in local storage and update calculations
    /// Saves data to SharedPreferences and recalculates all derived values
    setAllowanceData(prefs) async {
      await firestoreManager.setAllowanceDataFirestore(isAllowData.value[0], allowanceDate.value, allowanceItem.value, allowanceAmnt.value);
      maxIndex.value = allowanceAmnt.value.calcMaxIndex();
      listNumber.value = allowanceAmnt.value.calcListNumber();
      percent.value = allowanceAmnt.value.calcPercent(maxIndex.value);
      balance.value = allowanceAmnt.value.calcBalance(maxIndex.value);
      spends.value = allowanceAmnt.value.calcSpends(maxIndex.value);
      assets.value = balance.value.calcAssets(maxIndex.value, initialAssets.value);
    }

    /// Set all allowance data in Firestore database
    /// Saves user data, allowance entries, and metadata to Firebase
    setAllDataFirestore(SharedPreferences prefs) async {
      if (isLogin && isAllowData.value[0]) {
        try {
          final User? user = authManager.currentUser;
          DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
          await docRef.set({"startDateKey": startDate.value}, SetOptions(merge: true));
          await docRef.set({"nameKey": name.value}, SetOptions(merge: true));
          await docRef.set({"unitKey": unit.value}, SetOptions(merge: true));
          await docRef.set({"initialAssetsKey": initialAssets.value}, SetOptions(merge: true));
          await docRef.set({"dateKey": jsonEncode(allowanceDate.value)}, SetOptions(merge: true));
          await docRef.set({"itemKey": jsonEncode(allowanceItem.value)}, SetOptions(merge: true));
          await docRef.set({"amntKey": jsonEncode(allowanceAmnt.value)}, SetOptions(merge: true));
          await docRef.set({"serverSaveDateTimeKey": currentDateTime}, SetOptions(merge: true));
          isAllowData.value = [true, true];
          "serverSaveDateTimeKey".setSharedPrefInt(prefs, currentDateTime);
          "isAllowGetServerDataKey".setSharedPrefBool(prefs, isAllowData.value[1]);
          if (context.mounted) commonWidget.showSuccessSnackBar(context.storeDataSuccess());
        } on FirebaseException catch (e) {
          '${e.code}: $e'.debugPrint();
          if (context.mounted) commonWidget.showFailedSnackBar(context.storeDataFailed(), null);
        } finally {
          isLoading.value = false;
        }
      }
    }

    /// Get all allowance data from Firestore database
    /// Retrieves user data and allowance entries from Firebase
    getAllDataFirestore(SharedPreferences prefs) async {
      if (isLogin && isAllowData.value[1]) {
        try {
          final User? user = authManager.currentUser;
          DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
          DocumentSnapshot snapshot = await docRef.get();
          Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
          if (data != null) {
            "data: $data".debugPrint();
            name.value = data.getFirestoreString(prefs, "nameKey", "");
            unit.value = (context.mounted) ? data.getFirestoreString(prefs, "unitKey", context.defaultUnit()): "\$";
            initialAssets.value = data.getFirestoreDouble(prefs, "initialAssetsKey", 0.0);
            startDate.value = data.getFirestoreString(prefs, "startDateKey", currentDate);
            allowanceDate.value = data.getFirestoreDate(prefs);
            allowanceItem.value = data.getFirestoreItem(prefs);
            allowanceAmnt.value = data.getFirestoreAmnt(prefs);
            maxIndex.value = allowanceAmnt.value.calcMaxIndex();
            index.value = startDate.value.currentIndex();
            listNumber.value = allowanceAmnt.value.calcListNumber();
            percent.value = allowanceAmnt.value.calcPercent(maxIndex.value);
            balance.value = allowanceAmnt.value.calcBalance(maxIndex.value);
            spends.value = allowanceAmnt.value.calcSpends(maxIndex.value);
            assets.value = balance.value.calcAssets(maxIndex.value, initialAssets.value);
            localSaveDateTime.value = currentDateTime;
            isAllowData.value = [true, true];
            "localSaveDateTimeKey".setSharedPrefInt(prefs, currentDateTime);
            "isAllowSaveLocalDataKey".setSharedPrefBool(prefs, isAllowData.value[0]);
            if (context.mounted) commonWidget.showSuccessSnackBar(context.getDataSuccess());
          } else {
            if (context.mounted) commonWidget.showFailedSnackBar(context.noDataAvailable(), null);
          }
        } on FirebaseException catch (e) {
          '${e.code}: $e'.debugPrint();
          if (context.mounted) commonWidget.showFailedSnackBar(context.getDataFailed(), null);
        } finally {
          isLoading.value = false;
        }
      }
    }

    /// Get all allowance data from local storage
    /// Retrieves data from SharedPreferences and updates all state variables
    getAllowanceData(prefs) async {
      name.value = "nameKey".getSharedPrefString(prefs, "");
      unit.value = (context.mounted) ? "unitKey".getSharedPrefString(prefs, context.defaultUnit()): "\$";
      initialAssets.value = "initialAssetsKey".getSharedPrefDouble(prefs, 0.0);
      startDate.value = "startDateKey".getSharedPrefString(prefs, currentDate);
      allowanceDate.value = "dateKey".getSharedPrefString(prefs, "[[0]]").toString().toListListDate();
      allowanceItem.value = "itemKey".getSharedPrefString(prefs, "[[""]]").toString().toListListItem();
      allowanceAmnt.value = "amntKey".getSharedPrefString(prefs, "[[0.0]]").toString().toListListAmnt();
      maxIndex.value = allowanceAmnt.value.calcMaxIndex();
      index.value = startDate.value.currentIndex();
      listNumber.value = allowanceAmnt.value.calcListNumber();
      percent.value = allowanceAmnt.value.calcPercent(maxIndex.value);
      balance.value = allowanceAmnt.value.calcBalance(maxIndex.value);
      spends.value = allowanceAmnt.value.calcSpends(maxIndex.value);
      assets.value = balance.value.calcAssets(maxIndex.value, initialAssets.value);
      "toSetFirestore: ${isAllowData.value[0] && !isAllowData.value[1]}".debugPrint();
      (isAllowData.value[0] && !isAllowData.value[1]) ? await setAllDataFirestore(prefs): {isLoading.value = false};
    }

    /// Get allowance data for application initialization
    /// Sets up initial state and loads data based on user preferences
    getInitializeData(SharedPreferences prefs) async {
      isLoading.value = true;
      try {
        if (!("isStartKey".getSharedPrefBool(prefs, false))) {
          await authManager.signOut();
          "startDateKey".setSharedPrefString(prefs, startDate.value);
          "isStartKey".setSharedPrefBool(prefs, true);
        }
        login.setCurrentLogin(authManager.isLoggedIn);
        "isLogin: $isLogin, user: ${isLogin ? authManager.currentUserId: "none"}".debugPrint();
        localSaveDateTime.value = "localSaveDateTimeKey".getSharedPrefInt(prefs, currentDateTime);
        serverSaveDateTime.value = "serverSaveDateTimeKey".getSharedPrefInt(prefs, currentDateTime);
        isAllowData.value[0] = "isAllowSaveLocalDataKey".getSharedPrefBool(prefs, false);
        isAllowData.value[1] = "isAllowGetServerDataKey".getSharedPrefBool(prefs, false);
        "toFirestore: ${!isAllowData.value[0] && isAllowData.value[1]}".debugPrint();
        (!isAllowData.value[0] && isAllowData.value[1]) ? getAllDataFirestore(prefs): getAllowanceData(prefs);
      } catch (e) {
        "Error: $e".debugPrint();
        if (context.mounted) commonWidget.showFailedSnackBar(context.getDataFailed(), null);
        isLoading.value = false;
      }
    }

    /// Sort allowance list by date
    /// Reorders allowance entries chronologically and adds empty entry at end
    sortAllowanceList() {
      final List<AllowanceList> sortList = allowanceAmnt.value[index.value].getAllowanceList(allowanceDate.value[index.value], allowanceItem.value[index.value]);
      sortList.sort((a,b) => a.date.compareTo(b.date));
      sortList.removeAt(0);
      sortList.add(AllowanceList(0, "", 0.0));
      allowanceDate.value[index.value] = sortList.getDateFromAllowanceList();
      allowanceItem.value[index.value] = sortList.getItemFromAllowanceList();
      allowanceAmnt.value[index.value] = sortList.getAmntFromAllowanceList();
    }

    /// Delete allowance entry by ID
    /// Removes specific allowance entry and updates data storage
    deleteAllowance(int id) async {
      final int i = index.value;
      allowanceDate.value[i].removeAt(id);
      allowanceItem.value[i].removeAt(id);
      allowanceAmnt.value[i].removeAt(id);
      sortAllowanceList();
      SharedPreferences.getInstance().then((prefs) async =>
        await setAllowanceData(prefs)
      );
    }

    /// Toggle between summary view and detailed list view
    /// Updates view state and recalculates data for summary display
    changeSummary() {
      isSummary.value = !isSummary.value;
      maxIndex.value = allowanceAmnt.value.calcMaxIndex();
      index.value = startDate.value.currentIndex();
      "isSummary: ${isSummary.value}".debugPrint();
    }

    /// Change month index (navigate between months)
    /// Handles month navigation and creates new month data if needed
    changeIndex(bool isPlus) async {
      if (!isPlus && (index.value > 0)) index.value--;
      //Change Max Index
      if (isPlus && (index.value + 1 > maxIndex.value)) {
        allowanceDate.value.add([0]);
        allowanceItem.value.add([""]);
        allowanceAmnt.value.add([0.0]);
        await SharedPreferences.getInstance().then((prefs) async =>
          await setAllowanceData(prefs)
        );
      }
      if (isPlus) index.value++;
      "index: ${index.value}".debugPrint();
    }

    /// Handle user name input changes
    /// Updates temporary name input state
    onChangeName(String value) {
      "value: $value".debugPrint();
      if (value.isNotEmpty) inputName.value = value;
    }

    /// Set user name and save to storage
    /// Saves name to local storage and Firestore if enabled
    setName() async {
      if (inputName.value.isNotEmpty) {
        name.value = inputName.value;
        inputName.value = "";
        SharedPreferences.getInstance().then((prefs) async =>
          await firestoreManager.setStringFirestore(isAllowData.value[0], "nameKey", name.value),
        );
      }
      if (context.mounted) context.popPage();
    }

    /// Set currency unit and save to storage
    /// Updates unit and saves to local storage and Firestore
    setUnit(String value) async {
      "value: $value".debugPrint();
      if (value.isNotEmpty) {
        unit.value = value;
        SharedPreferences.getInstance().then((prefs) async =>
          await firestoreManager.setStringFirestore(isAllowData.value[0], "unitKey", unit.value),
        );
      }
      if (context.mounted) context.popPage();
    }

    /// Handle initial assets input changes
    /// Validates and processes initial assets input
    onChangeInitialAssets(String value) async {
      "value: $value".debugPrint();
      isInput.value = value.setIsInput(false);
      inputInitial.value = value.setInputAmount(isInput.value, false, unit.value);
      isInitialInput.value = value.setIsInitialAssetsInput(isInput.value);
    }

    /// Set initial assets and save to storage
    /// Saves initial assets and recalculates asset totals
    setInitialAssets() async {
      if (isInitialInput.value) {
        initialAssets.value = inputInitial.value;
        inputInitial.value = 0;
        SharedPreferences.getInstance().then((prefs) async {
          await firestoreManager.setDoubleFirestore(isAllowData.value[0], "initialAssetsKey", initialAssets.value);
          await setAllowanceData(prefs);
        });
      }
      if (context.mounted) context.popPage();
    }

    /// Select date for allowance entry
    /// Updates date for specific allowance entry and sorts list
    selectDate(DateTime? picked, int id) async {
      "picked: $picked.day".debugPrint();
      if (picked != null) {
        allowanceDate.value[index.value][id] = picked.day;
        sortAllowanceList();
        SharedPreferences.getInstance().then((prefs) async =>
          await setAllowanceData(prefs)
        );
      }
    }

    /// Handle item input changes
    /// Validates and processes item description input
    onChangeItem(String value, bool isSpend) async {
      "value: $value".debugPrint();
      isInput.value = value.isNotEmpty;
      inputItem.value = value.setInputItem(context, isInput.value, isSpend);
      isItemInput.value = value.setIsItemInput(isInput.value);
    }

    /// Rewrite allowance item description
    /// Updates item description for specific allowance entry
    rewriteAllowanceItem(int id) async {
      if (isItemInput.value) {
        allowanceItem.value[index.value][id] = inputItem.value;
        inputItem.value = "";
        SharedPreferences.getInstance().then((prefs) async =>
          await setAllowanceData(prefs)
        );
      }
      if (context.mounted) context.popPage();
    }

    /// Handle amount input changes
    /// Validates and processes amount input with spend/income logic
    onChangeAmount(String value, bool isSpend) async {
      "value: $value".debugPrint();
      isInput.value = value.setIsInput(false);
      inputAmount.value = value.setInputAmount(isInput.value, isSpend, unit.value);
      isAmountInput.value = value.setIsAmountInput(isInput.value);
    }

    /// Change allowance amount for specific entry
    /// Updates amount for specific allowance entry
    rewriteAllowanceAmnt(int id) async {
      if (isAmountInput.value) {
        allowanceAmnt.value[index.value][id] = inputAmount.value;
        inputAmount.value = 0.0;
        SharedPreferences.getInstance().then((prefs) async =>
          await setAllowanceData(prefs)
        );
      }
      if (context.mounted) context.popPage();
    }

    /// Set new allowance or spend entry
    /// Adds new allowance entry with day, item, and amount
    setNewAllowance(bool isSpend) async {
      if (isDayInput.value && isItemInput.value && isAmountInput.value) {
        allowanceDate.value[index.value].insert(0, inputDay.value);
        allowanceItem.value[index.value].insert(0, inputItem.value);
        allowanceAmnt.value[index.value].insert(0, inputAmount.value);
        sortAllowanceList();
        inputDay.value = 0;
        inputItem.value = "";
        inputAmount.value = 0.0;
        SharedPreferences.getInstance().then((prefs) async =>
          await setAllowanceData(prefs)
        );
      }
      if (context.mounted) context.popPage();
    }

    /// Handle day selection for allowance input dialog
    /// Processes selected day and opens input dialog for new allowance entry
    pickedDayToAllowanceInput(DateTime? picked, bool isSpend) async {
      if (picked != null) {
        "picked: ${picked.day}".debugPrint();
        isInput.value = picked.day.toString().setIsInput(true);
        inputDay.value = picked.day.toString().setInputDay(isInput.value);
        isDayInput.value = picked.day.toString().setIsDayInput(isInput.value, picked.year);
        if (isDayInput.value) {
          homeWidget.allowanceInputDialog(
            isSpend: isSpend,
            onChangedItem: (value, isSpend) => onChangeItem(value, isSpend),
            onChangedAmount: (value, isSpend) => onChangeAmount(value, isSpend),
            onConfirm: (isSpend) => setNewAllowance(isSpend),
          );
        }
      }
    }

    /// Connect to Firestore for data synchronization
    /// Enables Firestore integration for saving or retrieving data
    connectFirestore(SharedPreferences prefs, int i) async {
      isLoading.value = true;
      isAllowData.value[i] = true;
      "isAllowSaveLocalDataKey".setSharedPrefBool(prefs, isAllowData.value[i]);
      (i == 0) ? await setAllDataFirestore(prefs): await getAllDataFirestore(prefs);
      if (context.mounted) context.popPage();
    }

    /// UseEffect for application initialization
    /// Handles app startup, ATT plugin initialization, and data loading
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (Platform.isIOS || Platform.isMacOS) initATTPlugin(context);
        isLoading.value = true;
        SharedPreferences.getInstance().then((prefs) async =>
          await getInitializeData(prefs)
        );
        FlutterNativeSplash.remove();
      });
      return null;
    }, []);

    /// Main widget build method
    /// Returns the complete UI structure with all components
    return Stack(children: [
      Scaffold(
        backgroundColor: transpColor,
        /// AppBar with navigation and user actions
        appBar: homeWidget.homeAppBar(
          isLogin: isLogin,
          isSummary: isSummary.value,
          onTapBack: () => isSummary.value = false,
          onTapLogout: () => SharedPreferences.getInstance().then((prefs) => logout(prefs)),
        ),
        /// Drawer with user settings and data management options
        drawer: (isSummary.value) ? null: SafeArea(
          child: ClipRRect(borderRadius: context.drawerBorderRadius(),
            child: SizedBox(
              width: context.drawerWidth(),
              child: Drawer(
                child: ListView(children: [
                  homeWidget.drawerHeader(name.value),
                  SizedBox(height: context.drawerMenuListMarginTop()),
                  homeWidget.menuNameListTile(name.value,
                    onChanged: (value) => onChangeName(value),
                    onConfirm: () => setName(),
                  ),
                  homeWidget.menuUnitListTile(unit.value,
                    onChanged: (value) => (value != null) ? setUnit(value): null
                  ),
                  homeWidget.menuInitialAssetsTile(initialAssets.value,
                    unit: unit.value,
                    onChanged: (value) => onChangeInitialAssets(value),
                    onConfirm: () => setInitialAssets(),
                  ),
                  homeWidget.menuStartDateListTile(startDate.value),
                  if (!isAllowData.value[0]) homeWidget.menuLoginTile(isSaveData: true,
                    onTap: () => (isLogin) ? SharedPreferences.getInstance().then((prefs) => connectFirestore(prefs, 0)): context.pushPage("/l"),
                  ),
                  if (!isAllowData.value[1] && isLogin) homeWidget.menuLoginTile(isSaveData: false,
                    onTap: () => (isLogin) ? SharedPreferences.getInstance().then((prefs) => connectFirestore(prefs, 1)): context.pushPage("/l"),
                  ),
                  //StartDate
                  if (isLogin) homeWidget.menuDeleteAccountTile(context.deleteAccount(),
                    onTap: () =>  SharedPreferences.getInstance().then((prefs) => deleteAccount(prefs)),
                  ),
                ]),
              ),
            ),
          ),
        ),
        /// Main body content with allowance tracking interface
        body: Container(
          padding: EdgeInsets.only(top: context.mainBodyMarginTop()),
          decoration: commonWidget.backgroundDecoration(),
          child: isSummary.value ? ChartPage(): Column(children: [
            /// Month navigation controls with plus/minus buttons
            Stack(children: [
              Container(
                margin: EdgeInsets.only(top: context.plusMinusMarginTop()),
                child: Row(children: [
                  Spacer(flex: 1),
                  commonWidget.plusMinusButton(isPlus: false,
                    color: startDate.value.monthPlusMinusColor(false, index.value),
                    onTap: () => changeIndex(false),
                  ),
                  SizedBox(width: context.plusMinusSpace()),
                  commonWidget.plusMinusButton(isPlus: true,
                    color: startDate.value.monthPlusMinusColor(true, index.value),
                    onTap: () => changeIndex(true),
                  ),
                  Spacer(flex: 1),
                ]),
              ),
              Center(
                child: Text(startDate.value.stringThisMonthYear(index.value),
                  style: commonWidget.enAccentTextStyle(context.monthYearFontSize())
                ),
              ),
            ]),
            /// Balance and percentage display section
            FittedBox(
              child: Column(children: [
                homeWidget.balanceView(balance.value[index.value], unit.value),
                homeWidget.percentView(percent.value[index.value])
              ]),
            ),
            /// Spreadsheet-style allowance entry list
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.scrollViewMarginHorizontal(),
                  vertical: context.scrollViewMarginVertical(),
                ),
                child: SingleChildScrollView(
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: purpleColor),
                    child: SizedBox(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(context.spreadSheetCornerRadius()),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            /// Data table with allowance entries
                            child: DataTable(
                              headingRowHeight: context.spreadSheetRowHeight(),
                              dataRowMaxHeight: context.spreadSheetRowHeight(),
                              dataRowMinHeight: context.spreadSheetRowHeight(),
                              showCheckboxColumn: true,
                              columnSpacing: context.spreadSheetColumnSpacing(),
                              dividerThickness: spreadSheetDividerWidth,
                              decoration: BoxDecoration(color: whiteColor),
                              headingRowColor: WidgetStateColor.resolveWith((states) => purpleColor),
                              columns: homeWidget.dataColumnTitles(),
                              rows: List.generate(listNumber.value[index.value], (i) {
                                int date = allowanceDate.value[index.value][i];
                                String item = allowanceItem.value[index.value][i];
                                double amount = allowanceAmnt.value[index.value][i];
                                return DataRow(cells: [
                                  homeWidget.spreadSheetDateButton(date,
                                    amount: amount,
                                    id: i,
                                    startDate: startDate.value,
                                    index: index.value,
                                    onSelected: (picked, i) => selectDate(picked, i)
                                  ),
                                  homeWidget.dataCellDivider(),
                                  homeWidget.spreadSheetItemButton(item,
                                    amount: amount,
                                    onChanged: (value) => onChangeItem(value, true),
                                    onConfirm: () => rewriteAllowanceItem(i),
                                  ),
                                  homeWidget.dataCellDivider(),
                                  homeWidget.spreadSheetAmountButton(amount,
                                    unit: unit.value,
                                    onChanged: (value) => onChangeAmount(value, amount < 0),
                                    onConfirm: () => rewriteAllowanceAmnt(i),
                                  ),
                                  homeWidget.dataCellDivider(),
                                  homeWidget.spreadSheetDeleteButton(amount: amount,
                                    id: i,
                                    listNumber: listNumber.value[index.value],
                                    onSelected: (_) => deleteAllowance(i),
                                  ),
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
            /// Ad banner at bottom of screen
            AdBannerWidget(),
          ]),
        ),
        /// Floating action button for quick actions
        floatingActionButton: (isSummary.value) ? null: Container(
          margin: EdgeInsets.only(bottom: context.floatingActionBottomMargin()),
          child: Row(children: [
            // Change to List or Change to Summary
            if (maxIndex.value > 0 && (assets.value.reduce(max) > 0 || spends.value.reduce(max) > 0)) homeWidget.summaryButton(
              onTap: () => changeSummary()
            ),
            const Spacer(),
            // Input Speed Dial
            homeWidget.speedDialForInputs(
              startDate: startDate.value,
              index: index.value,
              onSelected: (picked, isSpend) => pickedDayToAllowanceInput(picked, isSpend),
            )
          ]),
        ),
      ),
      /// Loading indicator overlay
      if (isLoading.value) commonWidget.myCircularProgressIndicator(),
    ]);
  }
}