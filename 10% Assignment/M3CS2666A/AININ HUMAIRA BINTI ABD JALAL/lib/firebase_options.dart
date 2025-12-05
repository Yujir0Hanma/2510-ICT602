import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyB13jH_UwoFaQyDWCqbulqgo6vf3bpmND0',
      authDomain: 'ict602-assignment-app-5b17c.firebaseapp.com',
      projectId: 'ict602-assignment-app-5b17c',
      storageBucket: 'ict602-assignment-app-5b17c.firebasestorage.app',
      messagingSenderId: '46555048752',
      appId: '1:46555048752:web:5cc26cc1845fa8f448b6f5',
    );
  }
}
