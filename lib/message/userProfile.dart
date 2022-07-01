import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otp_auth/contacts.dart';
import 'package:otp_auth/message/message_screen.dart';
import 'package:otp_auth/uplodePhoto.dart';

class userProfile extends StatefulWidget {
  userProfile(this.id, this.name, {Key? key}) : super(key: key);
  late String id;
  late String name;

  @override
  State<userProfile> createState() => _userProfileState(id, name);
}

class _userProfileState extends State<userProfile> with WidgetsBindingObserver {
  _userProfileState(this.id, this.name);
  late String id;
  late String name;
  AppLifecycleState? _lastLifecycleState;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lastLifecycleState = state;
    });
    if (_lastLifecycleState == AppLifecycleState.paused ||
        _lastLifecycleState == AppLifecycleState.detached) {
      var data = {'OnlineStatus': false};
      FirebaseFirestore.instance.collection('users').doc(id).update(data);
      print('App is now not log in');
    } else if (_lastLifecycleState == AppLifecycleState.inactive ||
        _lastLifecycleState == AppLifecycleState.resumed) {
      var data = {'OnlineStatus': true};
      FirebaseFirestore.instance.collection('users').doc(id).update(data);
      print('App is now log in');
    }
  }

  @override
  Widget build(BuildContext context) {
    uploadPhoto upload = uploadPhoto();
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        bottomNavigationBar: BottomAppBar(
          color: const Color.fromARGB(31, 17, 12, 12),
          elevation: 15,
          shape: const CircularNotchedRectangle(),
          notchMargin: 0.0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Container(
                height: MediaQuery.of(context).size.height / 15,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Column(
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          child: Column(
                            children: [
                              Icon(
                                Ionicons.chatbubbles,
                                color: Colors.grey[700],
                                size: 25,
                              ),
                              const Text(
                                "Chats",
                                style: TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    message_screen(id, name),
                                transitionDuration: Duration(seconds: 0),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          child: Column(
                            children: [
                              Icon(
                                Ionicons.person_circle,
                                color: Colors.grey[700],
                                size: 25,
                              ),
                              const Text(
                                "Contacts",
                                style: TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => contacts(id, name),
                                transitionDuration: Duration(seconds: 0),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          child: Column(
                            children: [
                              Icon(
                                Ionicons.cog,
                                color: Colors.blue[700],
                                size: 25,
                              ),
                              const Text(
                                "Settings",
                                style: TextStyle(color: Colors.blue),
                              )
                            ],
                          ),
                          onTap: () async {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
            child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.25,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Edit",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder(
                    future: upload.downlordUrl(id),
                    builder: ((context, snapshot) {
                      if (snapshot.hasData) {
                        return CircleAvatar(
                          backgroundImage:
                              NetworkImage(snapshot.data!.toString()),
                          radius: 50,
                        );
                      }
                      return CircularProgressIndicator(
                        strokeWidth: 1,
                      );
                    })),
                const SizedBox(height: 10),
                Text(name,
                    style: const TextStyle(color: Colors.white, fontSize: 20)),
                const SizedBox(height: 5),
                Text(id,
                    style: const TextStyle(color: Colors.white, fontSize: 15)),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    print('done');
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      child: Row(
                        children: const [
                          SizedBox(
                            width: 10,
                          ),
                          Icon(Icons.add_box, color: Colors.white),
                          SizedBox(
                            width: 30,
                          ),
                          Text(
                            'Set Username',
                            style: TextStyle(color: Colors.white),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          )
                        ],
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromARGB(255, 37, 36, 36),
                      ),
                      height: 50),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(20)),
                  height: 310,
                  width: MediaQuery.of(context).size.width / 1.2,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          print('done');
                        },
                        child: Container(
                            child: Row(
                              children: const [
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.notifications, color: Colors.white),
                                SizedBox(
                                  width: 30,
                                ),
                                Text('Notification and Sounds',
                                    style: TextStyle(color: Colors.white)),
                                Spacer(),
                                Icon(Icons.arrow_forward_ios,
                                    color: Colors.white)
                              ],
                            ),
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 37, 36, 36),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20))),
                            height: 50),
                      ),
                      const Divider(height: 1, color: Colors.white),
                      GestureDetector(
                        onTap: () {
                          print('done');
                        },
                        child: Container(
                            child: Row(
                              children: const [
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.privacy_tip, color: Colors.white),
                                SizedBox(
                                  width: 30,
                                ),
                                Text('Privacy and Security',
                                    style: TextStyle(color: Colors.white)),
                                Spacer(),
                                Icon(Icons.arrow_forward_ios,
                                    color: Colors.white)
                              ],
                            ),
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 37, 36, 36),
                            ),
                            height: 50),
                      ),
                      const Divider(height: 2, color: Colors.white),
                      GestureDetector(
                        onTap: () {
                          print('done');
                        },
                        child: Container(
                            child: Row(
                              children: const [
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.storage, color: Colors.white),
                                SizedBox(
                                  width: 30,
                                ),
                                Text('Data and Storage',
                                    style: TextStyle(color: Colors.white)),
                                Spacer(),
                                Icon(Icons.arrow_forward_ios,
                                    color: Colors.white)
                              ],
                            ),
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 37, 36, 36),
                            ),
                            height: 50),
                      ),
                      const Divider(height: 2, color: Colors.white),
                      GestureDetector(
                        onTap: () {
                          print('done');
                        },
                        child: Container(
                            child: Row(
                              children: const [
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.colorize_outlined,
                                    color: Colors.white),
                                SizedBox(
                                  width: 30,
                                ),
                                Text('Appearance',
                                    style: TextStyle(color: Colors.white)),
                                Spacer(),
                                Icon(Icons.arrow_forward_ios,
                                    color: Colors.white)
                              ],
                            ),
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 37, 36, 36),
                            ),
                            height: 50),
                      ),
                      const Divider(height: 1, color: Colors.white),
                      GestureDetector(
                        onTap: () {
                          print('done');
                        },
                        child: Container(
                            child: Row(
                              children: const [
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.language, color: Colors.white),
                                SizedBox(
                                  width: 30,
                                ),
                                Text('Language',
                                    style: TextStyle(color: Colors.white)),
                                Spacer(),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                )
                              ],
                            ),
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 37, 36, 36),
                            ),
                            height: 50),
                      ),
                      const Divider(height: 1, color: Colors.white),
                      GestureDetector(
                        onTap: () {
                          print('done');
                        },
                        child: Container(
                            child: Row(
                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                const Icon(Icons.emoji_emotions,
                                    color: Colors.white),
                                const SizedBox(
                                  width: 30,
                                ),
                                const Text(
                                  'Stickers and Emoji',
                                  style: TextStyle(color: Colors.white),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                )
                              ],
                            ),
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 37, 36, 36),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20))),
                            height: 50),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )),
      ),
    );
  }
}
