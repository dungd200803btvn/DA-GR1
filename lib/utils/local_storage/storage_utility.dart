import 'package:get_storage/get_storage.dart';
class DLocalStorage{
 // static final DLocalStorage _instance  =DLocalStorage._internal();
  //late: Biến _storage sẽ được khởi tạo muộn, tức là sau khi đối tượng DLocalStorage được tạo ra, chứ không phải ngay lập tức khi đối tượng được khởi tạo.
  //final: ko thay doi dc gia tri
  late final GetStorage _storage ;
  //singleton instance
  static DLocalStorage? _instance;
  //Constructor riêng (private constructor) để tạo instance từ bên trong lớp, ngan chan viec tao tu ben ngoai
  DLocalStorage._internal();
  //tu khoa factory de chung ta tao ra constructor 1 cach tuy chinh theo code cua ban than, co the them ten phuong thuc constructor tuy chinh nay la instance

  factory DLocalStorage.instance() {
    _instance ??=  DLocalStorage._internal();
    return _instance!;
  }
  static Future<void> init(String bucketName) async{
    await GetStorage.init(bucketName);
    _instance = DLocalStorage._internal();
    _instance!._storage = GetStorage(bucketName);
  }
  Future<void> saveData<T>(String key, T value) async{
    await _storage.write(key,value);
  }
  T? readData<T>(String key){
    return _storage.read<T>(key);
  }
  Future<void> removeData<T>(String key) async{
    await _storage.remove(key);
  }
  Future<void> clearAll()  async{
    await _storage.erase();
  }

}