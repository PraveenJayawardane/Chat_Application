import 'package:flutter/cupertino.dart';

class StateManagement with ChangeNotifier {
  late String _imeiNo;
  late String _id;
  late String _name;
  late bool _conResult = false;
  late bool _conResultMain = false;
  late AppLifecycleState _appLifecycleState;
  late String _picUrl;

  String get imeiNo => _imeiNo;
  String get id => _id;
  String get name => _name;
  bool get conResult => _conResult;
  bool get conResultMain => _conResultMain;
  String get picUrl => _picUrl;

  AppLifecycleState get appLifecycleState => _appLifecycleState;

  void getImei(String imei) {
    _imeiNo = imei;
    notifyListeners();
  }

  void getIdAndName(String id, String name) {
    _id = id;
    _name = name;
    notifyListeners();
  }

  void connectionResult(bool state) {
    _conResult = state;
    notifyListeners();
  }

  void connectionResultMain(bool state) {
    _conResultMain = state;
    notifyListeners();
  }

  void onlineState(AppLifecycleState appLifecycleState) {
    _appLifecycleState = appLifecycleState;
    notifyListeners();
  }

  void getPicUrl(String url) {
    _picUrl = url;
    notifyListeners();
  }
}
