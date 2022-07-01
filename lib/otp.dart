import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otp_auth/Profile.dart';
import 'package:otp_auth/message/log_screen.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  OTPScreen(this.phone);
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late String _verificationCode;
  OtpFieldController otpController = OtpFieldController();
  late String pinNumber;
  bool linearStatusBar = true;

  fetch() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection("users").snapshots().listen((event) {
      event.docs.forEach((element) {
        print(element.data());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var _code;
    return Scaffold(
      backgroundColor: Colors.green[400],
      body: SafeArea(
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            children: [
              linearStatusBar ? LinearProgressIndicator() : Text(""),
              Container(
                margin: EdgeInsets.only(top: 40),
                child: const Center(
                  child: Text(
                    'Verification Code',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              const Text("Please Enter OTP sent on your Mobile Number "),
              Text("+94-${widget.phone}"),
              const SizedBox(
                height: 100,
              ),
              OTPTextField(
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  otpFieldStyle: OtpFieldStyle(
                      focusBorderColor: Colors.black,
                      borderColor: Colors.black,
                      disabledBorderColor: Colors.black,
                      enabledBorderColor: Colors.black),
                  controller: otpController,
                  length: 6,
                  width: MediaQuery.of(context).size.width,
                  textFieldAlignment: MainAxisAlignment.spaceEvenly,
                  fieldWidth: 20,
                  fieldStyle: FieldStyle.underline,
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                  onChanged: (pin) {
                    print("Changed: " + pin);
                  },
                  onCompleted: (pin) {
                    setState(() {
                      pinNumber = pin;
                    });
                    print("Completed: " + pin);
                  }),
              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
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
                child: const Text('Next'),
                onPressed: () async {
                  await _veryfyOtp(pinNumber);
                },
              ),
              ElevatedButton(
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
                child: const Text('Re-send OTP'),
                onPressed: () async {
                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (context) => OTPScreen(_controller.text)));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _genareteOtp() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '+94${widget.phone}',
          verificationCompleted: (PhoneAuthCredential credential) async {
            await FirebaseAuth.instance.signInWithCredential(credential);
            print("+94${widget.phone}");

            print("done");
          },
          verificationFailed: (FirebaseAuthException e) {
            print("code:" + e.code);
            if (e.code == 'invalid-phone-number') {
              error_showAlertDialog(context);
            }
            print(e.message);
            print("faild");
          },
          codeSent: (String verficationID, int? resendToken) {
            setState(() {
              _verificationCode = verficationID;
              linearStatusBar = false;
            });
            print("Id: " + _verificationCode);
            print("code sent");
          },
          codeAutoRetrievalTimeout: (String verificationID) {
            setState(() {
              _verificationCode = verificationID;
            });
            print("time out");
          },
          timeout: const Duration(seconds: 120));
    } on FirebaseAuthException catch (e) {
      print('exeption');
      print(e);
    }
  }

  _veryfyOtp(String pin) async {
    try {
      PhoneAuthCredential authCredential = PhoneAuthProvider.credential(
          verificationId: _verificationCode, smsCode: pin);
      final authCre =
          await FirebaseAuth.instance.signInWithCredential(authCredential);
      if (authCre.user != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Profile('+94' + widget.phone),
            ));
      } else {}
    } on FirebaseAuthException catch (e) {
      print(e);

      if (e.toString() ==
          '[firebase_auth/invalid-verification-code] The sms verification code used to create the phone auth credential is invalid. Please resend the verification code sms and be sure use the verification code provided by the user.') {
        error_showAlertDialog(context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _genareteOtp();
  }
}

error_showAlertDialog(BuildContext context) {
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
      child: const Text('OK'),
      onPressed: () {
        Navigator.pop(context, 'OK');
      },
    ),
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    content: const Text("Invalid code,please try again."),
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
