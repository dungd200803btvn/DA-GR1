import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lcd_ecommerce_app/utils/formatter/formatter.dart';

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
  String gender;
  late DateTime dateOfBirth;

  UserModel(
       this.id, this.firstName, this.lastName, this.userName, this.email,
      this.phoneNumber, this.profilePicture,{
        this.points = 100,this.fcmToken ="", this.gender = "Male", DateTime? dateOfBirth,
      }){
    this.dateOfBirth = dateOfBirth ?? DateTime(2003, 8, 20);
  }
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
      'Gender':gender,
      'DateOfBirth': Timestamp.fromDate(dateOfBirth),
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
          fcmToken: data['FcmToken'] ?? "",
          gender: data['Gender']?? "Male",
          dateOfBirth: data['DateOfBirth']!= null? (data['DateOfBirth'] as Timestamp).toDate(): DateTime(2003, 8, 20)
      );
    }else{
      return UserModel.empty();
    }
  }

}
