
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t_store/data/repositories/authentication/authentication_repository.dart';
import 'package:t_store/features/authentication/models/user_model.dart';

import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class UserRepository extends GetxController{
  static UserRepository get instance =>Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  //Function to save user data to Firestore
Future<void> saveUserRecord(UserModel user) async{
  try{
    await  _db.collection('User').doc(user.id).set(user.toJSon());
  }on FirebaseException catch (e) {
    throw TFirebaseException(e.code).message;
  } on FormatException catch (_) {
    throw const TFormatException();
  } on PlatformException catch (e) {
    throw TPlatformException(e.code).message;
  } catch (e) {
    throw 'Something went wrong. Please try again';
  }
}

//fetch user detail
  Future<UserModel> fetchUserDetails() async{
    try{
     final documentSnapshot = await _db.collection("User").doc(AuthenticationRepository.instance.authUser?.uid).get();
     if(documentSnapshot.exists){
       return UserModel.fromSnapshot(documentSnapshot);
     }else{
       return UserModel.empty();
     }
    }on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Lỗi: ${e.toString()} ';
    }
  }
  //update user
  Future<void> updateUserDetails( UserModel updatedUser) async{
    try{
       await _db.collection("User").doc(updatedUser.id).update(updatedUser.toJSon());
    }on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
  //update any field
  Future<void> updateSingleField( Map<String,dynamic> json) async{
    try{
      await _db.collection("User").doc(AuthenticationRepository.instance.authUser?.uid).update(json);
    }on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
  //remove user
  Future<void> removeUserRecord( String userId) async{
    try{
      await _db.collection("User").doc(userId).delete();
    }on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  //upload image
Future<String> uploadImage(String path,XFile image) async{
  try{
    final ref = FirebaseStorage.instance.ref(path).child(image.name);
    await ref.putFile(File(image.path));
    final url = await ref.getDownloadURL();
    return url;
  }on FirebaseException catch (e) {
    throw TFirebaseException(e.code).message;
  } on FormatException catch (_) {
    throw const TFormatException();
  } on PlatformException catch (e) {
    throw TPlatformException(e.code).message;
  }
  catch(e){
    throw 'Something went wrong. Please try again';
  }
}

  Future<void> updatePointsUsers() async {
    try {
      final querySnapshot = await _db.collection('User').get();
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (!data.containsKey('Points')) {
          await doc.reference.update({'Points': 100000});
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating points: $e');
      }
    }
  }

  Future<void> updateUserPoints(String userId, num newPoints) async {
    try {
      final userDoc =  await _db.collection("User").doc(userId).get();
      if(userDoc.exists){
        num existingPoints = userDoc.data()?['Points'] ?? 0;
        num updatedPoints = existingPoints+newPoints;
        await _db.collection("User").doc(userId).update({"Points": updatedPoints});
      }else{
        throw "User not found!";
      }
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<void> updateUserPointsAndFcmToken(String userId) async {
    try {
      if (kDebugMode) {
        print("Userid: $userId");
      }
      DocumentReference userRef = _db.collection('User').doc(userId);

      // Lấy thông tin user từ Firestore
      DocumentSnapshot userDoc = await userRef.get();
      if (!userDoc.exists) {
        if (kDebugMode) {
          print("User không tồn tại");
        }
        return;
      }

      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

      // Lấy FCM Token
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        if (kDebugMode) {
          print("Không thể lấy FCM Token");
        }
        return;
      }

      // Cập nhật Points (nếu chưa có) và FCM Token
      await userRef.update({
        if (!data.containsKey('FcmToken'))
        'FcmToken': fcmToken, // 🔥 Cập nhật FCM Token
      });

      if (kDebugMode) {
        print("Cập nhật thành công FCM Token cho userId: $userId");
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi khi cập nhật FCM Token: $e');
      }
    }
  }

}