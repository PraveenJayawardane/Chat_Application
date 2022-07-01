import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otp_auth/message/message_screen.dart';

class log_screen extends StatefulWidget {
  const log_screen({Key? key}) : super(key: key);

  @override
  _log_screenState createState() => _log_screenState();
}

class _log_screenState extends State<log_screen> {
  final TextEditingController _textEditingController = TextEditingController();
  late String name;

  _check() async {
    int id = int.parse(_textEditingController.text);
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    firebaseFirestore
        .collection("users")
        .where("id", isEqualTo: _textEditingController.text)
        .snapshots()
        .listen((event) async {
      if (event.docs.isNotEmpty) {
        event.docs.forEach((element) {
          name = element.data()["name"];
        });

        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    message_screen(_textEditingController.text, name)));
      } else {
        print("Invalid Id");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 100, 10, 20),
            child: TextFormField(
              controller: _textEditingController,
              decoration: InputDecoration(
                  icon: Icon(
                    Icons.email,
                    color: Colors.blue,
                  ),
                  labelText: 'Enter ID'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _check();
            },
            child: Text('Button'),
            style: ElevatedButton.styleFrom(shape: StadiumBorder()),
          ),
        ],
      ),
    );
  }
}

error_showAlertDialog(BuildContext context) {
  // set up the button
  Widget okButton = Center(
    child: ElevatedButton(
      style: ButtonStyle(
        fixedSize: MaterialStateProperty.all<Size>(Size.fromWidth(150)),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(
              color: Colors.grey,
              width: 2.0,
            ),
          ),
        ),
      ),
      child: Text('OK'),
      onPressed: () {
        Navigator.pop(context, 'OK');
      },
    ),
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    content: Text("Invalid code,please try again."),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
