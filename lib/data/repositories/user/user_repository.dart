import 'dart:io';
import 'package:app_my_app/features/personalization/controllers/user_controller.dart';
import 'package:app_my_app/utils/popups/loader.dart';
import 'package:app_my_app/utils/singleton/user_singleton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_my_app/data/repositories/authentication/authentication_repository.dart';
import 'package:app_my_app/features/authentication/models/user_model.dart';
import '../../../features/sale_group/model/friend_model.dart';
import '../../../features/sale_group/model/friend_request_model.dart';
import '../../../features/sale_group/model/group_request_model.dart';
import '../../../utils/enum/enum.dart';
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

Future<List<UserModel>> getAllUsers() async{
  try{
    final snapshot = await  _db.collection('User').get();
    return snapshot.docs.map((doc)=>UserModel.fromSnapshot(doc)).toList();
  }on FirebaseException catch (e) {
    throw TFirebaseException(e.code).message;
  } on FormatException catch (_) {
    throw const TFormatException();
  } on PlatformException catch (e) {
    throw TPlatformException(e.code).message;
  } catch (e) {
    throw 'Error in getAllUsers() in UserRepository';
  }
}

  Future<UserModel> getUserById(String userId) async{
    try{
      final snapshot = await  _db.collection('User').doc(userId).get();
      return UserModel.fromSnapshot(snapshot);
    }on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Error in getUserById() in UserRepository';
    }
  }

Future<void> saveFriendInvitation(UserModel friend) async{
  try{
    final Map<String, dynamic> friendRequestData = {
      'fromUserId': AuthenticationRepository.instance.authUser!.uid,
      'toUserId': friend.id,
      'message': "Bạn có mời kết bạn từ ${UserController.instance.user.value.fullname}",
      'status': 'pending', // trạng thái pending
      'sentAt': FieldValue.serverTimestamp(),
      'respondedAt': null,
    };

    // 2. Lưu lời mời vào subcollection "friendRequests" của người được mời
    await FirebaseFirestore.instance
        .collection('User')
        .doc(friend.id)
        .collection('friendRequests')
        .add(friendRequestData);
  }catch(e){
    print("Error in saveFriendInvitation in UserRepository: $e");
  }
}

  Future<void> saveGroupInvitation(UserModel friend,String groupId) async{
    try{
      final Map<String, dynamic> groupRequestData = {
        'fromUserId': AuthenticationRepository.instance.authUser!.uid,
        'toUserId': friend.id,
        'groupId': groupId,
        'message': "Bạn có lời mời vào nhóm từ ${UserController.instance.user.value.fullname}",
        'status': 'pending', // trạng thái pending
        'sentAt': FieldValue.serverTimestamp(),
        'respondedAt': null,
      };
      // 2. Lưu lời mời vào subcollection "groupRequests" của người được mời
      await FirebaseFirestore.instance
          .collection('User')
          .doc(friend.id)
          .collection('groupRequests')
          .add(groupRequestData);
    }catch(e){
      print("Error in saveGroupInvitation in UserRepository: $e");
    }
  }

  Future<List<FriendRequestModel>> fetchFriendRequests() async {
    try {
      final snapshot = await _db
          .collection('User')  // Kiểm tra collection name: 'User' hoặc 'Users'
          .doc(AuthenticationRepository.instance.authUser!.uid)
          .collection('friendRequests')
          .where('status', isEqualTo: "pending")
          .orderBy('sentAt', descending: true)
          .get();

      print("Snapshot size: ${snapshot.docs.length}"); // Debug: in số lượng document được trả về

      return snapshot.docs
          .map((doc) {
        print("Doc id: ${doc.id} - Data: ${doc.data()}"); // Debug: in dữ liệu của từng document
        return FriendRequestModel.fromMap(doc);
      })
          .toList();
    } on FirebaseException catch (e) {
      print("FirebaseException in fetchFriendRequests: ${e.code} ${e.message}");
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      print("FormatException in fetchFriendRequests");
      throw const TFormatException();
    } on PlatformException catch (e) {
      print("PlatformException in fetchFriendRequests: ${e.code} ${e.message}");
      throw TPlatformException(e.code).message;
    } catch (e) {
      print("Unknown error in fetchFriendRequests(): $e");
      throw 'Error in fetchFriendRequests() in UserRepository';
    }
  }

  Future<List<GroupRequestModel>> fetchGroupRequests() async {
    try {
      final snapshot = await _db
          .collection('User')  // Kiểm tra collection name: 'User' hoặc 'Users'
          .doc(AuthenticationRepository.instance.authUser!.uid)
          .collection('groupRequests')
          .where('status', isEqualTo: "pending")
          .orderBy('sentAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) {
        print("Doc id: ${doc.id} - Data: ${doc.data()}"); // Debug: in dữ liệu của từng document
        return GroupRequestModel.fromMap(doc);
      })
          .toList();
    } on FirebaseException catch (e) {
      print("FirebaseException in fetchGroupRequests: ${e.code} ${e.message}");
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      print("FormatException in fetchGroupRequests");
      throw const TFormatException();
    } on PlatformException catch (e) {
      print("PlatformException in fetchGroupRequests: ${e.code} ${e.message}");
      throw TPlatformException(e.code).message;
    } catch (e) {
      print("Unknown error in fetchGroupRequests(): $e");
      throw 'Error in fetchGroupRequests() in UserRepository';
    }
  }

  Future<List<FriendModel>> getAllFriends() async {
    try {
      final snapshot = await _db
          .collection('User')
          .doc(AuthenticationRepository.instance.authUser!.uid)
          .collection('friends')
          .get();
      print('Current user id: ${AuthenticationRepository.instance.authUser!.uid}');
      final List<FriendModel> friends = snapshot.docs
          .map((doc) => FriendModel.fromMap(doc))
          .toList();

      // Sắp xếp giảm dần theo acceptedAt
      friends.sort((a, b) => b.acceptedAt.compareTo(a.acceptedAt));
      friends.map((f)=> print('Thong tin friend: ${f.toMap()}'));
      return friends;
    } catch (e) {
      throw 'Lỗi khi lấy danh sách bạn bè: $e';
    }
  }

  Future<void> updateFriendRequestStatus(
     String requestId,
     String newStatus, // 'accepted' hoặc 'rejected'
  ) async {
    try {
      final now = DateTime.now();
      // Lấy thông tin request hiện tại
      final requestRef = _db
          .collection('User')
          .doc(UserSession.instance.userId)
          .collection('friendRequests')
          .doc(requestId);
      final requestSnap = await requestRef.get();
      if (!requestSnap.exists) return;

      final data = requestSnap.data()!;
      final String fromUserId = data['fromUserId'];
      // Cập nhật trạng thái
      await requestRef.update({
        'status': newStatus,
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // Nếu là accepted, thêm vào bảng friends
      if (newStatus == 'accepted') {
        final friendQuery = await _db
            .collection('User')
            .doc(UserSession.instance.userId!)
            .collection('friends')
            .where('friendId', isEqualTo: fromUserId)
            .get();

        if (friendQuery.docs.isEmpty){
          final fromUser = await getUserById(fromUserId);
          // nguoi nhan
          final currentUserFriendRef = _db
              .collection('User')
              .doc(UserSession.instance.userId!)
              .collection('friends')
              .doc();

          final fromUserFriendRef = _db
              .collection('User')
              .doc(fromUserId)
              .collection('friends')
              .doc();

          final friendModel1 = FriendModel(
            id: currentUserFriendRef.id,
            friendId: fromUserId,
            friendName: fromUser.fullname,
            acceptedAt: now,
            createdAt: now,
            updatedAt: now,
            status: FriendStatus.active,
          );

          final friendModel2 = FriendModel(
            id: fromUserFriendRef.id,
            friendId: UserSession.instance.userId!,
            friendName: UserSession.instance.userName!,
            acceptedAt: now,
            createdAt: now,
            updatedAt: now,
            status: FriendStatus.active,
          );

          await Future.wait([
            currentUserFriendRef.set(friendModel1.toMap()),
            fromUserFriendRef.set(friendModel2.toMap()),
          ]);
        }else{
          TLoader.warningSnackbar(title: 'Bạn đã là bạn bè với người này rồi.');
        }
      }
    } catch (e) {
      print("Error updating friend request status: $e");
    }
  }

  Future<GroupRequestResult> updateGroupRequestStatus(
      String requestId,
      String newStatus,)  // 'accepted' hoặc 'rejected'
      async {
    try {
      // Lấy thông tin request hiện tại
      final currentUserId = UserSession.instance.userId;
      final requestRef = _db
          .collection('User')
          .doc(currentUserId)
          .collection('groupRequests')
          .doc(requestId);
      final requestSnap = await requestRef.get();
      if (!requestSnap.exists) return GroupRequestResult.error;
      final data = requestSnap.data()!;
      final String groupId   =  data['groupId'];
      // Cập nhật trạng thái
      await requestRef.update({
        'status': newStatus,
        'respondedAt': FieldValue.serverTimestamp(),
      });
      // Nếu là accepted, thêm thành viên mới vào nhóm trong bảng sale_group
      if (newStatus == 'accepted') {
        final groupRef = _db.collection('sale_groups').doc(groupId);
        final groupSnap = await groupRef.get();
        if(groupSnap.exists){
          final groupData = groupSnap.data()!;
          final participants = List<String>.from(groupData['participants']?? []);
          if(participants.contains(currentUserId)){
            return GroupRequestResult.alreadyMember;
          }
          // Lấy currentParticipants và targetParticipants
          int currentParticipants = groupData['currentParticipants'] is int
              ? groupData['currentParticipants'] as int
              : 0;
          final int targetParticipants = groupData['targetParticipants'] is int
              ? groupData['targetParticipants'] as int
              : 0;

          // Tăng currentParticipants thêm 1
          final int updatedParticipantsCount = currentParticipants + 1;
          // Nếu số thành viên đạt targetParticipants và thời hạn của group chưa hết
          bool markCompleted = false;
          if (updatedParticipantsCount >= targetParticipants) {
            markCompleted = true;
          }
          // Chuẩn bị dữ liệu cập nhật:
          Map<String, dynamic> updateData = {
            'participants': FieldValue.arrayUnion([currentUserId]),
            'currentParticipants': updatedParticipantsCount,
          };
          if (markCompleted) {
            updateData['status'] = 'completed';
          }
          await groupRef.update(updateData);
          return markCompleted ? GroupRequestResult.completed : GroupRequestResult.accepted;
        }
      }
      return GroupRequestResult.rejected;
    } catch (e) {
      print("Error updating friend request status: $e");
      return GroupRequestResult.error;
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

  Future<void> updateUserPoints(String userId, num bonusPoints) async {
    try {
      final userDoc =  await _db.collection("User").doc(userId).get();
      if(userDoc.exists){
        num existingPoints = userDoc.data()?['Points'] ?? 0;
        num updatedPoints = existingPoints+bonusPoints;
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
      // Kiểm tra nếu đã có FcmToken và giá trị không rỗng thì không làm gì cả
      if (data.containsKey('FcmToken') && data['FcmToken'] != null && data['FcmToken'].toString().isNotEmpty) {
        if (kDebugMode) {
          print("FCM Token đã tồn tại, không cần cập nhật");
        }
        return;
      }
      // Lấy FCM Token
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        if (kDebugMode) {
          print("Không thể lấy FCM Token");
        }
        return;
      }
      // Cập nhật FCM Token
      await userRef.update({
        'FcmToken': fcmToken,
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
