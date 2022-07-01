import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otp_auth/message/message.dart';
import 'package:otp_auth/message/message_screen.dart';
import 'package:otp_auth/message/serchBarForContacts.dart';
import 'package:otp_auth/message/userProfile.dart';

class contacts extends StatefulWidget {
  String id;
  String name;
  contacts(this.id, this.name, {Key? key}) : super(key: key);

  @override
  State<contacts> createState() => _contactsState(id, name);
}

class _contactsState extends State<contacts> with WidgetsBindingObserver {
  _contactsState(this.id, this.name);
  String id;
  String name;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Contact>? _contacts;
  List<user> appsContact = [];
  AppLifecycleState? _lastLifecycleState;
  // ignore: unused_field
  bool _permissionDenied = false;

  deleteContacts() async {
    CollectionReference _collectionReferance = firestore
        .collection('message')
        .doc('messages$id')
        .collection('contacts');

    await _collectionReferance.get().then(
      (value) async {
        for (DocumentSnapshot snap in value.docs) {
          await snap.reference.delete();
        }
      },
    );
  }

  Future<void> _fetchContacts() async {
    List<String> databaseContacts = [];
    List<user> phoneContacts = [];

    CollectionReference reference = firestore.collection('users');
    reference.snapshots().listen((event) {
      event.docs.forEach((element) {
        databaseContacts.add(element.get('number'));
      });
    });

    CollectionReference _collectionReferance = firestore
        .collection('message')
        .doc('messages$id')
        .collection('contacts');

    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
      setState(() => _contacts = contacts);

      for (int i = 0; i < _contacts!.length; i++) {
        final contacts = await FlutterContacts.getContact(_contacts![i].id);

        if (contacts!.phones.first.normalizedNumber.isNotEmpty) {
          phoneContacts.add(user(
              name: contacts.name.first,
              number: contacts.phones.first.normalizedNumber));
        } else if (contacts.phones.first.number.length == 10 &&
            contacts.phones.first.number.substring(0, 2) == '07') {
          phoneContacts.add(user(
              name: contacts.name.first,
              number: '+94${contacts.phones.first.number.substring(1, 10)}'));
        } else if (contacts.phones.first.number.length == 9 &&
            contacts.phones.first.number.substring(0, 1) == '7') {
          phoneContacts.add(user(
              name: contacts.name.first,
              number: '+94${contacts.phones.first.number}'));
        } else if (contacts.phones.first.number.substring(0, 3) == '+94' &&
            contacts.phones.first.number.length == 12) {
          phoneContacts.add(user(
              name: contacts.name.first, number: contacts.phones.first.number));
        }
      }

      for (int x = 0; x < databaseContacts.length; x++) {
        for (int y = 0; y < phoneContacts.length; y++) {
          if (databaseContacts[x] == phoneContacts[y].number) {
            appsContact.add(user(
                name: phoneContacts[y].name, number: phoneContacts[y].number));
          }
        }
      }
    }

    Timer(const Duration(milliseconds: 400), () {
      for (var x in appsContact) {
        var data = {'name': x.name, 'number': x.number};
        if (x.number != id) {
          _collectionReferance.add(data);
        }
      }
    });
  }

  @override
  void initState() {
    deleteContacts();
    WidgetsBinding.instance.addObserver(this);
    _fetchContacts();
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
    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
            backgroundColor: Colors.transparent,
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
                                    color: Colors.blue[700],
                                    size: 25,
                                  ),
                                  const Text(
                                    "Contacts",
                                    style: TextStyle(color: Colors.blue),
                                  )
                                ],
                              ),
                              onTap: () async {},
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
                                    transitionDuration: Duration(seconds: 0),
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Sort",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 6,
                        ),
                        const Text(
                          "Contacts",
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 6,
                        ),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.add,
                              color: Colors.blue,
                            ))
                      ],
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            Padding(
                                padding:
                                    new EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              searchBarForContacts(id))),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    height: 45,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              25,
                                        ),
                                        Icon(Icons.search_outlined),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              100,
                                        ),
                                        const Text(
                                          "Search contacts...",
                                          style: TextStyle(fontSize: 16),
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                            Container(
                              height: 900,
                              child: Scrollbar(
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('message')
                                      .doc('messages$id')
                                      .collection('contacts')
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasData) {
                                      return ListView(
                                          physics: BouncingScrollPhysics(),
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          children: snapshot.data!.docs.map(
                                              (DocumentSnapshot
                                                  documentSnapshot) {
                                            if (documentSnapshot.data() ==
                                                null) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            } else {
                                              return Column(
                                                children: [
                                                  ListTile(
                                                    visualDensity:
                                                        const VisualDensity(
                                                            horizontal: 0,
                                                            vertical: -4),
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    minVerticalPadding: 2,
                                                    horizontalTitleGap: 2,
                                                    leading: const CircleAvatar(
                                                        radius: 17,
                                                        child:
                                                            Icon(Icons.person)),
                                                    title: Text(
                                                        documentSnapshot[
                                                            'name'],
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16)),
                                                    subtitle: Text(
                                                        documentSnapshot[
                                                            'number'],
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14)),
                                                    onTap: () async {
                                                      await Navigator.of(
                                                              context)
                                                          .push(
                                                        MaterialPageRoute(
                                                            builder: (context) => message(
                                                                documentSnapshot[
                                                                    'number'],
                                                                id,
                                                                documentSnapshot[
                                                                    'name'],
                                                                name)),
                                                      );
                                                    },
                                                  ),
                                                  const Divider(
                                                    thickness: 1,
                                                    height: 0,
                                                    indent: 50,
                                                    color: Colors.white,
                                                  )
                                                ],
                                              );
                                            }
                                          }).toList());
                                    }
                                    if (!snapshot.hasData) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }
}

class user {
  late String name;
  late String number;
  user({
    required this.name,
    required this.number,
  });
}
