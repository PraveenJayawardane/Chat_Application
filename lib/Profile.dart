import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_information/device_information.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp_auth/alert.dart';
import 'package:otp_auth/message/message_screen.dart';
import 'package:otp_auth/uplodePhoto.dart';

class Profile extends StatefulWidget {
  String phone;
  Profile(this.phone);

  @override
  State<Profile> createState() => _ProfileState(phone);
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameControler = TextEditingController();
  bool picCircular = false;
  String? path;
  String phone;
  _ProfileState(this.phone);
  late String _imeiNo;

  Future getImei() async {
    late String imeiNo = '';

    try {
      imeiNo = await DeviceInformation.deviceIMEINumber;
    } on PlatformException catch (e) {
      print(e.message);
    }

    if (!mounted) return;

    setState(() {
      _imeiNo = imeiNo;
    });
  }

  Future addUser() async {
    DateTime date = DateTime.now();
    print(widget.phone);
    var data = {
      'id': widget.phone,
      'name': _nameControler.text,
      'number': widget.phone,
      'created': date
    };
    var reference =
        FirebaseFirestore.instance.collection("users").doc(widget.phone);
    reference.set(data).then((value) => print("Add Success"));
    var imeiData = {
      'imei': int.parse(_imeiNo),
      'id': widget.phone,
      'name': _nameControler.text
    };
    await FirebaseFirestore.instance
        .collection("imei")
        .add(imeiData)
        .then((value) => print("imei Saved"));
  }

  @override
  void initState() {
    getImei();
    super.initState();
  }

  @override
  void dispose() {
    _nameControler.dispose();
  }

  @override
  Widget build(BuildContext context) {
    uploadPhoto upload = uploadPhoto();
    alert alrt = alert();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.green[400],
      body: SingleChildScrollView(
        reverse: true,
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: CircleAvatar(
                    backgroundColor: Colors.black12,
                    radius: 70,
                    child: CircleAvatar(
                      child: picCircular ? CircularProgressIndicator() : null,
                      backgroundColor: const Color.fromARGB(31, 51, 50, 50),
                      backgroundImage:
                          path != null ? FileImage(File(path!)) : null,
                      radius: 60,
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      setState(() {
                        picCircular = true;
                      });
                      var res = await FilePicker.platform.pickFiles(
                        allowMultiple: false,
                        type: FileType.custom,
                        allowedExtensions: ["png", "jpg"],
                      );
                      if (res != null) {
                        setState(() {
                          path = res.paths.first!;
                        });

                        var pat = res.files.first.path!;
                        //var nam = res.files.first.name;

                        upload.Upload(pat, phone).then((value) {
                          setState(() {
                            picCircular = false;
                          });
                          print("Upload Done");
                        });
                      }
                    },
                    icon: const Icon(Icons.add_a_photo_outlined)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _nameControler,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '                                               Plese enter your name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.black),
                          prefixIconColor: Colors.black,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(20)),
                          hintText: "Enter Name",
                          hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 29, 28, 28)),
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(20))),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 20),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      fixedSize:
                          MaterialStateProperty.all<Size>(Size.fromWidth(150)),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.green),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: const BorderSide(
                            color: Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    child: Text('Save'),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await addUser();
                      }
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => message_screen(
                              widget.phone, _nameControler.text)));
                    },
                  ),
                ),
                // FutureBuilder(
                //     future: upload.downlordUrl(phone),
                //     builder: ((context, snapshot) {
                //       if (snapshot.hasData) {
                //         return CircleAvatar(
                //           backgroundImage:
                //               NetworkImage(snapshot.data!.toString()),
                //           radius: 100,
                //         );
                //       }
                //       return CircularProgressIndicator();
                //     }))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
