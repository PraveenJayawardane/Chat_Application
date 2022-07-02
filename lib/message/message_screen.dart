import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otp_auth/Provider/StateManagement.dart';
import 'package:otp_auth/contacts.dart';
import 'package:otp_auth/message/searchBarForMessages.dart';
import 'package:otp_auth/message/userProfile.dart';
import 'package:otp_auth/uplodePhoto.dart';
import 'package:provider/provider.dart';
import 'message.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ionicons/ionicons.dart';

class message_screen extends StatefulWidget {
  final String id;
  final String name;
  const message_screen(this.id, this.name);

  @override
  _message_screenState createState() => _message_screenState(id, name);
}

late String searchText;
String lastMessage = "";

int count = 0;

class _message_screenState extends State<message_screen>
    with WidgetsBindingObserver {
  final String id;
  final String name;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool conResult = false;
  _message_screenState(this.id, this.name);
  bool selectContacts = false;
  bool editButton = false;
  AppLifecycleState? _lastLifecycleState;

  @override
  void initState() {
    uploadPhoto upload = uploadPhoto();
    super.initState();
    setOnlineStatus();
    WidgetsBinding.instance.addObserver(this);
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    Future<String> url = upload.downlordUrl(id);
    url.then((value) => print(value));
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    print('dispose');
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
    } else if (_lastLifecycleState == AppLifecycleState.inactive ||
        _lastLifecycleState == AppLifecycleState.resumed) {
      var data = {'OnlineStatus': true};
      FirebaseFirestore.instance.collection('users').doc(id).update(data);
    }
  }

  Future<void> getPicUrl() async {}

  Future<void> initConnectivity() async {
    late ConnectivityResult result;

    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile) {
      // setState(() {
      //   conResult = true;
      // });
      context.read<StateManagement>().connectionResultMain(true);
    } else if (result == ConnectivityResult.none) {
      // setState(() {
      //   conResult = false;
      // });

      context.read<StateManagement>().connectionResultMain(false);
    }
  }

  setOnlineStatus() {
    try {
      var data = {'OnlineStatus': true};
      FirebaseFirestore.instance.collection('users').doc(id).update(data);
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
        return Future.value(false);
      },
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.black12,
          bottomNavigationBar: BottomAppBar(
            color: Color.fromARGB(31, 17, 12, 12),
            elevation: 15,
            shape: CircularNotchedRectangle(),
            notchMargin: 0.0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Container(
                  height: MediaQuery.of(context).size.height / 15,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      editButton
                          ? TextButton(
                              onPressed: () {}, child: const Text('Read All'))
                          : Column(
                              children: [
                                InkWell(
                                    child: Icon(
                                  Ionicons.chatbubbles,
                                  color: Colors.blue[700],
                                  size: 25,
                                )),
                                const Text(
                                  "Chats",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                      editButton
                          ? TextButton(
                              onPressed: () {}, child: const Text('Archive'))
                          : Column(
                              children: [
                                InkWell(
                                  splashFactory: NoSplash.splashFactory,
                                  splashColor: Colors.blue,
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
                                        pageBuilder: (_, __, ___) =>
                                            contacts(id, name),
                                        transitionDuration:
                                            Duration(seconds: 0),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                      editButton
                          ? TextButton(
                              onPressed: () {}, child: const Text('Delete'))
                          : Column(
                              children: [
                                InkWell(
                                  splashColor: Colors.transparent,
                                  child: Column(
                                    children: [
                                      Icon(
                                        Ionicons.cog,
                                        color: Colors.grey[700],
                                        size: 25,
                                      ),
                                      const Text(
                                        "Settings",
                                        style: TextStyle(color: Colors.grey),
                                      )
                                    ],
                                  ),
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            userProfile(id, name),
                                        transitionDuration:
                                            Duration(seconds: 0),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                context.watch<StateManagement>().conResultMain
                    ? const Text('')
                    : Center(
                        child: Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 3.5,
                            ),
                            const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 16,
                            ),
                            const Text(
                              "Waiting for network...",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      editButton
                          ? TextButton(
                              onPressed: () {
                                setState(() {
                                  editButton = false;
                                });
                              },
                              child: const Text(
                                "Done",
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : TextButton(
                              onPressed: () {
                                setState(() {
                                  editButton = true;
                                });
                              },
                              child: const Text(
                                "Edit",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                      ),
                      const Text(
                        "Chats",
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                      ),
                      IconButton(
                          splashRadius: 1,
                          onPressed: () {},
                          icon: const Icon(
                            Icons.launch,
                            color: Colors.blue,
                          ))
                    ],
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => searchBar(id))),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(25)),
                                  height: 45,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                25,
                                      ),
                                      Icon(Icons.search_outlined),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                100,
                                      ),
                                      const Text(
                                        "Search for messages",
                                        style: TextStyle(fontSize: 16),
                                      )
                                    ],
                                  ),
                                ),
                              )),
                          Container(
                            height: MediaQuery.of(context).size.height,
                            child: Scrollbar(
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('message')
                                      .doc("messages$id")
                                      .collection("names")
                                      .orderBy("createdOn", descending: false)
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SizedBox(
                                          height: 60,
                                          width: 50,
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()));
                                    }
                                    if (!snapshot.hasData) {
                                      return const Text("No messages");
                                    }
                                    if (snapshot.connectionState ==
                                            ConnectionState.active &&
                                        snapshot.data!.docs.isNotEmpty) {
                                      return ListView(
                                        physics: const BouncingScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        children: snapshot.data!.docs
                                            .map((DocumentSnapshot document) {
                                          return Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 0, 0, 0),
                                              child: Column(
                                                children: <Widget>[
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 15)),
                                                  Slidable(
                                                    endActionPane: ActionPane(
                                                        motion:
                                                            const ScrollMotion(),
                                                        children: [
                                                          SlidableAction(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    0),
                                                            autoClose: true,
                                                            flex: 1,
                                                            spacing: 10,
                                                            onPressed:
                                                                doNothing,
                                                            backgroundColor:
                                                                Color(
                                                                    0xFFFE4A49),
                                                            foregroundColor:
                                                                Colors.white,
                                                            icon: Icons.delete,
                                                            label: 'Delete',
                                                          ),
                                                          SlidableAction(
                                                            spacing: 10,
                                                            onPressed:
                                                                doNothing,
                                                            backgroundColor:
                                                                Color(
                                                                    0xFF21B7CA),
                                                            foregroundColor:
                                                                Colors.white,
                                                            icon: Icons
                                                                .do_not_disturb_on_total_silence_outlined,
                                                            label: 'Mute',
                                                          ),
                                                        ]),
                                                    child: ListTile(
                                                      //tileColor: Colors.amber,
                                                      visualDensity:
                                                          const VisualDensity(
                                                              horizontal: 2,
                                                              vertical: -4),
                                                      contentPadding:
                                                          const EdgeInsets.only(
                                                              left: 15),
                                                      minVerticalPadding: 2,
                                                      horizontalTitleGap: 2,
                                                      title: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              document["name"]
                                                                  .toString(),
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyText2
                                                                  ?.apply(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSizeFactor:
                                                                          1.1),
                                                            ),
                                                            Spacer(),
                                                            document[
                                                                    'unreadMessages']
                                                                ? const Icon(
                                                                    Icons
                                                                        .circle,
                                                                    size: 10,
                                                                    color: Colors
                                                                        .red,
                                                                  )
                                                                : Text(''),
                                                            const SizedBox(
                                                              width: 20,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      subtitle: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                height: 22,
                                                              ),
                                                              Expanded(
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  child: Text(
                                                                    document[
                                                                            "lastMessage"]
                                                                        .toString(),
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyText2
                                                                        ?.apply(
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: Text(
                                                                  document[
                                                                          "time"]
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 20,
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      leading: editButton
                                                          ? Transform.scale(
                                                              scale: 1.2,
                                                              child: Theme(
                                                                data: ThemeData(
                                                                    unselectedWidgetColor:
                                                                        Colors
                                                                            .white),
                                                                child: Checkbox(
                                                                  shape: const CircleBorder(
                                                                      side: BorderSide(
                                                                          color:
                                                                              Colors.white)),
                                                                  value:
                                                                      selectContacts,
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      selectContacts =
                                                                          value
                                                                              as bool;
                                                                      print(
                                                                          selectContacts);
                                                                    });
                                                                  },
                                                                  checkColor:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                              ),
                                                            )
                                                          : CircleAvatar(
                                                              radius: 20,
                                                              child: Text(
                                                                  document[
                                                                          "name"]
                                                                      .toString()
                                                                      .substring(
                                                                          0, 1),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20)),
                                                              // backgroundImage:
                                                              //     NetworkImage(
                                                              //         '${document['imgUrl']}'),
                                                            ),
                                                      onTap: () async {
                                                        await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    message(
                                                                        document[
                                                                            "id"],
                                                                        id,
                                                                        document[
                                                                            "name"],
                                                                        name)));

                                                        DocumentReference doc =
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "message")
                                                                .doc(
                                                                    "messages$id")
                                                                .collection(
                                                                    "names")
                                                                .doc(document[
                                                                    'id']);
                                                        await doc.update({
                                                          'unreadMessages':
                                                              false
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            0, 0, 0, 0),
                                                    child: Divider(
                                                      thickness: 1,
                                                      color: Colors.grey,
                                                      indent: 60,
                                                    ),
                                                  )
                                                ],
                                              ));
                                        }).toList(),
                                      );
                                    }
                                    print("last");
                                    return const Center(
                                        child: Text(
                                      "No messages",
                                      style: TextStyle(color: Colors.white),
                                    ));
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void doNothing(BuildContext context) {
    print('delete');
  }
}
