import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constant.dart';
import 'extension.dart';
import 'common_widget.dart';

/// Whether App Check cleared. activate() only registers the provider; nothing
/// asks for a token until a guarded call is made, so this does it up front
final appCheckReady = ValueNotifier<bool>(false);

/// Fetches a token and records the outcome. Called at launch and again before
/// sign-in, so a session that started offline can still recover
// A failed attestation can still hand back a non-empty placeholder, which the
// backend later rejects. Only a real three part JWT counts as ready
bool _isValidAppCheckJwt(String? token) {
  if (token == null || token.isEmpty) return false;
  final parts = token.split('.');
  return parts.length == 3 && parts.every((part) => part.isNotEmpty);
}

Future<bool> refreshAppCheckReady() async {
  // Once it has cleared it stays cleared; getToken would only return the cache
  if (appCheckReady.value) return true;

  // Staged, not the same call repeated: a stale cache is fixed by forcing a
  // refresh, and a provider that never initialised is fixed by activating it
  // again. Repeating one call just repeats one failure
  var token = await _appCheckToken(forceRefresh: false);
  if (!_isValidAppCheckJwt(token)) {
    token = await _appCheckToken(forceRefresh: true);
  }
  if (!_isValidAppCheckJwt(token) && (Platform.isIOS || Platform.isMacOS)) {
    try {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: androidAppCheckProvider,
        providerApple: appleAppCheckProvider,
      );
      await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
      token = await _appCheckToken(forceRefresh: true);
    } catch (e) {
      'App Check re-activate failed: $e'.debugPrint();
    }
  }

  appCheckReady.value = _isValidAppCheckJwt(token);
  'appCheckReady: ${appCheckReady.value}'.debugPrint();
  return appCheckReady.value;
}

Future<String?> _appCheckToken({required bool forceRefresh}) async {
  try {
    return await FirebaseAppCheck.instance
        .getToken(forceRefresh)
        .timeout(const Duration(seconds: 10));
  } catch (e) {
    'App Check getToken failed (forceRefresh=$forceRefresh): $e'.debugPrint();
    return null;
  }
}

/// Firestore Manager - Handles Firebase Firestore operations for data synchronization
/// Manages local and cloud data storage with automatic sync capabilities
/// Provides methods for saving and retrieving user allowance data
class FirestoreManager {

  final BuildContext context;
  final bool isLogin;
  const FirestoreManager(this.context, {
    required this.isLogin,
  });

  /// Set Data to Firestore - Saves data to Firebase Firestore database
  /// Parameters:
  /// - isFirstSaveFinish: Indicates if this is the first save operation
  /// - key: Data key for storage
  /// - setValue: Value to be stored
  /// - currentDateTime: Current timestamp for sync tracking
  /// 
  /// This method handles the core Firestore write operation with error handling
  Future<void> setDataFireStore(bool isFirstSaveFinish, String key, dynamic setValue, int currentDateTime) async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now().toDateTimeInt();
    // Only save to Firestore if user is logged in and first save is complete
    if (isLogin && isFirstSaveFinish) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
        // Save the data with merge option to preserve existing data
        await docRef.set({key: setValue}, SetOptions(merge: true));
        await docRef.set({"serverSaveDateTimeKey": currentDateTime}, SetOptions(merge: true));
        "serverSaveDateTimeKey".setSharedPrefInt(prefs, currentTime);
      } on FirebaseException catch (e) {
        '${e.code}: $e'.debugPrint();
        if (context.mounted) CommonWidget(context).showFailedSnackBar(context.storeDataFailed(), null);
      }
    }
  }

  /// Set String to Firestore - Saves string data to both local storage and Firestore
  /// Parameters:
  /// - isFirstSaveFinish: Indicates if this is the first save operation
  /// - key: Data key for storage
  /// - setValue: String value to be stored
  /// 
  /// Saves data locally first, then syncs to Firestore if user is logged in
  Future<void> setStringFirestore(bool isFirstSaveFinish, String key, String setValue) async {
    final prefs = await SharedPreferences.getInstance();
    final currentDateTime = DateTime.now().toDateTimeInt();
    // Save to local storage first
    key.setSharedPrefString(prefs, setValue);
    "localSaveDateTimeKey".setSharedPrefInt(prefs, currentDateTime);
    // Sync to Firestore if context is still mounted
    if (context.mounted) await setDataFireStore(isFirstSaveFinish, key, setValue, currentDateTime);
  }

  /// Set Double to Firestore - Saves double data to both local storage and Firestore
  /// Parameters:
  /// - isFirstSaveFinish: Indicates if this is the first save operation
  /// - key: Data key for storage
  /// - setValue: Double value to be stored
  /// 
  /// Saves numeric data locally first, then syncs to Firestore if user is logged in
  Future<void> setDoubleFirestore(bool isFirstSaveFinish, String key, double setValue) async {
    final prefs = await SharedPreferences.getInstance();
    final currentDateTime = DateTime.now().toDateTimeInt();
    // Save to local storage first
    key.setSharedPrefDouble(prefs, setValue);
    "localSaveDateTimeKey".setSharedPrefInt(prefs, currentDateTime);
    // Sync to Firestore if context is still mounted
    if (context.mounted) await setDataFireStore(isFirstSaveFinish, key, setValue, currentDateTime);
  }

  /// Set Allowance Data to Firestore - Saves complete allowance tracking data
  /// Parameters:
  /// - isAllowData: Indicates if allowance data should be saved
  /// - allowanceDate: 2D array of allowance dates
  /// - allowanceItem: 2D array of allowance item names
  /// - allowanceAmnt: 2D array of allowance amounts
  /// 
  /// Saves allowance tracking data (dates, items, amounts) to both local storage and Firestore
  /// Handles JSON encoding for complex data structures
  Future<void> setAllowanceDataFirestore(bool isAllowData, List<List<int>> allowanceDate, List<List<String>> allowanceItem, List<List<double>> allowanceAmnt) async {
    final prefs = await SharedPreferences.getInstance();
    final currentDateTime = DateTime.now().toDateTimeInt();
    // Save allowance data to local storage with JSON encoding
    "dateKey".setSharedPrefString(prefs, jsonEncode(allowanceDate));
    "itemKey".setSharedPrefString(prefs, jsonEncode(allowanceItem));
    "amntKey".setSharedPrefString(prefs, jsonEncode(allowanceAmnt));
    "localSaveDateTimeKey".setSharedPrefInt(prefs, currentDateTime);
    // Save to Firestore if user is logged in and allowance data flag is true
    if (isLogin && isAllowData) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        "user: $user".debugPrint();
        DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
        // Save each allowance data component separately with merge option
        await docRef.set({"dateKey": jsonEncode(allowanceDate)}, SetOptions(merge: true));
        await docRef.set({"itemKey": jsonEncode(allowanceItem)}, SetOptions(merge: true));
        await docRef.set({"amntKey": jsonEncode(allowanceAmnt)}, SetOptions(merge: true));
        await docRef.set({"serverSaveDateTimeKey": currentDateTime}, SetOptions(merge: true));
        "serverSaveDateTimeKey".setSharedPrefInt(prefs, currentDateTime);
      } on FirebaseException catch (e) {
        '${e.code}: $e'.debugPrint();
        if (context.mounted) CommonWidget(context).showFailedSnackBar(context.storeDataFailed(), null);
      }
    }
  }

  /// Get Server Save DateTime - Retrieves the last server save timestamp
  /// Returns the timestamp of the last successful save to Firestore
  /// Used for data synchronization and conflict resolution
  /// 
  /// Returns current timestamp if no server data exists or error occurs
  Future<int> getServerSaveDateTime() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        DocumentSnapshot snapshot = await docRef.get();
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        // Return server save timestamp if it exists
        if (data!["serverSaveDateTimeKey"] != null) {
          "serverSaveDateTime: ${data["serverSaveDateTimeKey"]}".debugPrint();
          return data["serverSaveDateTimeKey"];
        } else {
          "serverSaveDateTime: current time".debugPrint();
          return DateTime.now().toDateTimeInt();
        }
      } else {
        // Return current time if no user is logged in
        "serverSaveDateTime: current time".debugPrint();
        return DateTime.now().toDateTimeInt();
      }
    } catch (e) {
      // Return current time on any error
      "Error: $e' -> serverSaveDateTime: current time}".debugPrint();
      return DateTime.now().toDateTimeInt();
    }
  }
}

