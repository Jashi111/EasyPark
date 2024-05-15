import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

//Sign-in function

// signInWithGoogle() async {
//
//   GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//
//   GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
//
//   AuthCredential credential = GoogleAuthProvider.credential(
//     accessToken: googleAuth?.accessToken,
//     idToken: googleAuth?.idToken
//   );
//
//   UserCredential user = await FirebaseAuth.instance.signInWithCredential(credential);
//   print(user.user?.displayName);
// }
class AuthController {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        final UserCredential authResult =
            await _firebaseAuth.signInWithCredential(credential);

        final User? user = authResult.user;

        if (user != null) {
          // Successful sign-in
          print("Signed in with Google: ${user.displayName}");
        } else {
          // Handle case where user is null after sign-in
          // You may want to throw an exception or handle this differently based on your needs.
          print("Sign-in failed, user is null.");
        }
      }
    } catch (e) {
      // You can throw an exception or handle this error based on your needs.
      print("An error occurred during sign-in: $e");
    }
  }
}
