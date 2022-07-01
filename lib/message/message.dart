import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:otp_auth/Provider/StateManagement.dart';
import 'package:otp_auth/alert.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:otp_auth/uplodePhoto.dart';
import 'package:provider/provider.dart';

class message extends StatefulWidget {
  const message(this.id, this.logId, this.name, this.logName);
  final String name;
  final String logName;
  final String id;
  final String logId;
  @override
  _messageState createState() => _messageState(id, logId, name, logName);
}

class _messageState extends State<message> with WidgetsBindingObserver {
  AppLifecycleState? _lastLifecycleState;
  alert alrtObj = alert();
  final TextEditingController _message = TextEditingController();
  bool typing = false;
  final String id;
  final String logId;
  late String name;
  final String logName;

  _messageState(this.id, this.logId, this.name, this.logName);

  String time = DateFormat('hh:mm a').format(DateTime.now());
  bool isConnected = false;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool conResult = false;
  bool onlineState = false;
  bool onlineOroffline = false;

  getLastMessage() {
    try {
      int x = 0;
      FirebaseFirestore.instance
          .collection("message")
          .doc("messages$logId")
          .collection(id)
          .orderBy("createdOn", descending: true)
          .limit(1)
          .snapshots()
          .listen((event) async {
        while (x < 1) {
          print(event.docs.first.data()["message"]);

          var data = {
            // 'name': name,
            'lastMessage': event.docs.first.data()["message"],
            'time': time,
            'unreadMessages': true
          };

          DocumentReference documentReference = FirebaseFirestore.instance
              .collection("message")
              .doc("messages$logId")
              .collection("names")
              .doc(id);
          DocumentReference documentReference1 = FirebaseFirestore.instance
              .collection("message")
              .doc("messages$id")
              .collection("names")
              .doc(logId);
          await documentReference1.update(data);
          await documentReference.update(data);
          x++;
        }
      });
    } catch (e) {
      print(e);
    }
  }

  sendMessage(String message) async {
    try {
      String msg = "message";
      var data = {
        msg: message,
        'createdOn': FieldValue.serverTimestamp(),
        'id': id,
        'time': time
      };
      CollectionReference collectionReference = FirebaseFirestore.instance
          .collection("message")
          .doc("messages$id")
          .collection(logId);
      CollectionReference collectionReferenceLog = FirebaseFirestore.instance
          .collection("message")
          .doc("messages$logId")
          .collection(id);
      await collectionReference
          .add(data)
          .then((value) => print("Send Sucsess"));
      await collectionReferenceLog.add(data);

      //send names to sender db
      FirebaseFirestore.instance
          .collection("message")
          .doc("messages$logId")
          .collection("names")
          .where("id", isEqualTo: id)
          .snapshots()
          .listen((event) async {
        var names = {
          "id": id,
          "name": name,
          'createdOn': FieldValue.serverTimestamp(),
          'lastMessage': "Hey im used we Chat",
          'time': time,
          'unreadMessages': false
        };

        if (event.docs.isEmpty) {
          int x = 0;
          while (x < 1) {
            DocumentReference collectionReferenceName = FirebaseFirestore
                .instance
                .collection("message")
                .doc("messages$logId")
                .collection("names")
                .doc(id);
            await collectionReferenceName.set(names);
            x++;
          }
        }
      });
//send names to receiver db
      FirebaseFirestore.instance
          .collection("message")
          .doc("messages$id")
          .collection("names")
          .where("id", isEqualTo: logId)
          .snapshots()
          .listen((event) async {
        String time = DateFormat('hh:mm a').format(DateTime.now());

        var names = {
          "id": logId,
          "name": logName,
          'createdOn': FieldValue.serverTimestamp(),
          'lastMessage': "Hey im used we Chat",
          'time': time,
          'unreadMessages': true
        };

        if (event.docs.isEmpty) {
          int x = 0;
          while (x < 1) {
            DocumentReference collectionReferenceName = FirebaseFirestore
                .instance
                .collection("message")
                .doc("messages$id")
                .collection("names")
                .doc(logId);
            await collectionReferenceName.set(names);
            x++;
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }

  // Future<void> initConnectivity() async {
  //   late ConnectivityResult result;

  //   try {
  //     result = await _connectivity.checkConnectivity();
  //   } on PlatformException catch (e) {
  //     developer.log('Couldn\'t check connectivity status', error: e);
  //     return;
  //   }

  //   if (!mounted) {
  //     return Future.value(null);
  //   }

  //   return _updateConnectionStatus(result);
  // }

  // Future<void> _updateConnectionStatus(ConnectivityResult result) async {
  //   if (result == ConnectivityResult.wifi ||
  //       result == ConnectivityResult.mobile) {
  //     setState(() {
  //       conResult = true;
  //     });
  //   } else if (result == ConnectivityResult.none) {
  //     setState(() {
  //       conResult = false;
  //     });
  //   }
  //   print(conResult);
  // }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getOnlineStatus();
    // initConnectivity();
    // _connectivitySubscription =
    //     _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    alrtObj.requestPermission();
    alrtObj.loadFCM();
    alrtObj.listenFCM();
    alrtObj.getToken(id);
  }

  @override
  void dispose() {
    _message.dispose();
    WidgetsBinding.instance.removeObserver(this);
    // _connectivitySubscription.cancel();
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
      FirebaseFirestore.instance.collection('users').doc(logId).update(data);
    } else if (_lastLifecycleState == AppLifecycleState.inactive ||
        _lastLifecycleState == AppLifecycleState.resumed) {
      var data = {'OnlineStatus': true};
      FirebaseFirestore.instance.collection('users').doc(logId).update(data);
    }
  }

  getOnlineStatus() async {
    DocumentSnapshot res =
        await FirebaseFirestore.instance.collection('users').doc(id).get();
    setState(() {
      onlineState = res['OnlineStatus'];
    });
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black12,
          shadowColor: Colors.grey,
          title: context.watch<StateManagement>().conResultMain
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FutureBuilder(
                        future: upload.downlordUrl(id),
                        builder: ((context, snapshot) {
                          if (snapshot.hasData) {
                            return CircleAvatar(
                              backgroundImage:
                                  NetworkImage(snapshot.data!.toString()),
                              radius: 25,
                            );
                          }
                          return CircularProgressIndicator(
                            strokeWidth: 1,
                          );
                        })),
                    SizedBox(width: 15),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          name,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              ?.apply(color: Colors.white),
                          overflow: TextOverflow.clip,
                        ),
                        StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(id)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.hasData) {
                                return snapshot.data!['OnlineStatus']
                                    ? Text(
                                        "Online",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            ?.apply(
                                              color: Colors.green,
                                            ),
                                      )
                                    : Text(
                                        "Offline",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            ?.apply(
                                              color: Colors.green,
                                            ),
                                      );
                              } else {
                                return Text('');
                              }
                            })
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 20,
                    ),
                    IconButton(
                      splashRadius: 1,
                      color: Colors.white,
                      icon: Icon(Icons.call),
                      onPressed: () {},
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 70,
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(
                    height: MediaQuery.of(context).size.height / 18,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 10,
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width / 20,
                            height: MediaQuery.of(context).size.height / 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            )),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 30,
                        ),
                        const Text(
                          "Waiting For Network...",
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 1.22,
                      child: Scrollbar(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('message')
                              .doc("messages$logId")
                              .collection(id)
                              .orderBy("createdOn", descending: true)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: Text("No Messages"),
                              );
                            }
                            return ListView(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              reverse: true,
                              children: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: document['id'] == id
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          document['id'] == id
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    BubbleSpecialOne(
                                                        color:
                                                            Color(0xff04658b),
                                                        delivered: conResult,
                                                        sent: false,
                                                        seen: context
                                                            .watch<
                                                                StateManagement>()
                                                            .conResultMain,
                                                        text: document[
                                                            "message"]),
                                                    Text(
                                                      document["time"],
                                                      style: const TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              181,
                                                              178,
                                                              178),
                                                          fontSize: 11),
                                                    ),
                                                    const SizedBox(
                                                      height: 3,
                                                    ),
                                                  ],
                                                )
                                              : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    BubbleSpecialOne(
                                                        color:
                                                            Color(0xff04658b),
                                                        delivered: false,
                                                        sent: false,
                                                        seen: false,
                                                        isSender: false,
                                                        text: document[
                                                            "message"]),
                                                    Container(
                                                      height: 10,
                                                      child: Align(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child: Text(
                                                          document["time"],
                                                          style:
                                                              const TextStyle(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          181,
                                                                          178,
                                                                          178),
                                                                  fontSize: 11),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 3,
                                                    ),
                                                  ],
                                                )
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ),
                    NotificationListener<OverscrollIndicatorNotification>(
                        onNotification:
                            (OverscrollIndicatorNotification overScroll) {
                          overScroll.disallowIndicator();
                          return false;
                        },
                        child: ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          children: [
                            Container(
                              padding: EdgeInsets.zero,
                              color: Color.fromARGB(255, 47, 46, 46),
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Row(
                                  children: <Widget>[
                                    IconButton(
                                      splashRadius: 1,
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.blue,
                                        size: 35,
                                      ),
                                      onPressed: () {},
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              Color.fromRGBO(122, 123, 123, 1),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  35,
                                            ),
                                            Expanded(
                                              child: TextField(
                                                style: TextStyle(
                                                    color: Colors.white),
                                                textAlign: TextAlign.start,
                                                maxLines: null,
                                                decoration:
                                                    const InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets.all(5),
                                                        isDense: true,
                                                        hintText: " Message",
                                                        border:
                                                            InputBorder.none),
                                                controller: _message,
                                                onChanged: (s) {
                                                  setState(() {
                                                    if (_message
                                                        .text.isNotEmpty) {
                                                      typing = true;
                                                    } else {
                                                      typing = false;
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                20),
                                    typing
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(right: 1),
                                            child: Container(
                                                height: 35,
                                                width: 35,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.blue),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: IconButton(
                                                    splashRadius: 1,
                                                    icon: Icon(Icons.send,
                                                        size: 18),
                                                    color: Colors.white,
                                                    onPressed: () async {
                                                      if (_message
                                                          .text.isNotEmpty) {
                                                        await sendMessage(
                                                            _message.text);
                                                        setState(() {
                                                          typing = false;
                                                        });
                                                        await getLastMessage();

                                                        DocumentSnapshot snap =
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'UserTokens')
                                                                .doc(logId)
                                                                .get();

                                                        String token =
                                                            snap['token'];

                                                        alrtObj.sendPushMessage(
                                                            token,
                                                            _message.text,
                                                            logName);
                                                        _message.text = "";
                                                      }
                                                    },
                                                  ),
                                                )),
                                          )
                                        : Center(
                                            child: IconButton(
                                              splashRadius: 1,
                                              color: Colors.blue,
                                              icon: const Icon(
                                                  Icons.photo_camera_outlined),
                                              onPressed: () {},
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
