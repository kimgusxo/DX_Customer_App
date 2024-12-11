import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 유저 데이터를 Firestore에서 가져오는 메서드
  Future<UserModel?> fetchUser(String kakaoId) async {
    try {
      final doc = await _firestore.collection('users').doc(kakaoId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!); // Firestore 데이터를 UserModel로 변환
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // 유저 데이터를 Firestore에 저장하는 메서드
  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.kakaoId).set(user.toMap());
    } catch (e) {
      print('Error saving user: $e');
    }
  }
}
