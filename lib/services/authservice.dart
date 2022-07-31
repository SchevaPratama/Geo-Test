import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:geolocator_app/model/user.dart';
import 'package:geolocator_app/services/databaseservices.dart';

class AuthService {
  final FirebaseAuth.FirebaseAuth _auth = FirebaseAuth.FirebaseAuth.instance;

  Future SignInWithEmailAndPassword(String email, String password) async {
    try {
      FirebaseAuth.UserCredential result =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel user = await DatabaseService().getUserById(result.user!.uid);
      return user;
    } catch (e) {
      print(e.toString());
      return e;
    }
  }

  Future SignUpWithEmailAndPassword(
      String email, String password, String name, String role) async {
    try {
      FirebaseAuth.UserCredential result =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel user = UserModel(
        id: result.user!.uid,
        email: email,
        name: name,
        role: role,
      );

      await DatabaseService().setUser(user);
      return user;
    } on FirebaseAuth.FirebaseAuthException catch (e) {
      // print(e.message);
      // print(e.code);
      return e;
    }
  }

  Future SignOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
