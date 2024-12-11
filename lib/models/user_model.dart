import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String kakaoId;
  final String name;
  final String email;
  final String gender;
  final int age;
  final bool isSubscribe;
  final DateTime isSubscribeDate;
  final DateTime createdAt;

  UserModel({
    required this.kakaoId,
    required this.name,
    required this.email,
    required this.gender,
    required this.age,
    required this.isSubscribe,
    required this.isSubscribeDate, // 기본값 null 허용
    required this.createdAt,
  });

  // Firestore 데이터로부터 모델 생성
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      kakaoId: data['kakaoId'],
      name: data['name'],
      email: data['email'],
      gender: data['gender'],
      age: data['age'],
      isSubscribe: data['isSubscribe'],
      isSubscribeDate: (data['isSubscribeDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Firestore에 저장할 데이터로 변환
  Map<String, dynamic> toMap() {
    return {
      'kakaoId': kakaoId,
      'name': name,
      'email': email,
      'gender': gender,
      'age': age,
      'isSubscribe': isSubscribe,
      'isSubscribeDate': isSubscribeDate,
      'createdAt': createdAt,
    };
  }
}
