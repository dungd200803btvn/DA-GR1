import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/utils/formatter/formatter.dart';

class AddressModel {
  String id;
  final String name;
  final String phoneNumber;
  final String street;
  final String city;
  final String district;
  final String commune;
  final String country;
  DateTime? dateTime;
  bool selectedAddress;

  AddressModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.street,
    required this.city,
    required this.district,
    required this.commune,
    required this.country,
    this.dateTime,
    this.selectedAddress = true,
  });

  String get formattedPhoneNo => DFormatter.formatPhoneNumber(phoneNumber);

  static AddressModel empty() => AddressModel(
    id: "",
    name: "",
    phoneNumber: "0335620803",
    street: "",
    city: "",
    district: "",
    commune: "",
    country: "",
  );

  Map<String, dynamic> toJson() {
    return {
      "Id": id,
      "Name": name,
      "PhoneNumber": phoneNumber,
      "Street": street,
      "City": city,
      "District":district,
      "Commune": commune,
      "Country": country,
      "DateTime": dateTime != null ? Timestamp.fromDate(dateTime!) : null,
      "SelectedAddress": selectedAddress,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> data) {
    return AddressModel(
      id: data['Id'] as String,
      name: data['Name'] as String,
      phoneNumber: data['PhoneNumber'] as String,
      street: data['Street'] as String,
      city: data['City'] as String,
      district: data['District'] as String,
      commune: data['Commune'] as String,
      country: data['Country'] as String,
      selectedAddress: data['SelectedAddress'] as bool,
      dateTime: data['DateTime'] != null ? (data['DateTime'] as Timestamp).toDate() : null,
    );
  }

  factory AddressModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return AddressModel(
      id: snapshot.id,
      name: data['Name'] ?? "",
      phoneNumber: data['PhoneNumber'] ?? "",
      street: data['Street'] ?? "",
      city: data['City'] ?? "",
      district: data['District'] ?? "",
      commune: data['Commune']  ?? "",
      country: data['Country'] ?? "",
      selectedAddress: data['SelectedAddress'] as bool,
      dateTime: data['DateTime'] != null ? (data['DateTime'] as Timestamp).toDate() : null,
    );
  }

  @override
  String toString() {
    return "$street, $commune, $district, $city, $country";
  }
}
