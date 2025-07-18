import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_my_app/utils/formatter/formatter.dart';

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
  String role;
  String status;

  UserModel(
       this.id, this.firstName, this.lastName, this.userName, this.email,
      this.phoneNumber, this.profilePicture,{
        this.points = 100,this.fcmToken ="", this.gender = "Male", DateTime? dateOfBirth,
        this.role = "customer",
        this.status = "Active"
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
      'firstName':firstName,
      'lastName':lastName,
      'userName':userName,
      'email':email,
      'phoneNumber':phoneNumber,
      'profilePicture':profilePicture,
      'points': points,
      'fcmToken': fcmToken,
      'gender':gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'role':role,
      'status':status
    };
  }

  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String,dynamic>> document){
    if(document.data()!=null){
      final data = document.data()!;
      return UserModel(document.id,
          data['firstName'] ?? " ",
          data['lastName'] ?? " ",
          data['userName']?? " ",
          data['email']?? " ",
          data['phoneNumber']?? " ",
          data['profilePicture']?? " ",
          points: data['points'] ?? 100,
          fcmToken: data['fcmToken'] ?? "",
          gender: data['gender']?? "Male",
          role: data['role']?? "customer",
          status: data['status']?? "Active",
          dateOfBirth: data['dateOfBirth']!= null? (data['dateOfBirth'] as Timestamp).toDate(): DateTime(2003, 8, 20)
      );
    }else{
      return UserModel.empty();
    }
  }
}
