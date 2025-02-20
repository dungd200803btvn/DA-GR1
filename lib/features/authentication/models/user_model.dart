import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t_store/utils/formatter/formatter.dart';

class UserModel {
  final String id;
  String firstName;
  String lastName;
  final String userName;
  final String email;
  String phoneNumber;
  String profilePicture;
  int points;
  String fcmToken;

  UserModel(
       this.id, this.firstName, this.lastName, this.userName, this.email,
      this.phoneNumber, this.profilePicture,{
        this.points = 100,this.fcmToken =""
      });
  String get fullname => '$firstName $lastName';
  String get formattedPhoneNo => DFormatter.formatPhoneNumber(phoneNumber);
  static List<String> nameParts(fullname) => fullname.split(" ");
  static String generateUsername(fullname){
    List<String> namePart = nameParts(fullname);
    String firstName = namePart[0].toLowerCase();
    String lastName  = namePart.length>1 ? namePart[1].toLowerCase():"";
    String camelCaseUserName = "$firstName$lastName";
    String userNameWithPrefix = "cwt_$camelCaseUserName";
    return userNameWithPrefix;
  }
  static UserModel empty() => UserModel("", "", "", "", "", "", "");
  Map<String,dynamic> toJSon(){
    return {
      'FirstName':firstName,
      'LastName':lastName,
      'UserName':userName,
      'Email':email,
      'PhoneNumber':phoneNumber,
      'ProfilePicture':profilePicture,
      'Points': points,
      'FcmToken': fcmToken,
    };
  }

  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String,dynamic>> document){
    if(document.data()!=null){
      final data = document.data()!;
      return UserModel(document.id,
          data['FirstName'] ?? " ",
          data['LastName'] ?? " ",
          data['UserName']?? " ",
          data['Email']?? " ",
          data['PhoneNumber']?? " ",
          data['ProfilePicture']?? " ",
          points: data['Points'] ?? 100,
          fcmToken: data['FcmToken'] ?? ""
      );
    }else{
      return UserModel.empty();
    }
  }

}
