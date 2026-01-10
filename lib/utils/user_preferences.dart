import 'dart:convert';

import 'package:nurebo/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static SharedPreferences? _preferences;

  // static const _keyUsers = 'users';
  static const _keyUser = 'user';
  static const _keyIsLogged = 'isLogged';
  static const _keyJWT = 'JWT';
  static const _updateNotification = 'updateNotification';
  static const _lastOpenNotification = 'lastOpenNotification';
  static const _lastClosedNotification = 'lastClosedNotification';
  static const _keyEnableNotifications = 'enableNotifications';
  static const _keyBackgroundNotifications = 'backgroundNotifications';
  static const _keyVibrateNotifications = 'vibrateNotifications';
  static const _keySilentNotifications = 'silentNotifications';
  static const _keyFollowExperienceNotifications = 'followExperienceNotifications';
  static const _keyNewFollowNotifications = 'newFollowNotifications';
  static const _keyFollowBookingNotifications = 'followBookingNotifications';
  static const _keyFollowPostNotifications = 'followPostNotifications';
  static const _keySessionId = 'sessionId';
  static const _keyDeviceId = 'deviceId';


  static Future init() async {
    _preferences = await SharedPreferences.getInstance();

    if(getUserToken() == null){
      await setUserToken('');
    }
    if(getSessionId() == null){
      await setSessionId('');
    }
    if(getDeviceId() == null){
      await setDeviceId('');
    }
    if(getIsLogged() == null){
      await setIsLogged(false);
    }
    if(getUserId() == null){
      await setUserId('');
    }
    if(getEnableNotifications() == null){
      await setEnableNotifications(true);
      // await setEnableNotifications(false);
    }
    if(getBackgroundNotifications() == null){
      // await setBackgroundNotifications(false);
      await setBackgroundNotifications(true);
    }
    if(getSilentNotifications() == null){
      await setSilentNotifications(false);
    }
    if(getVibrateNotifications() == null){
      await setVibrateNotifications(true);
    }
    if(getUserLastOpenNotification() == null){
      await _preferences!.setString(
          _lastOpenNotification,
          DateTime.now().subtract(const Duration(days: 99999)).toIso8601String()
      );
    }
    if(getUserLastClosedNotification() == null){
      await _preferences!.setString(
          _lastClosedNotification,
          DateTime.now().subtract(const Duration(days: 99998)).toIso8601String()
      );
    }

    // return _preferences = await SharedPreferences.getInstance();
    return _preferences;
  }

  static Future setUserId(String userId) async {
    await _preferences!.setString(_keyUser, userId);
  }

  static String? getUserId(/*String userId*/) {
    // return _preferences.getString(userId);
    return _preferences!/*?*/.getString(_keyUser);
  }

  static Future setUserToken(String token) async {
    await _preferences!.setString(_keyJWT, token);
  }

  static String? getUserToken() {
    return _preferences!/*?*/.getString(_keyJWT);
  }

  static Future setSessionId(String sessionId) async {
    await _preferences!.setString(_keySessionId, sessionId);
  }

  static String? getSessionId() {
    return _preferences!/*?*/.getString(_keySessionId);
  }

  static Future setDeviceId(String deviceId) async {
    await _preferences!.setString(_keyDeviceId, deviceId);
  }

  static String? getDeviceId() {
    return _preferences!/*?*/.getString(_keyDeviceId);
  }

  // static Future setUserLastUpbookingNotification() async {
  //   await _preferences/*!*/.setString(
  //     _upbookingNotification,
  //     DateTime.now().toIso8601String()
  //   );
  // }

  static Future setUserLastUpdateNotification(DateTime dateTime) async {
    await _preferences!.setString(
      _updateNotification,
      dateTime.toIso8601String()
    );
  }

  static String? getUserLastUpdateNotification() {
    return _preferences!/*?*/.getString(_updateNotification);
  }

  static Future setUserLastOpenNotification() async {
    await _preferences!.setString(
        _lastOpenNotification,
        DateTime.now().toIso8601String()
    );
  }

  static String? getUserLastOpenNotification() {
    return _preferences!/*?*/.getString(_lastOpenNotification);
  }

  static Future setUserLastClosedNotification() async {
    await _preferences!.setString(
      _lastClosedNotification,
      DateTime.now().toIso8601String()
    );
  }

  static String? getUserLastClosedNotification() {
    return _preferences!/*?*/.getString(_lastClosedNotification);
  }

  static Future setIsLogged(bool isLogged) async {
    await _preferences!.setBool(_keyIsLogged, isLogged);
  }

  static bool? getIsLogged(/*String isLogged*/) {
    // return _preferences.getBool(isLogged);
    return _preferences!/*?*/.getBool(_keyIsLogged);
  }

  static Future setEnableNotifications(bool enable) async {
    await _preferences!.setBool(_keyEnableNotifications, enable);
  }

  static bool? getEnableNotifications() {
    return _preferences!/*?*/.getBool(_keyEnableNotifications);
  }

  static Future setBackgroundNotifications(bool enable) async {
    await _preferences!.setBool(_keyBackgroundNotifications, enable);
  }

  static bool? getBackgroundNotifications() /*async*/ {
    // if(_preferences.getBool(_keyBackgroundNotifications) == null){
    //   await setBackgroundNotifications(true);
    // }
    return _preferences!/*?*/.getBool(_keyBackgroundNotifications);
  }

  static Future setVibrateNotifications(bool enable) async {
    await _preferences!.setBool(_keyVibrateNotifications, enable);
  }

  static bool? getVibrateNotifications() {
    return _preferences!/*?*/.getBool(_keyVibrateNotifications);
  }

  static Future setSilentNotifications(bool enable) async {
    await _preferences!.setBool(_keySilentNotifications, enable);
  }

  static bool? getSilentNotifications() {
    return _preferences!/*?*/.getBool(_keySilentNotifications);
  }

  static Future setFollowExperienceNotifications(bool enable) async {
    await _preferences!.setBool(_keyFollowExperienceNotifications, enable);
  }

  static bool? getFollowExperienceNotifications() {
    return _preferences!/*?*/.getBool(_keyFollowExperienceNotifications);
  }

  static Future setNewFollowNotifications(bool enable) async {
    await _preferences!.setBool(_keyNewFollowNotifications, enable);
  }

  static bool? getNewFollowNotifications() {
    return _preferences!/*?*/.getBool(_keyNewFollowNotifications);
  }

  static Future setFollowBookingNotifications(bool enable) async {
    await _preferences!.setBool(_keyFollowBookingNotifications, enable);
  }

  static bool? getFollowBookingNotifications() {
    return _preferences!/*?*/.getBool(_keyFollowBookingNotifications);
  }

  static Future setFollowPostNotifications(bool enable) async {
    await _preferences!.setBool(_keyFollowPostNotifications, enable);
  }

  static bool? getFollowPostNotifications() {
    return _preferences!/*?*/.getBool(_keyFollowPostNotifications);
  }
}
