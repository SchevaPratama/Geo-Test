import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator_app/model/user.dart';

class DatabaseService {
  CollectionReference _userReference =
      FirebaseFirestore.instance.collection('users');

  Future<void> setUser(UserModel user) async {
    try {
      _userReference.doc(user.id).set({
        'email': user.email,
        'name': user.name,
        'role': user.role,
      });
    } catch (e) {
      throw (e);
    }
  }

  Future<UserModel> getUserById(String id) async {
    try {
      DocumentSnapshot snapshot = await _userReference.doc(id).get();
      return UserModel(
          id: id,
          email: snapshot['email'],
          name: snapshot['name'],
          role: snapshot['role']);
    } catch (e) {
      throw e;
    }
  }

  Future<void> addLocation(locationMap) async {
    try {
      FirebaseFirestore.instance
          .collection('location')
          .doc('F7zwyLYBwWs0qZSfjPWY')
          .update(locationMap);
    } catch (e) {
      throw e;
    }
  }

  Future<void> addAbsen(absenMap) async {
    try {
      FirebaseFirestore.instance.collection('absen').doc(absenMap['userUID']+absenMap['username']).set(absenMap);
    } catch (e) {
      throw (e);
    }
  }
}
