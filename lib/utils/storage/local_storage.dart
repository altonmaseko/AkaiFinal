import 'package:get_storage/get_storage.dart';

class TLocalStorage {
  static final TLocalStorage _instance = TLocalStorage._internal();

  factory TLocalStorage() {
    return _instance;
  }

  TLocalStorage._internal();

  final _storage = GetStorage();

  //save
  Future<void> saveData<T>(String key, T value) async {
    await _storage.write(key, value);
  }

  //read
  T? readData<T>(String key) {
    return _storage.read<T>(key);
  }

  //remove
  Future<void> removeData<T>(String key) async {
    await _storage.remove(key);
  }

  //clear all
  Future<void> clearAll<T>(String key) async {
    await _storage.erase();
  }


}
