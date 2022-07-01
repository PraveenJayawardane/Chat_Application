import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class uploadPhoto {
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> Upload(String path, String phone) async {
    File file = File(path);
    String name = "profilePic";
    try {
      await storage.ref("profilePhotos/$phone/$name").putFile(file);
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<String> downlordUrl(String number) async {
    print(number);
    String url =
        await storage.ref("profilePhotos/$number/profilePic").getDownloadURL();
    return url;
  }
}
