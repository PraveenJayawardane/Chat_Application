import 'package:flutter/material.dart';
import 'package:otp_auth/otp.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[400],
      body: SingleChildScrollView(
        reverse: true,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 7),
              Column(children: [
                Center(
                  child: Column(
                    children: const [
                      Text("Your Phone \n\n",
                          style: TextStyle(fontSize: 20, fontFamily: 'Roboto')),
                      Text("Please confirm your county code",
                          style: TextStyle(fontFamily: 'Roboto')),
                      Text("and enter your phone number.")
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 50, 40),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        autofocus: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '                                               Plese fill field';
                          } else if (value.length == 9) {
                            return null;
                          }
                          return '                                                 Invalid number';
                        },
                        decoration: InputDecoration(
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(20)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(20)),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                                borderRadius: BorderRadius.circular(20)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                                borderRadius: BorderRadius.circular(20)),
                            hintText: '   Phone number',
                            prefix: const Text('+94'),
                            //prefixText: '+94',
                            prefixIcon: Icon(
                              Icons.phone_iphone,
                              color: Colors.black,
                            )),
                        maxLength: 9,
                        keyboardType: TextInputType.number,
                        controller: _controller,
                      ),
                    ),
                  ),
                )
              ]),
              ElevatedButton(
                style: ButtonStyle(
                  fixedSize:
                      MaterialStateProperty.all<Size>(Size.fromWidth(150)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
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
                child: Text('Next'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => OTPScreen(_controller.text)));
                    print("done");
                  } else {
                    print("Wrong");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
